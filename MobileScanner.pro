TARGET  = MobileScanner

VERSION = 0.1
DEFINES+= APP_NAME=\\\"$$TARGET\\\"
DEFINES+= APP_VERSION=\\\"$$VERSION\\\"

CONFIG += c++17
QT     += core concurrent qml quickcontrols2 svg sql

# Validate Qt version
!versionAtLeast(QT_VERSION, 6.5) : error("You need at least Qt version 6.5 for $${TARGET}")

# Build settings ###############################################################

# Select primary backend (zxingcpp / qzxing)
CONFIG += zxingcpp
# Select secondary backend (zint)
CONFIG += zint

# Use Qt Quick compiler
ios | android { CONFIG += qtquickcompiler }

# Debug defines
CONFIG(release, debug|release) : DEFINES += NDEBUG QT_NO_DEBUG QT_NO_DEBUG_OUTPUT

# Build artifacts ##############################################################

OBJECTS_DIR = build/$${QT_ARCH}/
MOC_DIR     = build/$${QT_ARCH}/
RCC_DIR     = build/$${QT_ARCH}/
UI_DIR      = build/$${QT_ARCH}/

DESTDIR     = bin/

# Project files ################################################################

SOURCES  += src/main.cpp \
            src/SettingsManager.cpp \
            src/DatabaseManager.cpp \
            src/BarcodeManager.cpp \
            src/Barcode.cpp

HEADERS  += src/DatabaseManager.h  \
            src/SettingsManager.h \
            src/BarcodeManager.h \
            src/Barcode.h

INCLUDEPATH += src/ src/thirdparty/

RESOURCES   += qml/qml.qrc \
               qml/components.qrc \
               assets/assets.qrc

OTHER_FILES += .gitignore \
               README.md

# Project dependencies #########################################################

# AppUtils
include(src/thirdparty/AppUtils/AppUtils.pri)

# Utils for mobile OS
include(src/thirdparty/MobileUI/MobileUI.pri)
include(src/thirdparty/MobileSharing/MobileSharing.pri)

# Barcode scanner (zxing-cpp)
CONFIG(zxingcpp, zxingcpp|qzxing) {
    message("Building MobileScanner with zxing-cpp backend")
    include(src/thirdparty/zxing-cpp/zxing-cpp.pri)
    DEFINES += zxingcpp
}

# Barcode scanner (QZXing)
CONFIG(qzxing, zxingcpp|qzxing) {
    message("Building MobileScanner with QZXing backend")
    include(src/thirdparty/QZXing/QZXing.pri)
    DEFINES += qzxing
}

# Barcode writer (zint)
CONFIG(zint) {
    message("Building MobileScanner with zint backend")
    include(src/thirdparty/zint-qml/zint-qml.pri)
    DEFINES += zint
}

# Application deployment #######################################################

linux:!android {
    TARGET = $$lower($${TARGET})
}

android {
    # ANDROID_TARGET_ARCH: [x86_64, armeabi-v7a, arm64-v8a]
    #message("ANDROID_TARGET_ARCH: $$ANDROID_TARGET_ARCH")

    # Bundle name
    QMAKE_TARGET_BUNDLE_PREFIX = io.emeric
    QMAKE_BUNDLE = mobilescanner

    ANDROID_PACKAGE_SOURCE_DIR = $${PWD}/assets/android

    DISTFILES += $${PWD}/assets/android/AndroidManifest.xml \
                 $${PWD}/assets/android/gradle.properties \
                 $${PWD}/assets/android/build.gradle
}

macx {
    #QMAKE_MACOSX_DEPLOYMENT_TARGET = 11.0
    #message("QMAKE_MACOSX_DEPLOYMENT_TARGET: $$QMAKE_MACOSX_DEPLOYMENT_TARGET")

    # Bundle name
    QMAKE_TARGET_BUNDLE_PREFIX = io.emeric
    QMAKE_BUNDLE = mobilescanner
    CONFIG += app_bundle
}

ios {
    #QMAKE_IOS_DEPLOYMENT_TARGET = 12.0
    #message("QMAKE_IOS_DEPLOYMENT_TARGET: $$QMAKE_IOS_DEPLOYMENT_TARGET")

    CONFIG += no_autoqmake

    # Bundle name
    QMAKE_TARGET_BUNDLE_PREFIX = io.emeric
    QMAKE_BUNDLE = mobilescanner

    # OS infos
    QMAKE_INFO_PLIST = $${PWD}/assets/ios/Info.plist
    QMAKE_APPLE_TARGETED_DEVICE_FAMILY = 1,2 # 1: iPhone / 2: iPad / 1,2: Universal

    # iOS developer settings
    exists($${PWD}/assets/ios/ios_signature.pri) {
        # Must contain values for:
        # QMAKE_DEVELOPMENT_TEAM
        # QMAKE_PROVISIONING_PROFILE
        include($${PWD}/assets/ios/ios_signature.pri)
    }
}
