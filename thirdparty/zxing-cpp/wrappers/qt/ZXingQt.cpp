/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingQt.h"
#include "ZXingQtVideoFilter.h"
#include "ZXingQtImageProvider.h"

#include <QUrl>
#include <QString>
#include <QColor>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QScopeGuard>

#include "ReadBarcode.h"
#include "BarcodeFormat.h"

#include "BitMatrix.h"
#include "MultiFormatWriter.h"

void ZXingQt::registerQMLTypes()
{
    //qRegisterMetaType<ZXingQt::BarcodeFormat>("BarcodeFormat");
    //qRegisterMetaType<ZXingQt::ContentType>("ContentType");
    //qRegisterMetaType<ZXingQt::Position>("Position");
    //qRegisterMetaType<ZXingQt::Result>("Result");

    qmlRegisterType<ZXingQt>("ZXingQt", 1, 0, "ZXingQt");
    qmlRegisterType<ZXingQtVideoFilter>("ZXingQt", 1, 0, "ZXingQtVideoFilter");
}

void ZXingQt::registerQMLImageProvider(QQmlEngine &engine)
{
    engine.addImageProvider("ZXingQt", new ZXingQtImageProvider());
}

int ZXingQt::stringToFormat(const QString &str)
{
    if (str == "aztec") return (int)ZXing::BarcodeFormat::Aztec;
    if (str == "codabar") return (int)ZXing::BarcodeFormat::Codabar;
    if (str == "code39") return (int)ZXing::BarcodeFormat::Code39;
    if (str == "code93") return (int)ZXing::BarcodeFormat::Code93;
    if (str == "code128") return (int)ZXing::BarcodeFormat::Code128;
    if (str == "databar") return (int)ZXing::BarcodeFormat::DataBar;
    if (str == "databarexpanded") return (int)ZXing::BarcodeFormat::DataBarExpanded;
    if (str == "datamatrix") return (int)ZXing::BarcodeFormat::DataMatrix;
    if (str == "ean8") return (int)ZXing::BarcodeFormat::EAN8;
    if (str == "ean13") return (int)ZXing::BarcodeFormat::EAN13;
    if (str == "itf") return (int)ZXing::BarcodeFormat::ITF;
    if (str == "maxicode") return (int)ZXing::BarcodeFormat::MaxiCode;
    if (str == "pdf417") return (int)ZXing::BarcodeFormat::PDF417;
    if (str == "qrcode") return (int)ZXing::BarcodeFormat::QRCode;
    if (str == "upca") return (int)ZXing::BarcodeFormat::UPCA;
    if (str == "upce") return (int)ZXing::BarcodeFormat::UPCE;
    if (str == "microqrcode") return (int)ZXing::BarcodeFormat::MicroQRCode;

    return 0;
}

QString ZXingQt::formatToString(const int fmt)
{
    if (fmt == (int)ZXing::BarcodeFormat::Aztec) return "aztec";
    if (fmt == (int)ZXing::BarcodeFormat::Codabar) return "codabar";
    if (fmt == (int)ZXing::BarcodeFormat::Code39) return "code39";
    if (fmt == (int)ZXing::BarcodeFormat::Code93) return "code93";
    if (fmt == (int)ZXing::BarcodeFormat::Code128) return "code128";
    if (fmt == (int)ZXing::BarcodeFormat::DataBar) return "databar";
    if (fmt == (int)ZXing::BarcodeFormat::DataBarExpanded) return "databarexpanded";
    if (fmt == (int)ZXing::BarcodeFormat::DataMatrix) return "datamatrix";
    if (fmt == (int)ZXing::BarcodeFormat::EAN8) return "ean8";
    if (fmt == (int)ZXing::BarcodeFormat::EAN13) return "ean13";
    if (fmt == (int)ZXing::BarcodeFormat::ITF) return "itf";
    if (fmt == (int)ZXing::BarcodeFormat::MaxiCode) return "maxicode";
    if (fmt == (int)ZXing::BarcodeFormat::PDF417) return "pdf417";
    if (fmt == (int)ZXing::BarcodeFormat::QRCode) return "qrcode";
    if (fmt == (int)ZXing::BarcodeFormat::UPCA) return "upca";
    if (fmt == (int)ZXing::BarcodeFormat::UPCE) return "upce";
    if (fmt == (int)ZXing::BarcodeFormat::MicroQRCode) return "microqrcode";

    return QString();
}

int ZXingQt::qimageFormatToXZingFormat(const QImage &img)
{
    ZXing::ImageFormat format = ZXing::ImageFormat::None;

    switch (img.format())
    {
        case QImage::Format_RGB32:
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
            format = ZXing::ImageFormat::BGRX; break;
#else
            format = ZXing::ImageFormat::XRGB; break;
#endif
        case QImage::Format_ARGB32:
        case QImage::Format_ARGB32_Premultiplied:
            format = ZXing::ImageFormat::XRGB; break;
        case QImage::Format_RGB888:
            format = ZXing::ImageFormat::RGB; break;
        case QImage::Format_BGR888:
            format = ZXing::ImageFormat::BGR; break;
        case QImage::Format_RGBX8888:
        case QImage::Format_RGBA8888:
        case QImage::Format_RGBA8888_Premultiplied:
            format = ZXing::ImageFormat::RGBX; break;
        case QImage::Format_Grayscale8:
            format = ZXing::ImageFormat::Lum; break;

        default: break;
    }

    return (int)format;
}

int ZXingQt::qvideoframeFormatToXZingFormat(const QVideoFrame &frame)
{
    ZXing::ImageFormat format = ZXing::ImageFormat::None;

    switch (frame.pixelFormat())
    {
        case QVideoFrameFormat::Format_ARGB8888:
        case QVideoFrameFormat::Format_ARGB8888_Premultiplied:
        case QVideoFrameFormat::Format_XRGB8888:
            format = ZXing::ImageFormat::XRGB; break;
        case QVideoFrameFormat::Format_BGRA8888:
        case QVideoFrameFormat::Format_BGRA8888_Premultiplied:
        case QVideoFrameFormat::Format_BGRX8888:
            format = ZXing::ImageFormat::BGRX; break;
        case QVideoFrameFormat::Format_ABGR8888:
        case QVideoFrameFormat::Format_XBGR8888:
            format = ZXing::ImageFormat::XBGR; break;
        case QVideoFrameFormat::Format_RGBA8888:
        case QVideoFrameFormat::Format_RGBX8888:
            format = ZXing::ImageFormat::RGBX; break;
/*
        case QVideoFrameFormat::Format_AYUV:
        case QVideoFrameFormat::Format_AYUV_Premultiplied:
        case QVideoFrameFormat::Format_YUV420P:
        case QVideoFrameFormat::Format_YUV422P:
        case QVideoFrameFormat::Format_YV12:
        case QVideoFrameFormat::Format_UYVY:
        case QVideoFrameFormat::Format_YUYV:
        case QVideoFrameFormat::Format_NV12:
        case QVideoFrameFormat::Format_NV21:
        case QVideoFrameFormat::Format_IMC1:
        case QVideoFrameFormat::Format_IMC2:
        case QVideoFrameFormat::Format_IMC3:
        case QVideoFrameFormat::Format_IMC4:
        case QVideoFrameFormat::Format_Y8:
        case QVideoFrameFormat::Format_Y16:
            format = ZXing::ImageFormat::Lum; break;

        case QVideoFrameFormat::Format_P010:
        case QVideoFrameFormat::Format_P016:
        case QVideoFrameFormat::Format_YUV420P10:
            format = ZXing::ImageFormat::Lum; break;
*/
        case QVideoFrameFormat::Format_SamplerExternalOES:
        case QVideoFrameFormat::Format_Jpeg:
        case QVideoFrameFormat::Format_SamplerRect:
        default: break;
    }

    return (int)format;
}

inline QList<Result> QListResults(ZXing::Results && zxres)
{
    QList<Result> res;
    for (auto &&r : zxres)
    {
        res.push_back(Result(std::move(r)));
    }

    return res;
}

/* ************************************************************************** */

Result ZXingQt::ReadBarcode(const QImage &img, const ZXing::ReaderOptions &opts)
{
    auto res = ReadBarcodes(img, ZXing::ReaderOptions(opts).setMaxNumberOfSymbols(1));
    return !res.isEmpty() ? res.takeFirst() : Result();
}

Result ZXingQt::ReadBarcode(const QVideoFrame &frame, const ZXing::ReaderOptions &opts, const QRect captureRect)
{
    auto res = ReadBarcodes(frame, ZXing::ReaderOptions(opts).setMaxNumberOfSymbols(1), captureRect);
    return !res.isEmpty() ? res.takeFirst() : Result();
}

/* ************************************************************************** */

//! Read barcode from QImage
QList<Result> ZXingQt::ReadBarcodes(const QImage &img,
                                     const ZXing::ReaderOptions &opts,
                                     const QRect captureRect)
{
    ZXing::ImageFormat format = (ZXing::ImageFormat)qimageFormatToXZingFormat(img);

    if (format != ZXing::ImageFormat::None)
    {
        return QListResults(ZXing::ReadBarcodes(ZXing::ImageView { img.constBits(), img.width(), img.height(),
                                                                   format, static_cast<int>(img.bytesPerLine()) },
                                                opts));
    }
    else
    {
        QImage converted = img.convertToFormat(QImage::Format_Grayscale8);

        return QListResults(ZXing::ReadBarcodes(ZXing::ImageView { converted.constBits(), converted.width(), converted.height(),
                                                                   ZXing::ImageFormat::Lum, static_cast<int>(converted.bytesPerLine()) },
                                                opts));
    }
}

//! Read barcode DIRECTLY from QVideoFrame
QList<Result> ZXingQt::ReadBarcodes(const QVideoFrame &frame,
                                     const ZXing::ReaderOptions &opts,
                                     const QRect captureRect)
{
    if (!frame.isValid()) return {};

    // shallow copy just get access to non-const map() function
    auto frame_ro = frame;
    if (frame_ro.handleType() == QVideoFrame::RhiTextureHandle)
    {
        if (!frame_ro.map(QVideoFrame::ReadOnly))
        {
            qWarning() << "ZXingQtVideoFilter error: invalid QVideoFrame, could not map memory";
            return {};
        }
    }

    ZXing::ImageFormat fmt = (ZXing::ImageFormat)qvideoframeFormatToXZingFormat(frame_ro);

    //qWarning() << "QVideoFrame pixel format :" << frame_ro.pixelFormat();
    //qWarning() << "ZXing::ImageFormat       :" << (int)fmt;
    //fmt = ZXing::ImageFormat::Lum;

    if (fmt != ZXing::ImageFormat::None)
    {
        return QListResults(
            ZXing::ReadBarcodes(
                ZXing::ImageView(frame_ro.bits(0), frame_ro.width(), frame_ro.height(),
                                 fmt, frame_ro.bytesPerLine(0)),//.cropped(captureRect.left(), captureRect.top(),
                                                                //   captureRect.width(), captureRect.height()),
                opts)
            );
    }
    else
    {
        // convert to greyscale QImage
        return ReadBarcodes(frame_ro.toImage().convertToFormat(QImage::Format_Grayscale8),
                            opts, captureRect);
    }
}

//! Read barcode from QVideoFrame, converting it to QImage
QList<Result> ZXingQt::ReadBarcodes2(const QVideoFrame &frame,
                                      const ZXing::ReaderOptions &opts,
                                      const QRect captureRect)
{
    if (!frame.isValid()) return {};

    QImage image = frame.toImage();
    if (image.isNull())
    {
        qWarning() << "ZXingQtVideoFilter error: Cant create image file to process.";
        return {};
    }

    return QListResults(ZXing::ReadBarcodes(
                            ZXing::ImageView(image.constBits(), image.width(), image.height(), (ZXing::ImageFormat)qimageFormatToXZingFormat(image))
                                .cropped(captureRect.left(), captureRect.top(), captureRect.width(), captureRect.height()), opts) );
/*
    QImage img(image);
    if (captureRect.isValid() && img.size() != captureRect.size())
    {
        //img = image.copy(captureRect);
        img = image.convertToFormat(QImage::Format_Grayscale8);
    }

    return QListResults(ZXing::ReadBarcodes(
                            ZXing::ImageView(img.constBits(), img.width(), img.height(), ZXing::ImageFormat::Lum)
                                .cropped(captureRect.left(), captureRect.top(), captureRect.width(), captureRect.height()), opts) );

    return QListResults(ZXing::ReadBarcodes(ZXing::ImageView {image.constBits(), image.width(), image.height(),
                             (ZXing::ImageFormat)qimageFormatToXZingFormat(image)}.cropped(captureRect.left(), captureRect.top(),
                         captureRect.width(), captureRect.height()),
            opts)
        );

    return QListResults(ZXing::ReadBarcodes(ZXing::ImageView { img.constBits(), img.width(), img.height(),
                                                               ZXing::ImageFormat::Lum, static_cast<int>(img.bytesPerLine()) },
                                            opts));
*/
    //return ReadBarcodes(img, opts/*, captureRect*/);
}

/* ************************************************************************** */

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

QImage ZXingQt::generateImage(const QString &data, const int width, const int height, const int margins,
                               const int format, const int encoding, const int eccLevel,
                               const QColor backgroundColor, const QColor foregroundColor)
{
    try
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
    catch (std::invalid_argument const &ex)
    {
        qWarning() << "ZXingQt::generateImage() invalid_argument:" << ex.what();
    }
    catch (...)
    {
        qWarning() << "ZXingQt::generateImage() error";
    }

    return QImage();
}

bool ZXingQt::saveImage(const QString &data, int width, int height, int margins,
                         const int format, const int encoding, const int eccLevel,
                         const QColor backgroundColor, const QColor foregroundColor,
                         const QUrl &fileurl)
{
    qDebug() << "ZXingQt::saveImage(" << data << fileurl << ")";
    qDebug() << "width:" << width << "height:" << height << "margins:" << margins;
    qDebug() << "format:" << format << "encoding:" << encoding << "eccLevel:" << eccLevel;

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

            try
            {
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
            }
            catch (...)
            {
                qWarning() << "ZXingQt::saveImage() writer.encode() error";
            }

            efile.close();
        }
    }
    else if (saveFileInfo.suffix() == "bmp" ||
             saveFileInfo.suffix() == "png" ||
             saveFileInfo.suffix() == "jpg" || saveFileInfo.suffix() == "jpeg" ||
             saveFileInfo.suffix() == "webp")
    {
        bool formatMatrix = (format & (int)BarcodeFormat::MatrixCodes);
        if (!formatMatrix) height = width / 3;

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

/* ************************************************************************** */
