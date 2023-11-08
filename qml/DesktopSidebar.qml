import QtQuick
import QtQuick.Controls
import QtQuick.Window

import ThemeEngine

Rectangle {
    id: appSidebar
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.bottom: parent.bottom

    z: 10
    width: isHdpi ? 72 : 80
    color: Theme.colorSidebar

    ////////////////////////////////////////////////////////////////////////////

    DragHandler {
        // Drag on the sidebar to drag the whole window // Qt 5.15+
        // Also, prevent clicks below this area
        onActiveChanged: if (active) appWindow.startSystemMove();
        target: null
    }

    ////////////////////////////////////////////////////////////////////////////

    // MENUS up

    Column {
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        spacing: 0

        DesktopSidebarItem {
            source: "qrc:/assets/icons_material/duotone-qr_code_scanner-24px.svg"
            sourceSize: 48

            highlightMode: "background"
            highlighted: (appContent.state === "ScreenBarcodeReader")

            indicatorVisible: false
            indicatorSource: "qrc:/assets/icons_material/baseline-camera-24px.svg"

            onClicked: screenBarcodeReader.loadScreen()
        }
        DesktopSidebarItem {
            source: "qrc:/assets/icons_material/duotone-qr_code_2-24px.svg"
            sourceSize: 48

            highlightMode: "background"
            highlighted: (appContent.state === "ScreenBarcodeWriter")

            onClicked: screenBarcodeWriter.loadScreen()
        }
        DesktopSidebarItem {
            source: "qrc:/assets/icons_material/duotone-list-24px.svg"
            sourceSize: 48

            highlightMode: "background"
            highlighted: (appContent.state === "ScreenBarcodeHistory")

            onClicked: screenBarcodeHistory.loadScreen()
        }
    }

    // MENUS down

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16

        spacing: 0

        DesktopSidebarItem {
            source: "qrc:/assets/icons_material/duotone-tune-24px.svg"
            sourceSize: 48

            highlightMode: (Theme.sidebarSelector) ? "indicator" : "background"
            highlighted: appContent.state === "ScreenSettings"

            onClicked: screenSettings.loadScreen()
        }
        DesktopSidebarItem {
            source: "qrc:/assets/icons_material/duotone-info-24px.svg"
            sourceSize: 48

            highlightMode: (Theme.sidebarSelector) ? "indicator" : "background"
            highlighted: (appContent.state === "ScreenAbout" ||
                          appContent.state === "ScreenAboutFormats" ||
                          appContent.state === "ScreenAboutPermissions")

            onClicked: screenAbout.loadScreen()
        }
        DesktopSidebarItem {
            source: "qrc:/assets/icons_material/duotone-exit_to_app-24px.svg"
            sourceSize: 48
            highlightMode: "circle"
            onClicked: appWindow.close()
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
