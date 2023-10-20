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

#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QDateTime>

/* ************************************************************************** */

/*!
 * \brief The SettingsManager class
 */
class SettingsManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool firstLaunch READ isFirstLaunch NOTIFY firstLaunchChanged)
    Q_PROPERTY(QString appTheme READ getAppTheme WRITE setAppTheme NOTIFY appThemeChanged)
    Q_PROPERTY(bool appThemeAuto READ getAppThemeAuto WRITE setAppThemeAuto NOTIFY appThemeAutoChanged)

    Q_PROPERTY(QString backend READ getBackend CONSTANT)
    Q_PROPERTY(QString defaultTab READ getDefaultTab WRITE setDefaultTab NOTIFY defaultTabChanged)

    Q_PROPERTY(bool showDebug READ getShowDebug WRITE setShowDebug NOTIFY debugChanged)
    Q_PROPERTY(bool scan_tryHarder READ getScanTryHarder WRITE setScanTryHarder NOTIFY tryHarderChanged)
    Q_PROPERTY(bool scan_tryRotate READ getScanTryRotate WRITE setScanTryRotate NOTIFY tryRotateChanged)
    Q_PROPERTY(bool scan_tryDownscale READ getScanTryDownscale WRITE setScanTryDownscale NOTIFY tryDownscaleChanged)

    bool m_firstlaunch = false;
    QString m_appTheme = "light";
    bool m_appThemeAuto = false;

    QString m_defaultTab = "reader";
    bool m_showDebug = false;
    bool m_scan_tryHarder = true;
    bool m_scan_tryRotate = false;
    bool m_scan_tryDownscale = false;

    static SettingsManager *instance;
    SettingsManager();
    ~SettingsManager();

    bool readSettings();
    bool writeSettings();

Q_SIGNALS:
    void firstLaunchChanged();
    void appThemeChanged();
    void appThemeAutoChanged();
    void debugChanged();
    void defaultTabChanged();
    void tryHarderChanged();
    void tryRotateChanged();
    void tryDownscaleChanged();

public:
    static SettingsManager *getInstance();

    bool isFirstLaunch() const { return m_firstlaunch; }

    QString getAppTheme() const { return m_appTheme; }
    void setAppTheme(const QString &value);

    bool getAppThemeAuto() const { return m_appThemeAuto; }
    void setAppThemeAuto(const bool value);

    // app specific
    QString getBackend() const;
    QString getDefaultTab() const { return m_defaultTab; }
    void setDefaultTab(const QString &value);
    bool getShowDebug() const { return m_showDebug; }
    void setShowDebug(const bool value);
    bool getScanTryHarder() const { return m_scan_tryHarder; }
    void setScanTryHarder(const bool value);
    bool getScanTryRotate() const { return m_scan_tryRotate; }
    void setScanTryRotate(const bool value);
    bool getScanTryDownscale() const { return m_scan_tryDownscale; }
    void setScanTryDownscale(const bool value);

    // Utils
    Q_INVOKABLE void resetSettings();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
