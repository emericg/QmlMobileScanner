cmake_minimum_required(VERSION 3.20)

project(QmlMobileScanner VERSION 0.5 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(APP_NAME ${PROJECT_NAME})
set(APP_VERSION ${PROJECT_VERSION})

option(USE_ZINT "Build with zint support (encoder)"                             ON)
option(USE_ZXINGCPP "Build with zxing-cpp support (decoder & encoder)"          ON)
option(USE_QZXING "Build with QZXing support (decoder & encoder) (LEGACY)"      OFF)

################################################################################

message(STATUS ">>> BUILDING ${PROJECT_NAME} v${PROJECT_VERSION} >>>")
message(STATUS "[CMAKE] CMAKE_VERSION               = ${CMAKE_VERSION}")
message(STATUS "[CMAKE] CMAKE_PREFIX_PATH           = ${CMAKE_PREFIX_PATH}")
message(STATUS "[BUILD] QT_HOST_PATH                = ${QT_HOST_PATH}")
message(STATUS "[BUILD] TOOLCHAIN_FILE              = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "[BUILD] BUILD_TYPE                  = ${CMAKE_BUILD_TYPE}")
message(STATUS "[SYSTEM] (HOST) SYSTEM NAME         = ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "[SYSTEM] (HOST) SYSTEM VERSION      = ${CMAKE_HOST_SYSTEM_VERSION}")
message(STATUS "[SYSTEM] (HOST) SYSTEM PROCESSOR    = ${CMAKE_HOST_SYSTEM_PROCESSOR}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM NAME       = ${CMAKE_SYSTEM_NAME}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM VERSION    = ${CMAKE_SYSTEM_VERSION}")
message(STATUS "[SYSTEM] (TARGET) SYSTEM PROCESSOR  = ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "[TOP PROJECT] CMAKE_PROJECT_NAME    = ${CMAKE_PROJECT_NAME}")
message(STATUS "[TOP PROJECT] CMAKE_PROJECT_VERSION = ${CMAKE_PROJECT_VERSION}")
message(STATUS "[TOP PROJECT] CMAKE_SOURCE_DIR      = ${CMAKE_SOURCE_DIR}")
message(STATUS "[PROJECT] PROJECT_NAME              = ${PROJECT_NAME}")
message(STATUS "[PROJECT] PROJECT_VERSION           = ${PROJECT_VERSION}")
message(STATUS "[PROJECT] PROJECT_SOURCE_DIR        = ${PROJECT_SOURCE_DIR}")
message(STATUS "[PROJECT] CMAKE_CURRENT_SOURCE_DIR  = ${CMAKE_CURRENT_SOURCE_DIR}")

################################################################################

find_package(Qt6 REQUIRED COMPONENTS Core Gui Svg Qml Quick QuickControls2)
find_package(Qt6 REQUIRED COMPONENTS Sql Multimedia Positioning)
find_package(Qt6 REQUIRED COMPONENTS LinguistTools)

qt_standard_project_setup(REQUIRES 6.8
                          I18N_SOURCE_LANGUAGE en
                          I18N_TRANSLATED_LANGUAGES en)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0002 NEW)
qt_policy(SET QTP0003 NEW)
qt_policy(SET QTP0004 NEW)

set(SOURCES
    src/main.cpp
    src/SettingsManager.cpp src/SettingsManager.h
    src/DatabaseManager.cpp src/DatabaseManager.h
    src/PermissionManager.cpp src/PermissionManager.h
    src/BarcodeManager.cpp src/BarcodeManager.h
    src/Barcode.cpp src/Barcode.h
    src/utils_camera.cpp src/utils_camera.h
    src/utils_barcode.cpp src/utils_barcode.h

    assets/assets.qrc
    thirdparty/IconLibrary/IconLibrary_material.qrc
)

if(IOS OR ANDROID) # Mobile

    set(QAPPLICATION_CLASS QGuiApplication)

else() # Desktop

    set(QAPPLICATION_CLASS QApplication)

    # Set app icons
    #if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    #    set(SOURCES_DESKTOP "${PROJECT_SOURCE_DIR}/assets/windows/${PROJECT_NAME}.rc")
    #elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    #    set(SOURCES_DESKTOP "${PROJECT_SOURCE_DIR}/assets/macos/${PROJECT_NAME}.icns")
    #endif()
endif()

qt_add_executable(${PROJECT_NAME} ${SOURCES} ${SOURCES_DESKTOP} ${SOURCES_MOBILE})

qt_add_ios_ffmpeg_libraries(${PROJECT_NAME})

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
    NO_PLUGIN
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

qt_add_translations(${PROJECT_NAME}
    TS_FILE_BASE ${PROJECT_NAME}
    TS_FILE_DIR ${PROJECT_SOURCE_DIR}/i18n/
    RESOURCE_PREFIX "/i18n"
)

################################################################################

# "Other Files" macro
function(add_other_files target)
    foreach(file IN LISTS ARGN)
        target_sources(${target} PRIVATE ${file})
        source_group("Other Files" FILES ${file})
    endforeach()
endfunction()

add_other_files(${PROJECT_NAME}
    README.md LICENSE.md TODO.md
    .github/workflows/builds_mobile.yml
    .gitignore
)

################################################################################

# AppUtils
set(UTILS_CLIPBOARD true CACHE BOOL "UTILS_CLIPBOARD" FORCE)
set(UTILS_DOCK_ENABLED true CACHE BOOL "UTILS_DOCK_ENABLED" FORCE)
add_subdirectory(thirdparty/AppUtils)
target_link_libraries(${PROJECT_NAME} PRIVATE AppUtils)

# MobileUI
add_subdirectory(thirdparty/MobileUI)
target_link_libraries(${PROJECT_NAME} PRIVATE MobileUI MobileUI_plugin)

# MobileSharing
add_subdirectory(thirdparty/MobileSharing)
target_link_libraries(${PROJECT_NAME} PRIVATE MobileSharing MobileSharing_plugin)

# ComponentLibrary
add_subdirectory(thirdparty/ComponentLibrary)
target_link_libraries(${PROJECT_NAME} PRIVATE ComponentLibrary_plugin)

if(USE_ZXINGCPP)
    # build zxing-cpp
    add_subdirectory(thirdparty/zxing-cpp)
    target_link_libraries(${PROJECT_NAME} PRIVATE ZXing)

    # build zxing-cpp Qt wrapper
    add_subdirectory(thirdparty/zxing-cpp/wrappers/qt)
    target_link_libraries(${PROJECT_NAME} PRIVATE ZXingQt)
    target_compile_definitions(${PROJECT_NAME} PRIVATE QMS_USE_ZXINGCPP)
elseif(USE_QZXING)
    # build QZXing
    add_subdirectory(thirdparty/QZXing)
    target_link_libraries(${PROJECT_NAME} PRIVATE QZXing)
    target_compile_definitions(${PROJECT_NAME} PRIVATE QMS_USE_QZXING)
else()
    #
endif()

if(USE_ZINT)
    # build zint
    add_subdirectory(thirdparty/zint-qml)
if (BUILD_SHARED_LIBS)
    target_link_libraries(${PROJECT_NAME} PRIVATE zint)
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE zint-static)
endif()

    # build Zint QML wrapper
    add_subdirectory(thirdparty/zint-qml/wrappers/qml)
    target_link_libraries(${PROJECT_NAME} PRIVATE ZintQml)
    target_compile_definitions(${PROJECT_NAME} PRIVATE QMS_USE_ZINT)
endif()

# Qt libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Svg
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
    Qt6::Multimedia
    Qt6::Positioning
)
if(NOT IOS AND NOT ANDROID)
    # for proper systray and menubar support
    find_package(Qt6 REQUIRED COMPONENTS Widgets)
    target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Widgets)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE src/)
target_include_directories(${PROJECT_NAME} PRIVATE thirdparty/)

# Qt official hacks...
set(QML_IMPORT_PATH
    "${CMAKE_BINARY_DIR}/thirdparty/"
    "${CMAKE_BINARY_DIR}/thirdparty/MobileUI"
    "${CMAKE_BINARY_DIR}/thirdparty/ComponentLibrary"
    CACHE STRING "QML Modules import paths" FORCE)

# Qt official hacks...
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

################################################################################

## Release build? Set "no debug" macros
target_compile_definitions(${PROJECT_NAME} PRIVATE
    $<$<CONFIG:Release>:NDEBUG>
    $<$<CONFIG:Release>:QT_NO_DEBUG>
    $<$<CONFIG:Release>:QT_NO_DEBUG_OUTPUT>
)

################################################################################

include(GNUInstallDirs)

## Linux
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # System install rules
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin/)
    #install(FILES ${PROJECT_SOURCE_DIR}/assets/linux/${PROJECT_NAME}.desktop DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications/)
    #install(FILES ${PROJECT_SOURCE_DIR}/assets/linux/${PROJECT_NAME}.appdata.xml DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/appdata/)
    #install(FILES ${PROJECT_SOURCE_DIR}/assets/linux/${PROJECT_NAME}.svg DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pixmaps/)
    #install(FILES ${PROJECT_SOURCE_DIR}/assets/linux/${PROJECT_NAME}.svg DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/scalable/apps/)
    #install(FILES ${PROJECT_SOURCE_DIR}/LICENSE.md DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licenses/${PROJECT_NAME}/)
endif()

## macOS
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    #set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "12.0")

    #set(app_icon_macos "${PROJECT_SOURCE_DIR}/assets/macos/${PROJECT_NAME}.icns")
    #set_source_files_properties(${app_icon_macos} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${PROJECT_SOURCE_DIR}/assets/macos/Info.plist"
        # New Xcode attributes (???)
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER           "io.emeric.qmlmobilescanner"
        XCODE_ATTRIBUTE_PRODUCT_NAME                        ${PROJECT_NAME}
        XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION             ${PROJECT_VERSION}
        XCODE_ATTRIBUTE_MARKETING_VERSION                   ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS             "${PROJECT_SOURCE_DIR}/assets/macos/${PROJECT_NAME}.entitlements"
        #XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME  AppIcon
    )
endif()

## Windows
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

################################################################################

## Android
if(CMAKE_SYSTEM_NAME STREQUAL "Android")
    set_target_properties(${PROJECT_NAME} PROPERTIES
        #QT_ANDROID_ABIS "armeabi-v7a;arm64-v8a;x86;x86_64"
        #QT_ANDROID_BUILD_ALL_ABIS ON
        QT_ANDROID_MIN_SDK_VERSION 28
        QT_ANDROID_TARGET_SDK_VERSION 36
        QT_ANDROID_PACKAGE_SOURCE_DIR "${PROJECT_SOURCE_DIR}/assets/android/"
    )

    # Support 16 KB page sizes / pre NDK28
    target_link_options(${PROJECT_NAME} PRIVATE "-Wl,-z,max-page-size=16384")

    ## Download SSL Libraries
    #include(FetchContent)
    #FetchContent_Declare(
    #    android_openssl
    #    DOWNLOAD_EXTRACT_TIMESTAMP true
    #    URL https://github.com/KDAB/android_openssl/archive/refs/heads/master.zip
    #)
    #FetchContent_MakeAvailable(android_openssl)

    ## Include SSL Libraries
    #include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)
    #add_android_openssl_libraries(${PROJECT_NAME})
endif()

## iOS
if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    #set(app_icon_ios "${PROJECT_SOURCE_DIR}/assets/ios/Assets.xcassets")
    #set_source_files_properties(${app_icon_ios} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_INFO_PLIST "${PROJECT_SOURCE_DIR}/assets/ios/Info.plist"
        # Qt
        #QT_IOS_LAUNCH_SCREEN "${PROJECT_SOURCE_DIR}/assets/ios/LaunchScreen.storyboard"
        # New Xcode attributes (???)
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER           "io.emeric.qmlmobilescanner"
        XCODE_ATTRIBUTE_PRODUCT_NAME                        ${PROJECT_NAME}
        XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION             ${PROJECT_VERSION}
        XCODE_ATTRIBUTE_MARKETING_VERSION                   ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET          "16.0"
        XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY              "1,2" # iPhone,iPad
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME  "AppIcon"
        XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS      "YES"
    )
endif()

################################################################################

# Output (build)
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin"
)

# Output (install)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION ${CMAKE_INSTALL_BINDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

################################################################################
