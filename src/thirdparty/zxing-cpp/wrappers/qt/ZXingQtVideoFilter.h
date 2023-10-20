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

    QString _text;
    QByteArray _bytes;
    Position _position;

public:
    Result() = default; // required for qmetatype machinery

    explicit Result(ZXing::Result &&r) : ZXing::Result(std::move(r)) {
        _text = QString::fromStdString(ZXing::Result::text());
        _bytes = QByteArray(reinterpret_cast<const char*>(ZXing::Result::bytes().data()), Size(ZXing::Result::bytes()));
        auto &pos = ZXing::Result::position();
        auto qp = [&pos](int i) { return QPoint(pos[i].x, pos[i].y); };
        _position = {qp(0), qp(1), qp(2), qp(3)};
    }

    int runTime = 0; // for debugging/development
    using ZXing::Result::isValid;

    BarcodeFormat format() const { return static_cast<BarcodeFormat>(ZXing::Result::format()); }
    ContentType contentType() const { return static_cast<ContentType>(ZXing::Result::contentType()); }
    QString formatName() const { return QString::fromStdString(ZXing::ToString(ZXing::Result::format())); }
    const QString &text() const { return _text; }
    const QByteArray &bytes() const { return _bytes; }
    const Position &position() const { return _position; }
};

class ZXingQtVideoFilter : public QObject, private DecodeHints
{
    Q_OBJECT

    Q_PROPERTY(bool tryHarder READ tryHarder WRITE setTryHarder NOTIFY tryHarderChanged)
    Q_PROPERTY(bool tryRotate READ tryRotate WRITE setTryRotate NOTIFY tryRotateChanged)
    Q_PROPERTY(bool tryDownscale READ tryDownscale WRITE setTryDownscale NOTIFY tryDownscaleChanged)

    Q_PROPERTY(int formats READ formats WRITE setFormats NOTIFY formatsChanged)
    Q_PROPERTY(QRect captureRect READ captureRect WRITE setCaptureRect NOTIFY captureRectChanged)
    Q_PROPERTY(QVideoSink *videoSink MEMBER m_videoSink WRITE setVideoSink)

    QVideoSink *m_videoSink = nullptr;
    QFuture<void> m_processThread;
    QElapsedTimer m_processTimer;
    QRect m_captureRect;

    bool m_decoding = false;
    bool m_active = true;

    bool m_tryHarder = true;
    bool m_tryRotate = true;
    bool m_tryDownscale = false;

    void setVideoSink(QVideoSink *sink);

signals:
    void tryHarderChanged();
    void tryRotateChanged();
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

    bool tryHarder() const { return m_tryHarder; }
    void setTryHarder(const bool value);
    bool tryRotate() const { return m_tryRotate; }
    void setTryRotate(const bool value);
    bool tryDownscale() const { return m_tryDownscale; }
    void setTryDownscale(const bool value);

    int formats() const noexcept;
    void setFormats(int newVal);

    QRect captureRect() const { return m_captureRect; }
    void setCaptureRect(const QRect &captureRect);

    Q_INVOKABLE void stopFilter();
};

} // namespace ZXingQt
