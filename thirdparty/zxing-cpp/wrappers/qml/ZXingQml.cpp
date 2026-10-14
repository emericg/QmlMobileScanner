/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2026 Emeric Grange
 */

#include "ZXingQml.h"
#include "ZXingQmlVideoFilter.h"
#include "ZXingQmlImageProvider.h"

#include "ReadBarcode.h"
#include "BarcodeFormat.h"

#include "CreateBarcode.h"
#include "WriteBarcode.h"

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

void ZXingQml::registerQMLTypes()
{
    qmlRegisterType<ZXingQml>("ZXingQml", 1, 0, "ZXingQml");
    qmlRegisterType<ZXingQmlVideoFilter>("ZXingQml", 1, 0, "ZXingQmlVideoFilter");
}

void ZXingQml::registerQMLImageProvider(QQmlEngine &engine)
{
    engine.addImageProvider("ZXingQml", new ZXingQmlImageProvider());
}

/* ************************************************************************** */

int ZXingQml::stringToFormat(const QString &str)
{
    // app specific names, not understood by ZXing::BarcodeFormatFromString()
    const QString name = str.toLower();
    if (name == "aztec") return (int)ZXing::BarcodeFormat::AztecCode;
    if (name == "rmqr") return (int)ZXing::BarcodeFormat::RMQRCode;

    try
    {
        // matches names ("QRCode") and human readable names ("QR Code", "DataBar Expanded")
        return (int)ZXing::BarcodeFormatFromString(str.toStdString());
    }
    catch (const std::invalid_argument &)
    {
        qWarning() << "ZXingQml::stringToFormat() unknown format:" << str;
    }

    return 0;
}

QString ZXingQml::formatToString(const int fmt)
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
    if (fmt == (int)ZXing::BarcodeFormat::RMQRCode) return "rmqr";
    if (fmt == (int)ZXing::BarcodeFormat::MicroPDF417) return "micropdf417";

    qWarning() << "ZXingQml::formatToString() unknown format";

    return QString();
}

ZXing::ImageFormat ZXingQml::qimageFormatToZXingFormat(const QImage &img)
{
    ZXing::ImageFormat format = ZXing::ImageFormat::None;

    switch (img.format())
    {
        case QImage::Format_RGB32:
        case QImage::Format_ARGB32:
        case QImage::Format_ARGB32_Premultiplied:
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
            format = ZXing::ImageFormat::BGRA; break;
#else
            format = ZXing::ImageFormat::ARGB; break;
#endif
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
            qWarning() << "ZXingQml::qimageFormatToZXingFormat() unknown format";
            break;
    }

    return format;
}

void ZXingQml::qvideoframeFormatToXZingFormat(const QVideoFrame &frame,
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
        pixStride = 2;
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
        pixOffset = 1;
#endif
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
        qDebug() << "ZXingQml::qvideoframeFormatToXZingFormat() unsupported format";
        break;

    default:
        qWarning() << "ZXingQml::qvideoframeFormatToXZingFormat() unknow format";
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

BarcodeQml ZXingQml::ReadBarcode(const QImage &image,
                                const ZXing::ReaderOptions &opts,
                                const QRect captureRect)
{
    auto res = ReadBarcodes(image, ZXing::ReaderOptions(opts).setMaxNumberOfSymbols(1), captureRect);
    return !res.isEmpty() ? res.takeFirst() : BarcodeQml();
}

BarcodeQml ZXingQml::ReadBarcode(const QVideoFrame &frame,
                                const ZXing::ReaderOptions &opts,
                                const QRect captureRect)
{
    auto res = ReadBarcodes(frame, ZXing::ReaderOptions(opts).setMaxNumberOfSymbols(1), captureRect);
    return !res.isEmpty() ? res.takeFirst() : BarcodeQml();
}

/* ************************************************************************** */

//! Read barcode from QImage
QList<BarcodeQml> ZXingQml::ReadBarcodes(const QImage &image,
                                        const ZXing::ReaderOptions &opts,
                                        const QRect captureRect)
{
    if (image.isNull())
    {
        qWarning() << "ZXingQml::ReadBarcodes(QImage) invalid QImage!";
        return {};
    }

    //qDebug() << ">>> ZXingQml::ReadBarcodes(QImage)";
    //qDebug() << "QImage geometry     :" << image.width() << "x" << image.height();
    //qDebug() << "QImage QPixelFormat :" << image.pixelFormat();
    //qDebug() << "ZXing ImageFormat   :" << (int)qimageFormatToZXingFormat(image);

    ZXing::ImageFormat format = qimageFormatToZXingFormat(image);
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
            qWarning() << "ZXingQml::ReadBarcodes(QImage) error: unable to convert to QImage";
        }
    }

    return {};
}

//! Read barcode from QVideoFrame DIRECTLY if possible, otherwise convert to QImage
QList<BarcodeQml> ZXingQml::ReadBarcodes(const QVideoFrame &frame,
                                        const ZXing::ReaderOptions &opts,
                                        const QRect captureRect)
{
    if (!frame.isValid())
    {
        qWarning() << "ZXingQml::ReadBarcodes(QVideoFrame) invalid QVideoFrame!";
        return {};
    }

    ZXing::ImageFormat format = ZXing::ImageFormat::None;
    int pixStride = 0;
    int pixOffset = 0;

    qvideoframeFormatToXZingFormat(frame, format, pixStride, pixOffset);

    //qDebug() << ">>> ZXingQml::ReadBarcodes(QVideoFrame)";
    //qDebug() << "QVideoFrame geometry    :" << frame.width() << "x" << frame.height() << "/" << frame.rotation();
    //qDebug() << "QVideoFrame PixelFormat :" << frame.pixelFormat();
    //qDebug() << "ZXing::ImageFormat       :" << (int)format;

    if (format != ZXing::ImageFormat::None)
    {
        // shallow copy just to get access to the non-const map() function
        auto frame_ro = frame;
        if (!frame_ro.map(QVideoFrame::ReadOnly))
        {
            qWarning() << "ZXingQml::ReadBarcodes(QVideoFrame) error: could not map QVideoFrame memory";
            return {};
        }
        QScopeGuard unmap([&] { frame_ro.unmap(); });

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
QList<BarcodeQml> ZXingQml::ReadBarcodes2(const QVideoFrame &frame,
                                         const ZXing::ReaderOptions &opts,
                                         const QRect captureRect)
{
    if (!frame.isValid())
    {
        qWarning() << "ZXingQml::ReadBarcodes2(QVideoFrame) invalid QVideoFrame!";
        return {};
    }

    //qDebug() << ">>> ZXingQml::ReadBarcodes2(QVideoFrame)";
    //qDebug() << "QVideoFrame geometry    :" << frame.width() << "x" << frame.height() << "/" << frame.rotation();
    //qDebug() << "QVideoFrame PixelFormat :" << frame.pixelFormat();

    QImage image = frame.toImage(); // .convertToFormat(QImage::Format_Grayscale8, Qt::MonoOnly);
    return ReadBarcodes(image, opts, captureRect);
}

/* ************************************************************************** */

QList<BarcodeQml> ZXingQml::loadImage(const QUrl &fileUrl)
{
    QString filepath = fileUrl.toLocalFile();
    QImage img(filepath);

    return ReadBarcodes(img);
}

QList<BarcodeQml> ZXingQml::loadImage(const QImage &img)
{
    return ReadBarcodes(img);
}

//! Build the CreatorOptions string
static std::string makeCreatorOptions(const int encoding, const int eccLevel)
{
    Q_UNUSED(encoding) // we only support ECC level ATM

    // from the app: (QR: 2/4/6/8 = L/M/Q/H) (Aztec/PDF417: 0..8)
    if (eccLevel >= 0 && eccLevel <= 8) return "ecLevel=" + std::to_string(eccLevel);

    return {};
}

QImage ZXingQml::generateImage(const QString &data, const int width, const int height, const int margins,
                              const int format, const int encoding, const int eccLevel,
                              const QColor backgroundColor, const QColor foregroundColor)
{
    try
    {
        const auto zformat = static_cast<ZXing::BarcodeFormat>(format);
        if (zformat == ZXing::BarcodeFormat::None)
        {
            qWarning() << "ZXingQml::generateImage() unsupported barcode format: this format is not writable by the zxing-cpp backend";
            return QImage();
        }

        ZXing::CreatorOptions copts(zformat, makeCreatorOptions(encoding, eccLevel));
        auto barcode = ZXing::CreateBarcodeFromText(data.toStdString(), copts);
        if (!barcode.isValid())
        {
            qWarning() << "ZXingQml::generateImage() failed to encode data";
            return QImage();
        }

        // Render the barcode at its natural aspect ratio, auto-scaled to fit
        // the requested size minus the margin we draw ourselves

        // The new writer API can only toggle a standard quiet zone on/off (addQuietZones),
        // so we add it here as a 'margins'-pixel border of background color
        const int border = qMax(0, margins);
        int targetPx = qMax(width, height) - 2 * border;
        if (targetPx < 16) targetPx = qMax(width, height); // margin too large for the target size

        auto wopts = ZXing::WriterOptions().scale(targetPx > 0 ? -targetPx : 4).addQuietZones(false);
        ZXing::Image img = ZXing::WriteBarcodeToImage(barcode, wopts);
        if (!img.data() || img.width() <= 0 || img.height() <= 0) return QImage();

        const QColor bgc = backgroundColor.isValid() ? backgroundColor : QColor(0, 0, 0, 0);
        const QColor fgc = foregroundColor.isValid() ? foregroundColor : QColor(0, 0, 0, 255);
        const QRgb fg = fgc.rgba();
        const QRgb bg = bgc.rgba();

        // Recolor (black modules -> foreground, white -> background)
        // into an image padded with a 'border'-pixel background margin on every side
        const int w = img.width();
        const int h = img.height();
        QImage image(w + 2 * border, h + 2 * border, QImage::Format_ARGB32);
        image.fill(bg);
        for (int y = 0; y < h; y++)
        {
            const uint8_t *s = img.data() + static_cast<qsizetype>(y) * w;
            QRgb *d = reinterpret_cast<QRgb *>(image.scanLine(y + border)) + border;
            for (int x = 0; x < w; x++) d[x] = (s[x] < 128) ? fg : bg;
        }

        return image;
    }
    catch (std::invalid_argument const &ex)
    {
        qWarning() << "ZXingQml::generateImage() invalid_argument:" << ex.what();
    }
    catch (...)
    {
        qWarning() << "ZXingQml::generateImage() error";
    }

    return QImage();
}

static QString getExternalFilesDirPath()
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

QString ZXingQml::shareImage(const QString &data, int width, int height, int margins,
                            const int format, const int encoding, const int eccLevel,
                            const QColor backgroundColor, const QColor foregroundColor)
                            //const QString exportFileDir)
{
    qDebug() << "ZXingQml::shareImage()";

    QString exportFilePath;

    // Get temp directory path (1)
    //QString exportDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    //QDir exportDirectory(exportDirectoryPath + "/export");
    //if (!exportDirectory.exists()) exportDirectory.mkpath(exportDirectoryPath + "/export");

    // Get temp directory path (2)
    QString exportDirectoryPath = getExternalFilesDirPath();
    if (exportDirectoryPath.isEmpty()) exportDirectoryPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    if (exportDirectoryPath.isEmpty()) return QString();
    QDir exportDirectory(exportDirectoryPath);
    if (!exportDirectory.exists()) exportDirectory.mkpath(exportDirectoryPath);

    // Get temp file path
    exportFilePath = exportDirectoryPath + "/barcode.png";

    if (saveImage(data, width, height, margins, format, encoding, eccLevel,
                  backgroundColor, foregroundColor, QUrl::fromLocalFile(exportFilePath)))
    {
        QFileInfo saveFileInfo(exportFilePath);
        qDebug() << "saveFileInfo " << saveFileInfo << ")";
        qDebug() << "saveFileInfo e " << saveFileInfo.exists() << ")";

        return exportFilePath;
    }

    return QString();
}

bool ZXingQml::saveImage(const QString &data, int width, int height, int margins,
                        const int format, const int encoding, const int eccLevel,
                        const QColor backgroundColor, const QColor foregroundColor,
                        const QUrl &fileurl)
{
    qDebug() << "ZXingQml::saveImage(" << data << fileurl << ")";
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
        // Vector output, rendered by the library (replaces the old hand-rolled SVG path).
        QFile efile(filepath);
        if (efile.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            try
            {
                const auto zformat = static_cast<ZXing::BarcodeFormat>(format);
                if (zformat == ZXing::BarcodeFormat::None)
                {
                    qWarning() << "ZXingQml::saveImage() unsupported barcode format: this format is not writable by the zxing-cpp backend";
                }
                else
                {
                    ZXing::CreatorOptions copts(zformat, makeCreatorOptions(encoding, eccLevel));
                    auto barcode = ZXing::CreateBarcodeFromText(data.toStdString(), copts);
                    if (barcode.isValid())
                    {
                        std::string svg = ZXing::WriteBarcodeToSVG(barcode, ZXing::WriterOptions().addQuietZones(margins > 0));

                        QTextStream eout(&efile);
                        eout << QString::fromStdString(svg);
                        status = true;
                    }
                    else
                    {
                        qWarning() << "ZXingQml::saveImage(svg) failed to encode data";
                    }
                }
            }
            catch (...)
            {
                qWarning() << "ZXingQml::saveImage(svg) unknown ERROR";
            }

            efile.close();
        }
    }
    else if (saveFileInfo.suffix() == "bmp" || saveFileInfo.suffix() == "png" ||
             saveFileInfo.suffix() == "jpg" || saveFileInfo.suffix() == "jpeg" ||
             saveFileInfo.suffix() == "webp")
    {
        // The library renders the barcode at its natural aspect ratio, so no 1D height tweak here.
        QImage img = generateImage(data, width, height, margins,
                                   format, encoding, eccLevel,
                                   backgroundColor, foregroundColor);

        status = img.save(filepath, saveFileInfo.suffix().toStdString().c_str(), -1);
    }
    else
    {
        qWarning() << "ZXingQml::saveImage() unknown format ERROR:" << saveFileInfo.suffix();
    }

    return status;
}

/* ************************************************************************** */
