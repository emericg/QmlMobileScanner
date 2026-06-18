/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2024 Emeric Grange
 */

#include "ZXingQtVideoFilter.h"

#include <QtConcurrent>
#include <QElapsedTimer>
#include <QImage>
#include <QDebug>

ZXingQtVideoFilter::ZXingQtVideoFilter(QObject *parent) : QObject(parent)
{
    m_readerOptions.setMinLineCount(4); // default is 2
    m_readerOptions.setMaxNumberOfSymbols(4); // default is 255
    m_readerOptions.setFormats(ZXing::BarcodeFormat::AllReadable); // default is
    m_readerOptions.setTextMode(ZXing::TextMode::HRI); // default is
    //m_readerOptions.setBinarizer(ZXing::Binarizer::GlobalHistogram); // default is LocalAverage
}

ZXingQtVideoFilter::~ZXingQtVideoFilter()
{
    stopFilter();
}

void ZXingQtVideoFilter::stopFilter()
{
    if (!m_processThread.isFinished())
    {
        m_processThread.cancel();
        m_processThread.waitForFinished();
    }

    m_active = false;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);
}

void ZXingQtVideoFilter::setVideoSink(QVideoSink *sink)
{
    if (!sink) return;
    if (m_videoSink == sink) return;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);

    m_active = true;

    m_videoSink = qobject_cast<QVideoSink*>(sink);

    connect(m_videoSink, &QVideoSink::videoFrameChanged,
            this, &ZXingQtVideoFilter::process,
            Qt::QueuedConnection);
}

void ZXingQtVideoFilter::setTryHarder(const bool value)
{
    if (m_readerOptions.tryHarder() != value)
    {
        m_readerOptions.setTryHarder(value);
        emit tryHarderChanged();
    }
}

void ZXingQtVideoFilter::setTryRotate(const bool value)
{
    if (m_readerOptions.tryRotate() != value)
    {
        m_readerOptions.setTryRotate(value);
        emit tryRotateChanged();
    }
}

void ZXingQtVideoFilter::setTryInvert(const bool value)
{
    if (m_readerOptions.tryInvert() != value)
    {
        m_readerOptions.setTryInvert(value);
        emit tryInvertChanged();
    }
}

void ZXingQtVideoFilter::setTryDownscale(const bool value)
{
    if (m_readerOptions.tryDownscale() != value)
    {
        m_readerOptions.setTryDownscale(value);
        emit tryDownscaleChanged();
    }
}
static ZXing::BarcodeFormats appBitmaskToZXingFormats(int bitmask)
{
    using AF = ZXingQt::BarcodeFormat; // app flags (legacy layout, canonical)
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

int ZXingQtVideoFilter::formats() const noexcept
{
    return m_formats;
}

void ZXingQtVideoFilter::setFormats(int newVal)
{
    if (m_formats != newVal)
    {
        m_formats = newVal;
        m_readerOptions.setFormats(appBitmaskToZXingFormats(newVal));
        emit formatsChanged();
    }
}

void ZXingQtVideoFilter::setCaptureRect(const QRect &captureRect)
{
    if (captureRect == m_captureRect) return;

    m_captureRect = captureRect;
    emit captureRectChanged();
}

BarcodeQml ZXingQtVideoFilter::process(const QVideoFrame &frame)
{
    if (m_active && m_videoSink && m_processThread.isFinished())
    {
        //qWarning() << ">>> ZXingQtVideoFilter::process() >>> surfaceFormat > " << frame.surfaceFormat() << " > rotation > " << frame.rotationAngle();

        m_processThread = QtConcurrent::run([=, this]() {
            QElapsedTimer t;
            t.start();

            auto results = ZXingQt::ReadBarcodes2(frame, m_readerOptions, m_captureRect);

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
                    qWarning() << ">>> ZXingQtVideoFilter::process() >>> INVALID RESULTS";
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
