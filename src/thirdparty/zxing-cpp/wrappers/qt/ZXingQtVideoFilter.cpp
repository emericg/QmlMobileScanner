/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingQtVideoFilter.h"

#include "ReadBarcode.h"
#include "BarcodeFormat.h"

#include <QtConcurrent>
#include <QScopeGuard>
#include <QMetaType>
#include <QImage>
#include <QDebug>

namespace ZXingQt {
/*
template<typename T, typename = decltype(ZXing::ToString(T()))>
QDebug operator<<(QDebug dbg, const T& v)
{
    return dbg.noquote() << QString::fromStdString(ToString(v));
}
*/
inline QList<Result> QListResults(ZXing::Results&& zxres)
{
    QList<Result> res;
    for (auto &&r : zxres)
    {
        res.push_back(Result(std::move(r)));
    }

    return res;
}

inline QList<Result> ReadBarcodes(const QImage &img, const DecodeHints &hints = {})
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
        return QListResults(ZXing::ReadBarcodes( {img.bits(), img.width(), img.height(),
                                                  ImgFmtFromQImg(img), static_cast<int>(img.bytesPerLine())}, hints));
    };

    return ImgFmtFromQImg(img) == ZXing::ImageFormat::None ? exec(img.convertToFormat(QImage::Format_Grayscale8)) : exec(img);
}

inline Result ReadBarcode(const QImage &img, const DecodeHints &hints = {})
{
    auto res = ReadBarcodes(img, DecodeHints(hints).setMaxNumberOfSymbols(1));
    return !res.isEmpty() ? res.takeFirst() : Result();
}

inline QList<Result> ReadBarcodes(const QVideoFrame &frame, const DecodeHints &hints = {}, const QRect captureRect = QRect())
{
    auto img = frame; // shallow copy just get access to non-const map() function
    if (!frame.isValid() || !img.map(QVideoFrame::ReadOnly))
    {
        qWarning() << "invalid QVideoFrame: could not map memory";
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

inline Result ReadBarcode(const QVideoFrame &frame, const DecodeHints &hints = {}, const QRect captureRect = QRect())
{
    auto res = ReadBarcodes(frame, DecodeHints(hints).setMaxNumberOfSymbols(1), captureRect);
    return !res.isEmpty() ? res.takeFirst() : Result();
}

ZXingQtVideoFilter::ZXingQtVideoFilter(QObject *parent) : QObject(parent)
{
    m_decodeHints.setMinLineCount(3); // default is 2
    m_decodeHints.setMaxNumberOfSymbols(4); // default is 255
}

ZXingQtVideoFilter::~ZXingQtVideoFilter()
{
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);
}

ZXingQt::Result ZXingQtVideoFilter::process(const QVideoFrame &frame)
{
    if (m_active && !m_decoding && m_processThread.isFinished() &&
        (!m_processTimer.isValid() || m_processTimer.elapsed() >= 10))
    {
        m_decoding = true;
        //qDebug() << "Decoding : Time between last decode : " << m_processTimer.elapsed();

        m_processThread = QtConcurrent::run([=]() {

            QElapsedTimer t;
            t.start();

            QImage image = frame.toImage(); // moved here, from outside the QtConcurrent::run()
            if (image.isNull())
            {
                qWarning() << "ZXingQtVideoFilter error: Cant create image file to process.";
                m_decoding = false;
                m_processTimer.restart();
                return ZXingQt::Result();;
            }

            QImage frameToProcess(image);
            if (m_captureRect.isValid() && frameToProcess.size() != m_captureRect.size())
            {
                frameToProcess = image.copy(m_captureRect);
            }

            auto results = ReadBarcodes(frameToProcess, m_decodeHints);
            for (auto &r: results) {
                //qDebug() << "+ barcode " << ZXing::ToString(r.format()) << ": " << r.text();

                if (r.isValid() && m_active) {
                    r.runTime = t.elapsed();
                    emit tagFound(r);
                }
            }

            m_decoding = false;
            m_processTimer.restart();

            if (results.size())
            {
                results.first().runTime = t.elapsed();
                emit decodingFinished(results.first());
                return results.first();
            }
            else
            {
                ZXingQt::Result r;
                r.runTime = t.elapsed();
                emit decodingFinished(r);
                return r;
            }
        });
    }

    return ZXingQt::Result();
}

void ZXingQtVideoFilter::setTryHarder(const bool value)
{
    if (m_decodeHints.tryHarder() != value)
    {
        m_decodeHints.setTryHarder(value);
        emit tryHarderChanged();
    }
}

void ZXingQtVideoFilter::setTryRotate(const bool value)
{
    if (m_decodeHints.tryRotate() != value)
    {
        m_decodeHints.setTryRotate(value);
        emit tryRotateChanged();
    }
}

void ZXingQtVideoFilter::setTryInvert(const bool value)
{
    if (m_decodeHints.tryInvert() != value)
    {
        m_decodeHints.setTryInvert(value);
        emit tryInvertChanged();
    }
}

void ZXingQtVideoFilter::setTryDownscale(const bool value)
{
    if (m_decodeHints.tryDownscale() != value)
    {
        m_decodeHints.setTryDownscale(value);
        emit tryDownscaleChanged();
    }
}

int ZXingQtVideoFilter::formats() const noexcept
{
    auto fmts = m_decodeHints.formats();
    return *reinterpret_cast<int*>(&fmts);
}

void ZXingQtVideoFilter::setFormats(int newVal)
{
    if (formats() != newVal)
    {
        m_decodeHints.setFormats(static_cast<ZXing::BarcodeFormat>(newVal));
        emit formatsChanged();
    }
}

void ZXingQtVideoFilter::setCaptureRect(const QRect &captureRect)
{
    if (captureRect == m_captureRect) return;

    m_captureRect = captureRect;
    emit captureRectChanged();
}

void ZXingQtVideoFilter::setVideoSink(QVideoSink *sink)
{
    if (m_videoSink == sink) return;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);

    m_videoSink = qobject_cast<QVideoSink*>(sink);

    m_active = true;
    connect(m_videoSink, &QVideoSink::videoFrameChanged,
            this, &ZXingQtVideoFilter::process,
            Qt::DirectConnection);
}

void ZXingQtVideoFilter::stopFilter()
{
    m_active = false;
    disconnect(m_videoSink, nullptr, this, nullptr);
}

} // namespace ZXingQt
