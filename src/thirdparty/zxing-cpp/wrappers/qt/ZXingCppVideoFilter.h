/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#ifndef ZXINGCPP_VIDEOFILTER_H
#define ZXINGCPP_VIDEOFILTER_H

#include "ZXingCpp.h"

#include <QObject>
#include <QRect>
#include <QPoint>
#include <QVideoSink>
#include <QVideoFrame>
#include <QFuture>

class ZXingCppVideoFilter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVideoSink *videoSink MEMBER m_videoSink WRITE setVideoSink)

    Q_PROPERTY(QRect captureRect READ captureRect WRITE setCaptureRect NOTIFY captureRectChanged)
    Q_PROPERTY(int formats READ formats WRITE setFormats NOTIFY formatsChanged)

    Q_PROPERTY(bool tryHarder READ tryHarder WRITE setTryHarder NOTIFY tryHarderChanged)
    Q_PROPERTY(bool tryRotate READ tryRotate WRITE setTryRotate NOTIFY tryRotateChanged)
    Q_PROPERTY(bool tryInvert READ tryInvert WRITE setTryInvert NOTIFY tryInvertChanged)
    Q_PROPERTY(bool tryDownscale READ tryDownscale WRITE setTryDownscale NOTIFY tryDownscaleChanged)

    bool m_active = true;
    QFuture <void> m_processThread;

    QRect m_captureRect;
    ZXing::ReaderOptions m_readerOptions;

    QVideoSink *m_videoSink = nullptr;
    void setVideoSink(QVideoSink *sink);

signals:
    void tryHarderChanged();
    void tryRotateChanged();
    void tryInvertChanged();
    void tryDownscaleChanged();

    void formatsChanged();
    void captureRectChanged();

    void decodingStarted();
    void decodingFinished(Result result);
    void tagFound(Result result);

public slots:
    Result process(const QVideoFrame &frame);

public:
    ZXingCppVideoFilter(QObject *parent = nullptr);
    virtual ~ZXingCppVideoFilter();

    Q_INVOKABLE void stopFilter();

    // capture rectangle
    QRect captureRect() const { return m_captureRect; }
    void setCaptureRect(const QRect &captureRect);

    // barcode reader options
    int formats() const noexcept;
    void setFormats(int newVal);
    bool tryHarder() const { return m_readerOptions.tryHarder(); }
    void setTryHarder(const bool value);
    bool tryRotate() const { return m_readerOptions.tryRotate(); }
    void setTryRotate(const bool value);
    bool tryInvert() const { return m_readerOptions.tryInvert(); }
    void setTryInvert(const bool value);
    bool tryDownscale() const { return m_readerOptions.tryDownscale(); }
    void setTryDownscale(const bool value);
};

#endif // ZXINGCPP_VIDEOFILTER_H
