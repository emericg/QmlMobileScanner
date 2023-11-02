/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#pragma once

#include "ReadBarcode.h"
#include "BarcodeFormat.h"

#include <QObject>
#include <QVideoFrame>
#include <QVideoSink>
#include <QFuture>
#include <QRect>
#include <QElapsedTimer>

namespace ZXingQt {

using ZXing::DecodeHints;
using ZXing::Binarizer;
using ZXing::BarcodeFormat;
using ZXing::ContentType;

class Position : public ZXing::Quadrilateral<QPoint>
{
    Q_GADGET

    Q_PROPERTY(QPoint topLeft READ topLeft)
    Q_PROPERTY(QPoint topRight READ topRight)
    Q_PROPERTY(QPoint bottomRight READ bottomRight)
    Q_PROPERTY(QPoint bottomLeft READ bottomLeft)

    using Base = ZXing::Quadrilateral<QPoint>;

public:
    using Base::Base;
};

class Result : private ZXing::Result
{
    Q_GADGET

    Q_PROPERTY(BarcodeFormat format READ format)
    Q_PROPERTY(QString formatName READ formatName)
    Q_PROPERTY(QString text READ text)
    Q_PROPERTY(QByteArray bytes READ bytes)
    Q_PROPERTY(bool isValid READ isValid)
    Q_PROPERTY(ContentType contentType READ contentType)
    Q_PROPERTY(Position position READ position)
    Q_PROPERTY(int runTime MEMBER runTime)

    QString m_text;
    QByteArray m_bytes;
    Position m_position;

public:
    Result() = default; // required for qmetatype machinery

    explicit Result(ZXing::Result &&r) : ZXing::Result(std::move(r)) {
        m_text = QString::fromStdString(ZXing::Result::text());
        m_bytes = QByteArray(reinterpret_cast<const char*>(ZXing::Result::bytes().data()), Size(ZXing::Result::bytes()));
        auto &pos = ZXing::Result::position();
        auto qp = [&pos](int i) { return QPoint(pos[i].x, pos[i].y); };
        m_position = {qp(0), qp(1), qp(2), qp(3)};
    }

    int runTime = 0; // for debugging/development
    using ZXing::Result::isValid;

    BarcodeFormat format() const { return static_cast<BarcodeFormat>(ZXing::Result::format()); }
    ContentType contentType() const { return static_cast<ContentType>(ZXing::Result::contentType()); }
    QString formatName() const { return QString::fromStdString(ZXing::ToString(ZXing::Result::format())); }
    const QString &text() const { return m_text; }
    const QByteArray &bytes() const { return m_bytes; }
    const Position &position() const { return m_position; }
};

class ZXingQtVideoFilter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool tryHarder READ tryHarder WRITE setTryHarder NOTIFY tryHarderChanged)
    Q_PROPERTY(bool tryRotate READ tryRotate WRITE setTryRotate NOTIFY tryRotateChanged)
    Q_PROPERTY(bool tryInvert READ tryInvert WRITE setTryInvert NOTIFY tryInvertChanged)
    Q_PROPERTY(bool tryDownscale READ tryDownscale WRITE setTryDownscale NOTIFY tryDownscaleChanged)
    Q_PROPERTY(int formats READ formats WRITE setFormats NOTIFY formatsChanged)
    Q_PROPERTY(QRect captureRect READ captureRect WRITE setCaptureRect NOTIFY captureRectChanged)
    Q_PROPERTY(QVideoSink *videoSink MEMBER m_videoSink WRITE setVideoSink)

    bool m_active = true;
    bool m_decoding = false;
    QFuture <void> m_processThread;
    QElapsedTimer m_processTimer;

    QRect m_captureRect;
    DecodeHints m_decodeHints;

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
    void decodingFinished(ZXingQt::Result result);
    void tagFound(ZXingQt::Result result);

public slots:
    ZXingQt::Result process(const QVideoFrame &frame);

public:
    ZXingQtVideoFilter(QObject *parent = nullptr);
    ~ZXingQtVideoFilter();

    QRect captureRect() const { return m_captureRect; }
    void setCaptureRect(const QRect &captureRect);

    Q_INVOKABLE void stopFilter();

    // decode hints
    int formats() const noexcept;
    void setFormats(int newVal);
    bool tryHarder() const { return m_decodeHints.tryHarder(); }
    void setTryHarder(const bool value);
    bool tryRotate() const { return m_decodeHints.tryRotate(); }
    void setTryRotate(const bool value);
    bool tryInvert() const { return m_decodeHints.tryInvert(); }
    void setTryInvert(const bool value);
    bool tryDownscale() const { return m_decodeHints.tryDownscale(); }
    void setTryDownscale(const bool value);
};

} // namespace ZXingQt
