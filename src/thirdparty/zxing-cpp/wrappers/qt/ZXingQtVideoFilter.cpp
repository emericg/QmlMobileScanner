/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#include "ZXingQtVideoFilter.h"

#include <QtConcurrent>
#include <QElapsedTimer>
#include <QImage>
#include <QDebug>

ZXingQtVideoFilter::ZXingQtVideoFilter(QObject *parent) : QObject(parent)
{
    m_decodeHints.setMinLineCount(3); // default is 2
    m_decodeHints.setMaxNumberOfSymbols(4); // default is 255
}

ZXingQtVideoFilter::~ZXingQtVideoFilter()
{
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);
}

void ZXingQtVideoFilter::stopFilter()
{
    m_active = false;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);
}

Result ZXingQtVideoFilter::process(const QVideoFrame &frame)
{
    if (m_active && !m_decoding && m_processThread.isFinished())
    {
        //qDebug() << "Decoding : Time between last decode : " << m_processTimer.elapsed();

        m_decoding = true;
        m_processThread = QtConcurrent::run([=]() {
            QElapsedTimer t;
            t.start();

            QImage image = frame.toImage(); // moved here, from outside the QtConcurrent::run()
            if (image.isNull())
            {
                qWarning() << "ZXingQtVideoFilter error: Cant create image file to process.";
                m_decoding = false;
                return Result();
            }

            QImage imageToProcess(image);
            if (m_captureRect.isValid() && imageToProcess.size() != m_captureRect.size())
            {
                imageToProcess = image.copy(m_captureRect);
            }

            auto results = ZXingQt::ReadBarcodes(imageToProcess, m_decodeHints);
            //auto results = ZXingQt::ReadBarcodes(frame, m_decodeHints, m_captureRect);

            for (auto &r: results)
            {
                //qDebug() << "+ barcode " << ZXing::ToString(r.format()) << ": " << r.text();

                if (r.isValid() && m_active)
                {
                    r.runTime = t.elapsed();
                    emit tagFound(r);
                }
            }

            m_decoding = false;

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
