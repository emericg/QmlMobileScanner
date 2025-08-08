/*
 * Copyright 2023 Emeric Grange
 */

#include "ZintImageProvider.h"
#include "ZintQml.h"

#include "../../backend/zint.h"   // Use the embedded zint copy
//#include <zint.h>         // Use the system zint copy

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
            format = ZintQml::stringToFormat(formatString);

            if (format <= 0)
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
    }

    // Generate barcode
    int width = requestedSize.width(), height = requestedSize.height();
    //if (!format_matrix) height /= 3; // 1D codes

    QImage img = ZintQml::generateImage(data, width, height, margins,
                                        (int)format, (int)encoding, eccLevel,
                                        bgc, fgc);

    *size = img.size();
    return img;
}
