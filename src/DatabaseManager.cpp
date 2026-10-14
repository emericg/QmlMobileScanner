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

#include "DatabaseManager.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QJSEngine>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

#include <QStandardPaths>
#include <QDateTime>
#include <QFile>
#include <QDir>
#include <QDebug>

/* ************************************************************************** */

DatabaseManager *DatabaseManager::getInstance()
{
    static DatabaseManager *instance = new DatabaseManager(QCoreApplication::instance());
    return instance;
}

DatabaseManager *DatabaseManager::create(QQmlEngine *, QJSEngine *)
{
    DatabaseManager *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
    bool status = false;

    if (!status)
    {
        status = openDatabase_sqlite();
    }

    if (!status)
    {
        qWarning() << "DatabaseManager > NO DATABASE AVAILABLE !!!";
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DatabaseManager::openDatabase_sqlite()
{
    if (QSqlDatabase::isDriverAvailable("QSQLITE") == false)
    {
        qWarning() << "> SQLite is NOT available";
        return false;
    }

    m_dbInternalAvailable = true;

    if (m_dbInternalOpen)
    {
        closeDatabase();
    }

    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dbDirectory(dbPath);

    if (dbPath.isEmpty() == false)
    {
        if (dbDirectory.exists() == false)
        {
            if (dbDirectory.mkpath(dbPath) == false)
            {
                qWarning() << "Cannot create dbDirectory...";
            }
        }
    }
    if (dbPath.isEmpty() || dbDirectory.exists() == false)
    {
        qWarning() << "> Cannot make a SQLite database file";
        return false;
    }

    dbPath += "/data.db";

    QSqlDatabase dbFile(QSqlDatabase::addDatabase("QSQLITE"));
    dbFile.setDatabaseName(dbPath);

    if (dbFile.isOpen())
    {
        m_dbInternalOpen = true;
    }
    else
    {
        if (dbFile.open())
        {
            if (dbFile.isOpenError())
            {
                qWarning() << "Error while opening database:" << dbFile.lastError();
            }

            m_dbInternalOpen = true;

            // Concurrency settings ////////////////////////////////////////////

            // - WAL mode allows one writer and concurrent readers across processes
            // - busy_timeout makes a blocked writer retry instead of failing immediately with SQLITE_BUSY

            QSqlQuery setWalMode("PRAGMA journal_mode = WAL");
            QSqlQuery("PRAGMA synchronous = NORMAL");
            QSqlQuery("PRAGMA busy_timeout = 5000");

            // PRAGMA journal_mode returns the resulting mode, so we warn if WAL wasn't actually applied
            if (setWalMode.next())
            {
                QString journalMode = setWalMode.value(0).toString();
                if (journalMode.compare("wal", Qt::CaseInsensitive) != 0)
                {
                    qWarning() << "Database journal_mode is" << journalMode << "(expected 'wal') !!!";
                }
            }

            // Migration(s) ////////////////////////////////////////////////////

            // Migrate old data tables instead of creating new empty tables
            // Must be done before the creation...

            migrateDatabase();

            // Check if our tables exists //////////////////////////////////////

            createDatabase();

            // Sanitize database ///////////////////////////////////////////////

            // Delete everything 180 days old
            //QSqlQuery sanitizePastData("DELETE FROM barcodes WHERE date < DATE('now', '-" + QString::number(180) + " days')");
        }
        else
        {
            qWarning() << "Cannot open database... Error:" << dbFile.lastError();
        }
    }

    return m_dbInternalOpen;
}

/* ************************************************************************** */

void DatabaseManager::closeDatabase()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (db.isValid())
    {
        QString conName = db.connectionName();

        // close db
        db.close();
        db = QSqlDatabase();
        QSqlDatabase::removeDatabase(conName);

        m_dbInternalOpen = false;
        m_dbExternalOpen = false;
    }
}

/* ************************************************************************** */

void DatabaseManager::resetDatabase()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (db.isValid())
    {
        QString dbName = db.databaseName();
        QString conName = db.connectionName();

        // close db
        db.close();
        db = QSqlDatabase();
        QSqlDatabase::removeDatabase(conName);

        m_dbInternalOpen = false;
        m_dbExternalOpen = false;

        // remove db file, and its WAL journal files
        QFile::remove(dbName);
        QFile::remove(dbName + "-wal");
        QFile::remove(dbName + "-shm");
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DatabaseManager::tableExists(const QString &tableName)
{
    bool result = false;

    if (tableName.isEmpty())
    {
        qWarning() << "tableExists() with empty table name!";
    }
    else
    {
        QSqlQuery checkTable;
        if (m_dbInternalOpen) // sqlite
        {
            checkTable.exec("PRAGMA table_info(" + tableName + ");");
        }
        else if (m_dbExternalOpen) // mysql
        {
            //
        }
        if (checkTable.first())
        {
            result = true;
        }
    }

    return result;
}

/* ************************************************************************** */

void DatabaseManager::createDatabase()
{
    if (!tableExists("version"))
    {
        qDebug() << "+ Adding 'version' table to local database";

        QSqlQuery createDbVersion;
        createDbVersion.prepare("CREATE TABLE version (dbVersion INT);");
        if (createDbVersion.exec())
        {
            QSqlQuery writeDbVersion;
            writeDbVersion.prepare("INSERT INTO version (dbVersion) VALUES (:dbVersion)");
            writeDbVersion.bindValue(":dbVersion", s_dbCurrentVersion);
            writeDbVersion.exec();
        }
        else
        {
            qWarning() << "> createDbVersion.exec() ERROR"
                       << createDbVersion.lastError().type() << ":" << createDbVersion.lastError().text();
        }
    }

    if (!tableExists("barcodes"))
    {
        qDebug() << "+ Adding 'barcodes' table to local database";

        QSqlQuery createBarcodes;
        createBarcodes.prepare("CREATE TABLE barcodes (" \
                                       "data VARCHAR(5120)," \
                                       "format VARCHAR(16)," \
                                       "encoding VARCHAR(8)," \
                                       "ecc VARCHAR(8)," \
                                       "date DATETIME," \
                                       "lat FLOAT," \
                                       "long FLOAT," \
                                       "starred BOOLEAN" \
                                     ");");

        if (createBarcodes.exec() == false)
        {
            qWarning() << "> createBarcodes.exec() ERROR"
                       << createBarcodes.lastError().type() << ":" << createBarcodes.lastError().text();
        }
    }
}

/* ************************************************************************** */
/* ************************************************************************** */

bool DatabaseManager::migrateDatabase()
{
    int dbVersion = 0;

    QSqlQuery readVersion;
    readVersion.prepare("SELECT dbVersion FROM version");
    readVersion.exec();
    if (readVersion.first())
    {
        dbVersion = readVersion.value(0).toInt();
        //qDebug() << "dbVersion is #" << dbVersion;
    }
    readVersion.finish();

    if (dbVersion > 0 && dbVersion != s_dbCurrentVersion)
    {
        qDebug() << "dbVersion is #" << dbVersion;
    }

    return (dbVersion == s_dbCurrentVersion);
}

/* ************************************************************************** */
