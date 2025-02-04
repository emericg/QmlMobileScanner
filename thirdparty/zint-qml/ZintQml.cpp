/*
 * Copyright 2023 Emeric Grange
 */

#include "ZintQml.h"
#include "ZintImageProvider.h"

#include "backend/zint.h"   // Use the embedded zint copy
//#include <zint.h>         // Use the system zint copy

#include <QUrl>
#include <QColor>
#include <QImage>
#include <QFile>
#include <QFileInfo>

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

QImage ZintQml::generateImage(const QString &data, const int width, const int height, const int margins,
                              const int format, const int encoding, const int eccLevel,
                              const QColor backgroundColor, const QColor foregroundColor)
{
    Q_UNUSED(width)
    Q_UNUSED(height)
    Q_UNUSED(eccLevel)

    bool format_rgb = (format == BARCODE_ULTRA);
    bool format_rotated = false;

    // rotated codes?
    if (format == BARCODE_PDF417 || format == BARCODE_MICROPDF417 ||
        format == BARCODE_CODE49 || format == BARCODE_CODE16K || format == BARCODE_CODABLOCKF)
    {
        format_rotated = true;
    }

    // Generate barcode
    struct zint_symbol *zint_symbol = ZBarcode_Create();
    //zint_symbol->height = requestedSize.height();
    //zint_symbol->scale = 1.0;
    zint_symbol->symbology = format;
    zint_symbol->input_mode = encoding;
    //zint_symbol->border_width = margins;
    zint_symbol->whitespace_width = margins;
    zint_symbol->whitespace_height = margins;
    zint_symbol->output_options |= format_rgb ? 0 : OUT_BUFFER_INTERMEDIATE;

    QByteArray bstr = data.toUtf8();
    int error = ZBarcode_Encode_and_Buffer(zint_symbol, (unsigned char *)bstr.data(), bstr.size(), 0);



/*
    Aztec Code  1 to 4 (10%, 23%, 36%, 50%)
    Grid Matrix 1 to 5 (10% to 50%)
    Han Xin     1 to 4 (8%, 15%, 23%, 30%)
    Micro QR    1 to 3 (7%, 15%, 25%) (L, M, Q)
    PDF417      0 to 8 (2^(INTEGER + 1) codewords)
    QR Code     1 to 4 (7%, 15%, 25%, 30%) (L, M, Q, H)
    rMQR        2 or 4 (15% or 30%) (M or H)
    Ultracode   1 to 6 (0%, 5%, 9%, 17%, 25%, 33%)
*/
/*
    qDebug() << ">> recap >>";
    qDebug() << "- DATA  : " << data;
    qDebug() << "- data_sz  : " << data_sz;
    qDebug() << "- exmarkIndex  : " << exmarkIndex;
    qDebug() << "- slashIndex  : " << slashIndex;
    qDebug() << "- format: " << (int)format;
    qDebug() << "- ecc   : " << eccLevel;
    qDebug() << "- margin: " << margins;
*/
/*
    qDebug() << "data:" << data;
    qDebug() << "encoded width:" << zint_symbol->width << " height:" << zint_symbol->height;
    qDebug() << "encoded width:" << zint_symbol->bitmap_width << " height:" << zint_symbol->bitmap_height;
    qDebug() << "encoded error:" << error << zint_symbol->errtxt;
*/



    QImage img(zint_symbol->bitmap_width, zint_symbol->bitmap_height, QImage::Format_ARGB32);

    if (error < ZINT_ERROR)
    {
        int i = 0;
        for (int row = 0; row < zint_symbol->bitmap_height; row++)
        {
            for (int col = 0; col < zint_symbol->bitmap_width; col++)
            {
                if (format_rgb)
                {
                    img.setPixel(col, row, QColor(zint_symbol->bitmap[i], zint_symbol->bitmap[i + 1], zint_symbol->bitmap[i + 2]).rgba());
                    i += 3;
                }
                else
                {
                    img.setPixel(col, row, zint_symbol->bitmap[i] == '1' ? foregroundColor.rgba() : backgroundColor.rgba());
                    i++;
                }
            }
        }
    }

    ZBarcode_Delete(zint_symbol);

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

    if (saveFileInfo.suffix() == "svg")
    {
        // to vector
        struct zint_symbol *zint_symbol = ZBarcode_Create();
        zint_symbol->height = height;
        zint_symbol->scale = 1.0;
        zint_symbol->symbology = format;
        zint_symbol->input_mode = encoding;
        zint_symbol->whitespace_width = 4;
        zint_symbol->whitespace_height = 4;

        strncpy(zint_symbol->outfile, filepath.toStdString().c_str(), 256);

        QByteArray bstr = data.toUtf8();
        int error = ZBarcode_Encode_and_Print(zint_symbol, (unsigned char *)bstr.data(), bstr.size(), 0);

        if (error >= ZINT_ERROR)
        {
            qWarning() << "ZintQml::saveImage() error" << error << zint_symbol->errtxt;
        }

        ZBarcode_Delete(zint_symbol);
    }
    else if (saveFileInfo.suffix() == "bmp" ||
             saveFileInfo.suffix() == "png" ||
             saveFileInfo.suffix() == "jpg" ||
             saveFileInfo.suffix() == "jpeg" ||
             saveFileInfo.suffix() == "webp")
    {
        QImage img = generateImage(data, width, height, margins,
                                   format, encoding, eccLevel,
                                   backgroundColor, foregroundColor);

        status = img.save(filepath, saveFileInfo.suffix().toStdString().c_str(), -1);
    }
    else
    {
        qWarning() << "ZintQml::saveImage() unknown format error:" << saveFileInfo.suffix();
    }

    return status;
}
