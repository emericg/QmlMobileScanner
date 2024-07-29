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
#include "SettingsManager.h"
#include "BarcodeManager.h"

#include "utils_app.h"
#include "utils_screen.h"
#include "utils_camera.h"
#include "utils_clipboard.h"
#include "utils_fpsmonitor.h"

#include <MobileUI>
#include <MobileSharing>

#if defined(qzxing)
#include <QZXing>
#endif

#if defined(zxingcpp)
#include <ZXingCpp>
#endif

#if defined(zint)
#include <ZintQml>
#endif

#include <QtGlobal>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#if QT_CONFIG(permissions)
#include <QPermissions>
#endif

/* ************************************************************************** */

int main(int argc, char *argv[])
{
#if defined(Q_OS_ANDROID) && (QT_VERSION <= QT_VERSION_CHECK(6,6,1))
    // Force "old" Android native multimedia backend
    // android backend doesn't work past Qt 6.6.1
    // ffmpeg backend doesn't work below Qt 6.6.2
    // (ffmpeg multimedia backend is buggy as hell...)
    qputenv("QT_MEDIA_BACKEND", "android");
#endif

    QGuiApplication app(argc, argv);

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    QIcon appIcon(":/assets/gfx/logos/logo_black.svg");
    app.setWindowIcon(appIcon);
#endif

    // Application name
    app.setApplicationName("QmlMobileScanner");
    app.setApplicationDisplayName("QmlMobileScanner");
    app.setOrganizationName("emeric");
    app.setOrganizationDomain("emeric");

    // Init app components
    DatabaseManager *dbm = DatabaseManager::getInstance();
    if (!dbm) return EXIT_FAILURE;

    SettingsManager *stm = SettingsManager::getInstance();
    if (!stm) return EXIT_FAILURE;

    BarcodeManager *bch = BarcodeManager::getInstance();
    if (!bch) return EXIT_FAILURE;

    // Init app utils
    UtilsScreen *utilsScreen = UtilsScreen::getInstance();
    if (!utilsScreen) return EXIT_FAILURE;

    UtilsCamera *utilsCamera = UtilsCamera::getInstance();
    if (!utilsCamera) return EXIT_FAILURE;

    UtilsClipboard *utilsClipboard = new UtilsClipboard();
    if (!utilsClipboard) return EXIT_FAILURE;

    UtilsApp *utilsApp = UtilsApp::getInstance();
    if (!utilsApp) return EXIT_FAILURE;

    // ThemeEngine
    qmlRegisterSingletonType(QUrl("qrc:/qml/ThemeEngine.qml"), "ThemeEngine", 1, 0, "Theme");

    // Mobile UI
    qmlRegisterType<MobileUI>("MobileUI", 1, 0, "MobileUI");

    // QML engine
    QQmlApplicationEngine engine;
    QQmlContext *engine_context = engine.rootContext();
    engine_context->setContextProperty("settingsManager", stm);
    engine_context->setContextProperty("barcodeManager", bch);
    engine_context->setContextProperty("utilsScreen", utilsScreen);
    engine_context->setContextProperty("utilsCamera", utilsCamera);
    engine_context->setContextProperty("utilsClipboard", utilsClipboard);
    engine_context->setContextProperty("utilsApp", utilsApp);

#if QT_CONFIG(permissions)
    if (qApp->checkPermission(QCameraPermission{}) != Qt::PermissionStatus::Granted) {
        qApp->requestPermission(QCameraPermission{}, [](const QPermission &permission) {
            if (permission.status() != Qt::PermissionStatus::Granted) {
                qWarning() << "Impossible to get Camera permission!";
            }
        });
    }
#endif

#if defined(qzxing)
    // Barcode (QZXing)
    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);
#endif

#if defined(zxingcpp)
    // Barcode (zxing-cpp)
    ZXingCpp::registerQMLTypes();
    ZXingCpp::registerQMLImageProvider(engine);
#endif

#if defined(zint)
    // Barcode generator (zint-qml)
    ZintQml::registerQMLTypes();
    ZintQml::registerQMLImageProvider(engine);
#endif

    // Then we start the UI
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(FORCE_MOBILE_UI)
    engine.load(QUrl(QStringLiteral("qrc:/qml/MobileApplication.qml")));
#else
    engine.load(QUrl(QStringLiteral("qrc:/qml/DesktopApplication.qml")));
#endif

    if (engine.rootObjects().isEmpty())
    {
        qWarning() << "Cannot init QmlApplicationEngine!";
        return EXIT_FAILURE;
    }

    // Setup FPS monitor
    QQuickWindow *window = qobject_cast<QQuickWindow*>(engine.rootObjects().at(0));
    FrameRateMonitor *utilsFpsMonitor = new FrameRateMonitor(window);
    engine_context->setContextProperty("utilsFpsMonitor", utilsFpsMonitor);

#if defined(Q_OS_ANDROID)
    QNativeInterface::QAndroidApplication::hideSplashScreen(233);
#endif

    return app.exec();
}

/* ************************************************************************** */
