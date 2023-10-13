
#include "SettingsManager.h"

#include "utils_app.h"
#include "utils_screen.h"

#include <MobileUI/MobileUI.h>

#if defined(qzxing)
#include <QZXing/QZXing.h>
#endif

#if defined(zxingcpp)
#include "zxing-cpp/ZXingQtReader.h"
#endif

#include <QtGlobal>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

/* ************************************************************************** */

int main(int argc, char *argv[])
{
#if defined(Q_OS_ANDROID)
    // Force "old" Android native multimedia backend
    qputenv("QT_MEDIA_BACKEND", "android");
#endif

    QGuiApplication app(argc, argv);

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    QIcon appIcon(":/assets/logos/logo_black.svg");
    app.setWindowIcon(appIcon);
#endif

    // Application name
    app.setApplicationName("MobileScanner");
    app.setApplicationDisplayName("MobileScanner");
    app.setOrganizationName("emeric");
    app.setOrganizationDomain("emeric");

    // Init app components
    SettingsManager *stm = SettingsManager::getInstance();
    if (!stm) return EXIT_FAILURE;

    // Init utils
    UtilsScreen *utilsScreen = UtilsScreen::getInstance();
    if (!utilsScreen) return EXIT_FAILURE;

    UtilsApp *utilsApp = UtilsApp::getInstance();
    if (!utilsApp) return EXIT_FAILURE;

    // ThemeEngine
    qmlRegisterSingletonType(QUrl("qrc:/qml/ThemeEngine.qml"), "ThemeEngine", 1, 0, "Theme");

    // Mobile UI
    qmlRegisterType<MobileUI>("MobileUI", 1, 0, "MobileUI");

    // QML engine
    QQmlApplicationEngine engine;

#if defined(qzxing)
    // Barcode (QZXing)
    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);
#endif

#if defined(zxingcpp)
    // Barcode (zxing-cpp)
    ZXingQt::registerQmlAndMetaTypes();
#endif

    // Then we start the UI
    QQmlContext *engine_context = engine.rootContext();
    engine_context->setContextProperty("settingsManager", stm);
    engine_context->setContextProperty("utilsScreen", utilsScreen);
    engine_context->setContextProperty("utilsApp", utilsApp);

    engine.load(QUrl(QStringLiteral("qrc:/qml/MobileApplication.qml")));
    if (engine.rootObjects().isEmpty()) return EXIT_FAILURE;

#if defined(Q_OS_ANDROID)
    QNativeInterface::QAndroidApplication::hideSplashScreen(133);
#endif

    return app.exec();
}

/* ************************************************************************** */
