import QtQuick
import QtQuick.Controls

import ComponentLibrary
import QmlMobileScanner

DrawerThemed {
    contentItem: Item {

        Column {
            id: rectangleHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            z: 5

            ////////

            Rectangle {
                id: rectangleStatusbar
                anchors.left: parent.left
                anchors.right: parent.right

                height: Math.max(screenPaddingTop, screenPaddingStatusbar)
                color: Theme.colorBackground // to hide flickable content

                Rectangle {
                    anchors.fill: parent
                    color: Theme.colorStatusbar // so we can read the statusbar
                    opacity: 0.85
                }
            }

            ////////

            Rectangle {
                id: rectangleLogo
                anchors.left: parent.left
                anchors.right: parent.right

                height: 80
                color: Theme.colorBackground

                IconSvg {
                    id: imageHeader
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    width: 40
                    height: 40
                    source: "qrc:/assets/gfx/logos/logo_black.svg"
                    //sourceSize: Qt.size(width, height)
                    color: Theme.colorIcon
                }
                Text {
                    id: textHeader
                    anchors.left: imageHeader.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 0

                    text: utilsApp.appName()
                    color: Theme.colorText
                    font.bold: false
                    font.pixelSize: Theme.fontSizeTitle
                }
            }

            ////////
        }

        ////////////////////////////////////////////////////////////////////////

        Flickable {
            anchors.top: rectangleHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            contentWidth: -1
            contentHeight: contentColumn.height

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right

                ////////

                ListSeparatorPadded { }

                ////////

                DrawerItem {
                    highlighted: (appContent.state === "ScreenBarcodeReader")
                    text: qsTr("Barcode reader")
                    source: "qrc:/IconLibrary/material-icons/duotone/qr_code_scanner.svg"

                    onClicked: {
                        screenBarcodeReader.loadScreen()
                        appDrawer.close()
                    }
                }

                DrawerItem {
                    highlighted: (appContent.state === "ScreenBarcodeWriter")
                    text: qsTr("Barcode writer")
                    source: "qrc:/IconLibrary/material-symbols/qr_code_2.svg"

                    onClicked: {
                        screenBarcodeWriter.loadScreen()
                        appDrawer.close()
                    }
                }

                ////////

                ListSeparatorPadded { }

                DrawerItem {
                    highlighted: (appContent.state === "ScreenBarcodeHistory")
                    text: qsTr("Barcodes history")
                    source: "qrc:/IconLibrary/material-icons/duotone/list.svg"

                    onClicked: {
                        screenBarcodeHistory.loadScreen()
                        appDrawer.close()
                    }
                }

                ////////

                ListSeparatorPadded { }

                ////////

                DrawerItem {
                    text: qsTr("Settings")
                    source: "qrc:/IconLibrary/material-symbols/settings.svg"
                    highlighted: (appContent.state === "ScreenSettings")

                    onClicked: {
                        screenSettings.loadScreen()
                        appDrawer.close()
                    }
                }

                DrawerItem {
                    text: qsTr("About")
                    source: "qrc:/IconLibrary/material-symbols/info.svg"
                    highlighted: (appContent.state === "ScreenAbout" ||
                                  appContent.state === "ScreenAboutFormats" ||
                                  appContent.state === "ScreenAboutPermissions")

                    onClicked: {
                        screenAbout.loadScreen()
                        appDrawer.close()
                    }
                }

                ////////

                ListSeparatorPadded { }

                ////////
            }
        }

        ////////////////

        Rectangle {
            id: rectangleNavigationbar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: Math.max(screenPaddingBottom, screenPaddingNavbar)
            color: Theme.colorForeground // so we can read the navigation bar
            opacity: 0.85
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
