import QtQuick

import ComponentLibrary
import QmlMobileScanner

Rectangle {
    id: appSidebar
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.bottom: parent.bottom

    z: 10
    width: isHdpi ? 220 : 240
    color: Theme.colorSidebar

    ////////////

    DragHandler {
        // Drag on the sidebar to drag the whole window // Qt 5.15+
        // Also, prevent clicks below this area
        onActiveChanged: if (active) appWindow.startSystemMove();
        target: null
    }

    ////////////

    Column { // top menu
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        spacing: 8

        DesktopSidebarMenu {
            text: qsTr("Scanner")
            source: "qrc:/IconLibrary/material-icons/duotone/qr_code_scanner.svg"
            checked: (appContent.state === "ScreenBarcodeReader")

            onClicked: screenBarcodeReader.loadScreen()
        }
        DesktopSidebarMenu {
            text: qsTr("Generator")
            source: "qrc:/IconLibrary/material-icons/duotone/qr_code_2.svg"
            checked: (appContent.state === "ScreenBarcodeWriter")

            onClicked: screenBarcodeWriter.loadScreen()
        }
        DesktopSidebarMenu {
            text: qsTr("Barcode history")
            source: "qrc:/IconLibrary/material-icons/duotone/list.svg"
            checked: (appContent.state === "ScreenBarcodeHistory")

            onClicked: screenBarcodeHistory.loadScreen()
        }
    }

    ////////////

    Column { // bottom menu
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        spacing: 8

        DesktopSidebarMenu {
            text: qsTr("Settings")
            source: "qrc:/IconLibrary/material-icons/duotone/tune.svg"
            checked: (appContent.state === "ScreenSettings")

            onClicked: screenSettings.loadScreen()
        }

        DesktopSidebarMenu {
            text: qsTr("About")
            source: "qrc:/IconLibrary/material-icons/duotone/info.svg"
            checked: (appContent.state === "ScreenAbout" ||
                      appContent.state === "ScreenAboutFormats" ||
                      appContent.state === "ScreenAboutPermissions")

            onClicked: screenAbout.loadScreen()
        }

        DesktopSidebarMenu {
            text: qsTr("Exit")
            source: "qrc:/IconLibrary/material-icons/duotone/exit_to_app.svg"
            onClicked: Qt.quit()
        }
    }

    ////////////

    Rectangle { // border
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: 2
        opacity: 1.0
        color: Theme.colorSeparator
    }

    Rectangle { // fake shadow
        anchors.top: parent.top
        anchors.left: parent.right
        anchors.bottom: parent.bottom

        width: 8
        opacity: 0.333

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.colorSeparator; }
            GradientStop { position: 1.0; color: "transparent"; }
        }
    }

    ////////////
}
