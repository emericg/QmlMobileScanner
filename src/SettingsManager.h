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

#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H
/* ************************************************************************** */

#include <QObject>
#include <QSize>
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

    Q_PROPERTY(QSize initialSize READ getInitialSize NOTIFY initialSizeChanged)
    Q_PROPERTY(QSize initialPosition READ getInitialPosition NOTIFY initialSizeChanged)
    Q_PROPERTY(int initialVisibility READ getInitialVisibility NOTIFY initialSizeChanged)

    Q_PROPERTY(QString appTheme READ getAppTheme WRITE setAppTheme NOTIFY appThemeChanged)
    Q_PROPERTY(bool appThemeAuto READ getAppThemeAuto WRITE setAppThemeAuto NOTIFY appThemeAutoChanged)

    Q_PROPERTY(QString backend_reader READ getBackendReader CONSTANT)
    Q_PROPERTY(QString backend_writer READ getBackendWriter WRITE setBackendWriter NOTIFY backendWriterChanged)
    Q_PROPERTY(bool backend_qzxing READ getBackendQZXing CONSTANT)
    Q_PROPERTY(bool backend_zxingcpp READ getBackendZXingCpp CONSTANT)
    Q_PROPERTY(bool backend_zint READ getBackendZint CONSTANT)

    Q_PROPERTY(QString defaultTab READ getDefaultTab WRITE setDefaultTab NOTIFY defaultTabChanged)
    Q_PROPERTY(unsigned formatsEnabled READ getFormatsEnabled WRITE setFormatsEnabled NOTIFY formatsEnabledChanged)

    Q_PROPERTY(bool save_barcodes READ getSaveBarcode WRITE setSaveBarcode NOTIFY saveChanged)
    Q_PROPERTY(bool save_camera READ getSaveCamera WRITE setSaveCamera NOTIFY saveChanged)
    Q_PROPERTY(bool save_gps READ getSaveGPS WRITE setSaveGPS NOTIFY saveChanged)

    Q_PROPERTY(bool showDebug READ getShowDebug WRITE setShowDebug NOTIFY debugChanged)
    Q_PROPERTY(bool scan_fullres READ getScanFullresolution WRITE setScanFullresolution NOTIFY fullresChanged)
    Q_PROPERTY(bool scan_fullscreen READ getScanFullscreen WRITE setScanFullscreen NOTIFY fullscreenChanged)
    Q_PROPERTY(bool scan_tryHarder READ getScanTryHarder WRITE setScanTryHarder NOTIFY tryHarderChanged)
    Q_PROPERTY(bool scan_tryRotate READ getScanTryRotate WRITE setScanTryRotate NOTIFY tryRotateChanged)
    Q_PROPERTY(bool scan_tryInvert READ getScanTryInvert WRITE setScanTryInvert NOTIFY tryInvertChanged)
    Q_PROPERTY(bool scan_tryDownscale READ getScanTryDownscale WRITE setScanTryDownscale NOTIFY tryDownscaleChanged)

    bool m_firstlaunch = false;

    // Application window
    QSize m_appSize = QSize(1280, 720);
    QSize m_appPosition = QSize(64, 64);
    int m_appVisibility = 1;                        //!< QWindow::Visibility

    // Application generic
    QString m_appTheme = "THEME_MOBILE_LIGHT";
    bool m_appThemeAuto = false;

    // Application specific
    QString m_defaultTab = "reader";
    QString m_backendWriter = "";
    unsigned m_formatsEnabled_zxingcpp = 0xffffffff;
    unsigned m_formatsEnabled_qzxing = 0xffffffff;

    bool m_save_barcodes = true;
    bool m_save_camera = false;
    bool m_save_gps = false;

    bool m_showDebug = false;
    bool m_scan_fullresolution = false;
    bool m_scan_fullscreen = false;
    bool m_scan_tryHarder = true;
    bool m_scan_tryRotate = true;
    bool m_scan_tryInvert = true;
    bool m_scan_tryDownscale = true;

    static SettingsManager *instance;
    SettingsManager();
    ~SettingsManager();

    bool readSettings();
    bool writeSettings();

Q_SIGNALS:
    void firstLaunchChanged();
    void initialSizeChanged();
    void appThemeChanged();
    void appThemeAutoChanged();
    void defaultTabChanged();
    void backendWriterChanged();
    void saveChanged();
    void debugChanged();
    void formatsEnabledChanged();
    void fullresChanged();
    void fullscreenChanged();
    void tryHarderChanged();
    void tryRotateChanged();
    void tryInvertChanged();
    void tryDownscaleChanged();

public:
    static SettingsManager *getInstance();

    bool isFirstLaunch() const { return m_firstlaunch; }

    QSize getInitialSize() { return m_appSize; }
    QSize getInitialPosition() { return m_appPosition; }
    int getInitialVisibility() { return m_appVisibility; }

    ////

    QString getAppTheme() const { return m_appTheme; }
    void setAppTheme(const QString &value);

    bool getAppThemeAuto() const { return m_appThemeAuto; }
    void setAppThemeAuto(const bool value);

    ////

    QString getBackendReader() const;
    QString getBackendWriter() const;
    void setBackendWriter(const QString &value);

    bool getBackendQZXing() const;
    bool getBackendZXingCpp() const;
    bool getBackendZint() const;

    ////

    QString getDefaultTab() const { return m_defaultTab; }
    void setDefaultTab(const QString &value);
    unsigned getFormatsEnabled() const;
    void setFormatsEnabled(const unsigned value);

    bool getSaveBarcode() const { return m_save_barcodes; }
    void setSaveBarcode(const bool value);
    bool getSaveCamera() const { return m_save_camera; }
    void setSaveCamera(const bool value);
    bool getSaveGPS() const { return m_save_gps; }
    void setSaveGPS(const bool value);

    bool getShowDebug() const { return m_showDebug; }
    void setShowDebug(const bool value);
    bool getScanFullresolution() const { return m_scan_fullresolution; }
    void setScanFullresolution(const bool value);
    bool getScanFullscreen() const { return m_scan_fullscreen; }
    void setScanFullscreen(const bool value);
    bool getScanTryHarder() const { return m_scan_tryHarder; }
    void setScanTryHarder(const bool value);
    bool getScanTryRotate() const { return m_scan_tryRotate; }
    void setScanTryRotate(const bool value);
    bool getScanTryInvert() const { return m_scan_tryInvert; }
    void setScanTryInvert(const bool value);
    bool getScanTryDownscale() const { return m_scan_tryDownscale; }
    void setScanTryDownscale(const bool value);

    ////

    Q_INVOKABLE void resetSettings();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
