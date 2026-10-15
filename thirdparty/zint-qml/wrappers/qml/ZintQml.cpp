/*
 * Copyright 2023 Emeric Grange
 */

#include "ZintQml.h"
#include "ZintImageProvider.h"

#include "../../backend/zint.h"   // Use the embedded zint copy
//#include <zint.h>         // Use the system zint copy

#include <QUrl>
#include <QColor>
#include <QImage>
#include <QFile>
#include <QFileInfo>

#include <algorithm>
#include <cmath>
#include <cstdio>

void ZintQml::registerQMLTypes()
{
    qmlRegisterType<ZintQml>("ZintQml", 1, 0, "ZintQml");
}

void ZintQml::registerQMLImageProvider(QQmlEngine &engine)
{
    engine.addImageProvider("ZintQml", new ZintImageProvider());
}

int ZintQml::stringToFormat(const QString &str)
{
    if (str == "aztec") return BARCODE_AZTEC;
    if (str == "datamatrix") return BARCODE_DATAMATRIX;
    if (str == "maxicode") return BARCODE_MAXICODE;
    if (str == "pdf417") return BARCODE_PDF417;
    if (str == "micropdf417") return BARCODE_MICROPDF417;
    if (str == "qrcode") return BARCODE_QRCODE;
    if (str == "microqrcode") return BARCODE_MICROQR;
    if (str == "rmqr") return BARCODE_RMQR;
    if (str == "gridmatrix") return BARCODE_GRIDMATRIX;
    if (str == "dotcode") return BARCODE_DOTCODE;
    if (str == "ultracode") return BARCODE_ULTRA;
    if (str == "codeone") return BARCODE_CODEONE;
    if (str == "hanxin") return BARCODE_HANXIN;
    if (str == "code49") return BARCODE_CODE49;
    if (str == "code16k") return BARCODE_CODE16K;
    if (str == "codablockf") return BARCODE_CODABLOCKF;

    if (str == "ean8") return BARCODE_EANX;
    if (str == "ean13") return BARCODE_EANX;
    if (str == "databar") return BARCODE_DBAR_OMNSTK;
    if (str == "databarexpanded") return BARCODE_DBAR_EXPSTK;
    if (str == "itf") return BARCODE_ITF14;

    if (str == "upca") return BARCODE_UPCA;
    if (str == "upce") return BARCODE_UPCE;
    if (str == "codabar") return BARCODE_CODABAR;
    if (str == "code39") return BARCODE_CODE39;
    if (str == "code93") return BARCODE_CODE93;
    if (str == "code128") return BARCODE_CODE128;

    return 0;
}

QString ZintQml::formatToString(const int fmt)
{
    if (fmt == BARCODE_AZTEC) return "aztec";
    if (fmt == BARCODE_DATAMATRIX) return "datamatrix";
    if (fmt == BARCODE_MAXICODE) return "maxicode";
    if (fmt == BARCODE_PDF417) return "pdf417";
    if (fmt == BARCODE_MICROPDF417) return "micropdf417";
    if (fmt == BARCODE_QRCODE) return "qrcode";
    if (fmt == BARCODE_MICROQR) return "microqrcode";
    if (fmt == BARCODE_RMQR) return "rmqr";
    if (fmt == BARCODE_GRIDMATRIX) return "gridmatrix";
    if (fmt == BARCODE_DOTCODE) return "dotcode";
    if (fmt == BARCODE_ULTRA) return "ultracode";
    if (fmt == BARCODE_CODEONE) return "codeone";
    if (fmt == BARCODE_HANXIN) return "hanxin";
    if (fmt == BARCODE_CODE49) return "code49";
    if (fmt == BARCODE_CODE16K) return "code16k";
    if (fmt == BARCODE_CODABLOCKF) return "codablockf";

    if (fmt == BARCODE_EANX) return "ean13";
    if (fmt == BARCODE_DBAR_OMNSTK) return "databar";
    if (fmt == BARCODE_DBAR_EXPSTK) return "databarexpanded";
    if (fmt == BARCODE_ITF14) return "itf";

    if (fmt == BARCODE_UPCA) return "upca";
    if (fmt == BARCODE_UPCE) return "upce";
    if (fmt == BARCODE_CODABAR) return "codabar";
    if (fmt == BARCODE_CODE39) return "code39";
    if (fmt == BARCODE_CODE93) return "code93";
    if (fmt == BARCODE_CODE128) return "code128";

    return QString();
}

/*!
 * \brief Convert the application error correction level into the zint 'option_1' value.
 * \param format: zint symbology.
 * \param eccLevel: application level (QR: 2/4/6/8 = L/M/Q/H, Aztec: 1..4, PDF417: 0..8, 0: default).
 * \return The zint 'option_1' value, or -1 to use the symbology default.
 *
 * zint ranges are:
 * - QR Code 1 to 4 (7%, 15%, 25%, 30%), Micro QR 1 to 3 (7%, 15%, 25%), rMQR 2 or 4 (15% or 30%).
 * - Aztec Code 1 to 4 (10%, 23%, 36%, 50%).
 * - PDF417 0 to 8 (2^(level + 1) codewords).
 */
static int eccToZintOption1(const int format, const int eccLevel)
{
    if (format == BARCODE_PDF417) return qBound(0, eccLevel, 8);
    if (eccLevel <= 0) return -1;

    if (format == BARCODE_QRCODE) return qBound(1, (eccLevel + 1) / 2, 4);
    if (format == BARCODE_MICROQR) return qBound(1, (eccLevel + 1) / 2, 3);
    if (format == BARCODE_RMQR) return (eccLevel <= 4) ? 2 : 4;
    if (format == BARCODE_AZTEC) return qBound(1, eccLevel, 4);

    return -1;
}

/*!
 * \brief Write a color into a zint 'fgcolour' or 'bgcolour' string, as "RRGGBBAA".
 */
static void setZintColour(char (&dst)[16], const QColor &color)
{
    std::snprintf(dst, sizeof(dst), "%02X%02X%02X%02X", color.red(), color.green(), color.blue(), color.alpha());
}

/*!
 * \brief Encode data into a new zint symbol.
 * \param height: bar height in X-dimensions, or 0 for the symbology default.
 * \return The encoded symbol, to free with ZBarcode_Delete(), or nullptr on error.
 */
static zint_symbol *encodeSymbol(const QString &data, const int format, const int encoding, const int eccLevel,
                                 const float height = 0.f)
{
    zint_symbol *symbol = ZBarcode_Create();
    if (!symbol) return nullptr;

    if (height > 0.f) symbol->height = height;
    symbol->symbology = format;
    symbol->input_mode = (encoding > 0) ? encoding : UNICODE_MODE;
    symbol->option_1 = eccToZintOption1(format, eccLevel);

    const QByteArray bstr = data.toUtf8();
    const int error = ZBarcode_Encode(symbol, reinterpret_cast<const unsigned char *>(bstr.constData()), bstr.size());
    if (error >= ZINT_ERROR)
    {
        qWarning() << "ZintQml::encodeSymbol() error" << error << symbol->errtxt;
        ZBarcode_Delete(symbol);
        return nullptr;
    }

    return symbol;
}

/*!
 * \brief Find the largest zint scale fitting an encoded symbol into a target size.
 * \param symbol: encoded symbol, with no whitespace set.
 * \param targetWidth: target width in pixels.
 * \param targetHeight: target height in pixels.
 * \return The zint scale to use, or 1 if the symbol can't be measured.
 *
 * Scales are rounded down to half-integers (whole pixels per module),
 * except for MaxiCode which is drawn with hexagons.
 */
static float fitScale(zint_symbol *symbol, const int targetWidth, const int targetHeight)
{
    symbol->scale = 1.f;
    if (targetWidth <= 0 || targetHeight <= 0) return 1.f;

    if (ZBarcode_Buffer(symbol, 0) >= ZINT_ERROR ||
        symbol->bitmap_width <= 0 || symbol->bitmap_height <= 0) return 1.f;

    const float ratio = std::min(targetWidth / float(symbol->bitmap_width),
                                 targetHeight / float(symbol->bitmap_height));

    if (symbol->symbology == BARCODE_MAXICODE) return std::max(0.2f, std::floor(ratio * 10.f) / 10.f);
    return std::max(0.5f, std::floor(ratio * 2.f) / 2.f);
}

/*!
 * \brief Encode data into a new zint symbol, scaled to fit a target size.
 * \param targetWidth: target width in pixels, or 0 to keep the default scale.
 * \param targetHeight: target height in pixels, or 0 to keep the default scale.
 * \return The encoded symbol, to free with ZBarcode_Delete(), or nullptr on error.
 *
 * Linear barcodes limited by the target height are encoded again with shorter bars,
 * so they can use the whole target width.
 */
static zint_symbol *createSymbol(const QString &data, const int format, const int encoding, const int eccLevel,
                                 const int targetWidth, const int targetHeight)
{
    zint_symbol *symbol = encodeSymbol(data, format, encoding, eccLevel);
    if (!symbol) return nullptr;

    symbol->scale = fitScale(symbol, targetWidth, targetHeight);

    if (symbol->rows == 1 && ZBarcode_Cap(format, ZINT_CAP_STACKABLE) && symbol->bitmap_width > 0)
    {
        // fitScale() measured the bitmap at scale 1, which is 2 pixels per X-dimension
        const float widthScale = std::max(0.5f, std::floor(2.f * targetWidth / symbol->bitmap_width) / 2.f);
        const float textHeight = symbol->bitmap_height / 2.f - symbol->height;
        const float barHeight = std::floor(targetHeight / (2.f * widthScale) - textHeight);

        if (widthScale > symbol->scale && barHeight >= 10.f)
        {
            ZBarcode_Delete(symbol);
            symbol = encodeSymbol(data, format, encoding, eccLevel, barHeight);
            if (symbol) symbol->scale = widthScale;
        }
    }

    return symbol;
}

/*!
 * \brief Compute the barcode area, inside the requested size minus the margins.
 * \note Margins are ignored if they leave less than 16 pixels for the barcode.
 */
static QSize targetSize(const int width, const int height, const int margins)
{
    const int border = std::max(0, margins);
    if (width - 2 * border < 16 || height - 2 * border < 16) return QSize(width, height);
    return QSize(width - 2 * border, height - 2 * border);
}

QImage ZintQml::generateImage(const QString &data, const int width, const int height, const int margins,
                              const int format, const int encoding, const int eccLevel,
                              const QColor backgroundColor, const QColor foregroundColor)
{
    const QSize target = targetSize(width, height, margins);
    const int border = (target.width() < width) ? std::max(0, margins) : 0;

    zint_symbol *symbol = createSymbol(data, format, encoding, eccLevel, target.width(), target.height());
    if (!symbol) return QImage();

    const bool format_rgb = (format == BARCODE_ULTRA);
    symbol->output_options |= format_rgb ? 0 : OUT_BUFFER_INTERMEDIATE;

    QImage img;
    const int error = ZBarcode_Buffer(symbol, 0);

    if (error < ZINT_ERROR)
    {
        const QRgb fg = foregroundColor.isValid() ? foregroundColor.rgba() : qRgba(0, 0, 0, 255);
        const QRgb bg = backgroundColor.isValid() ? backgroundColor.rgba() : qRgba(0, 0, 0, 0);
        const int w = symbol->bitmap_width;
        const int h = symbol->bitmap_height;

        img = QImage(w + 2 * border, h + 2 * border, QImage::Format_ARGB32);
        img.fill(bg);

        const unsigned char *s = symbol->bitmap;
        for (int y = 0; y < h; y++)
        {
            QRgb *d = reinterpret_cast<QRgb *>(img.scanLine(y + border)) + border;
            for (int x = 0; x < w; x++)
            {
                if (format_rgb)
                {
                    d[x] = qRgb(s[0], s[1], s[2]);
                    s += 3;
                }
                else
                {
                    d[x] = (*s == '1') ? fg : bg;
                    s++;
                }
            }
        }
    }
    else
    {
        qWarning() << "ZintQml::generateImage() error" << error << symbol->errtxt;
    }

    ZBarcode_Delete(symbol);

    return img;
}

bool ZintQml::saveImage(const QString &data, const int width, const int height, const int margins,
                        const int format, const int encoding, const int eccLevel,
                        const QColor backgroundColor, const QColor foregroundColor,
                        const QUrl &fileurl)
{
    //qDebug() << "ZintQml::saveImage(" << data << fileurl;
    if (data.isEmpty() || fileurl.isEmpty()) return false;
    bool status = false;

    QString filepath = fileurl.toLocalFile();
    QFileInfo saveFileInfo(filepath);
    const QString suffix = saveFileInfo.suffix().toLower();

    if (suffix == "svg")
    {
        // to vector, sized like the raster export
        const QSize target = targetSize(width, height, margins);
        const int border = (target.width() < width) ? std::max(0, margins) : 0;

        zint_symbol *symbol = createSymbol(data, format, encoding, eccLevel, target.width(), target.height());
        if (!symbol) return false;

        // whitespace is in X-dimensions, rounded down to stay within the requested size
        const float pxPerModule = symbol->scale * 2.f;
        symbol->whitespace_width = (border > 0) ? std::max(1, int(border / pxPerModule)) : 0;
        symbol->whitespace_height = symbol->whitespace_width;

        setZintColour(symbol->fgcolour, foregroundColor.isValid() ? foregroundColor : QColor(Qt::black));
        setZintColour(symbol->bgcolour, backgroundColor.isValid() ? backgroundColor : QColor(Qt::transparent));

        // zint expects UTF-8 file names, on every platform
        const QByteArray path = filepath.toUtf8();
        if (path.size() >= int(sizeof(symbol->outfile)))
        {
            qWarning() << "ZintQml::saveImage() file path too long:" << filepath;
        }
        else
        {
            qstrncpy(symbol->outfile, path.constData(), sizeof(symbol->outfile));

            const int error = ZBarcode_Print(symbol, 0);
            status = (error < ZINT_ERROR);
            if (!status) qWarning() << "ZintQml::saveImage() error" << error << symbol->errtxt;
        }

        ZBarcode_Delete(symbol);
    }
    else if (suffix == "bmp" || suffix == "png" || suffix == "jpg" || suffix == "jpeg" || suffix == "webp")
    {
        QImage img = generateImage(data, width, height, margins,
                                   format, encoding, eccLevel,
                                   backgroundColor, foregroundColor);

        status = !img.isNull() && img.save(filepath, suffix.toLatin1().constData(), -1);
    }
    else
    {
        qWarning() << "ZintQml::saveImage() unknown format error:" << saveFileInfo.suffix();
    }

    return status;
}
