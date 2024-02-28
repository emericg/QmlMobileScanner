#include "QZXingFilterVideoSink.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrent>

QZXingFilter::QZXingFilter(QObject *parent) : QObject(parent)
{
    connect(&m_decoder, &QZXing::decodingStarted, this, &QZXingFilter::handleDecodingStarted);
    connect(&m_decoder, &QZXing::decodingFinished, this, &QZXingFilter::handleDecodingFinished);
}

QZXingFilter::~QZXingFilter()
{
    stopFilter();
}

void QZXingFilter::stopFilter()
{
    if (!m_processThread.isFinished())
    {
        m_processThread.cancel();
        m_processThread.waitForFinished();
    }

    m_active = false;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);
}

void QZXingFilter::setVideoSink(QObject *sink)
{
    if (!sink) return;
    if (m_videoSink == sink) return;
    if (m_videoSink) disconnect(m_videoSink, nullptr, this, nullptr);

    m_active = true;

    m_videoSink = qobject_cast<QVideoSink*>(sink);

    connect(m_videoSink, &QVideoSink::videoFrameChanged,
            this, &QZXingFilter::processFrame,
            Qt::QueuedConnection);
}

void QZXingFilter::setCaptureRect(const QRect &captureRect)
{
    if (captureRect == m_captureRect) return;

    m_captureRect = captureRect;
    emit captureRectChanged();
}


void QZXingFilter::setOrientation(int orientation)
{
    if (m_orientation == orientation) return;

    m_orientation = orientation;
    emit orientationChanged(m_orientation);
}

void QZXingFilter::handleDecodingStarted()
{
    emit decodingStarted();
}

void QZXingFilter::handleDecodingFinished(bool succeeded)
{
    emit decodingFinished(succeeded, m_decoder.getProcessTimeOfLastDecoding());
}

void QZXingFilter::processFrame(const QVideoFrame &frame)
{
    if (m_decoder.getEnabledFormats() == QZXing::DecoderFormat_None) return;

    if (m_active && m_videoSink && m_processThread.isFinished())
    {
        //qWarning() << ">>> QZXingFilter::process() >>> surfaceFormat > " << frame.surfaceFormat() << " > rotation > " << frame.rotationAngle();

        m_processThread = QtConcurrent::run([=, this]() {
            QImage image = frame.toImage(); // moved here, from outside the QtConcurrent::run()
            if (image.isNull())
            {
                qWarning() << "QZXingFilter error: Cant create image file to process.";
                return;
            }

            QImage frameToProcess(image);

            if (m_captureRect.isValid() && frameToProcess.size() != m_captureRect.size())
            {
                frameToProcess = image.copy(m_captureRect);
            }

            if (!m_orientation)
            {
                m_decoder.decodeImage(frameToProcess/*, frameToProcess.width(), frameToProcess.height()*/);
            }
            else
            {
                QTransform transformation;
                transformation.translate(frameToProcess.rect().center().x(), frameToProcess.rect().center().y());
                transformation.rotate(-m_orientation);

                QImage translatedImage = frameToProcess.transformed(transformation);

                m_decoder.decodeImage(translatedImage);
            }
        });
    }
}
