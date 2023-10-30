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
                 QObject *parent) : QObject(parent)
{
    m_data = data;
    m_format = format;
    m_encoding = enc;
    m_ecc = ecc;

    m_date = date;
    m_geo_lat = lat;
    m_geo_long = lon;

    m_isMatrix = (format == "QR_CODE" || format == "QRCode" || format == "MicroQRCode" ||
                  format == "DATA_MATRIX" || format == "DataMatrix" || format == "Aztec" ||
                  format == "PDF417" || format == "MaxiCode");
}

Barcode::~Barcode()
{
    //
}

/* ************************************************************************** */

QString Barcode::getContent() const
{
    if (m_data.startsWith("http://") || m_data.startsWith("https://")) return "URL";
    if (m_data.startsWith("WIFI:")) return "WiFi";
    if (m_data.startsWith("mailto:")) return "Email";
    if (m_data.startsWith("geo:")) return "Geolocation";
    if (m_data.startsWith("tel:")) return "Phone";
    if (m_data.startsWith("smsto:")) return "SMS";

    if (m_data.startsWith("BEGIN:VCARD") || m_data.startsWith("MECARD:")) return "Contact";
    if (m_data.startsWith("BEGIN:VEVENT")) return "Calendar";

    return "";
}

/* ************************************************************************** */
