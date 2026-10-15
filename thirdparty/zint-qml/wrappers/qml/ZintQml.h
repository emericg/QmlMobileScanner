/*
 * Copyright 2023 Emeric Grange
 */

#ifndef ZINT_QML_H
#define ZINT_QML_H

#include <QObject>
#include <QUrl>
#include <QColor>
#include <QImage>
#include <QString>
#include <QQmlEngine>

class ZintQml : public QObject
{
    Q_OBJECT

public:
    explicit ZintQml(QObject *parent = nullptr) : QObject(parent) {}

    static void registerQMLTypes();
    static void registerQMLImageProvider(QQmlEngine &engine);

    ///

    /*!
     * \brief Convert an application format name into a zint symbology.
     * \param str: lowercase format name (ex. "qrcode", "aztec", "code128").
     * \return The zint symbology (BARCODE_*), or 0 if the format is not supported.
     */
    Q_INVOKABLE static int stringToFormat(const QString &str);

    /*!
     * \brief Convert a zint symbology into an application format name.
     * \param fmt: zint symbology (BARCODE_*).
     * \return The lowercase format name, or an empty string if the symbology is not supported.
     */
    Q_INVOKABLE static QString formatToString(const int fmt);

    ///

    /*!
     * \brief Generate a barcode image.
     * \param data: the data to encode.
     * \param width: maximum image width, in pixels.
     * \param height: maximum image height, in pixels.
     * \param margins: background border around the barcode, in pixels.
     * \param format: zint symbology (BARCODE_*).
     * \param encoding: zint input mode (UNICODE_MODE, GS1_MODE...), or 0 for UTF-8 text (UNICODE_MODE).
     * \param eccLevel: error correction level (QR: 2/4/6/8 = L/M/Q/H, Aztec: 1..4, PDF417: 0..8, 0: default).
     * \param backgroundColor: background color, transparent if invalid.
     * \param foregroundColor: foreground color, black if invalid.
     * \return The barcode image, or a null image on error.
     *
     * The barcode is drawn with a whole number of pixels per module, as large as possible,
     * so the image can be smaller than the requested size.
     * Margins are ignored if they leave less than 16 pixels for the barcode.
     * Linear barcodes get shorter bars if needed, to use the whole width.
     */
    Q_INVOKABLE static QImage generateImage(const QString &data, const int width, const int height, const int margins,
                                            const int format, const int encoding, const int eccLevel,
                                            const QColor backgroundColor, const QColor foregroundColor);

    /*!
     * \brief Generate a barcode and save it to a file.
     * \param data: the data to encode.
     * \param width: maximum image width, in pixels.
     * \param height: maximum image height, in pixels.
     * \param margins: background border around the barcode, in pixels.
     * \param format: zint symbology (BARCODE_*).
     * \param encoding: zint input mode (UNICODE_MODE, GS1_MODE...), or 0 for UTF-8 text (UNICODE_MODE).
     * \param eccLevel: error correction level (see generateImage()).
     * \param backgroundColor: background color, transparent if invalid.
     * \param foregroundColor: foreground color, black if invalid.
     * \param fileurl: destination file. The format is chosen from its suffix (bmp, png, jpg, jpeg, webp or svg).
     * \return True if the file has been written.
     *
     * Raster files are rendered with generateImage().
     * SVG files use the same geometry, with margins rounded down to whole modules.
     */
    Q_INVOKABLE static bool saveImage(const QString &data, const int width, const int height, const int margins,
                                      const int format, const int encoding, const int eccLevel,
                                      const QColor backgroundColor, const QColor foregroundColor,
                                      const QUrl &fileurl);

    ///
};

#endif // ZINT_QML_H
