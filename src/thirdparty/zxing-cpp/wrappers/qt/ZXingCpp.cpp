/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingCpp.h"
#include "ZXingCppVideoFilter.h"
#include "ZXingCppImageProvider.h"

#include <QUrl>
#include <QColor>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QScopeGuard>

#include "ReadBarcode.h"
#include "BarcodeFormat.h"

#include "BitMatrix.h"
#include "MultiFormatWriter.h"

void ZXingCpp::registerQMLTypes()
{
    //qRegisterMetaType<ZXingCpp::BarcodeFormat>("BarcodeFormat");
    //qRegisterMetaType<ZXingCpp::ContentType>("ContentType");
    //qRegisterMetaType<ZXingCpp::Position>("Position");
    //qRegisterMetaType<ZXingCpp::Result>("Result");

    qmlRegisterType<ZXingCpp>("ZXingCpp", 1, 0, "ZXingCpp");
    qmlRegisterType<ZXingCppVideoFilter>("ZXingCpp", 1, 0, "ZXingCppVideoFilter");
}

void ZXingCpp::registerQMLImageProvider(QQmlEngine &engine)
{
    engine.addImageProvider("ZXingCpp", new ZXingCppImageProvider());
}

int ZXingCpp::stringToFormat(const QString &str)
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

QString ZXingCpp::formatToString(const int fmt)
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

inline QList<Result> QListResults(ZXing::Results&& zxres)
{
    QList<Result> res;
    for (auto &&r : zxres)
    {
        res.push_back(Result(std::move(r)));
    }

    return res;
}

/* ************************************************************************** */

Result ZXingCpp::ReadBarcode(const QImage &img, const ZXing::ReaderOptions &opts)
{
    auto res = ReadBarcodes(img, ZXing::ReaderOptions(opts).setMaxNumberOfSymbols(1));
    return !res.isEmpty() ? res.takeFirst() : Result();
}

Result ZXingCpp::ReadBarcode(const QVideoFrame &frame, const ZXing::ReaderOptions &opts, const QRect captureRect)
{
    auto res = ReadBarcodes(frame, ZXing::ReaderOptions(opts).setMaxNumberOfSymbols(1), captureRect);
    return !res.isEmpty() ? res.takeFirst() : Result();
}

QList<Result> ZXingCpp::ReadBarcodes(const QImage &img, const ZXing::ReaderOptions &opts)
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

        return QListResults(ZXing::ReadBarcodes(ZXing::ImageView { img.constBits(), img.width(), img.height(),
                                                                   ImgFmtFromQImg(img), static_cast<int>(img.bytesPerLine()) },
                                                opts));
    };

    return (ImgFmtFromQImg(img) == ZXing::ImageFormat::None) ? exec(img.convertToFormat(QImage::Format_Grayscale8)) : exec(img);
}

QList<Result> ZXingCpp::ReadBarcodes(const QVideoFrame &frame, const ZXing::ReaderOptions &opts, const QRect captureRect)
{
    auto img = frame; // shallow copy just get access to non-const map() function
    if (!frame.isValid() || !img.map(QVideoFrame::ReadOnly))
    {
        qWarning() << "ZXingCppVideoFilter error: invalid QVideoFrame, could not map memory";
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
                                                                               captureRect.width(), captureRect.height()), opts));
    }
    else
    {
        return ReadBarcodes(img.toImage().copy(captureRect), opts);
    }
}

QList<Result> ZXingCpp::loadImage(const QUrl &fileUrl)
{
    QString filepath = fileUrl.toLocalFile();
    QImage img(filepath);

    return ReadBarcodes(img);
}

QList<Result> ZXingCpp::loadImage(const QImage &img)
{
    return ReadBarcodes(img);
}

QImage ZXingCpp::generateImage(const QString &data, const int width, const int height, const int margins,
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
        qWarning() << "ZXingCpp::generateImage() invalid_argument:" << ex.what();
    }
    catch (...)
    {
        qWarning() << "ZXingCpp::generateImage() error";
    }

    return QImage();
}

bool ZXingCpp::saveImage(const QString &data, int width, int height, int margins,
                         const int format, const int encoding, const int eccLevel,
                         const QColor backgroundColor, const QColor foregroundColor,
                         const QUrl &fileurl)
{
    qDebug() << "ZXingCpp::saveImage(" << data << fileurl << ")";
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
                qWarning() << "ZXingCpp::saveImage() writer.encode() error";
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
        qWarning() << "ZXingCpp::saveImage() unknown format error:" << saveFileInfo.suffix();
    }

    return status;
}
