/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingQt.h"
#include "ZXingQtVideoFilter.h"
#include "ZXingQtImageProvider.h"

#include "ReadBarcode.h"
#include "BarcodeFormat.h"

#include "BitMatrix.h"
#include "MultiFormatWriter.h"

#include <QString>
#include <QColor>
#include <QUrl>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextStream>
#include <QScopeGuard>

#if defined(Q_OS_ANDROID)
#include <QCoreApplication>
#include <QJniObject>
#endif

/* ************************************************************************** */

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

/* ************************************************************************** */

int ZXingQt::stringToFormat(const QString &str)
{
    if (str == "aztec") return (int)ZXing::BarcodeFormat::AztecCode;
    if (str == "aztecrune") return (int)ZXing::BarcodeFormat::AztecRune;
    if (str == "codabar") return (int)ZXing::BarcodeFormat::Codabar;
    if (str == "code39") return (int)ZXing::BarcodeFormat::Code39;
    if (str == "code93") return (int)ZXing::BarcodeFormat::Code93;
    if (str == "code128") return (int)ZXing::BarcodeFormat::Code128;
    if (str == "databar") return (int)ZXing::BarcodeFormat::DataBar;
    if (str == "databarexpanded") return (int)ZXing::BarcodeFormat::DataBarExp;
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

    qWarning() << "ZXingQt::stringToFormat() unknown string";

    return 0;
}

QString ZXingQt::formatToString(const int fmt)
{
    if (fmt == (int)ZXing::BarcodeFormat::AztecCode) return "aztec";
    if (fmt == (int)ZXing::BarcodeFormat::AztecRune) return "aztecrune";
    if (fmt == (int)ZXing::BarcodeFormat::Codabar) return "codabar";
    if (fmt == (int)ZXing::BarcodeFormat::Code39) return "code39";
    if (fmt == (int)ZXing::BarcodeFormat::Code93) return "code93";
    if (fmt == (int)ZXing::BarcodeFormat::Code128) return "code128";
    if (fmt == (int)ZXing::BarcodeFormat::DataBar) return "databar";
    if (fmt == (int)ZXing::BarcodeFormat::DataBarExp) return "databarexpanded";
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

    qWarning() << "ZXingQt::formatToString() unknown format";

    return QString();
}

ZXing::ImageFormat ZXingQt::qimageFormatToXZingFormat(const QImage &img)
{
    ZXing::ImageFormat format = ZXing::ImageFormat::None;

    switch (img.format())
    {
        case QImage::Format_RGB32:
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
            format = ZXing::ImageFormat::BGRA; break;
#else
            format = ZXing::ImageFormat::ARGB; break;
#endif
        case QImage::Format_ARGB32:
        case QImage::Format_ARGB32_Premultiplied:
            format = ZXing::ImageFormat::ARGB; break;
        case QImage::Format_RGB888:
            format = ZXing::ImageFormat::RGB; break;
        case QImage::Format_BGR888:
            format = ZXing::ImageFormat::BGR; break;
        case QImage::Format_RGBX8888:
        case QImage::Format_RGBA8888:
        case QImage::Format_RGBA8888_Premultiplied:
            format = ZXing::ImageFormat::RGBA; break;
        case QImage::Format_Grayscale8:
            format = ZXing::ImageFormat::Lum; break;

        default:
            qWarning() << "ZXingQt::qimageFormatToXZingFormat() unknown format";
            break;
    }

    return format;
}

void ZXingQt::qvideoframeFormatToXZingFormat(const QVideoFrame &frame,
                                             ZXing::ImageFormat &format, int &pixStride, int &pixOffset)
{
    format = ZXing::ImageFormat::None;
    pixStride = 0;
    pixOffset = 0;

    switch (frame.pixelFormat())
    {
    case QVideoFrameFormat::Format_ARGB8888:
    case QVideoFrameFormat::Format_ARGB8888_Premultiplied:
    case QVideoFrameFormat::Format_XRGB8888:
        format = ZXing::ImageFormat::ARGB; break;

    case QVideoFrameFormat::Format_BGRA8888:
    case QVideoFrameFormat::Format_BGRA8888_Premultiplied:
    case QVideoFrameFormat::Format_BGRX8888:
        format = ZXing::ImageFormat::BGRA; break;

    case QVideoFrameFormat::Format_ABGR8888:
    case QVideoFrameFormat::Format_XBGR8888:
        format = ZXing::ImageFormat::ABGR; break;

    case QVideoFrameFormat::Format_RGBA8888:
    case QVideoFrameFormat::Format_RGBX8888:
        format = ZXing::ImageFormat::RGBA; break;

    case QVideoFrameFormat::Format_P010:
    case QVideoFrameFormat::Format_P016:
        format = ZXing::ImageFormat::Lum;
        pixStride = 1;
        break;

    case QVideoFrameFormat::Format_YUV420P:
    case QVideoFrameFormat::Format_YUV422P:
    case QVideoFrameFormat::Format_NV12:
    case QVideoFrameFormat::Format_NV21:
    case QVideoFrameFormat::Format_IMC1:
    case QVideoFrameFormat::Format_IMC2:
    case QVideoFrameFormat::Format_IMC3:
    case QVideoFrameFormat::Format_IMC4:
    case QVideoFrameFormat::Format_YV12:
        format = ZXing::ImageFormat::Lum; break;

    case QVideoFrameFormat::Format_AYUV_Premultiplied:
    case QVideoFrameFormat::Format_AYUV: format = ZXing::ImageFormat::Lum, pixStride = 4, pixOffset = 1; break;
    case QVideoFrameFormat::Format_UYVY: format = ZXing::ImageFormat::Lum, pixStride = 2, pixOffset = 1; break;
    case QVideoFrameFormat::Format_YUYV: format = ZXing::ImageFormat::Lum, pixStride = 2; break;

    case QVideoFrameFormat::Format_Y8: format = ZXing::ImageFormat::Lum; break;
    case QVideoFrameFormat::Format_Y16: format = ZXing::ImageFormat::Lum, pixStride = 2, pixOffset = 1; break;

    case QVideoFrameFormat::Format_Jpeg:
    case QVideoFrameFormat::Format_SamplerRect:
    case QVideoFrameFormat::Format_SamplerExternalOES:
        qDebug() << "ZXingQt::qvideoframeFormatToXZingFormat() unsupported format";
        break;

    default:
        qWarning() << "ZXingQt::qvideoframeFormatToXZingFormat() unknow format";
        break;
    }
}

inline QList<BarcodeQml> QListBarcodes(ZXing::Barcodes && zxres)
{
    QList<BarcodeQml> res;
    for (auto &&r : zxres)
    {
        res.push_back(BarcodeQml(std::move(r)));
    }

    return res;
}

/* ************************************************************************** */

BarcodeQml ZXingQt::ReadBarcode(const QImage &image,
                                const ZXing::ReaderOptions &opts,
                                const QRect captureRect)
{
    auto res = ReadBarcodes(image, ZXing::ReaderOptions(opts).setMaxNumberOfSymbols(1), captureRect);
    return !res.isEmpty() ? res.takeFirst() : BarcodeQml();
}

BarcodeQml ZXingQt::ReadBarcode(const QVideoFrame &frame,
                                const ZXing::ReaderOptions &opts,
                                const QRect captureRect)
{
    auto res = ReadBarcodes(frame, ZXing::ReaderOptions(opts).setMaxNumberOfSymbols(1), captureRect);
    return !res.isEmpty() ? res.takeFirst() : BarcodeQml();
}

/* ************************************************************************** */

//! Read barcode from QImage
QList<BarcodeQml> ZXingQt::ReadBarcodes(const QImage &image,
                                        const ZXing::ReaderOptions &opts,
                                        const QRect captureRect)
{
    if (image.isNull())
    {
        qWarning() << "ZXingQt::ReadBarcodes(QImage) invalid QImage!";
        return {};
    }

    //qDebug() << ">>> ZXingQt::ReadBarcodes(QImage)";
    //qDebug() << "QImage geometry     :" << image.width() << "x" << image.height();
    //qDebug() << "QImage QPixelFormat :" << image.pixelFormat();
    //qDebug() << "ZXing ImageFormat   :" << (int)qimageFormatToXZingFormat(image);

    ZXing::ImageFormat format = qimageFormatToXZingFormat(image);
    if (format != ZXing::ImageFormat::None)
    {
        return QListBarcodes(
            ZXing::ReadBarcodes(
                ZXing::ImageView(image.constBits(), image.width(), image.height(),
                                 format, static_cast<int>(image.bytesPerLine())).cropped(captureRect.left(), captureRect.top(),
                                                                                         captureRect.width(), captureRect.height()),
                opts)
            );
    }
    else
    {
        QImage converted = image.convertToFormat(QImage::Format_Grayscale8, Qt::MonoOnly);
        if (!converted.isNull() && converted.format() != QImage::Format_Invalid)
        {
            return QListBarcodes(
                ZXing::ReadBarcodes(
                    ZXing::ImageView(converted.constBits(), converted.width(), converted.height(),
                                     ZXing::ImageFormat::Lum, static_cast<int>(converted.bytesPerLine())).cropped(captureRect.left(), captureRect.top(),
                                                                                                                  captureRect.width(), captureRect.height()),
                    opts)
                );
        }
        else
        {
            qWarning() << "ZXingQt::ReadBarcodes(QImage) error: unable to convert to QImage";
        }
    }

    return {};
}

//! Read barcode from QVideoFrame DIRECTLY if possible, otherwise convert to QImage
QList<BarcodeQml> ZXingQt::ReadBarcodes(const QVideoFrame &frame,
                                        const ZXing::ReaderOptions &opts,
                                        const QRect captureRect)
{
    if (!frame.isValid())
    {
        qWarning() << "ZXingQt::ReadBarcodes(QVideoFrame) invalid QVideoFrame!";
        return {};
    }

    ZXing::ImageFormat format = ZXing::ImageFormat::None;
    int pixStride = 0;
    int pixOffset = 0;

    qvideoframeFormatToXZingFormat(frame, format, pixStride, pixOffset);

    //qDebug() << ">>> ZXingQt::ReadBarcodes(QVideoFrame)";
    //qDebug() << "QVideoFrame geometry    :" << frame.width() << "x" << frame.height() << "/" << frame.rotation();
    //qDebug() << "QVideoFrame PixelFormat :" << frame.pixelFormat();
    //qDebug() << "ZXing::ImageFormat       :" << (int)format;

    if (format != ZXing::ImageFormat::None)
    {
        // shallow copy just get access to non-const map() function
        auto frame_ro = frame;
        //if (frame_ro.handleType() == QVideoFrame::RhiTextureHandle)
        {
            if (!frame_ro.map(QVideoFrame::ReadOnly))
            {
                qWarning() << "ZXingQtVideoFilter error: invalid QVideoFrame, could not map memory";
                return {};
            }
            //QScopeGuard unmap([&] { frame_ro.unmap(); });
        }

        return QListBarcodes(
            ZXing::ReadBarcodes(
                ZXing::ImageView(frame_ro.bits(0) + pixOffset, frame_ro.width(), frame_ro.height(),
                                 format, frame_ro.bytesPerLine(0), pixStride).cropped(captureRect.left(), captureRect.top(),
                                                                                      captureRect.width(), captureRect.height()),
                opts)
            );
    }

    // QImage fallback
    QImage image = frame.toImage(); // .convertToFormat(QImage::Format_Grayscale8, Qt::MonoOnly);
    return ReadBarcodes(image, opts, captureRect);
}

//! Read barcode from QVideoFrame, but converting it to QImage first
QList<BarcodeQml> ZXingQt::ReadBarcodes2(const QVideoFrame &frame,
                                         const ZXing::ReaderOptions &opts,
                                         const QRect captureRect)
{
    if (!frame.isValid())
    {
        qWarning() << "ZXingQt::ReadBarcodes2(QVideoFrame) invalid QVideoFrame!";
        return {};
    }

    //qDebug() << ">>> ZXingQt::ReadBarcodes2(QVideoFrame)";
    //qDebug() << "QVideoFrame geometry    :" << frame.width() << "x" << frame.height() << "/" << frame.rotation();
    //qDebug() << "QVideoFrame PixelFormat :" << frame.pixelFormat();

    QImage image = frame.toImage(); // .convertToFormat(QImage::Format_Grayscale8, Qt::MonoOnly);
    return ReadBarcodes(image, opts, captureRect);
}

/* ************************************************************************** */

QList<BarcodeQml> ZXingQt::loadImage(const QUrl &fileUrl)
{
    QString filepath = fileUrl.toLocalFile();
    QImage img(filepath);

    return ReadBarcodes(img);
}

QList<BarcodeQml> ZXingQt::loadImage(const QImage &img)
{
    return ReadBarcodes(img);
}

QImage ZXingQt::generateImage(const QString &data, const int width, const int height, const int margins,
                              const int format, const int encoding, const int eccLevel,
                              const QColor backgroundColor, const QColor foregroundColor)
{
    try
    {
        auto writer = ZXing::MultiFormatWriter((ZXing::BarcodeFormat)format)
                          .setEccLevel(eccLevel)
                          .setEncoding((ZXing::CharacterSet)encoding)
                          .setMargin(margins);
        auto matrix = writer.encode(data.toStdString(), width, height);

        //bool formatMatrix = (format & (int)BarcodeFormat::MatrixCodes);
        //int hhh = (formatMatrix) height : width / 3;

        QColor bgc(0, 0, 0, 0);
        QColor fgc(0, 0, 0, 255);
        if (backgroundColor.isValid()) bgc = backgroundColor;
        if (foregroundColor.isValid()) fgc = foregroundColor;

        QImage image(width, height, QImage::Format_ARGB32);
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                image.setPixel(i, j, matrix.get(i, j) ? fgc.rgba() : bgc.rgba());
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

QString getExternalFilesDirPath()
{
#if defined(Q_OS_ANDROID)

    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (activity.isValid())
    {
        QJniObject file = activity.callObjectMethod("getExternalFilesDir", "(Ljava/lang/String;)Ljava/io/File;", nullptr);

        if (file.isValid())
        {
            QJniObject path = file.callObjectMethod("getAbsolutePath", "()Ljava/lang/String;");
            return path.toString();
        }
    }
#endif

    return QString();
}

QString ZXingQt::shareImage(const QString &data, int width, int height, int margins,
                            const int format, const int encoding, const int eccLevel,
                            const QColor backgroundColor, const QColor foregroundColor)
                            //const QString exportFileDir)
{
    qDebug() << "ZXingQt::shareImage()";

    QString exportFilePath;

    // Get temp directory path (1)
    //QString exportDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    //QDir exportDirectory(exportDirectoryPath + "/export");
    //if (!exportDirectory.exists()) exportDirectory.mkpath(exportDirectoryPath + "/export");

    // Get temp directory path (2)
    QString exportDirectoryPath = getExternalFilesDirPath();
    QDir exportDirectory(exportDirectoryPath);
    if (!exportDirectory.exists()) exportDirectory.mkpath(exportDirectoryPath);

    // Get temp file path
    exportFilePath = exportDirectoryPath + "/barcode.png";

    if (saveImage(data, width, height, margins, format, encoding, eccLevel,
                  backgroundColor, foregroundColor, exportFilePath))
    {
        QFileInfo saveFileInfo(exportFilePath);
        qDebug() << "saveFileInfo " << saveFileInfo << ")";
        qDebug() << "saveFileInfo e " << saveFileInfo.exists() << ")";

        return exportFilePath;
    }

    return QString();
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
    if (filepath.isEmpty()) filepath = fileurl.toString();

    qDebug() << "fileurl " << fileurl << ")";
    qDebug() << "filepath " << filepath << ")";

    QFileInfo saveFileInfo(filepath);
    if (saveFileInfo.suffix() == "svg")
    {
        qDebug() << "saveFileInfo " << saveFileInfo << ")";

        // to vector
        QFile efile(filepath);
        if (efile.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            //bool formatMatrix = (format & (int)BarcodeFormat::MatrixCodes);
            //int hhh = (formatMatrix) height : width / 3;
            int ww = 64;
            int hh = 64;

            try
            {
                auto writer = ZXing::MultiFormatWriter((ZXing::BarcodeFormat)format)
                                  .setEccLevel(eccLevel)
                                  .setEncoding((ZXing::CharacterSet)encoding)
                                  .setMargin(margins);
                auto matrix = writer.encode(data.toStdString(), ww, hh);

                QString barcodePath;
                for (int i = 0; i < ww; i++) {
                    for (int j = 0; j < hh; j++) {
                        if (matrix.get(j, i)) {
                            barcodePath += " M" + QString::number(i) + "," + QString::number(j) + "h1v1h-1z";
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
    else if (saveFileInfo.suffix() == "bmp" || saveFileInfo.suffix() == "png" ||
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
