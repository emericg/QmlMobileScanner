/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingQt.h"
#include "ZXingQtVideoFilter.h"
#include "ZXingQtImageProvider.h"

#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QScopeGuard>

#include "ReadBarcode.h"
#include "BarcodeFormat.h"

#include "BitMatrix.h"
#include "MultiFormatWriter.h"

////////////////////////////////////////////////////////////////////////////////

void ZXingQt::registerQMLTypes()
{
    //qRegisterMetaType<ZXingQt::BarcodeFormat>("BarcodeFormat");
    //qRegisterMetaType<ZXingQt::ContentType>("ContentType");

    // supposedly the Q_DECLARE_METATYPE should be used with the overload without a custom name
    // but then the qml side complains about "unregistered type"
    //qRegisterMetaType<ZXingQt::Position>("Position");
    //qRegisterMetaType<ZXingQt::Result>("Result");

    //qmlRegisterUncreatableMetaObject(ZXingQt::staticMetaObject, "ZXingCpp", 1, 0, "ZXingCpp", "Access to enums & flags only");

    qmlRegisterType<ZXingQt>("ZXingCpp", 1, 0, "ZXingQt");
    qmlRegisterType<ZXingQtVideoFilter>("ZXingCpp", 1, 0, "ZXingQtVideoFilter");
}

void ZXingQt::registerQMLImageProvider(QQmlEngine &engine)
{
    engine.addImageProvider("ZXingCpp", new ZXingQtImageProvider());
}

////////////////////////////////////////////////////////////////////////////////

inline QList<Result> QListResults(ZXing::Results&& zxres)
{
    QList<Result> res;
    for (auto &&r : zxres)
    {
        res.push_back(Result(std::move(r)));
    }

    return res;
}

Result ZXingQt::ReadBarcode(const QImage &img, const ZXing::DecodeHints &hints)
{
    auto res = ReadBarcodes(img, ZXing::DecodeHints(hints).setMaxNumberOfSymbols(1));
    return !res.isEmpty() ? res.takeFirst() : Result();
}

Result ZXingQt::ReadBarcode(const QVideoFrame &frame, const ZXing::DecodeHints &hints, const QRect captureRect)
{
    auto res = ReadBarcodes(frame, ZXing::DecodeHints(hints).setMaxNumberOfSymbols(1), captureRect);
    return !res.isEmpty() ? res.takeFirst() : Result();
}

QList<Result> ZXingQt::ReadBarcodes(const QImage &img, const ZXing::DecodeHints &hints)
{
    auto ImgFmtFromQImg = [](const QImage &img) {
        switch (img.format()) {
        case QImage::Format_ARGB32:
        case QImage::Format_RGB32:
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
            return ZXing::ImageFormat::BGRX;
#else
            return ZXing::ImageFormat::XRGB;
#endif
        case QImage::Format_RGB888: return ZXing::ImageFormat::RGB;
        case QImage::Format_RGBX8888:
        case QImage::Format_RGBA8888: return ZXing::ImageFormat::RGBX;
        case QImage::Format_Grayscale8: return ZXing::ImageFormat::Lum;
        default: return ZXing::ImageFormat::None;
        }
    };

    auto exec = [&](const QImage &img) {
        return QListResults(ZXing::ReadBarcodes({img.bits(), img.width(), img.height(),
                                                 ImgFmtFromQImg(img), static_cast<int>(img.bytesPerLine())},
                                                hints));
    };

    return (ImgFmtFromQImg(img) == ZXing::ImageFormat::None) ? exec(img.convertToFormat(QImage::Format_Grayscale8)) : exec(img);
}

QList<Result> ZXingQt::ReadBarcodes(const QVideoFrame &frame, const ZXing::DecodeHints &hints, const QRect captureRect)
{
    auto img = frame; // shallow copy just get access to non-const map() function
    if (!frame.isValid() || !img.map(QVideoFrame::ReadOnly))
    {
        qWarning() << "ZXingQtVideoFilter error: invalid QVideoFrame, could not map memory";
        return {};
    }
    auto unmap = qScopeGuard([&] { img.unmap(); });

    ZXing::ImageFormat fmt = ZXing::ImageFormat::None;
    int pixStride = 0;
    int pixOffset = 0;

#define FORMAT(F5, F6) QVideoFrameFormat::Format_##F6
#define FIRST_PLANE 0

    switch (frame.pixelFormat()) {
    case FORMAT(ARGB32, ARGB8888):
    case FORMAT(ARGB32_Premultiplied, ARGB8888_Premultiplied):
    case FORMAT(RGB32, RGBX8888):
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
        fmt = ZXing::ImageFormat::BGRX;
#else
        fmt = ZXing::ImageFormat::XRGB;
#endif
        break;

    case FORMAT(BGRA32, BGRA8888):
    case FORMAT(BGRA32_Premultiplied, BGRA8888_Premultiplied):
    case FORMAT(BGR32, BGRX8888):
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
        fmt = ZXing::ImageFormat::RGBX;
#else
        fmt = ZXing::ImageFormat::XBGR;
#endif
        break;

    case QVideoFrameFormat::Format_P010:
    case QVideoFrameFormat::Format_P016: fmt = ZXing::ImageFormat::Lum, pixStride = 1; break;

    case FORMAT(AYUV444, AYUV):
    case FORMAT(AYUV444_Premultiplied, AYUV_Premultiplied):
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
        fmt = ZXing::ImageFormat::Lum, pixStride = 4, pixOffset = 3;
#else
        fmt = ZXing::ImageFormat::Lum, pixStride = 4, pixOffset = 2;
#endif
        break;

    case FORMAT(YUV420P, YUV420P):
    case FORMAT(NV12, NV12):
    case FORMAT(NV21, NV21):
    case FORMAT(IMC1, IMC1):
    case FORMAT(IMC2, IMC2):
    case FORMAT(IMC3, IMC3):
    case FORMAT(IMC4, IMC4):
    case FORMAT(YV12, YV12): fmt = ZXing::ImageFormat::Lum; break;
    case FORMAT(UYVY, UYVY): fmt = ZXing::ImageFormat::Lum, pixStride = 2, pixOffset = 1; break;
    case FORMAT(YUYV, YUYV): fmt = ZXing::ImageFormat::Lum, pixStride = 2; break;

    case FORMAT(Y8, Y8): fmt = ZXing::ImageFormat::Lum; break;
    case FORMAT(Y16, Y16): fmt = ZXing::ImageFormat::Lum, pixStride = 2, pixOffset = 1; break;

    case FORMAT(ABGR32, ABGR8888):
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
        fmt = ZXing::ImageFormat::RGBX;
#else
        fmt = ZXing::ImageFormat::XBGR;
#endif
        break;

    case FORMAT(YUV422P, YUV422P): fmt = ZXing::ImageFormat::Lum; break;
    default: break;
    }

    if (fmt != ZXing::ImageFormat::None)
    {
        return QListResults(ZXing::ReadBarcodes(
            ZXing::ImageView(img.bits(FIRST_PLANE) + pixOffset, img.width(), img.height(), fmt,
                             img.bytesPerLine(FIRST_PLANE), pixStride).cropped(captureRect.left(), captureRect.top(),
                                                                               captureRect.width(), captureRect.height()), hints));
    }
    else
    {
        return ReadBarcodes(img.toImage().copy(captureRect), hints);
    }
}

QList<Result> ZXingQt::loadImage(const QUrl &fileUrl)
{
    QString filepath = fileUrl.toLocalFile();
    QImage img(filepath);

    return ReadBarcodes(img);
}

QList<Result> ZXingQt::loadImage(const QImage &img)
{
    return ReadBarcodes(img);
}

////////////////////////////////////////////////////////////////////////////////

QImage ZXingQt::generateImage(const QString &data, const int width, const int height, const int margins,
                              const int format, const int encoding, const int eccLevel,
                              const QColor backgroundColor, const QColor foregroundColor)
{
    auto writer = ZXing::MultiFormatWriter((ZXing::BarcodeFormat)format).setEccLevel(eccLevel).setEncoding((ZXing::CharacterSet)encoding).setMargin(margins);
    auto matrix = writer.encode(data.toStdString(), width, height);

    bool formatMatrix = (format & (int)BarcodeFormat::MatrixCodes);

    QColor bgc(0, 0, 0, 0);
    QColor fgc(0, 0, 0, 255);
    if (backgroundColor.isValid()) bgc = backgroundColor;
    if (foregroundColor.isValid()) fgc = foregroundColor;

    QImage image(width, height, QImage::Format_ARGB32);
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (formatMatrix) {
                image.setPixel(i, j, matrix.get(j, i) ? fgc.rgba() : bgc.rgba()); // 2D codes
            } else {
                image.setPixel(i, j, matrix.get(i, j) ? fgc.rgba() : bgc.rgba()); // 1D codes
            }
        }
    }

    return image;
}

bool ZXingQt::saveImage(const QString &data, const int width, const int height, const int margins,
                        const int format, const int encoding, const int eccLevel,
                        const QColor backgroundColor, const QColor foregroundColor,
                        const QUrl &fileurl)
{
    //qDebug() << "ZXingQt::saveImage(" << data << fileurl;
    if (data.isEmpty() || fileurl.isEmpty()) return false;
    bool status = false;

    QString filepath = fileurl.toLocalFile();

    QFileInfo saveFileInfo(filepath);
    if (saveFileInfo.suffix() == "svg")
    {
        // to vector
        QFile efile(filepath);
        if (efile.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            bool formatMatrix = (format & (int)BarcodeFormat::MatrixCodes);
            int ww = 64;
            int hh = 64;

            auto writer = ZXing::MultiFormatWriter((ZXing::BarcodeFormat)format).setEccLevel(eccLevel).setEncoding((ZXing::CharacterSet)encoding).setMargin(margins);
            auto matrix = writer.encode(data.toStdString(), ww, hh);

            QString barcodePath;
            for (int i = 0; i < ww; i++) {
                for (int j = 0; j < hh; j++) {
                    if (matrix.get(j, i)) {
                        if (formatMatrix) {
                            barcodePath += " M" + QString::number(i) + "," + QString::number(j) + "h1v1h-1z";
                        } else {
                            barcodePath += " M" + QString::number(i) + "," + QString::number(j) + "h1v1h-1z";
                        }
                    }
                }
            }

            QTextStream eout(&efile);
            eout << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"  << Qt::endl;
            eout << "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" viewBox=\"0 0 " << QString::number(ww) << " " << QString::number(hh) << "\" stroke=\"none\">" << Qt::endl;
            eout << "<style type=\"text/css\">" << Qt::endl;
            eout << ".black {fill:#000000;}" << Qt::endl;
            eout << "</style>" << Qt::endl;
            eout << "<path class=\"black\"  d=\"" << barcodePath << "\"/>" << Qt::endl;
            eout << "</svg>" << Qt::endl;
            efile.close();
        }
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
        qWarning() << "ZXingQt::saveImage() unknown format error:" << saveFileInfo.suffix();
    }

    return status;
}

////////////////////////////////////////////////////////////////////////////////
