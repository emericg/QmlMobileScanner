/*
 * Copyright 2017 QZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef QZXingFilter_H
#define QZXingFilter_H

#include "QZXing.h"

#include <QObject>
#include <QRect>
#include <QVideoSink>
#include <QVideoFrame>
#include <QFuture>

/// Video filter is the filter that has to be registered in C++, instantiated and attached in QML
class QZXingFilter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVideoSink *videoSink MEMBER m_videoSink WRITE setVideoSink)
    Q_PROPERTY(QZXing *decoder READ getDecoder CONSTANT)

    Q_PROPERTY(QRect captureRect READ captureRect WRITE setCaptureRect NOTIFY captureRectChanged)
    Q_PROPERTY(int orientation READ orientation WRITE setOrientation NOTIFY orientationChanged)

    bool m_active = false;
    QFuture <void> m_processThread;

    QZXing m_decoder = QZXing::DecoderFormat_QR_CODE;
    QZXing *getDecoder() { return &m_decoder; }

    QRect m_captureRect;
    int m_orientation = 0;

    QVideoSink *m_videoSink = nullptr;
    void setVideoSink(QObject *sink);

signals:
    void captureRectChanged();
    void orientationChanged(int orientation);

    void decodingStarted();
    void decodingFinished(bool succeeded, int decodeTime);

private slots:
    void handleDecodingStarted();
    void handleDecodingFinished(bool succeeded);
    void processFrame(const QVideoFrame &frame);

public:
    QZXingFilter(QObject *parent = nullptr);
    virtual ~QZXingFilter();

    Q_INVOKABLE void stopFilter();

    // capture rectangle
    QRect captureRect() const { return m_captureRect; }
    void setCaptureRect(const QRect &captureRect);

    // capture orientation
    void setOrientation(int orientation);
    int orientation() const { return m_orientation; };
};

#endif // QZXingFilter_H
