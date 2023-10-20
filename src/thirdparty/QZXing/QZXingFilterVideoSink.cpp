#include "QZXingFilterVideoSink.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrent>

QZXingFilter::QZXingFilter(QObject *parent) : QObject(parent)
{
    /// Connecting signals to handlers that will send signals to QML
    connect(&m_decoder, &QZXing::decodingStarted,
            this, &QZXingFilter::handleDecodingStarted);
    connect(&m_decoder, &QZXing::decodingFinished,
            this, &QZXingFilter::handleDecodingFinished);
}

QZXingFilter::~QZXingFilter()
{
    if(!m_processThread.isFinished())
    {
        m_processThread.cancel();
        m_processThread.waitForFinished();
    }
}

void QZXingFilter::handleDecodingStarted()
{
    m_decoding = true;
    emit decodingStarted();
    emit isDecodingChanged();
}

void QZXingFilter::handleDecodingFinished(bool succeeded)
{
    m_decoding = false;
    emit decodingFinished(succeeded, m_decoder.getProcessTimeOfLastDecoding());
    emit isDecodingChanged();
}

void QZXingFilter::setOrientation(int orientation)
{
    if (m_orientation == orientation)
    {
        return;
    }

    m_orientation = orientation;
    emit orientationChanged(m_orientation);
}

void QZXingFilter::setVideoSink(QObject *videoSink)
{
    m_videoSink = qobject_cast<QVideoSink*>(videoSink);

    connect(m_videoSink, &QVideoSink::videoFrameChanged,
            this, &QZXingFilter::processFrame,
            Qt::DirectConnection);
}

void QZXingFilter::processFrame(const QVideoFrame &frame)
{
    if (!isDecoding() && m_processThread.isFinished())
    {
        m_decoding = true;

        m_processThread = QtConcurrent::run([=]() {

            QImage image = frame.toImage(); // moved here, from outside the QtConcurrent::run()
            if (image.isNull())
            {
                qWarning() << "QZXingFilter error: Cant create image file to process.";
                m_decoding = false;
                return;
            }

            QImage frameToProcess(image);
            const QRect &rect = m_captureRect.toRect();

            if (m_captureRect.isValid() && frameToProcess.size() != rect.size())
            {
                frameToProcess = image.copy(rect);
            }

            if (!m_orientation)
            {
                m_decoder.decodeImage(frameToProcess); //, frameToProcess.width(), frameToProcess.height());
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
