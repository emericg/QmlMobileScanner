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
 * \date      2023
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef BARCODE_MANAGER_H
#define BARCODE_MANAGER_H
/* ************************************************************************** */

#include <QObject>
#include <QUrl>
#include <QString>
#include <QDateTime>
#include <QGeoCoordinate>

class QNetworkAccessManager;
class QNetworkReply;

class Barcode;

/* ************************************************************************** */

/*!
 * \brief The BarcodeManager class
 */
class BarcodeManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool hasBarcodes READ hasBarcodes NOTIFY barcodesChanged)
    Q_PROPERTY(int barcodesCount READ getBarcodesCount NOTIFY barcodesChanged)
    Q_PROPERTY(QVariant barcodes READ getBarcodes NOTIFY barcodesChanged)

    Q_PROPERTY(bool hasBarcodesHistory READ hasBarcodesHistory NOTIFY historyChanged)
    Q_PROPERTY(int barcodesHistoryCount READ getBarcodesHistoryCount NOTIFY historyChanged)
    Q_PROPERTY(QVariant barcodesHistory READ getBarcodesHistory NOTIFY historyChanged)

    QList <QObject *> m_barcodes_onscreen;
    QList <QObject *> m_barcodes_history;

    QNetworkAccessManager *m_nwManager = nullptr;
    QNetworkReply *firmwareReply = nullptr;

    QStringList m_colorsAvailable = {
        "HotPink", "Tomato", "Yellow", "Orange", "OrangeRed", "DarkOrange",
        "LimeGreen", "PaleGreen", "GreenYellow", "LawnGreen",
        "MediumVioletRed", "Indigo", "Magenta", "Violet", "Fuchsia",
        "DodgerBlue", "DeepSkyBlue", "MidnightBlue"
    };
    QStringList m_colorsLeft;
    QString getAvailableColor();

    static BarcodeManager *instance;
    BarcodeManager();
    ~BarcodeManager();

Q_SIGNALS:
    void barcodesChanged();
    void historyChanged();

public:
    static BarcodeManager *getInstance();

    Q_INVOKABLE bool loadImage(const QUrl &fileUrl);

    Q_INVOKABLE bool addBarcode(const QString &data, const QString &format,
                                const QString &enc, const QString &ecc,
                                const QPointF &p1, const QPointF &p2,  const QPointF &p3, const QPointF &p4,
                                const bool fromVideo = true);

    Q_INVOKABLE void addHistory(const QString &data, const QString &format,
                                const QString &enc, const QString &ecc,
                                const QGeoCoordinate &coord);
    Q_INVOKABLE void removeHistory(const QString &data);

    bool hasBarcodes() const { return !m_barcodes_onscreen.isEmpty(); }
    int getBarcodesCount() const { return m_barcodes_onscreen.size(); }
    QVariant getBarcodes() const { return QVariant::fromValue(m_barcodes_onscreen); };

    bool hasBarcodesHistory() const { return !m_barcodes_history.isEmpty(); }
    int getBarcodesHistoryCount() const { return m_barcodes_history.size(); }
    QVariant getBarcodesHistory() const { return QVariant::fromValue(m_barcodes_history); };
};

/* ************************************************************************** */
#endif // BARCODE_MANAGER_H
