import QtQuick
import QtQuick.Controls
import QtQuick.Window

import ThemeEngine
import MobileUI

ApplicationWindow {
    id: appWindow
    minimumWidth: 480
    minimumHeight: 800

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    color: Theme.colorBackground
    visible: true

    property bool isHdpi: (utilsScreen.screenDpi >= 128 || utilsScreen.screenPar >= 2.0)
    property bool isDesktop: (Qt.platform.os !== "android" && Qt.platform.os !== "ios")
    property bool isMobile: (Qt.platform.os === "android" || Qt.platform.os === "ios")
    property bool isPhone: ((Qt.platform.os === "android" || Qt.platform.os === "ios") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "android" || Qt.platform.os === "ios") && (utilsScreen.screenSize >= 7.0))

    property bool wideMode: (isDesktop && width >= 640) || (isTablet && width >= 480)
    property bool singleColumn: (width < height)

    // Mobile stuff ////////////////////////////////////////////////////////////

    // 1 = Qt.PortraitOrientation, 2 = Qt.LandscapeOrientation
    // 4 = Qt.InvertedPortraitOrientation, 8 = Qt.InvertedLandscapeOrientation
    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: 0
    property int screenPaddingNavbar: 0

    property int screenPaddingTop: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0

    Connections {
        target: Screen
        function onOrientationChanged() { mobileUI.handleSafeAreas() }
    }

    MobileUI {
        id: mobileUI

        statusbarColor: "transparent"
        statusbarTheme: (appContent.state === "ScreenBarcodeReader") ? MobileUI.Dark : Theme.themeStatusbar
        navbarColor: "transparent"
        navbarTheme: (appContent.state === "ScreenBarcodeReader") ? MobileUI.Dark : Theme.themeStatusbar

        Component.onCompleted: handleSafeAreas()

        function handleSafeAreas() {
            // safe areas handling is a work in progress /!\
            // safe areas are only taken into account when using maximized geometry / full screen mode

            mobileUI.refreshUI() // hack

            if (appWindow.visibility === Window.FullScreen ||
                appWindow.flags & Qt.MaximizeUsingFullscreenGeometryHint) {

                screenPaddingStatusbar = mobileUI.statusbarHeight
                screenPaddingNavbar = mobileUI.navbarHeight

                screenPaddingTop = mobileUI.safeAreaTop
                screenPaddingLeft = mobileUI.safeAreaLeft
                screenPaddingRight = mobileUI.safeAreaRight
                screenPaddingBottom = mobileUI.safeAreaBottom

                // hacks
                if (Qt.platform.os === "android") {
                    if (appWindow.visibility === Window.FullScreen) {
                        screenPaddingStatusbar = 0
                        screenPaddingNavbar = 0
                    }
                    if (appWindow.flags & Qt.MaximizeUsingFullscreenGeometryHint) {
                        if (mobileUI.isPhone) {
                            if (Screen.orientation === Qt.LandscapeOrientation) {
                                screenPaddingLeft = screenPaddingStatusbar
                                screenPaddingRight = screenPaddingNavbar
                                screenPaddingNavbar = 0
                            } else if (Screen.orientation === Qt.InvertedLandscapeOrientation) {
                                screenPaddingLeft = screenPaddingNavbar
                                screenPaddingRight = screenPaddingStatusbar
                                screenPaddingNavbar = 0
                            }
                        }
                    }
                }
                // hacks
                if (Qt.platform.os === "ios") {
                    if (appWindow.visibility === Window.FullScreen) {
                        screenPaddingStatusbar = 0
                    }
                }
            } else {
                screenPaddingStatusbar = 0
                screenPaddingNavbar = 0
                screenPaddingTop = 0
                screenPaddingLeft = 0
                screenPaddingRight = 0
                screenPaddingBottom = 0
            }
/*
            console.log("> handleSafeAreas()")
            console.log("- window mode:         " + appWindow.visibility)
            console.log("- window flags:        " + appWindow.flags)
            console.log("- screen dpi:          " + Screen.devicePixelRatio)
            console.log("- screen width:        " + Screen.width)
            console.log("- screen width avail:  " + Screen.desktopAvailableWidth)
            console.log("- screen height:       " + Screen.height)
            console.log("- screen height avail: " + Screen.desktopAvailableHeight)
            console.log("- screen orientation (full): " + Screen.orientation)
            console.log("- screen orientation (primary): " + Screen.primaryOrientation)
            console.log("- screenSizeStatusbar: " + screenPaddingStatusbar)
            console.log("- screenSizeNavbar:    " + screenPaddingNavbar)
            console.log("- screenPaddingTop:    " + screenPaddingTop)
            console.log("- screenPaddingLeft:   " + screenPaddingLeft)
            console.log("- screenPaddingRight:  " + screenPaddingRight)
            console.log("- screenPaddingBottom: " + screenPaddingBottom)
*/
        }
    }

    MobileHeader {
        id: appHeader

        visible: (appContent.state !== "ScreenBarcodeReader")
    }

    MobileDrawer {
        id: appDrawer

        interactive: (appContent.state !== "Tutorial")
    }

    // Events handling /////////////////////////////////////////////////////////

    Component.onCompleted: {
        if (settingsManager.defaultTab === "writer") {
            screenBarcodeWriter.loadScreen()
        } else {
            screenBarcodeReader.loadScreen()
        }
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            switch (Qt.application.state) {
                case Qt.ApplicationSuspended:
                    //console.log("Qt.ApplicationSuspended")
                    screenBarcodeReader.close()
                    break
                case Qt.ApplicationHidden:
                    //console.log("Qt.ApplicationHidden")
                    break
                case Qt.ApplicationInactive:
                    //console.log("Qt.ApplicationInactive")
                    break
                case Qt.ApplicationActive:
                    //console.log("Qt.ApplicationActive")

                    if (appContent.state === "ScreenBarcodeReader")
                        screenBarcodeReader.loadScreen()

                    // Check if we need an 'automatic' theme change
                    Theme.loadTheme(settingsManager.appTheme)

                    break
            }
        }
    }

    Connections {
        target: appHeader
        function onLeftMenuClicked() {
            if (appHeader.leftMenuMode === "drawer") {
                appDrawer.open()
            } else if (appHeader.leftMenuMode === "close") {
                appContent.state = screenTutorial.entryPoint
            } else {
                backAction()
            }
        }
        function onRightMenuClicked() {
            //
        }
    }

    function backAction() {
        //console.log("backAction() backAction() backAction() backAction()")

        if (appContent.state === "ScreenTutorial")  return // do nothing

        if (appContent.state === "ScreenBarcodeReader") {
            if (exitTimer.running)
                Qt.quit()
            else
                exitTimer.start()
        } else if (appContent.state === "ScreenBarcodeWriter") {
            screenBarcodeWriter.backAction()
        } else if (appContent.state === "ScreenBarcodeHistory") {
            screenBarcodeHistory.backAction()
        } else if (appContent.state === "ScreenAbout" ||
                   appContent.state === "ScreenAboutFormats" ||
                   appContent.state === "ScreenAboutPermissions") {
            screenAbout.backAction()
        } else {
            screenBarcodeReader.loadScreen()
        }
    }
    function forwardAction() {
        //console.log("forwardAction() forwardAction() forwardAction() forwardAction()")
    }

    Shortcut {
        sequences: [StandardKey.Back]
        onActivated: backAction()
    }
    Shortcut {
        sequences: [StandardKey.Forward]
        onActivated: forwardAction()
    }

    Timer {
        id: exitTimer
        interval: 3333
        repeat: false
    }

    // QML /////////////////////////////////////////////////////////////////////

    FocusScope {
        id: appContent

        anchors.top: (appContent.state === "ScreenBarcodeReader") ? parent.top : appHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: screenPaddingBottom

        focus: true
        Keys.onBackPressed: backAction()

        ScreenTutorial {
            id: screenTutorial
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
        ScreenMainMenu {
            id: screenMainMenu
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }

        ScreenBarcodeReader {
            id: screenBarcodeReader
        }
        ScreenBarcodeHistory {
            id: screenBarcodeHistory
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
        ScreenBarcodeWriter {
            id: screenBarcodeWriter
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }

        ScreenSettings {
            id: screenSettings
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
        ScreenAbout {
            id: screenAbout
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
        ScreenAboutFormats {
            id: screenAboutFormats
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
        MobilePermissions {
            id: screenAboutPermissions
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }

        // Initial state
        state: "ScreenBarcodeReader"

        onStateChanged: {
            if (state === "ScreenBarcodeReader")
                appHeader.leftMenuMode = "drawer"
            else if (state === "ScreenTutorial")
                appHeader.leftMenuMode = "close"
            else
                appHeader.leftMenuMode = "back"

            if (state === "ScreenBarcodeReader") {
                //
            } else {
                screenBarcodeReader.close()
            }
        }

        states: [
            State {
                name: "ScreenTutorial"
                PropertyChanges { target: appHeader; headerTitle: utilsApp.appName(); }
                PropertyChanges { target: screenTutorial; visible: true; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },

            State {
                name: "ScreenMainMenu"
                PropertyChanges { target: appHeader; headerTitle: utilsApp.appName(); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: true; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenBarcodeReader"
                PropertyChanges { target: appHeader; headerTitle: ""; }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: true; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenBarcodeWriter"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Barcode writer"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: true; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenBarcodeHistory"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Barcodes history"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: true; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },

            State {
                name: "ScreenSettings"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Settings"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenSettings; visible: true; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenAbout"
                PropertyChanges { target: appHeader; headerTitle: qsTr("About"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: true; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenAboutFormats"
                PropertyChanges { target: appHeader; headerTitle: qsTr("About formats"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: true; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenAboutPermissions"
                PropertyChanges { target: appHeader; headerTitle: qsTr("About permissions"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: true; }
            }
        ]
    }

    ////////////////

    Rectangle { // navbar area
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: screenPaddingNavbar

        visible: (appContent.state !== "ScreenBarcodeReader")
        color: {
            if (appContent.state === "ScreenTutorial") return Theme.colorHeader
            return Theme.colorBackground
        }
    }

    ////////////////
}
