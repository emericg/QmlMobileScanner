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
#include <QFuture>
#include <QRect>
#include <QVideoSink>
#include <QVideoFrame>

/// Video filter is the filter that has to be registered in C++, instantiated and attached in QML
class QZXingFilter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool decoding READ isDecoding NOTIFY isDecodingChanged)
    Q_PROPERTY(QZXing *decoder READ getDecoder)
    Q_PROPERTY(QRectF captureRect MEMBER m_captureRect NOTIFY captureRectChanged)
    Q_PROPERTY(QObject *videoSink MEMBER m_videoSink WRITE setVideoSink)
    Q_PROPERTY(int orientation READ orientation WRITE setOrientation NOTIFY orientationChanged)

    QZXing m_decoder = QZXing::DecoderFormat_QR_CODE;
    bool m_decoding = false;

    QRectF m_captureRect;
    int m_orientation = 0;

    QVideoSink *m_videoSink = nullptr;
    QFuture<void> m_processThread;

signals:
    void isDecodingChanged();
    void decodingFinished(bool succeeded, int decodeTime);
    void decodingStarted();
    void captureRectChanged();
    void orientationChanged(int orientation);

private slots:
    void handleDecodingStarted();
    void handleDecodingFinished(bool succeeded);
    void processFrame(const QVideoFrame &frame);
    void setOrientation(int orientation);
    int orientation() const { return m_orientation; };

public:
    explicit QZXingFilter(QObject *parent = nullptr);
    void setVideoSink(QObject *videoSink);
    virtual ~QZXingFilter();

    bool isDecoding() const { return m_decoding; }
    QZXing *getDecoder() { return &m_decoder; }
};

#endif // QZXingFilter_H
