import QtQuick
import QtQuick.Controls
import QtQuick.Window

import ThemeEngine
import MobileUI

ApplicationWindow {
    id: appWindow
    minimumWidth: 480
    minimumHeight: 960

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    color: Theme.colorBackground
    visible: true

    property bool isHdpi: (utilsScreen.screenDpi >= 128 || utilsScreen.screenPar >= 2.0)
    property bool isDesktop: (Qt.platform.os !== "ios" && Qt.platform.os !== "android")
    property bool isMobile: (Qt.platform.os === "ios" || Qt.platform.os === "android")
    property bool isPhone: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize >= 7.0))

    property bool singleColumn: true
    property bool headerUnicolor: false
    property bool wideMode: (isDesktop && width >= 560) || (isTablet && width >= 480)
    property bool wideWideMode: (width >= 640)

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

    onScreenOrientationChanged: handleSafeAreas()
    onVisibilityChanged: handleSafeAreas()

    function handleSafeAreas() {
        // safe areas handling is a work in progress /!\
        // safe areas are only taken into account when using maximized geometry / full screen mode

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
                if (Screen.primaryOrientation === Qt.PortraitOrientation) {
                    if (appWindow.visibility === Window.FullScreen) {
                        screenPaddingStatusbar = 0
                        screenPaddingNavbar = 0
                    } else {
                        screenPaddingStatusbar = mobileUI.safeAreaTop
                        screenPaddingTop = 0
                    }
                } else {
                    screenPaddingNavbar = 0
                }
            }
            // hacks
            if (Qt.platform.os === "ios") {
                if (appWindow.visibility === Window.FullScreen) {
                    screenPaddingStatusbar = 0
                } else {
                    screenPaddingStatusbar = mobileUI.safeAreaTop
                    screenPaddingTop = 0
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
        console.log("- screen width:        " + Screen.width)
        console.log("- screen width avail:  " + Screen.desktopAvailableWidth)
        console.log("- screen height:       " + Screen.height)
        console.log("- screen height avail: " + Screen.desktopAvailableHeight)
        console.log("- screen orientation:  " + Screen.orientation)
        console.log("- screen orientation (primary): " + Screen.primaryOrientation)
        console.log("- screenSizeStatusbar: " + screenPaddingStatusbar)
        console.log("- screenSizeNavbar:    " + screenPaddingNavbar)
        console.log("- screenPaddingTop:    " + screenPaddingTop)
        console.log("- screenPaddingLeft:   " + screenPaddingLeft)
        console.log("- screenPaddingRight:  " + screenPaddingRight)
        console.log("- screenPaddingBottom: " + screenPaddingBottom)
*/
    }

    MobileUI {
        id: mobileUI

        statusbarColor: {
            if (appContent.state === "ScreenScanner") return "#000"
            return Theme.colorStatusbar
        }
        navbarColor: {
            if (appContent.state === "ScreenScanner") return "#000"
            return Theme.colorStatusbar
        }
    }

    MobileHeader {
        id: appHeader
        visible: (appContent.state !== "ScreenScanner")
    }

    MobileDrawer {
        id: appDrawer
        interactive: (appContent.state !== "Tutorial")
    }

    // Events handling /////////////////////////////////////////////////////////

    Component.onCompleted: {
        handleSafeAreas()
        screenScanner.loadScreen()
    }

    Connections {
        target: Qt.application

        function onStateChanged() {
            switch (Qt.application.state) {
            case Qt.ApplicationSuspended:
                //console.log("Qt.ApplicationSuspended")
                screenScanner.close()
                break
            case Qt.ApplicationHidden:
                //console.log("Qt.ApplicationHidden")
                break
            case Qt.ApplicationInactive:
                //console.log("Qt.ApplicationInactive")
                break
            case Qt.ApplicationActive:
                //console.log("Qt.ApplicationActive")

                if (appContent.state === "ScreenScanner")
                    screenScanner.loadScreen()

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
/*
        if (screenScanner.active) {
            screenScanner.close()
            return
        }
*/
        if (appContent.state === "ScreenTutorial")  return // do nothing

        if (appContent.state === "ScreenScanner") {
            if (exitTimer.running)
                Qt.quit()
            else
                exitTimer.start()
        } else if (appContent.state === "screenAboutPermissions") {
            appContent.state = screenAboutPermissions.entryPoint
        } else {
            screenScanner.loadScreen()
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

    FocusScope {
        id: appContent

        anchors.top: (appContent.state === "ScreenScanner") ? parent.top : appHeader.bottom
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

        ScreenScanner_qzxing {
            id: screenScanner
        }
        ScreenBarcode_qzxing {
            id: screenBarcode
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
/*
        ScreenScanner_zxingcpp {
            id: screenScanner
        }
        ScreenBarcode_zxingcpp {
            id: screenBarcode
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
*/
        ScreenSettings {
            id: screenSettings
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
        ScreenAbout {
            id: screenAbout
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }
        MobilePermissions {
            id: screenAboutPermissions
            anchors.bottomMargin: screenPaddingBottom + screenPaddingNavbar
        }

        // Initial state
        state: "ScreenScanner"

        onStateChanged: {
            if (state === "ScreenScanner")
                appHeader.leftMenuMode = "drawer"
            else if (state === "ScreenTutorial")
                appHeader.leftMenuMode = "close"
            else
                appHeader.leftMenuMode = "back"

            if (state === "ScreenScanner") {
                //
            } else {
                screenScanner.close()
                //mobileUI.refreshUI()
            }
        }

        states: [
            State {
                name: "ScreenTutorial"
                PropertyChanges { target: appHeader; headerTitle: qsTr("MobileScanner"); }
                PropertyChanges { target: screenTutorial; visible: true; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenScanner; visible: false; }
                PropertyChanges { target: screenBarcode; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },

            State {
                name: "ScreenMainMenu"
                PropertyChanges { target: appHeader; headerTitle: qsTr("MobileScanner"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: true; }
                PropertyChanges { target: screenScanner; visible: false; }
                PropertyChanges { target: screenBarcode; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenScanner"
                PropertyChanges { target: appHeader; headerTitle: qsTr("MobileScanner"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenScanner; visible: true; }
                PropertyChanges { target: screenBarcode; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenBarcode"
                PropertyChanges { target: appHeader; headerTitle: qsTr("MobileScanner"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenScanner; visible: false; }
                PropertyChanges { target: screenBarcode; visible: true; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },

            State {
                name: "ScreenSettings"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Settings"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenScanner; visible: false; }
                PropertyChanges { target: screenBarcode; visible: false; }
                PropertyChanges { target: screenSettings; visible: true; }
                PropertyChanges { target: screenAbout; visible: false; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenAbout"
                PropertyChanges { target: appHeader; headerTitle: qsTr("About"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenScanner; visible: false; }
                PropertyChanges { target: screenBarcode; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: true; }
                PropertyChanges { target: screenAboutPermissions; visible: false; }
            },
            State {
                name: "ScreenAboutPermissions"
                PropertyChanges { target: appHeader; headerTitle: qsTr("Permissions"); }
                PropertyChanges { target: screenTutorial; visible: false; }
                PropertyChanges { target: screenMainMenu; visible: false; }
                PropertyChanges { target: screenScanner; visible: false; }
                PropertyChanges { target: screenBarcode; visible: false; }
                PropertyChanges { target: screenSettings; visible: false; }
                PropertyChanges { target: screenAbout; visible: false; }
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

        visible: (appContent.state !== "ScreenScanner")
        color: {
            if (appContent.state === "ScreenTutorial") return Theme.colorHeader
            return Theme.colorBackground
        }
    }

    ////////////////
}
