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

#include "BarcodeManager.h"
#include "Barcode.h"
#include "DatabaseManager.h"

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

/* ************************************************************************** */

BarcodeManager *BarcodeManager::instance = nullptr;

BarcodeManager *BarcodeManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new BarcodeManager();
        return instance;
    }

    return instance;
}

BarcodeManager::BarcodeManager()
{
    // Database
    DatabaseManager *db = DatabaseManager::getInstance();
    if (db && db->hasDatabaseInternal())
    {
        // Load saved barcodes
        QSqlQuery queryBarcodes;
        queryBarcodes.exec("SELECT data, format, encoding, ecc, date, lat, long FROM barcodes");
        while (queryBarcodes.next())
        {
            QString barcodeData = queryBarcodes.value(0).toString();
            QString barcodeFormat = queryBarcodes.value(1).toString();
            QString barcodeEncoding = queryBarcodes.value(2).toString();
            QString barcodeEcc = queryBarcodes.value(3).toString();
            QDateTime barcodeDateTime = QDateTime::fromMSecsSinceEpoch(queryBarcodes.value(4).toULongLong());
            double barcodeLatitude = queryBarcodes.value(5).toDouble();
            double barcodeLongitude = queryBarcodes.value(6).toDouble();

            qWarning() << "loading tag (" << barcodeData << ")";

            Barcode *bc = new Barcode(barcodeData, barcodeFormat, barcodeEncoding, barcodeEcc,
                                      barcodeDateTime, barcodeLatitude, barcodeLongitude, this);
            if (bc) m_barcodes_history.push_back(bc);
        }
    }
}

BarcodeManager::~BarcodeManager()
{
    //
}

/* ************************************************************************** */

void BarcodeManager::addBarcode(const QString &data, const QString &format,
                                const QString &enc, const QString &ecc)
{
    if (!data.isEmpty())
    {
        // check if exists
        for (auto bc: std::as_const(m_barcodes_onscreen)) // barcode already exists
        {
            Barcode *bbc = qobject_cast<Barcode*>(bc);
            if (bbc && (bbc->getData() == data))
            {
                qDebug() << "tag exist (" << data << ")";
                return;
            }
        }

        // add barcode to the onscreen list
        Barcode *bc = new Barcode(data, format, enc, ecc,
                                  QDateTime::currentDateTime(), 0, 0,
                                  this);
        if (bc)
        {
            qWarning() << "addBarcode(" << data << ")";
            m_barcodes_onscreen.push_back(bc);
            Q_EMIT barcodesChanged();
        }
    }
}

/* ************************************************************************** */

void BarcodeManager::addHistory(const QString &data, const QString &format,
                                const QString &enc, const QString &ecc)
{
    if (!data.isEmpty())
    {
        // check if exists
        for (auto bc: std::as_const(m_barcodes_history)) // barcode already exists
        {
            Barcode *bbc = qobject_cast<Barcode*>(bc);
            if (bbc && (bbc->getData() == data))
            {
                qDebug() << "tag exist (" << data << ")";
                return;
            }
        }

        // add barcode to the history list
        Barcode *bc = new Barcode(data, format, enc, ecc,
                                  QDateTime::currentDateTime(), 0, 0,
                                  this);
        if (bc)
        {
            qWarning() << "addHistory(" << data << ")";
            m_barcodes_history.push_back(bc);
            Q_EMIT barcodesChanged();
        }

        // add barcode to the history database
        if (bc)
        {
            // if
            //QSqlQuery queryBarcode;
            //queryBarcode.prepare("SELECT data FROM barcodes WHERE data = :data");
            //queryBarcode.bindValue(":data", d->getData());
            //queryBarcode.exec();

            // then
            //if (queryBarcode.last() == false)
            {
                QSqlQuery addBarcode;
                addBarcode.prepare("INSERT INTO barcodes (data, format, date) VALUES (:data, :format, :date)");
                addBarcode.bindValue(":data", data);
                addBarcode.bindValue(":format", format);
                addBarcode.bindValue(":date", QDateTime::currentDateTime().toMSecsSinceEpoch());

                if (addBarcode.exec() == false)
                {
                    qWarning() << "> addBarcode.exec() ERROR"
                               << addBarcode.lastError().type() << ":" << addBarcode.lastError().text();
                }
            }
        }
    }
}

void BarcodeManager::removeHistory(const QString &data)
{
    if (data.isEmpty())
    {
        for (auto bc: std::as_const(m_barcodes_history)) // barcode already exists
        {
            Barcode *bbc = qobject_cast<Barcode*>(bc);
            if (bbc && (bbc->getData() == data))
            {
                qWarning() << "removeHistory";
                m_barcodes_history.removeAll(bbc);
                Q_EMIT barcodesChanged();

                return;
            }
        }
    }
}

/* ************************************************************************** */
