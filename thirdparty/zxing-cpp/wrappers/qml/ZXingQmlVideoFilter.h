/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2026 Emeric Grange
 */

#ifndef ZXING_QML_VIDEOFILTER_H
#define ZXING_QML_VIDEOFILTER_H
/* ************************************************************************** */

#include "ZXingQml.h"

#include <QObject>
#include <QRect>
#include <QPoint>
#include <QVideoSink>
#include <QVideoFrame>
#include <QFuture>
#include <QPointer>

/* ************************************************************************** */

class ZXingQmlVideoFilter : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QVideoSink *videoSink READ videoSink WRITE setVideoSink NOTIFY videoSinkChanged)

    Q_PROPERTY(QRectF captureRect READ captureRect_normalized WRITE setCaptureRect_normalized NOTIFY captureRectChanged)
    Q_PROPERTY(int orientation READ orientation WRITE setOrientation NOTIFY orientationChanged)
    Q_PROPERTY(bool mirrored READ mirrored WRITE setMirrored NOTIFY mirroredChanged)
    Q_PROPERTY(int formats READ formats WRITE setFormats NOTIFY formatsChanged)

    Q_PROPERTY(bool tryHarder READ tryHarder WRITE setTryHarder NOTIFY tryHarderChanged)
    Q_PROPERTY(bool tryRotate READ tryRotate WRITE setTryRotate NOTIFY tryRotateChanged)
    Q_PROPERTY(bool tryInvert READ tryInvert WRITE setTryInvert NOTIFY tryInvertChanged)
    Q_PROPERTY(bool tryDownscale READ tryDownscale WRITE setTryDownscale NOTIFY tryDownscaleChanged)

    bool m_active = true;
    QFuture <void> m_processThread;

    QRectF m_captureRect_normalized;
    QRect m_captureRect_pixel;
    int m_orientation = 0;
    bool m_mirrored = false;
    ZXing::ReaderOptions m_readerOptions;

    int m_formats = static_cast<int>(ZXingQml::BarcodeFormat::Any);

    QPointer<QVideoSink> m_videoSink;
    QVideoSink *videoSink() const { return m_videoSink; }
    void setVideoSink(QVideoSink *sink);

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

signals:
    void videoSinkChanged();

    void tryHarderChanged();
    void tryRotateChanged();
    void tryInvertChanged();
    void tryDownscaleChanged();

    void formatsChanged();
    void captureRectChanged();
    void orientationChanged();
    void mirroredChanged();

    void decodingStarted();
    void decodingFinished(BarcodeQml result);
    void tagFound(BarcodeQml result);

public slots:
    BarcodeQml process(const QVideoFrame &frame);

public:
    ZXingQmlVideoFilter(QObject *parent = nullptr);
    virtual ~ZXingQmlVideoFilter();

    Q_INVOKABLE void stopFilter();

    /*!
     * \brief Set the capture rectangle, in normalized coordinates.
     * \param captureRect_normalized: the capture rectangle, in normalized (0 to 1) coordinates of the displayed video frame.
     *
     * Clears the pixel capture rectangle, the last capture rectangle set is the one used.
     * Uses the same coordinates as BarcodeQml::positionNormalized,
     * the displayed video frame being the VideoOutput contentRect.
     */
    void setCaptureRect_normalized(const QRectF &captureRect_normalized);
    int orientation() const { return m_orientation; }

    /*!
     * \brief Set the orientation of the VideoOutput displaying the video frames.
     * \param orientation: the VideoOutput orientation, clockwise in degrees, a multiple of 90.
     *
     * Same as VideoOutput.orientation, other values are ignored.
     * Applied to the normalized capture rectangle and BarcodeQml::positionNormalized,
     * so they match the VideoOutput contentRect.
     */
    void setOrientation(int orientation);

    bool mirrored() const { return m_mirrored; }

    /*!
     * \brief Set the mirrored state of the VideoOutput displaying the video frames.
     * \param mirrored: true if the VideoOutput mirrors the video around its vertical axis.
     *
     * Same as VideoOutput.mirrored (Qt 6.9+), applied after the orientation.
     * Applied to the normalized capture rectangle and BarcodeQml::positionNormalized,
     * so they match the VideoOutput contentRect.
     */
    void setMirrored(bool mirrored);

    QRectF captureRect_normalized() const { return m_captureRect_normalized; }

    /*!
     * \brief Set the capture rectangle, in pixel coordinates (C++ only).
     * \param captureRect_pixel: the capture rectangle, in QVideoFrame::toImage() pixel coordinates.
     *
     * Clears the normalized capture rectangle, the last capture rectangle set is the one used.
     * An empty rectangle captures the whole frame.
     * Doesn't take the frame own rotation() and mirrored() into account.
     */
    void setCaptureRect_pixel(const QRect &captureRect_pixel);
    QRect captureRect_pixel() const { return m_captureRect_pixel; }
};

/* ************************************************************************** */
#endif // ZXING_QML_VIDEOFILTER_H
