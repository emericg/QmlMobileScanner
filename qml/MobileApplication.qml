import QtQuick
import QtQuick.Controls
import QtQuick.Window

import ComponentLibrary
import QmlMobileScanner
import MobileUI

Window {
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

    property int screenPaddingStatusbar: MobileUI.statusbarHeight
    property int screenPaddingNavbar: MobileUI.navbarHeight

    property int screenPaddingTop: MobileUI.safeAreaTop
    property int screenPaddingLeft: MobileUI.safeAreaLeft
    property int screenPaddingRight: MobileUI.safeAreaRight
    property int screenPaddingBottom: MobileUI.safeAreaBottom

    Binding {
        target: MobileUI
        property: "statusbarTheme"
        value: { return (appContent.state === "ScreenBarcodeReader") ? MobileUI.Dark : Theme.themeStatusbar }
    }
    Binding {
        target: MobileUI
        property: "navbarTheme"
        value: { return (appContent.state === "ScreenBarcodeReader") ? MobileUI.Dark : Theme.themeStatusbar }
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

        if (appContent.state === "ScreenTutorial") {
            if (screenTutorial.entryPoint === "ScreenBarcodeReader") {
                return // do nothing
            } else {
                appContent.state = screenTutorial.entryPoint
                return
            }
        }

        if (appContent.state === "ScreenBarcodeReader") {
            screenBarcodeReader.backAction()
        } else if (appContent.state === "ScreenBarcodeWriter") {
            screenBarcodeWriter.backAction()
        } else if (appContent.state === "ScreenBarcodeHistory") {
            screenBarcodeHistory.backAction()
        } else if (appContent.state === "ScreenAbout" ||
                   appContent.state === "ScreenAboutFormats" ||
                   appContent.state === "ScreenAboutPermissions") {
            screenAbout.backAction()
        } else {
            backAction_default()
        }
    }
    function backAction_default() {
        if ((appContent.state === "ScreenBarcodeReader" && settingsManager.defaultTab === "reader") ||
            (appContent.state === "ScreenBarcodeWriter" && settingsManager.defaultTab === "writer")) {
            if (exitTimer.running)
                Qt.quit()
            else
                exitTimer.start()
        }

        if (settingsManager.defaultTab === "reader")
            screenBarcodeReader.loadScreen()
        else if (settingsManager.defaultTab === "writer")
            screenBarcodeWriter.loadScreen()
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
