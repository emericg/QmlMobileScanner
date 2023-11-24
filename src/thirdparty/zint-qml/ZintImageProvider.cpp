/*
 * Copyright 2023 Emeric Grange
 */

#include "ZintImageProvider.h"

#include "backend/zint.h"   // Use the embedded copy
//#include <zint.h>         // Use the system copy

#include <QDebug>
#include <QUrlQuery>
#include <QRegularExpression>

ZintImageProvider::ZintImageProvider() : QQuickImageProvider(QQuickImageProvider::Image)
{
    //
}

QImage ZintImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    if (id.isEmpty() || requestedSize.width() <= 0 || requestedSize.height() <= 0) return QImage();
    //qDebug() << "ZintImageProvider::requestImage(" << id << ") size " << *size << " /  requestedSize" << requestedSize;

    int slashIndex = id.indexOf('/');
    if (slashIndex == -1)
    {
        qWarning() << "Can't parse url" << id << ". Usage is encode/<data>?params";
        return QImage();
    }
    int exmarkIndex = id.lastIndexOf('?');
    if (exmarkIndex == -1)
    {
        exmarkIndex = id.size();
    }

    // Detect operation (ex. encode)
    QString operationName = id.left(slashIndex);
    if (operationName != "encode")
    {
        qWarning() << "Operation not supported: " << operationName;
        return QImage();
    }

    // Data
    int data_sz = id.size() - slashIndex - 1 - (id.size() - exmarkIndex);
    QString data = id.mid(slashIndex + 1, data_sz);

    // Settings
    int format = BARCODE_QRCODE;
    bool format_rgb = false;
    bool format_rotated = false;
    int encoding = UNICODE_MODE;
    int eccLevel = 0;
    int margins = 0;
    QColor bgc(0, 0, 0, 0);
    QColor fgc(0, 0, 0, 255);

    int customSettingsIndex = id.lastIndexOf(QRegularExpression("\\?(format|encoding|eccLevel|margin)="));
    if (customSettingsIndex >= 0)
    {
        QUrlQuery optionQuery(id.mid(customSettingsIndex + 1));

        if (optionQuery.hasQueryItem("format"))
        {
            QString formatString = optionQuery.queryItemValue("format").toLower().remove('-');

            if (formatString == "aztec") format = BARCODE_AZTEC;
            else if (formatString == "datamatrix") format = BARCODE_DATAMATRIX;
            else if (formatString == "qrcode") format = BARCODE_QRCODE;
            else if (formatString == "microqrcode") format = BARCODE_MICROQR;
            else if (formatString == "rmqr") format = BARCODE_RMQR;
            else if (formatString == "pdf417") format = BARCODE_PDF417;
            else if (formatString == "micropdf417") format = BARCODE_MICROPDF417;
            else if (formatString == "gridmatrix") format = BARCODE_GRIDMATRIX;
            else if (formatString == "dotcode") format = BARCODE_DOTCODE;
            else if (formatString == "maxicode") format = BARCODE_MAXICODE;
            else if (formatString == "ultracode") format = BARCODE_ULTRA;
            else if (formatString == "codeone") format = BARCODE_CODEONE;
            else if (formatString == "hanxin") format = BARCODE_HANXIN;
            else if (formatString == "code49") format = BARCODE_CODE49;
            else if (formatString == "code16k") format = BARCODE_CODE16K;
            else if (formatString == "codablockf") format = BARCODE_CODABLOCKF;

            else if (formatString == "codabar") format = BARCODE_CODABAR;
            else if (formatString == "code39") format = BARCODE_CODE39;
            else if (formatString == "code93") format = BARCODE_CODE93;
            else if (formatString == "code128") format = BARCODE_CODE128;
            //else if (formatString == "ean8") format = BARCODE_EAN8;
            //else if (formatString == "ean13") format = BARCODE_EAN13;
            else if (formatString == "itf") format = BARCODE_ITF14;
            else if (formatString == "upca") format = BARCODE_UPCA;
            else if (formatString == "upce") format = BARCODE_UPCE;

            else
            {
                qWarning() << "Format not supported: " << formatString;
                format = BARCODE_QRCODE;
            }
        }

        if (optionQuery.hasQueryItem("eccLevel"))
        {
            bool ok = false;
            int e = optionQuery.queryItemValue("eccLevel").toInt(&ok);
            if (ok && e >= 0 && e <= 8) eccLevel = e;
        }

        if (optionQuery.hasQueryItem("margins"))
        {
            bool ok = false;
            int m = optionQuery.queryItemValue("margins").toInt(&ok);
            if (ok && m > 0 && m < 128) margins = std::ceil(m / 12.0);
        }

        if (optionQuery.hasQueryItem("backgroundColor"))
        {
            bgc = QColor(optionQuery.queryItemValue("backgroundColor"));
        }
        if (optionQuery.hasQueryItem("foregroundColor"))
        {
            fgc = QColor(optionQuery.queryItemValue("foregroundColor"));
        }

    // rgb
    if (format == BARCODE_ULTRA)
    {
        format_rgb = true;
    }

    // rotated
    if (format == BARCODE_PDF417 || format == BARCODE_MICROPDF417 ||
        format == BARCODE_CODE49 || format == BARCODE_CODE16K || format == BARCODE_CODABLOCKF)
    {
        format_rotated = true;
    }

    // Generate barcode

    struct zint_symbol *zint_symbol = ZBarcode_Create();
    zint_symbol->height = requestedSize.height();
    zint_symbol->scale = 1.0;
    zint_symbol->symbology = format;
    zint_symbol->input_mode = encoding;
    //zint_symbol->border_width = margins;
    zint_symbol->whitespace_width = margins;
    zint_symbol->whitespace_height = margins;
    zint_symbol->output_options |= format_rgb ? 0 : OUT_BUFFER_INTERMEDIATE;
/*
    QByteArray bstr = data.toUtf8();
    int error = ZBarcode_Encode_and_Buffer(zint_symbol, (unsigned char *)bstr.data(), bstr.size(), format_rotated ? 0 : 0);

    int width = zint_symbol->bitmap_width, height = zint_symbol->bitmap_height;

    QImage img(width, height, QImage::Format_ARGB32);

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
                    img.setPixel(col, row, zint_symbol->bitmap[i] == '1' ? fgc.rgba() : bgc.rgba());
                    i++;
                }
            }
        }
    }

    ZBarcode_Delete(zint_symbol);

    *size = img.size();
    return img;
}
