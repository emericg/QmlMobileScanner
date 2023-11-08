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
    property bool isDesktop: true
    property bool isMobile: false
    property bool isPhone: false
    property bool isTablet: false

    property bool singleColumn: (width < height)
    property bool wideMode: (isDesktop && width >= 640) || (isTablet && width >= 480)

    // Desktop stuff ///////////////////////////////////////////////////////////

    width: {
        if (settingsManager.initialSize.width > 0)
            return settingsManager.initialSize.width
        else
            return isHdpi ? 960 : 1280
    }
    height: {
        if (settingsManager.initialSize.height > 0)
            return settingsManager.initialSize.height
        else
            return isHdpi ? 640 : 720
    }
    x: settingsManager.initialPosition.width
    y: settingsManager.initialPosition.height
    visibility: settingsManager.initialVisibility

    WindowGeometrySaver {
        windowInstance: appWindow
    }

    // Mobile stuff ////////////////////////////////////////////////////////////

    property int screenOrientation: Screen.primaryOrientation
    property int screenOrientationFull: Screen.orientation

    property int screenPaddingStatusbar: 0
    property int screenPaddingNavbar: 0
    property int screenPaddingTop: 0
    property int screenPaddingLeft: 0
    property int screenPaddingRight: 0
    property int screenPaddingBottom: 0

    Item { // compat
        id: appHeader
        property int headerPosition: 64
    }
    Item { // compat
        id: mobileUI
        function setScreenAlwaysOn() {}
    }
    Item { // compat
        id: appDrawer
        visible: false
    }
    Item { // compat
        id: exitTimer
        property bool running: false
    }

    // Events handling /////////////////////////////////////////////////////////

    Component.onCompleted: {
        //screenBarcodeHistory.loadScreen(); return; // DEBUG

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

    function backAction() {
        //console.log("backAction() backAction() backAction() backAction()")

        if (appContent.state === "ScreenTutorial")  return // do nothing

        if (appContent.state === "ScreenBarcodeReader") {
            //
        } else if (appContent.state === "ScreenBarcodeWriter") {
            screenBarcodeWriter.backAction()
        } else if (appContent.state === "ScreenBarcodeDetails") {
           screenBarcodeDetails.backAction()
        } else if (appContent.state === "ScreenAbout") {
            screenAbout.backAction()
        } else if (appContent.state === "ScreenAboutFormats") {
            screenAboutFormats.backAction()
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

    Shortcut {
        sequence: StandardKey.FullScreen
        onActivated: {
            if (appWindow.visibility === Window.Windowed)
                appWindow.visibility = Window.FullScreen
            else
                appWindow.visibility = Window.Windowed
        }
    }
    Shortcut {
        sequence: StandardKey.Preferences
        onActivated: appContent.state = "settings"
    }
    Shortcut {
        sequences: [StandardKey.Close]
        onActivated: appWindow.close()
    }
    Shortcut {
        sequence: StandardKey.Quit
        onActivated: appWindow.close()
    }

    MouseArea {
        anchors.fill: parent

        enabled: isDesktop
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.BackButton) {
                backAction()
            } else if (mouse.button === Qt.ForwardButton) {
                forwardAction()
            }
        }
    }

    // QML /////////////////////////////////////////////////////////////////////

    DesktopSidebar {
        id: appSidebar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
    }

    FocusScope {
        id: appContent

        anchors.top: parent.top
        anchors.left: appSidebar.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom

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
        ScreenBarcodeDetails {
            id: screenBarcodeDetails
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

        // Initial state
        state: "ScreenBarcodeReader"

        onStateChanged: {
            if (state === "ScreenBarcodeReader") {
                //
            } else {
                screenBarcodeReader.close()
            }
        }

        states: [
            State {
                name: "ScreenTutorial"
                PropertyChanges { target: screenTutorial; visible: true; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenBarcodeDetails; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
            },

            State {
                name: "ScreenMainMenu"
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: true; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenBarcodeDetails; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
            },
            State {
                name: "ScreenBarcodeReader"
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: true; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenBarcodeDetails; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
            },
            State {
                name: "ScreenBarcodeWriter"
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: true; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenBarcodeDetails; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
            },
            State {
                name: "ScreenBarcodeHistory"
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: true; }
                PropertyChanges { target: screenBarcodeDetails; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
            },
            State {
                name: "ScreenBarcodeDetails"
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenBarcodeDetails; visible: true; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
            },

            State {
                name: "ScreenSettings"
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenBarcodeDetails; visible: false; }
                PropertyChanges { target: screenSettings; visible: true; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
            },
            State {
                name: "ScreenAbout"
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenBarcodeDetails; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: true; }
                PropertyChanges { target: screenAboutFormats; visible: false; }
            },
            State {
                name: "ScreenAboutFormats"
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenBarcodeReader; visible: false; }
                PropertyChanges { target: screenBarcodeWriter; visible: false; }
                PropertyChanges { target: screenBarcodeHistory; visible: false; }
                PropertyChanges { target: screenBarcodeDetails; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutFormats; visible: true; }
            }
        ]
    }

    ////////////////////////////////////////////////////////////////////////////
}
