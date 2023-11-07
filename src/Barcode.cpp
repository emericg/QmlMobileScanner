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

#include "Barcode.h"

/* ************************************************************************** */

Barcode::Barcode(const QString &data, const QString &format,
                 const QString &enc, const QString &ecc,
                 const QDateTime &date, const double lat, const double lon,
                 const bool starred,
                 QObject *parent) : QObject(parent)
{
    m_data = data;
    m_format = format;
    m_encoding = enc;
    m_ecc = ecc;

    m_date = date;
    m_geo_lat = lat;
    m_geo_long = lon;

    m_starred = starred;

    m_isMatrix = (format == "QR_CODE" || format == "QRCode" || format == "MicroQRCode" ||
                  format == "DATA_MATRIX" || format == "DataMatrix" || format == "Aztec" ||
                  format == "PDF417" || format == "MaxiCode");

    if (m_data.startsWith("http://") || m_data.startsWith("https://")) m_content = "URL";
    else if (m_data.startsWith("WIFI:")) m_content = "WiFi";
    else if (m_data.startsWith("mailto:")) m_content = "Email";
    else if (m_data.startsWith("geo:")) m_content = "Geolocation";
    else if (m_data.startsWith("tel:")) m_content = "Phone";
    else if (m_data.startsWith("smsto:")) m_content = "SMS";
    else if (m_data.startsWith("BEGIN:VCARD") || m_data.startsWith("MECARD:")) m_content = "Contact";
    else if (m_data.startsWith("BEGIN:VEVENT")) m_content = "Calendar";
}

Barcode::Barcode(const QString &data, const QString &format, const QString &enc, const QString &ecc,
                 const QDateTime &lastseen, const QPoint &p1, const QPoint &p2, const QPoint &p3, const QPoint &p4,
                 QObject *parent) : QObject(parent)
{
    m_data = data;
    m_format = format;
    m_encoding = enc;
    m_ecc = ecc;

    m_isMatrix = (format == "QR_CODE" || format == "QRCode" || format == "MicroQRCode" ||
                  format == "DATA_MATRIX" || format == "DataMatrix" || format == "Aztec" ||
                  format == "PDF417" || format == "MaxiCode");

    if (m_data.startsWith("http://") || m_data.startsWith("https://")) m_content = "URL";
    else if (m_data.startsWith("WIFI:")) m_content = "WiFi";
    else if (m_data.startsWith("mailto:")) m_content = "Email";
    else if (m_data.startsWith("geo:")) m_content = "Geolocation";
    else if (m_data.startsWith("tel:")) m_content = "Phone";
    else if (m_data.startsWith("smsto:")) m_content = "SMS";
    else if (m_data.startsWith("BEGIN:VCARD") || m_data.startsWith("MECARD:")) m_content = "Contact";
    else if (m_data.startsWith("BEGIN:VEVENT")) m_content = "Calendar";

    m_lastSeen = lastseen;
    m_lastCoordinates << p1 << p2 << p3 << p4;

    m_isOnScreen = true;
    m_lastTimer.start(1000);
    connect(&m_lastTimer, &QTimer::timeout, [this]() { m_isOnScreen = false; Q_EMIT lastseenChanged(); });
}

Barcode::~Barcode()
{
    //
}

/* ************************************************************************** */

void Barcode::setStarred(const bool value)
{
    if (m_starred != value)
    {
        m_starred = value;
        Q_EMIT barcodeChanged();
    }
}

void Barcode::setLastSeen(const QDateTime &value)
{
    if (m_lastSeen != value)
    {
        m_isOnScreen = true;
        m_lastTimer.start(1000);
        m_lastSeen = value;
        Q_EMIT lastseenChanged();
    }
}

void Barcode::setLastCoordinates(const QPoint &p1, const QPoint &p2, const QPoint &p3, const QPoint &p4)
{
    m_lastCoordinates.clear();
    m_lastCoordinates << p1 << p2 << p3 << p4;
    Q_EMIT lastseenChanged();
}

/* ************************************************************************** */
