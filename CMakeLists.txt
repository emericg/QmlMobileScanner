cmake_minimum_required(VERSION 3.20)

project(QmlMobileScanner VERSION 0.4 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(APP_NAME ${CMAKE_PROJECT_NAME})
set(APP_VERSION ${CMAKE_PROJECT_VERSION})

option(USE_QZXING "Build with QZXing support (decoder&encoder)" OFF)
option(USE_ZXINGCPP "Build with zxing-cpp support (decoder&encoder)" ON)
option(USE_ZINT "Build with zint support (encoder)" OFF)

################################################################################

message(STATUS "[CMAKE]   CMAKE_VERSION             = ${CMAKE_VERSION}")
message(STATUS "[CMAKE]   CMAKE_PREFIX_PATH         = ${CMAKE_PREFIX_PATH}")
message(STATUS "[SYSTEM]  (HOST) SYSTEM NAME        = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "[SYSTEM]  (HOST) SYSTEM VERSION     = ${CMAKE_HOST_SYSTEM_VERSION}")
message(STATUS "[SYSTEM]  (TARGET) SYSTEM NAME      = ${CMAKE_SYSTEM_NAME}")
message(STATUS "[SYSTEM]  (TARGET) SYSTEM VERSION   = ${CMAKE_SYSTEM_VERSION}")
message(STATUS "[PROJECT] SOURCE_DIR                = ${CMAKE_SOURCE_DIR}")
message(STATUS "[PROJECT] BUILD_TYPE                = ${CMAKE_BUILD_TYPE}")
message(STATUS "[PROJECT] TOOLCHAIN_FILE            = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "[PROJECT] QT_HOST_PATH              = ${QT_HOST_PATH}")

################################################################################

find_package(Qt6 REQUIRED COMPONENTS Core Sql Multimedia Positioning)
find_package(Qt6 REQUIRED COMPONENTS Gui Svg Qml Quick QuickControls2)
find_package(Qt6 REQUIRED COMPONENTS LinguistTools)

qt_standard_project_setup(REQUIRES 6.7)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0002 NEW)
qt_policy(SET QTP0003 NEW) # Qt 6.7
#qt_policy(SET QTP0004 NEW) # Qt 6.8

set(SOURCES
    src/main.cpp
    src/SettingsManager.cpp src/SettingsManager.h
    src/DatabaseManager.cpp src/DatabaseManager.h
    src/PermissionManager.cpp src/PermissionManager.h
    src/BarcodeManager.cpp src/BarcodeManager.h
    src/Barcode.cpp src/Barcode.h
    src/utils_camera.cpp src/utils_camera.h

    assets/assets.qrc
    thirdparty/IconLibrary/IconLibrary_material.qrc
)

if (IOS OR ANDROID)
    # Mobile
    set(QAPPLICATION_CLASS QGuiApplication)
else()
    # Desktop
    set(QAPPLICATION_CLASS QApplication)
endif()

qt_add_executable(${CMAKE_PROJECT_NAME} ${SOURCES} ${SOURCES_DESKTOP} ${SOURCES_MOBILE})

qt_add_qml_module(${CMAKE_PROJECT_NAME}
    URI ${CMAKE_PROJECT_NAME}
    QML_FILES
        qml/MobileApplication.qml
        qml/MobileHeader.qml
        qml/MobileDrawer.qml
        qml/MobilePermissions.qml
        qml/DesktopApplication.qml
        qml/DesktopSidebar.qml

        qml/ScreenTutorial.qml
        qml/ScreenMainMenu.qml
        qml/ScreenSettings.qml
        qml/ScreenAbout.qml
        qml/ScreenAboutFormats.qml

        qml/ScreenBarcodeReader.qml
        qml/ScreenBarcodeHistory.qml
        qml/ScreenBarcodeDetails.qml
        qml/ScreenBarcodeWriter.qml
        qml/Reader_QZXing.qml
        qml/Reader_ZXingCpp.qml
        qml/Writer_QZXing.qml
        qml/Writer_ZXingCpp.qml
        qml/Writer_Zint.qml

        qml/popups/PopupBarcodeFullscreen.qml
        qml/popups/PopupHistoryDelete.qml

        qml/components/MenuDebug.qml
        qml/components/MenuCamera.qml
        qml/components/MenuFormats.qml
        qml/components/MenuScreens.qml
        qml/components/WidgetBarcodeHistory.qml
        qml/components/WidgetBarcodeResult.qml
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE src/)

################################################################################

qt_standard_project_setup(
    I18N_SOURCE_LANGUAGE en
    I18N_TRANSLATED_LANGUAGES fr
)
qt_add_translations(${CMAKE_PROJECT_NAME}
    TS_FILE_BASE ${CMAKE_PROJECT_NAME}
    TS_FILE_DIR ${CMAKE_SOURCE_DIR}/i18n/
    RESOURCE_PREFIX "/i18n"
)

################################################################################

# Qt libraries
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Sql
    Qt6::Multimedia
    Qt6::Positioning
    Qt6::Sql
    Qt6::Gui
    Qt6::Svg
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

if (NOT IOS AND NOT ANDROID)
    # for proper systray and menubar support
    find_package(Qt6 REQUIRED COMPONENTS Widgets)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt6::Widgets)
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    #
endif()

################################################################################

# AppUtils
set(UTILS_CLIPBOARD true)
set(UTILS_DOCK_ENABLED true)
add_subdirectory(thirdparty/AppUtils)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE AppUtils)

# MobileUI
add_subdirectory(thirdparty/MobileUI)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE MobileUI)

# MobileSharing
add_subdirectory(thirdparty/MobileSharing)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE MobileSharing)

# ComponentLibrary
add_subdirectory(thirdparty/ComponentLibrary)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ComponentLibraryplugin)

if (USE_ZXINGCPP)
    # build zxing-cpp
    add_subdirectory(thirdparty/zxing-cpp)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ZXing)

    # build zxing-cpp Qt wrapper
    add_subdirectory(thirdparty/zxing-cpp/wrappers/qt)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ZXingQt)

    set(zxingcpp true)
    add_definitions(-Dzxingcpp)
elseif (USE_QZXING)
    # build QZxing
    add_subdirectory(thirdparty/QZXing)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE QZXing)

    set(qzxing true)
    add_definitions(-Dqzxing)
else()
endif()

if (USE_ZINT)
    # build zint
    add_subdirectory(thirdparty/zint-qml)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE zint)

    # build ZintQml
    add_subdirectory(thirdparty/zint-qml/wrappers/qml)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ZintQml)

    set(zint true)
    add_definitions(-Dzint)
endif()

################################################################################

## Android
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        #QT_ANDROID_ABIS "armeabi-v7a;arm64-v8a;x86;x86_64"
        #QT_ANDROID_BUILD_ALL_ABIS ON
        QT_ANDROID_MIN_SDK_VERSION 23
        QT_ANDROID_TARGET_SDK_VERSION 36
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/assets/android/"
    )
endif()

## macOS
if (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    #set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")

    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/assets/macos/Info.plist"
        # New Xcode attributes (???)
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER           "io.emeric.qmlmobilescanner"
        XCODE_ATTRIBUTE_PRODUCT_NAME                        ${CMAKE_PROJECT_NAME}
        XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION             ${CMAKE_PROJECT_VERSION}
        XCODE_ATTRIBUTE_MARKETING_VERSION                   ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS             "${CMAKE_SOURCE_DIR}/assets/macos/${CMAKE_PROJECT_NAME}.entitlements"
        #XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME  AppIcon
    )
endif()

## iOS
if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
    #set(app_icon_ios "${CMAKE_SOURCE_DIR}/assets/ios/Assets.xcassets")
    #set_source_files_properties(${app_icon_ios} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/assets/ios/Info.plist"
        # Qt
        #QT_IOS_LAUNCH_SCREEN "${CMAKE_SOURCE_DIR}/assets/ios/LaunchScreen.storyboard"
        # New Xcode attributes (???)
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER           "io.emeric.qmlmobilescanner"
        XCODE_ATTRIBUTE_PRODUCT_NAME                        ${CMAKE_PROJECT_NAME}
        XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION             ${CMAKE_PROJECT_VERSION}
        XCODE_ATTRIBUTE_MARKETING_VERSION                   ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET          "14.0"
        XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY              "1,2"   # iPhone,iPad
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME  "AppIcon"
        XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS      "YES"
    )
endif()

## Windows
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    #set(app_icon_windows "${CMAKE_SOURCE_DIR}/assets/windows/${CMAKE_PROJECT_NAME}.rc")

    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

## Release build? Set "no debug" macros
if (CMAKE_BUILD_TYPE STREQUAL Release)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
        NDEBUG
        QT_NO_DEBUG
        QT_NO_DEBUG_OUTPUT
    )
endif()

################################################################################

# Output?
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
    #ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib"
    #LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin"
)

# Output?
install(TARGETS ${CMAKE_PROJECT_NAME}
    BUNDLE DESTINATION "${CMAKE_SOURCE_DIR}/bin"
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

################################################################################
