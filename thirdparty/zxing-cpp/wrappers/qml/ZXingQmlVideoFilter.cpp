/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2026 Emeric Grange
 */

#include "ZXingQmlVideoFilter.h"

#include <QtConcurrent>
#include <QElapsedTimer>
#include <QImage>
#include <QDebug>
#include <QTransform>

ZXingQmlVideoFilter::ZXingQmlVideoFilter(QObject *parent) : QObject(parent)
{
    m_readerOptions.setMinLineCount(4); // default is 2
    m_readerOptions.setMaxNumberOfSymbols(4); // default is 255
    m_readerOptions.setFormats(ZXing::BarcodeFormat::AllReadable); // default is
    m_readerOptions.setTextMode(ZXing::TextMode::HRI); // default is
    //m_readerOptions.setBinarizer(ZXing::Binarizer::GlobalHistogram); // default is LocalAverage
}

ZXingQmlVideoFilter::~ZXingQmlVideoFilter()
{
    stopFilter();
}

void ZXingQmlVideoFilter::stopFilter()
{
    if (!m_processThread.isFinished())
    {
        m_processThread.cancel();
        m_processThread.waitForFinished();
    }

    m_active = false;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);
}

void ZXingQmlVideoFilter::setVideoSink(QVideoSink *sink)
{
    // setting the same sink again restarts a stopped filter
    if (m_videoSink == sink && m_active) return;
    const bool changed = (m_videoSink != sink);

    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);

    m_videoSink = sink;
    m_active = (m_videoSink != nullptr);

    if (m_videoSink)
    {
        connect(m_videoSink, &QVideoSink::videoFrameChanged,
                this, &ZXingQmlVideoFilter::process,
                Qt::QueuedConnection);
    }

    if (changed) emit videoSinkChanged();
}

void ZXingQmlVideoFilter::setTryHarder(const bool value)
{
    if (m_readerOptions.tryHarder() != value)
    {
        m_readerOptions.setTryHarder(value);
        emit tryHarderChanged();
    }
}

void ZXingQmlVideoFilter::setTryRotate(const bool value)
{
    if (m_readerOptions.tryRotate() != value)
    {
        m_readerOptions.setTryRotate(value);
        emit tryRotateChanged();
    }
}

void ZXingQmlVideoFilter::setTryInvert(const bool value)
{
    if (m_readerOptions.tryInvert() != value)
    {
        m_readerOptions.setTryInvert(value);
        emit tryInvertChanged();
    }
}

void ZXingQmlVideoFilter::setTryDownscale(const bool value)
{
    if (m_readerOptions.tryDownscale() != value)
    {
        m_readerOptions.setTryDownscale(value);
        emit tryDownscaleChanged();
    }
}

static ZXing::BarcodeFormats appBitmaskToZXingFormats(int bitmask)
{
    using AF = ZXingQml::BarcodeFormat; // app flags (legacy layout, canonical)
    using ZF = ZXing::BarcodeFormat;   // library enum (ID based)

    static const struct { AF bit; ZF zx; } s_map[] = {
        { AF::Aztec,           ZF::Aztec },
        { AF::Codabar,         ZF::Codabar },
        { AF::Code39,          ZF::Code39 },
        { AF::Code93,          ZF::Code93 },
        { AF::Code128,         ZF::Code128 },
        { AF::DataBar,         ZF::DataBar },
        { AF::DataBarExpanded, ZF::DataBarExp },
        { AF::DataMatrix,      ZF::DataMatrix },
        { AF::EAN8,            ZF::EAN8 },
        { AF::EAN13,           ZF::EAN13 },
        { AF::ITF,             ZF::ITF },
        { AF::MaxiCode,        ZF::MaxiCode },
        { AF::PDF417,          ZF::PDF417 },
        { AF::QRCode,          ZF::QRCode },
        { AF::UPCA,            ZF::UPCA },
        { AF::UPCE,            ZF::UPCE },
        { AF::MicroQRCode,     ZF::MicroQRCode },
        { AF::RMQRCode,        ZF::RMQRCode },
        { AF::DataBarLimited,  ZF::DataBarLtd },
        { AF::DXFilmEdge,      ZF::DXFilmEdge },
    };

    std::vector<ZF> formats;
    for (const auto &m : s_map)
    {
        if (bitmask & static_cast<int>(m.bit)) formats.push_back(m.zx);
    }

    return ZXing::BarcodeFormats(std::move(formats));
}

int ZXingQmlVideoFilter::formats() const noexcept
{
    return m_formats;
}

void ZXingQmlVideoFilter::setFormats(int newVal)
{
    if (m_formats != newVal)
    {
        m_formats = newVal;
        m_readerOptions.setFormats(appBitmaskToZXingFormats(newVal));
        emit formatsChanged();
    }
}

void ZXingQmlVideoFilter::setOrientation(int orientation)
{
    if (orientation % 90 != 0)
    {
        qWarning() << "ZXingQmlVideoFilter::setOrientation() unsupported orientation:" << orientation;
        return;
    }
    if (orientation == m_orientation) return;

    m_orientation = orientation;
    emit orientationChanged();
}

void ZXingQmlVideoFilter::setMirrored(bool mirrored)
{
    if (mirrored == m_mirrored) return;

    m_mirrored = mirrored;
    emit mirroredChanged();
}

void ZXingQmlVideoFilter::setCaptureRect_normalized(const QRectF &captureRect_normalized)
{
    m_captureRect_pixel = QRect();

    if (captureRect_normalized == m_captureRect_normalized) return;

    m_captureRect_normalized = captureRect_normalized;
    emit captureRectChanged();
}

void ZXingQmlVideoFilter::setCaptureRect_pixel(const QRect &captureRect_pixel)
{
    m_captureRect_pixel = captureRect_pixel;

    if (m_captureRect_normalized == QRectF()) return;

    m_captureRect_normalized = QRectF();
    emit captureRectChanged();
}

/*!
 * \brief Clockwise rotation, in normalized coordinates.
 * \param degrees: the rotation angle, a multiple of 90 degrees.
 * \return the rotation of the unit square onto itself.
 */
static QTransform normalizedRotation(int degrees)
{
    switch (((degrees % 360) + 360) % 360)
    {
        case 90: return QTransform(0, 1, -1, 0, 1, 0);
        case 180: return QTransform(-1, 0, 0, -1, 1, 1);
        case 270: return QTransform(0, -1, 1, 0, 0, 1);
        default: return QTransform();
    }
}

/*!
 * \brief Compute the transformation applied to QVideoFrame::toImage() for display.
 * \param frame: the video frame.
 * \param orientation: the VideoOutput orientation, in degrees.
 * \param mirrored: the VideoOutput mirrored state.
 * \return transformation from normalized toImage() coordinates to normalized displayed coordinates.
 *
 * toImage() only applies the surface format transformation,
 * the frame own rotation() and mirrored() are applied for presentation only.
 * Same as Qt's qNormalizedFrameTransformation(): frame clockwise rotation, then horizontal mirroring,
 * then VideoOutput clockwise rotation, then horizontal mirroring.
 */
static QTransform frameDisplayTransform(const QVideoFrame &frame, int orientation, bool mirrored)
{
    const QTransform mirror(-1, 0, 0, 1, 1, 0);

    QTransform transform = normalizedRotation(qToUnderlying(frame.rotation()));
    if (frame.mirrored()) transform *= mirror;
    transform *= normalizedRotation(orientation);
    if (mirrored) transform *= mirror;

    return transform;
}

/*!
 * \brief Read barcodes from a video frame, and compute their normalized positions.
 * \param frame: the video frame.
 * \param opts: the reader options.
 * \param captureRect_normalized: capture rectangle, in normalized displayed coordinates.
 * \param captureRect_pixel: capture rectangle, in toImage() pixel coordinates.
 * \param orientation: the VideoOutput orientation, in degrees.
 * \param mirrored: the VideoOutput mirrored state.
 *
 * At most one of the capture rectangles is set, both empty means the whole frame.
 * \return the barcodes found.
 */
static QList<BarcodeQml> readFrame(const QVideoFrame &frame, const ZXing::ReaderOptions &opts,
                                   const QRectF &captureRect_normalized, QRect captureRect_pixel,
                                   int orientation, bool mirrored)
{
    const QImage image = frame.toImage();
    if (image.isNull()) return {};

    const QTransform toDisplay = frameDisplayTransform(frame, orientation, mirrored);
    const qreal w = image.width();
    const qreal h = image.height();

    if (!captureRect_normalized.isEmpty())
    {
        const QRectF r = toDisplay.inverted().mapRect(captureRect_normalized & QRectF(0, 0, 1, 1));
        captureRect_pixel = QRectF(r.x() * w, r.y() * h, r.width() * w, r.height() * h).toRect();
        if (captureRect_pixel.isEmpty()) return {};
    }

    auto results = ZXingQml::ReadBarcodes(image, opts, captureRect_pixel);

    // map pixel centers
    const auto map = [&](const QPoint &p) {
        return toDisplay.map(QPointF((p.x() + 0.5) / w, (p.y() + 0.5) / h));
    };

    for (auto &r : results)
    {
        const auto &pos = r.positionPixels();
        r.setPositionNormalized({map(pos.topLeft()), map(pos.topRight()),
                                 map(pos.bottomRight()), map(pos.bottomLeft())});
    }

    return results;
}

BarcodeQml ZXingQmlVideoFilter::process(const QVideoFrame &frame)
{
    if (m_active && m_videoSink && m_processThread.isFinished())
    {
        //qWarning() << ">>> ZXingQmlVideoFilter::process() >>> surfaceFormat > " << frame.surfaceFormat() << " > rotation > " << frame.rotationAngle();

        m_processThread = QtConcurrent::run([this, frame, opts = m_readerOptions,
                                             rectN = m_captureRect_normalized, rectP = m_captureRect_pixel,
                                             orientation = m_orientation, mirrored = m_mirrored]() {
            QElapsedTimer t;
            t.start();

            auto results = readFrame(frame, opts, rectN, rectP, orientation, mirrored);

            for (auto &r: results)
            {
                //qDebug() << "+ barcode " << ZXing::ToString(r.format()) << ": " << r.text();

                if (r.isValid())
                {
                    r.runTime = t.elapsed();
                    emit tagFound(r);
                }
                else
                {
                    qWarning() << ">>> ZXingQmlVideoFilter::process() >>> INVALID RESULTS";
                }
            }

            if (results.size())
            {
                results.first().runTime = t.elapsed();
                emit decodingFinished(results.first());
                return results.first();
            }
            else
            {
                BarcodeQml r;
                r.runTime = t.elapsed();
                emit decodingFinished(r);
                return r;
            }
        });
    }

    return BarcodeQml();
}
