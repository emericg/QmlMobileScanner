/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingQtImageProvider.h"

#include "BarcodeFormat.h"
#include "BitMatrix.h"
#include "MultiFormatWriter.h"

#include <QDebug>
#include <QUrlQuery>
#include <QRegularExpression>

ZXingQtImageProvider::ZXingQtImageProvider() : QQuickImageProvider(QQuickImageProvider::Image)
{
    //
}

QImage ZXingQtImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    if (id.isEmpty() || requestedSize.width() <= 0 || requestedSize.height() <= 0) return QImage();
    //qDebug() << "requestImage(" << id << ") size " << *size << " /  requestedSize" << requestedSize;

    int slashIndex = id.indexOf('/');
    if (slashIndex == -1)
    {
        qWarning() << "Can't parse url" << id << ". Usage is encode/<data>?params";
        return QImage();
    }
    int exmarkIndex = id.indexOf('?');
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
    ZXing::BarcodeFormat format = ZXing::BarcodeFormat::QRCode;
    ZXing::CharacterSet encoding = ZXing::CharacterSet::UTF8;
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
            QString formatString = optionQuery.queryItemValue("format");
            if (formatString == "aztec") format = ZXing::BarcodeFormat::Aztec;
            else if (formatString == "codabar") format = ZXing::BarcodeFormat::Codabar;
            else if (formatString == "code39") format = ZXing::BarcodeFormat::Code39;
            else if (formatString == "code93") format = ZXing::BarcodeFormat::Code93;
            else if (formatString == "code128") format = ZXing::BarcodeFormat::Code128;
            else if (formatString == "datamatrix") format = ZXing::BarcodeFormat::DataMatrix;
            else if (formatString == "ean8") format = ZXing::BarcodeFormat::EAN8;
            else if (formatString == "ean13") format = ZXing::BarcodeFormat::EAN13;
            else if (formatString == "itf") format = ZXing::BarcodeFormat::ITF;
            else if (formatString == "pdf417") format = ZXing::BarcodeFormat::PDF417;
            else if (formatString == "qrcode") format = ZXing::BarcodeFormat::QRCode;
            else if (formatString == "upca") format = ZXing::BarcodeFormat::UPCA;
            else if (formatString == "upce") format = ZXing::BarcodeFormat::UPCE;
            else
            {
                qWarning() << "Format not supported: " << formatString;
                format = ZXing::BarcodeFormat::QRCode;
            }
        }

        if (optionQuery.hasQueryItem("encoding"))
        {
            QString encodingString = optionQuery.queryItemValue("encoding");
            if (encodingString == "iso88591") encoding = ZXing::CharacterSet::ISO8859_1;
            else if (encodingString == "utf8") encoding = ZXing::CharacterSet::UTF8;
            else
            {
                qWarning() << "Format not supported: " << encodingString;
                encoding = ZXing::CharacterSet::UTF8;
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
            if (ok && m > 0 && m < 128) margins = m;
        }

        if (optionQuery.hasQueryItem("backgroundColor"))
        {
            bgc = QColor(optionQuery.queryItemValue("backgroundColor"));
        }
        if (optionQuery.hasQueryItem("foregroundColor"))
        {
            fgc = QColor(optionQuery.queryItemValue("foregroundColor"));
        }
    }

    //
    bool formatMatrix = (format == ZXing::BarcodeFormat::Aztec ||
                         format == ZXing::BarcodeFormat::DataMatrix ||
                         format == ZXing::BarcodeFormat::QRCode ||
                         format == ZXing::BarcodeFormat::PDF417);

    // TODO // Validate data, depending on the format selected
    {
        if (data.isEmpty())
        {
            data = "empty";
        }

        if (format == ZXing::BarcodeFormat::EAN8)
        {
            // numeric - 7 char + 1 char checksum
            data = "1234567";
        }
        else if (format == ZXing::BarcodeFormat::EAN13)
        {
            // numeric - 12 char + 1 char checksum
            data = "123456789123";
        }
        else if (format == ZXing::BarcodeFormat::UPCA)
        {
            data = "12345678912";
        }
        else if (format == ZXing::BarcodeFormat::UPCE)
        {
            data = "1234567";
        }
        else if (format == ZXing::BarcodeFormat::Codabar)
        {
            data = "A0123456789A";
        }
        else if (format == ZXing::BarcodeFormat::ITF)
        {
            data = "0011223344";
        }
    }

    // Generate barcode
    int width = requestedSize.width(), height = requestedSize.height();
    if (!formatMatrix) height /= 3; // 1D codes

    auto writer = ZXing::MultiFormatWriter(format).setMargin(margins).setEccLevel(eccLevel).setEncoding(encoding);
    auto matrix = writer.encode(data.toStdString(), width, height);

    QImage image = QImage(width, height, QImage::Format_ARGB32);
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (formatMatrix) {
                image.setPixel(i, j, matrix.get(j, i) ? fgc.rgba() : bgc.rgba()); // 2D codes
            } else {
                image.setPixel(i, j, matrix.get(i, j) ? fgc.rgba() : bgc.rgba()); // 1D codes
            }
        }
    }

    *size = image.size();
    return image;
}
