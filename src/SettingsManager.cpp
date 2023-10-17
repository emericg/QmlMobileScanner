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

#include "SettingsManager.h"

#include <QCoreApplication>
#include <QStandardPaths>
#include <QSettings>
#include <QLocale>
#include <QDir>
#include <QDebug>

#include <cmath>

/* ************************************************************************** */

SettingsManager *SettingsManager::instance = nullptr;

SettingsManager *SettingsManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new SettingsManager();
        return instance;
    }

    return instance;
}

SettingsManager::SettingsManager()
{
    readSettings();
}

SettingsManager::~SettingsManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

bool SettingsManager::readSettings()
{
    bool status = false;

    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());

    if (settings.status() == QSettings::NoError)
    {
        if (settings.contains("settings/appTheme"))
            m_appTheme = settings.value("settings/appTheme").toString();

        if (settings.contains("settings/appThemeAuto"))
            m_appThemeAuto = settings.value("settings/appThemeAuto").toBool();

        if (settings.contains("settings/showDebug"))
            m_showDebug = settings.value("settings/showDebug").toBool();

        if (settings.contains("settings/tryHarder"))
            m_scan_tryHarder = settings.value("settings/tryHarder").toBool();
        if (settings.contains("settings/tryRotate"))
            m_scan_tryRotate = settings.value("settings/tryRotate").toBool();
        if (settings.contains("settings/tryDownscale"))
            m_scan_tryDownscale = settings.value("settings/tryDownscale").toBool();

        status = true;
    }
    else
    {
        qWarning() << "SettingsManager::readSettings() error:" << settings.status();
    }

    if (m_firstlaunch)
    {
        // force settings file creation
        writeSettings();
    }

    return status;
}

/* ************************************************************************** */

bool SettingsManager::writeSettings()
{
    bool status = false;

    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());

    if (settings.isWritable())
    {
        settings.setValue("settings/appTheme", m_appTheme);
        settings.setValue("settings/appThemeAuto", m_appThemeAuto);

        settings.setValue("settings/showDebug", m_showDebug);
        settings.setValue("settings/tryHarder", m_scan_tryHarder);
        settings.setValue("settings/tryRotate", m_scan_tryRotate);
        settings.setValue("settings/tryDownscale", m_scan_tryDownscale);

        if (settings.status() == QSettings::NoError)
        {
            status = true;
        }
        else
        {
            qWarning() << "SettingsManager::writeSettings() error:" << settings.status();
        }
    }
    else
    {
        qWarning() << "SettingsManager::writeSettings() error: read only file?";
    }

    return status;
}

/* ************************************************************************** */

void SettingsManager::resetSettings()
{
    m_appTheme = "light";
    Q_EMIT appThemeChanged();
    m_appThemeAuto = false;
    Q_EMIT appThemeAutoChanged();

    m_showDebug = false;
    m_scan_tryRotate = false;
    m_scan_tryHarder = false;
    m_scan_tryDownscale = false;

    writeSettings();
}

/* ************************************************************************** */
/* ************************************************************************** */

void SettingsManager::setAppTheme(const QString &value)
{
    if (m_appTheme != value)
    {
        m_appTheme = value;
        Q_EMIT appThemeChanged();

        writeSettings();
    }
}

void SettingsManager::setAppThemeAuto(const bool value)
{
    if (m_appThemeAuto != value)
    {
        m_appThemeAuto = value;
        Q_EMIT appThemeAutoChanged();

        writeSettings();
    }
}

/* ************************************************************************** */

QString SettingsManager::getBackend() const
{
#if defined(qzxing)
    return "qzxing";
#elif defined(zxingcpp)
    return "zxingcpp";
#endif

    qWarning() << "SettingsManager::getBackend() no backend set";
    return "error";
}

void SettingsManager::setShowDebug(const bool value)
{
    if (m_showDebug != value)
    {
        m_showDebug = value;
        Q_EMIT debugChanged();

        writeSettings();
    }
}

void SettingsManager::setScanTryHarder(const bool value)
{
    if (m_scan_tryHarder != value)
    {
        m_scan_tryHarder = value;
        Q_EMIT tryHarderChanged();

        writeSettings();
    }
}

void SettingsManager::setScanTryRotate(const bool value)
{
    if (m_scan_tryRotate != value)
    {
        m_scan_tryRotate = value;
        Q_EMIT tryRotateChanged();

        writeSettings();
    }
}

void SettingsManager::setScanTryDownscale(const bool value)
{
    if (m_scan_tryDownscale != value)
    {
        m_scan_tryDownscale = value;
        Q_EMIT tryDownscaleChanged();

        writeSettings();
    }
}

/* ************************************************************************** */
