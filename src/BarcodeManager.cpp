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

#include "BarcodeManager.h"
#include "Barcode.h"
#include "DatabaseManager.h"

#include <QRandomGenerator>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>

#if defined(zxingcpp)
#include "ZXingCpp.h"
#endif

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
        QSqlQuery loadBarcodes;
        bool status = loadBarcodes.exec("SELECT data, format, encoding, ecc, date, lat, long, starred FROM barcodes");
        if (status)
        {
            while (loadBarcodes.next())
            {
                QString barcodeData = loadBarcodes.value(0).toString();
                QString barcodeFormat = loadBarcodes.value(1).toString();
                QString barcodeEncoding = loadBarcodes.value(2).toString();
                QString barcodeEcc = loadBarcodes.value(3).toString();
                QDateTime barcodeDateTime = QDateTime::fromMSecsSinceEpoch(loadBarcodes.value(4).toULongLong());
                double barcodeLatitude = loadBarcodes.value(5).toDouble();
                double barcodeLongitude = loadBarcodes.value(6).toDouble();
                bool barcodeStarred = loadBarcodes.value(7).toBool();

                Barcode *bc = new Barcode(barcodeData, barcodeFormat, barcodeEncoding, barcodeEcc,
                                          barcodeDateTime, barcodeLatitude, barcodeLongitude, barcodeStarred, this);
                if (bc) m_barcodes_history.push_front(bc);
            }
        }
        else
        {
            qWarning() << "> loadBarcodes.exec() ERROR"
                       << loadBarcodes.lastError().type() << ":" << loadBarcodes.lastError().text();
        }
    }

    // Colors
    m_colorsLeft = m_colorsAvailable;
}

BarcodeManager::~BarcodeManager()
{
    qDeleteAll(m_barcodes_onscreen);
    m_barcodes_onscreen.clear();

    qDeleteAll(m_barcodes_history);
    m_barcodes_history.clear();

    delete m_nwManager;
    delete firmwareReply;
}

/* ************************************************************************** */

bool BarcodeManager::loadImage(const QUrl &fileUrl)
{
    bool status = false;

#if defined(zxingcpp)
    QImage img;
    if (img.load(fileUrl.toLocalFile()))
    {
        qDeleteAll(m_barcodes_onscreen);
        m_barcodes_onscreen.clear();

        QList<Result> results = ZXingCpp::loadImage(fileUrl);
        for (auto r: results)
        {
            QPointF tl = r.position().topLeft();
            tl.setX(tl.x() / img.width());
            tl.setY(tl.y() / img.height());
            QPointF tr = r.position().topRight();
            tr.setX(tr.x() / img.width());
            tr.setY(tr.y() / img.height());
            QPointF bl = r.position().bottomLeft();
            bl.setX(bl.x() / img.width());
            bl.setY(bl.y() / img.height());
            QPointF br = r.position().bottomRight();
            br.setX(br.x() / img.width());
            br.setY(br.y() / img.height());

            addBarcode(r.text(), r.formatName(), "", "", tl, tr, br, bl, false);
        }

        status = true;
    }
#endif

    return status;
}

/* ************************************************************************** */

QString BarcodeManager::getAvailableColor()
{
    QString clr_str;

    if (m_colorsLeft.size())
    {
        // unique colors
        int clr_id = QRandomGenerator::global()->bounded(m_colorsLeft.size() - 1);
        clr_str = m_colorsLeft.at(clr_id);
        m_colorsLeft.remove(clr_id);
    }
    else
    {
        // start reusing colors
        clr_str = m_colorsAvailable.at(QRandomGenerator::global()->bounded(m_colorsAvailable.size()) - 1);
    }

    return clr_str;
}

bool BarcodeManager::addBarcode(const QString &data, const QString &format,
                                const QString &enc, const QString &ecc,
                                const QPointF &p1, const QPointF &p2, const QPointF &p3, const QPointF &p4,
                                const bool fromVideo)
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

        QDateTime dt;
        if (fromVideo) dt = QDateTime::currentDateTime();

        // add barcode to the onscreen list
        Barcode *bc = new Barcode(data, format, enc, ecc,
                                  dt, getAvailableColor(), this);
        if (bc)
        {
            bc->setLastCoordinates(p1, p2, p3, p4);

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
                                  QDateTime::currentDateTime(), 0, 0, false,
                                  this);
        if (bc)
        {
            qDebug() << "addHistory(" << data << ")";

            // add barcode to the history list
            m_barcodes_history.push_front(bc);
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
