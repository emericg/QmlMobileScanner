/*!
 * This file is part of MobileScanner.
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

#ifndef BARCODE_H
#define BARCODE_H
/* ************************************************************************** */

#include <QObject>
#include <QTimer>
#include <QPoint>
#include <QString>
#include <QDateTime>

/* ************************************************************************** */

/** Calendar event (vEvent)
BEGIN:VEVENT
SUMMARY:title
DTSTART:20231016T171100Z
DTEND:20231017T181100Z
LOCATION:location
DESCRIPTION:description
END:VEVENT
*/

/** Contact (vCard)
BEGIN:VCARD
VERSION:3.0
N:name
ORG:company
TITLE:title
TEL:0479123456
URL:https://website.com
EMAIL:email@email.com
ADR:addr1 addr2
NOTE:memo
END:VCARD
*/

/** Contact (MECARD)
MECARD:N:name;ORG:company;TEL:0479123456;URL:https\://website.com;EMAIL:email@email.com;ADR:addr1 addr2;NOTE:memotitle;;
*/

/** Email
mailto:email@email.com
*/

/** Geolocation
geo:4.55,56.5?q=query
*/

/** Phone
tel:0479123456
*/

/** SMS
smsto:0479123456:message
*/

/** url
https://website.com
*/

/** WiFi
WIFI:S:ssid;T:WEP;P:password;;
WIFI:S:ssid;T:WPA;P:password;H:true;;
WIFI:S:ssid;P:password;;
*/

/* ************************************************************************** */

/*!
 * \brief The Barcode class
 */
class Barcode: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString data READ getData CONSTANT)
    Q_PROPERTY(QString format READ getFormat CONSTANT)
    Q_PROPERTY(QString encoding READ getEnc CONSTANT)
    Q_PROPERTY(QString errorCorrection READ getEcc CONSTANT)

    Q_PROPERTY(bool isMatrix READ isMatrix CONSTANT)
    Q_PROPERTY(bool isLinear READ isLinear CONSTANT)
    Q_PROPERTY(QString content READ getContent CONSTANT)

    Q_PROPERTY(QDateTime date READ getDate CONSTANT)
    Q_PROPERTY(double latitude READ getLat CONSTANT)
    Q_PROPERTY(double longitude READ getLon CONSTANT)

    Q_PROPERTY(bool lastVisible READ getLastVisible NOTIFY lastseenChanged)
    Q_PROPERTY(QDateTime lastSeen READ getLastSeen NOTIFY lastseenChanged)
    //Q_PROPERTY(QList<QPoint> lastCoordinates READ getLastCoordinates NOTIFY lastseenChanged)
    Q_PROPERTY(QPoint p1 READ getP1 NOTIFY lastseenChanged)
    Q_PROPERTY(QPoint p2 READ getP2 NOTIFY lastseenChanged)
    Q_PROPERTY(QPoint p3 READ getP3 NOTIFY lastseenChanged)
    Q_PROPERTY(QPoint p4 READ getP4 NOTIFY lastseenChanged)

    QString m_data;
    QString m_format;
    QString m_encoding;
    QString m_ecc;

    bool m_isMatrix = false;
    QString m_content;

    QDateTime m_date;
    double m_geo_lat;
    double m_geo_long;

    bool m_lastVisible = false;
    QTimer m_lastTimer;
    QDateTime m_lastSeen;
    QList<QPoint> m_lastCoordinates;

Q_SIGNALS:
    void barcodeChanged();
    void lastseenChanged();

public:
    Barcode(const QString &data, const QString &format, const QString &enc, const QString &ecc,
            const QDateTime &date = QDateTime(), const double lat = 0.0, const double lon = 0.0,
            QObject *parent = nullptr);
    Barcode(const QString &data, const QString &format, const QString &enc, const QString &ecc,
            const QDateTime &lastseen, const QPoint &p1, const QPoint &p2, const QPoint &p3, const QPoint &p4,
            QObject *parent = nullptr);
    ~Barcode();

    QString getData() const { return m_data; }
    QString getFormat() const { return m_format; }
    QString getEnc() const { return m_encoding; }
    QString getEcc() const { return m_ecc; }
    QDateTime getDate() const { return m_date; }
    double getLat() const { return m_geo_lat; }
    double getLon() const { return m_geo_long; }

    bool isMatrix() const { return m_isMatrix; }
    bool isLinear() const { return !m_isMatrix; }
    QString getContent() const { return m_content; }

    bool getLastVisible() const { return m_lastVisible; }
    QDateTime getLastSeen() const { return m_lastSeen; }
    void setLastSeen(const QDateTime &value);
    QList<QPoint> getLastCoordinates() const { return m_lastCoordinates; }
    void setLastCoordinates(const QPoint &p1, const QPoint &p2, const QPoint &p3, const QPoint &p4);

    QPoint getP1() const { if (m_lastCoordinates.size() != 4) return QPoint(100, 100); return m_lastCoordinates.at(0); }
    QPoint getP2() const { if (m_lastCoordinates.size() != 4) return QPoint(200, 100); return m_lastCoordinates.at(1); }
    QPoint getP3() const { if (m_lastCoordinates.size() != 4) return QPoint(200, 200); return m_lastCoordinates.at(2); }
    QPoint getP4() const { if (m_lastCoordinates.size() != 4) return QPoint(100, 200); return m_lastCoordinates.at(3); }
};

/* ************************************************************************** */
#endif // BARCODE_H
