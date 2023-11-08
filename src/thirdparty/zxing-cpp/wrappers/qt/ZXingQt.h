/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#ifndef ZXING_QT_H
#define ZXING_QT_H

#include <QObject>
#include <QQmlEngine>

#include <QUrl>
#include <QList>
#include <QRect>
#include <QPoint>
#include <QImage>
#include <QVideoFrame>

#include "Result.h"
#include "Quadrilateral.h"

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

    Q_PROPERTY(ZXing::BarcodeFormat format READ format)
    Q_PROPERTY(QString formatName READ formatName)
    Q_PROPERTY(QString text READ text)
    Q_PROPERTY(QByteArray bytes READ bytes)
    Q_PROPERTY(bool isValid READ isValid)
    Q_PROPERTY(ZXing::ContentType contentType READ contentType)
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

    ZXing::BarcodeFormat format() const { return static_cast<ZXing::BarcodeFormat>(ZXing::Result::format()); }
    ZXing::ContentType contentType() const { return static_cast<ZXing::ContentType>(ZXing::Result::contentType()); }
    QString formatName() const { return QString::fromStdString(ZXing::ToString(ZXing::Result::format())); }
    const QString &text() const { return m_text; }
    const QByteArray &bytes() const { return m_bytes; }
    const Position &position() const { return m_position; }
};

class ZXingQt : public QObject
{
    Q_OBJECT

public:
    const int AZTEC_ERROR_CORRECTION_0  = 0;
    const int AZTEC_ERROR_CORRECTION_12 = 1;
    const int AZTEC_ERROR_CORRECTION_25 = 2;
    const int AZTEC_ERROR_CORRECTION_37 = 3;
    const int AZTEC_ERROR_CORRECTION_50 = 4;
    const int AZTEC_ERROR_CORRECTION_62 = 5;
    const int AZTEC_ERROR_CORRECTION_75 = 6;
    const int AZTEC_ERROR_CORRECTION_87 = 7;
    const int AZTEC_ERROR_CORRECTION_100= 8;
    const int QR_ERROR_CORRECTION_LOW       = 2;
    const int QR_ERROR_CORRECTION_MEDIUM    = 4;
    const int QR_ERROR_CORRECTION_QUARTILE  = 6;
    const int QR_ERROR_CORRECTION_HIGH      = 8;
    const int PDF417_ERROR_CORRECTION_0 = 0;
    const int PDF417_ERROR_CORRECTION_1 = 1;
    const int PDF417_ERROR_CORRECTION_2 = 2;
    const int PDF417_ERROR_CORRECTION_3 = 3;
    const int PDF417_ERROR_CORRECTION_4 = 4;
    const int PDF417_ERROR_CORRECTION_5 = 5;
    const int PDF417_ERROR_CORRECTION_6 = 6;
    const int PDF417_ERROR_CORRECTION_7 = 7;
    const int PDF417_ERROR_CORRECTION_8 = 8;

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
        PDF417          = (1 << 12), ///< PDF417
        QRCode          = (1 << 13), ///< QR Code
        UPCA            = (1 << 14), ///< UPC-A
        UPCE            = (1 << 15), ///< UPC-E
        MicroQRCode     = (1 << 16), ///< Micro QR Code

        LinearCodes = Codabar | Code39 | Code93 | Code128 | EAN8 | EAN13 | ITF | DataBar | DataBarExpanded | UPCA | UPCE,
        MatrixCodes = Aztec | DataMatrix | MaxiCode | PDF417 | QRCode | MicroQRCode,
        Any         = LinearCodes | MatrixCodes,
    };
    Q_ENUM(BarcodeFormat)

    enum class ContentType {
        Text,
        Binary,
        Mixed,
        GS1,
        ISO15434,
        UnknownECI
    };
    Q_ENUM(ContentType)

    enum class CharacterSet {
        Unknown,
        ASCII,
        ISO8859_1,
        ISO8859_2,
        ISO8859_3,
        ISO8859_4,
        ISO8859_5,
        ISO8859_6,
        ISO8859_7,
        ISO8859_8,
        ISO8859_9,
        ISO8859_10,
        ISO8859_11,
        ISO8859_13,
        ISO8859_14,
        ISO8859_15,
        ISO8859_16,
        Cp437,
        Cp1250,
        Cp1251,
        Cp1252,
        Cp1256,

        Shift_JIS,
        Big5,
        GB2312,
        GB18030,
        EUC_JP,
        EUC_KR,
        UTF16BE,
        UnicodeBig [[deprecated]] = UTF16BE,
        UTF8,
        UTF16LE,
        UTF32BE,
        UTF32LE,

        BINARY,

        CharsetCount
    };
    Q_ENUM(CharacterSet)

public:
    explicit ZXingQt(QObject *parent = nullptr) : QObject(parent) {}

    static void registerQMLTypes();
    static void registerQMLImageProvider(QQmlEngine &engine);

    ///

    static Result ReadBarcode(const QImage &img, const ZXing::DecodeHints &hints = {});

    static Result ReadBarcode(const QVideoFrame &frame, const ZXing::DecodeHints &hints = {},
                              const QRect captureRect = QRect());

    static QList<Result> ReadBarcodes(const QImage &img, const ZXing::DecodeHints &hints = {});

    static QList<Result> ReadBarcodes(const QVideoFrame &frame, const ZXing::DecodeHints &hints = {},
                                      const QRect captureRect = QRect());

    ///

    Q_INVOKABLE static QList<Result> loadImage(const QUrl &fileurl);

    Q_INVOKABLE static QImage generateImage(const QString &data, const int width, const int height, const int margins,
                                            const int format, const int encoding, const int eccLevel,
                                            const QColor backgroundColor, const QColor foregroundColor);

    Q_INVOKABLE static bool saveImage(const QString &data, const int width, const int height, const int margins,
                                      const int format, const int encoding, const int eccLevel,
                                      const QColor backgroundColor, const QColor foregroundColor,
                                      const QUrl &fileurl);

    ///
};

#endif // ZXING_QT_H
