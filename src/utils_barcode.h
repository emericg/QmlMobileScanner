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
};

/* ************************************************************************** */
#endif // BARCODE_UTILS_H
