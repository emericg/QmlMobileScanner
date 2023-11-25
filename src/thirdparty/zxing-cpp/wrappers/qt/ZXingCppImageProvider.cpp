/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingCppImageProvider.h"
#include "ZXingCpp.h"

#include "BarcodeFormat.h"
#include "BitMatrix.h"
#include "MultiFormatWriter.h"

#include <QDebug>
#include <QUrlQuery>
#include <QRegularExpression>

ZXingCppImageProvider::ZXingCppImageProvider() : QQuickImageProvider(QQuickImageProvider::Image)
{
    //
}

QImage ZXingCppImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    if (id.isEmpty() || requestedSize.width() <= 0 || requestedSize.height() <= 0) return QImage();
    //qDebug() << "ZXingCppImageProvider::requestImage(" << id << ") size " << *size << " /  requestedSize" << requestedSize;

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
            QString formatString = optionQuery.queryItemValue("format").toLower().remove('-');
            format = (ZXing::BarcodeFormat)ZXingCpp::stringToFormat(formatString);

            if (format <= ZXing::BarcodeFormat::None)
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

    // TODO // Validate data, depending on the format selected
    {
        if (data.isEmpty())
        {
            data = "empty";
            if (format == ZXing::BarcodeFormat::EAN8) data = "1234567";
            if (format == ZXing::BarcodeFormat::EAN13) data = "123456789123";
            if (format == ZXing::BarcodeFormat::UPCA) data = "12345678912";
            if (format == ZXing::BarcodeFormat::UPCE) data = "1234567";
            if (format == ZXing::BarcodeFormat::Codabar) data = "A0123456789A";
            if (format == ZXing::BarcodeFormat::ITF) data = "0011223344";
        }

        if (format == ZXing::BarcodeFormat::EAN8)
        {
            // numeric - 7 char + 1 char checksum
            data.resize(7, '0');
        }
        else if (format == ZXing::BarcodeFormat::EAN13)
        {
            // numeric - 12 char + 1 char checksum
            data.resize(12, '0');
        }
        else if (format == ZXing::BarcodeFormat::UPCE)
        {
            // numeric - 7 char + 1 char checksum
            data.resize(7, '0');
        }
        else if (format == ZXing::BarcodeFormat::UPCA)
        {
            // numeric - 11 char + 1 char checksum
            data.resize(11, '0');
        }
        else if (format == ZXing::BarcodeFormat::Codabar)
        {
            data.resize(12, '0');
        }
        else if (format == ZXing::BarcodeFormat::ITF)
        {
            data.resize(10, '0');
        }
    }

    // Generate barcode
    int width = requestedSize.width(), height = requestedSize.height();
    bool formatMatrix = ((int)format & (int)ZXing::BarcodeFormat::MatrixCodes);
    if (!formatMatrix) height /= 3; // 1D codes

    QImage img = ZXingCpp::generateImage(data, width, height, margins,
                                         (int)format, (int)encoding, eccLevel,
                                         bgc, fgc);

    *size = img.size();
    return img;
}
