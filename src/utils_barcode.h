/*!
 * This file is part of QmlMobileScanner.
 * Copyright (c) 2023 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef BARCODE_UTILS_H
#define BARCODE_UTILS_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>

#include <QObject>
#include <QVariantList>
#include <QString>
#include <QUrl>
#include <QSize>

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief The UtilsBarcode class
 */
class UtilsBarcode: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // Singleton
    explicit UtilsBarcode(QObject *parent = nullptr);

public:
    static UtilsBarcode *getInstance();
    static UtilsBarcode *create(QQmlEngine *, QJSEngine *);

    /*!
     * \brief Catalog of toggleable barcode formats for the active (compile-time) reader backend.
     *
     * Single source of truth for MenuFormats.qml; each entry is { "text", "value" }
     * where "value" is a bitmask in that backend's native formatsEnabled layout.
     */
    static Q_INVOKABLE QVariantList getAvailableFormats();

    /*!
     * \brief Check if a file can be loaded as barcode content.
     * \param fileUrl: the file url.
     * \return true if the file is a local text file (text/plain or inherited, like vCard or iCalendar).
     */
    static Q_INVOKABLE bool isTextFile(const QUrl &fileUrl);

    /*!
     * \brief Load a text file as barcode content.
     * \param fileUrl: the file url.
     * \return the file content, decoded as UTF-8, or an empty string on error.
     *
     * Files bigger than 4 KiB are rejected, as no 2D barcode can hold that much data.
     */
    static Q_INVOKABLE QString loadTextFile(const QUrl &fileUrl);

    /*!
     * \brief Get a file url inside a temporary folder, for exporting files to other applications.
     * \param fileName: the file name.
     * \return the file url, or an empty url if the temporary folder can't be created.
     *
     * The folder is created once per session, and removed with its content when the application quits.
     */
    static Q_INVOKABLE QUrl getTemporaryFileUrl(const QString &fileName);

    /*!
     * \brief Compute the QML Image sourceSize needed to load a picture with its longest side capped.
     * \param fileUrl: the image file url.
     * \param maxSize: the maximum size of the longest side, in pixels.
     * \return the sourceSize to use, or an empty size (native size) if the picture is small enough or can't be read.
     *
     * Only one dimension is set, as setting both scales the picture to fit its shortest side.
     * Image applies sourceSize before the orientation metadata (EXIF),
     * so the dimension is chosen from the picture as stored in the file.
     */
    static Q_INVOKABLE QSize getImageSourceSize(const QUrl &fileUrl, int maxSize);
};

/* ************************************************************************** */
#endif // BARCODE_UTILS_H
