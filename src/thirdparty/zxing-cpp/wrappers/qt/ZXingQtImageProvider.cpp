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

namespace ZXingQt {

ZXingQtImageProvider::ZXingQtImageProvider() : QQuickImageProvider(QQuickImageProvider::Image)
{
    //
}

QImage ZXingQtImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
/*
    QString data;

    bool border = false;
    bool transparent = false;
    QSize explicitSize = requestedSize;

    //QZXing::EncoderFormat format = QZXing::EncoderFormat_QR_CODE;
    //QZXing::EncodeErrorCorrectionLevel correctionLevel = QZXing::EncodeErrorCorrectionLevel_L;

    int customSettingsIndex = id.lastIndexOf(QRegularExpression("\\?(correctionLevel|format|border|transparent)="));
    if (customSettingsIndex >= 0)
    {
        int startOfDataIndex = slashIndex + 1;
        data = id.mid(startOfDataIndex, customSettingsIndex - (startOfDataIndex));

        //The dummy option has been added due to a bug(?) of QUrlQuery
        // it could not recognize the first key-value pair provided
        QUrlQuery optionQuery("options?dummy=&" + id.mid(customSettingsIndex + 1));

        if (optionQuery.hasQueryItem("format"))
        {
            QString formatString = optionQuery.queryItemValue("format");
            if (formatString != "qrcode")
            {
                qWarning() << "Format not supported: " << formatString;
                return QImage();
            }
        }

        QString correctionLevelString = optionQuery.queryItemValue("correctionLevel");
        if(correctionLevelString == "H")
            correctionLevel = QZXing::EncodeErrorCorrectionLevel_H;
        else if(correctionLevelString == "Q")
            correctionLevel = QZXing::EncodeErrorCorrectionLevel_Q;
        else if(correctionLevelString == "M")
            correctionLevel = QZXing::EncodeErrorCorrectionLevel_M;
        else if(correctionLevelString == "L")
            correctionLevel = QZXing::EncodeErrorCorrectionLevel_L;

        if (optionQuery.hasQueryItem("border"))
            border = optionQuery.queryItemValue("border") == "true";

        if (optionQuery.hasQueryItem("transparent"))
            transparent = optionQuery.queryItemValue("transparent") == "true";

        if (optionQuery.hasQueryItem("explicitSize"))
        {
            QString explicitSizeStr = optionQuery.queryItemValue("explicitSize");
            bool ok;
            int size = explicitSizeStr.toInt(&ok);
            if(ok){
                explicitSize = QSize(size, size);
            }
        }
    }
    else
    {
        data = id.mid(slashIndex + 1);
    }
*/
    QImage image;
    if (id != "")
    {
        int slashIndex = id.indexOf('/');
        if (slashIndex == -1)
        {
            qWarning() << "Can't parse url" << id << ". Usage is encode/<data>";
            return QImage();
        }

        // Detect operation (ex. encode)
        QString operationName = id.left(slashIndex);
        if (operationName != "encode")
        {
            qWarning() << "Operation not supported: " << operationName;
            return QImage();
        }

        QString data;
        data = id.mid(slashIndex + 1);

        if (data != "")
        {
            ZXing::BarcodeFormat format = ZXing::BarcodeFormat::QRCode;

            int width = requestedSize.width(), height = requestedSize.height();

            int margin = 10;
            int eccLevel = 1;
            auto writer = ZXing::MultiFormatWriter(format).setMargin(margin).setEccLevel(eccLevel);
            auto matrix = writer.encode(data.toStdString(), width, height);

            image = QImage(width, height, QImage::Format_ARGB32);
            image.fill(qRgba(255, 255, 255, 255));

            for (int i = 0; i < width; ++i)
            {
                for (int j = 0; j < height; ++j)
                {
                    if (i < matrix.width() && j < matrix.height())
                    {
                        if (matrix.get(j, i)) // or i, j for linear?
                        {
                            image.setPixel(i, j, qRgba(0, 0, 0, 255));
                        }
                    }
                }
            }
        }
    }

    *size = image.size();
    return image;
}

} // namespace ZXingQt
