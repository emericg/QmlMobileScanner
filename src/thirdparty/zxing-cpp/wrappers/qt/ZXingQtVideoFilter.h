/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#pragma once

#include "ReadBarcode.h"
#include "BarcodeFormat.h"

#include <QVideoFrame>
#include <QVideoSink>
#include <QElapsedTimer>
#include <QRect>

namespace ZXingQt {

enum class BarcodeFormat {
    None            = 0,         ///< Used as a return value if no valid barcode has been detected
    Aztec           = (1 << 0),  ///< Aztec
    Codabar         = (1 << 1),  ///< Codabar
    Code39          = (1 << 2),  ///< Code39
    Code93          = (1 << 3),  ///< Code93
    Code128         = (1 << 4),  ///< Code128
    DataBar         = (1 << 5),  ///< GS1 DataBar, formerly known as RSS 14
    DataBarExpanded = (1 << 6),  ///< GS1 DataBar Expanded, formerly known as RSS EXPANDED
    DataMatrix      = (1 << 7),  ///< DataMatrix
    EAN8            = (1 << 8),  ///< EAN-8
    EAN13           = (1 << 9),  ///< EAN-13
    ITF             = (1 << 10), ///< ITF (Interleaved Two of Five)
    MaxiCode        = (1 << 11), ///< MaxiCode
    PDF417          = (1 << 12), ///< PDF417 or
    QRCode          = (1 << 13), ///< QR Code
    UPCA            = (1 << 14), ///< UPC-A
    UPCE            = (1 << 15), ///< UPC-E
    MicroQRCode     = (1 << 16), ///< Micro QR Code

    LinearCodes = Codabar | Code39 | Code93 | Code128 | EAN8 | EAN13 | ITF | DataBar | DataBarExpanded | UPCA | UPCE,
    MatrixCodes = Aztec | DataMatrix | MaxiCode | PDF417 | QRCode | MicroQRCode,
};
//Q_ENUM_NS(BarcodeFormat)

enum class ContentType { Text, Binary, Mixed, GS1, ISO15434, UnknownECI };
//Q_ENUM_NS(ContentType)

using ZXing::DecodeHints;
using ZXing::Binarizer;
using ZXing::BarcodeFormats;
/*
template<typename T, typename = decltype(ZXing::ToString(T()))>
QDebug operator<<(QDebug dbg, const T& v)
{
    return dbg.noquote() << QString::fromStdString(ToString(v));
}
*/
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

#define ZQ_PROPERTY(Type, name, setter) \
public: \
    Q_PROPERTY(Type name READ name WRITE setter NOTIFY name##Changed) \
    Type name() const noexcept { return DecodeHints::name(); } \
    Q_SLOT void setter(const Type& newVal) \
    { \
        if (name() != newVal) { \
            DecodeHints::setter(newVal); \
            emit name##Changed(); \
        } \
    } \
    Q_SIGNAL void name##Changed();


class ZXingQtVideoFilter : public QObject, private DecodeHints
{
    Q_OBJECT

    ZQ_PROPERTY(bool, tryRotate, setTryRotate)
    ZQ_PROPERTY(bool, tryHarder, setTryHarder)
    ZQ_PROPERTY(bool, tryDownscale, setTryDownscale)

    // TODO: find out how to properly expose QFlags to QML
    // simply using ZQ_PROPERTY(BarcodeFormats, formats, setFormats)
    // results in the runtime error "can't assign int to formats"
    Q_PROPERTY(int formats READ formats WRITE setFormats NOTIFY formatsChanged)
    Q_PROPERTY(QRect captureRect READ captureRect WRITE setCaptureRect NOTIFY captureRectChanged)
    Q_PROPERTY(QVideoSink *videoSink MEMBER m_videoSink WRITE setVideoSink)

    QRect m_captureRect;
    QVideoSink *m_videoSink = nullptr;
    QElapsedTimer m_processTimer;

    bool m_decoding = false;
    bool m_active = true;

    void setVideoSink(QVideoSink *sink);

signals:
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

    int formats() const noexcept;
    void setFormats(int newVal);

    QRect captureRect() const { return m_captureRect; }
    void setCaptureRect(const QRect &captureRect);

    Q_INVOKABLE void stopFilter();
};

#undef ZX_PROPERTY

} // namespace ZXingQt
