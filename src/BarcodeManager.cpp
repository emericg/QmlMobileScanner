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

bool BarcodeManager::addBarcode(const QString &data, const QString &format,
                                const QString &enc, const QString &ecc,
                                const QPoint &p1, const QPoint &p2, const QPoint &p3, const QPoint &p4)
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

                bbc->setLastSeen(QDateTime::currentDateTime());
                bbc->setLastCoordinates(p1, p2, p3, p4);

                Q_EMIT barcodesChanged();
                return false;
            }
        }

        // add barcode to the onscreen list
        Barcode *bc = new Barcode(data, format, enc, ecc,
                                  QDateTime::currentDateTime(), p1, p2, p3, p4,
                                  this);
        if (bc)
        {
            qDebug() << "addBarcode(" << data << ")";
            m_barcodes_onscreen.push_back(bc);

            Q_EMIT barcodesChanged();
            return true;
        }
    }

    return false;
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

        Barcode *bc = new Barcode(data, format, enc, ecc,
                                  QDateTime::currentDateTime(), 0, 0,
                                  this);
        if (bc)
        {
            qDebug() << "addHistory(" << data << ")";

            // add barcode to the history list
            m_barcodes_history.push_back(bc);
            Q_EMIT historyChanged();

            // add barcode to the history database
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

void BarcodeManager::removeHistory(const QString &data)
{
    if (!data.isEmpty())
    {
        for (auto bc: std::as_const(m_barcodes_history)) // barcode already exists
        {
            Barcode *bbc = qobject_cast<Barcode*>(bc);
            if (bbc && (bbc->getData() == data))
            {
                qDebug() << "removeHistory(" << data << ")";

                // remove barcode from the history list
                m_barcodes_history.removeAll(bbc);
                Q_EMIT historyChanged();

                // remove barcode from the history database
                QSqlQuery removeBarcode;
                removeBarcode.prepare("DELETE FROM barcodes WHERE data = :data");
                removeBarcode.bindValue(":data", bbc->getData());

                if (removeBarcode.exec() == false)
                {
                    qWarning() << "> removeBarcode.exec() ERROR"
                               << removeBarcode.lastError().type() << ":" << removeBarcode.lastError().text();
                }

                return;
            }
        }
    }
}

/* ************************************************************************** */
