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
#if defined(Q_OS_LINUX) || defined(Q_OS_MACOS) || defined(Q_OS_WINDOWS)
        if (settings.contains("ApplicationWindow/x"))
            m_appPosition.setWidth(settings.value("ApplicationWindow/x").toInt());
        if (settings.contains("ApplicationWindow/y"))
            m_appPosition.setHeight(settings.value("ApplicationWindow/y").toInt());
        if (settings.contains("ApplicationWindow/width"))
            m_appSize.setWidth(settings.value("ApplicationWindow/width").toInt());
        if (settings.contains("ApplicationWindow/height"))
            m_appSize.setHeight(settings.value("ApplicationWindow/height").toInt());
        if (settings.contains("ApplicationWindow/visibility"))
            m_appVisibility = settings.value("ApplicationWindow/visibility").toUInt();

        if (m_appPosition.width() > 8192) m_appPosition.setWidth(100);
        if (m_appPosition.height() > 8192) m_appPosition.setHeight(100);
        if (m_appSize.width() > 8192) m_appSize.setWidth(1920);
        if (m_appSize.height() > 8192) m_appSize.setHeight(1080);
        if (m_appVisibility < 1 || m_appVisibility > 5) m_appVisibility = 1;
#endif

        ////

        if (settings.contains("settings/appTheme"))
            m_appTheme = settings.value("settings/appTheme").toString();

        if (settings.contains("settings/appThemeAuto"))
            m_appThemeAuto = settings.value("settings/appThemeAuto").toBool();

        ////

        if (settings.contains("settings/defaultTab"))
            m_defaultTab = settings.value("settings/defaultTab").toString();

        if (settings.contains("settings/backendWriter"))
            m_backendWriter = settings.value("settings/backendWriter").toString();

        if (settings.contains("settings/formatsEnabled_zxingcpp"))
            m_formatsEnabled_zxingcpp = settings.value("settings/formatsEnabled_zxingcpp").toUInt();
        if (settings.contains("settings/formatsEnabled_qzxing"))
            m_formatsEnabled_qzxing = settings.value("settings/formatsEnabled_qzxing").toUInt();

        ////

        if (settings.contains("settings/saveBarcodes"))
            m_save_barcodes = settings.value("settings/saveBarcodes").toBool();
        if (settings.contains("settings/saveCamera"))
            m_save_camera = settings.value("settings/saveCamera").toBool();
        if (settings.contains("settings/saveGPS"))
            m_save_gps = settings.value("settings/saveGPS").toBool();

        ////

        if (settings.contains("settings/showDebug"))
            m_showDebug = settings.value("settings/showDebug").toBool();

        if (settings.contains("settings/scanFullscreen"))
            m_scan_fullscreen = settings.value("settings/scanFullscreen").toBool();
        if (settings.contains("settings/scanTryHarder"))
            m_scan_tryHarder = settings.value("settings/scanTryHarder").toBool();
        if (settings.contains("settings/scanTryRotate"))
            m_scan_tryRotate = settings.value("settings/scanTryRotate").toBool();
        if (settings.contains("settings/scanTryInvert"))
            m_scan_tryInvert = settings.value("settings/scanTryInvert").toBool();
        if (settings.contains("settings/scanTryDownscale"))
            m_scan_tryDownscale = settings.value("settings/scanTryDownscale").toBool();

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

        settings.setValue("settings/defaultTab", m_defaultTab);
        settings.setValue("settings/backendWriter", m_backendWriter);
        settings.setValue("settings/formatsEnabled_zxingcpp", m_formatsEnabled_zxingcpp);
        settings.setValue("settings/formatsEnabled_qzxing", m_formatsEnabled_qzxing);

        settings.setValue("settings/saveBarcodes", m_save_barcodes);
        settings.setValue("settings/saveCamera", m_save_camera);
        settings.setValue("settings/saveGPS", m_save_gps);

        settings.setValue("settings/showDebug", m_showDebug);
        settings.setValue("settings/scanFullscreen", m_scan_fullscreen);
        settings.setValue("settings/scanTryHarder", m_scan_tryHarder);
        settings.setValue("settings/scanTryRotate", m_scan_tryRotate);
        settings.setValue("settings/scanTryInvert", m_scan_tryInvert);
        settings.setValue("settings/scanTryDownscale", m_scan_tryDownscale);

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

    m_defaultTab = "reader";
    m_backendWriter = "";
    m_formatsEnabled_zxingcpp = 0xffffffff; // ZXing::LinearCodes | ZXing::MatrixCodes;
    m_formatsEnabled_qzxing = 0xffffffff; // QZXing::LinearCodes | QZXing::MatrixCodes;

    m_save_barcodes = false;
    m_save_camera = false;
    m_save_gps = false;

    m_showDebug = false;
    m_scan_fullscreen = false;
    m_scan_tryHarder = true;
    m_scan_tryRotate = true;
    m_scan_tryInvert = true;
    m_scan_tryDownscale = true;

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

QString SettingsManager::getBackendReader() const
{
#if defined(zxingcpp)
    return "zxingcpp";
#elif defined(qzxing)
    return "qzxing";
#endif

    qWarning() << "SettingsManager::getBackendReader() no backend set";
    return "error";
}

QString SettingsManager::getBackendWriter() const
{
    if (m_backendWriter == "qzxing" && getBackendQZXing()) return "qzxing";
    if (m_backendWriter == "zxingcpp" && getBackendZXingCpp()) return "zxingcpp";
    if (m_backendWriter == "zint" && getBackendZint()) return "zint";

    // fallbacks
    if (getBackendZint()) return "zint";
    if (getBackendZXingCpp()) return "zxingcpp";
    if (getBackendQZXing()) return "qzxing";

    qWarning() << "SettingsManager::getBackendWriter() no backend set";
    return "error";
}

void SettingsManager::setBackendWriter(const QString &value)
{
    if (value == "" || value == "qzxing" || value == "zxingcpp" || value == "zint")
    {
        if (m_backendWriter != value)
        {
            m_backendWriter = value;
            Q_EMIT backendWriterChanged();

            writeSettings();
        }
    }
}

bool SettingsManager::getBackendQZXing() const
{
#if defined(qzxing)
    return true;
#endif
    return false;
}

bool SettingsManager::getBackendZXingCpp() const
{
#if defined(zxingcpp)
    return true;
#endif
    return false;
}
bool SettingsManager::getBackendZint() const
{
#if defined(zint)
    return true;
#endif
    return false;
}

void SettingsManager::setDefaultTab(const QString &value)
{
    if (m_defaultTab != value)
    {
        m_defaultTab = value;
        Q_EMIT defaultTabChanged();

        writeSettings();
    }
}

unsigned SettingsManager::getFormatsEnabled() const
{
#if defined(zxingcpp)
    return m_formatsEnabled_zxingcpp;
#elif defined(qzxing)
        return m_formatsEnabled_qzxing;
#endif
}

void SettingsManager::setFormatsEnabled(const unsigned value)
{
#if defined(zxingcpp)
    if (m_formatsEnabled_zxingcpp != value)
    {
        m_formatsEnabled_zxingcpp = value;
        Q_EMIT formatsEnabledChanged();

        writeSettings();
    }
#elif defined(qzxing)
    if (m_formatsEnabled_qzxing != value)
    {
        m_formatsEnabled_qzxing = value;
        Q_EMIT formatsEnabledChanged();

        writeSettings();
    }
#endif
}

void SettingsManager::setSaveBarcode(const bool value)
{
    if (m_save_barcodes != value)
    {
        m_save_barcodes = value;
        Q_EMIT saveChanged();

        writeSettings();
    }
}

void SettingsManager::setSaveCamera(const bool value)
{
    if (m_save_camera != value)
    {
        m_save_camera = value;
        Q_EMIT saveChanged();

        writeSettings();
    }
}

void SettingsManager::setSaveGPS(const bool value)
{
    if (m_save_gps != value)
    {
        m_save_gps = value;
        Q_EMIT saveChanged();

        writeSettings();
    }
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

void SettingsManager::setScanFullscreen(const bool value)
{
    if (m_scan_fullscreen != value)
    {
        m_scan_fullscreen = value;
        Q_EMIT fullscreenChanged();

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

void SettingsManager::setScanTryInvert(const bool value)
{
    if (m_scan_tryInvert != value)
    {
        m_scan_tryInvert = value;
        Q_EMIT tryInvertChanged();

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
