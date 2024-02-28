/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingCppVideoFilter.h"

#include <QtConcurrent>
#include <QElapsedTimer>
#include <QImage>
#include <QDebug>

ZXingCppVideoFilter::ZXingCppVideoFilter(QObject *parent) : QObject(parent)
{
    m_readerOptions.setMinLineCount(4); // default is 2
    m_readerOptions.setMaxNumberOfSymbols(4); // default is 255
    //m_readerOptions.setBinarizer(ZXing::Binarizer::GlobalHistogram); // default is LocalAverage
}

ZXingCppVideoFilter::~ZXingCppVideoFilter()
{
    stopFilter();
}

void ZXingCppVideoFilter::stopFilter()
{
    if (!m_processThread.isFinished())
    {
        m_processThread.cancel();
        m_processThread.waitForFinished();
    }

    m_active = false;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);
}

void ZXingCppVideoFilter::setVideoSink(QVideoSink *sink)
{
    if (!sink) return;
    if (m_videoSink == sink) return;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);

    m_active = true;

    m_videoSink = qobject_cast<QVideoSink*>(sink);

    connect(m_videoSink, &QVideoSink::videoFrameChanged,
            this, &ZXingCppVideoFilter::process,
            Qt::QueuedConnection);
}

void ZXingCppVideoFilter::setTryHarder(const bool value)
{
    if (m_readerOptions.tryHarder() != value)
    {
        m_readerOptions.setTryHarder(value);
        emit tryHarderChanged();
    }
}

void ZXingCppVideoFilter::setTryRotate(const bool value)
{
    if (m_readerOptions.tryRotate() != value)
    {
        m_readerOptions.setTryRotate(value);
        emit tryRotateChanged();
    }
}

void ZXingCppVideoFilter::setTryInvert(const bool value)
{
    if (m_readerOptions.tryInvert() != value)
    {
        m_readerOptions.setTryInvert(value);
        emit tryInvertChanged();
    }
}

void ZXingCppVideoFilter::setTryDownscale(const bool value)
{
    if (m_readerOptions.tryDownscale() != value)
    {
        m_readerOptions.setTryDownscale(value);
        emit tryDownscaleChanged();
    }
}

int ZXingCppVideoFilter::formats() const noexcept
{
    auto fmts = m_readerOptions.formats();
    return *reinterpret_cast<int*>(&fmts);
}

void ZXingCppVideoFilter::setFormats(int newVal)
{
    if (formats() != newVal)
    {
        m_readerOptions.setFormats(static_cast<ZXing::BarcodeFormat>(newVal));
        emit formatsChanged();
    }
}

void ZXingCppVideoFilter::setCaptureRect(const QRect &captureRect)
{
    if (captureRect == m_captureRect) return;

    m_captureRect = captureRect;
    emit captureRectChanged();
}

Result ZXingCppVideoFilter::process(const QVideoFrame &frame)
{
    if (m_active && m_videoSink && m_processThread.isFinished())
    {
        //qWarning() << ">>> ZXingCppVideoFilter::process() >>> surfaceFormat > " << frame.surfaceFormat() << " > rotation > " << frame.rotationAngle();

        m_processThread = QtConcurrent::run([=, this]() {
            QElapsedTimer t;
            t.start();

            auto results = ZXingCpp::ReadBarcodes2(frame, m_readerOptions, m_captureRect);

            for (auto &r: results)
            {
                //qDebug() << "+ barcode " << ZXing::ToString(r.format()) << ": " << r.text();

                if (r.isValid())
                {
                    r.runTime = t.elapsed();
                    emit tagFound(r);
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
                Result r;
                r.runTime = t.elapsed();
                emit decodingFinished(r);
                return r;
            }
        });
    }

    return Result();
}
