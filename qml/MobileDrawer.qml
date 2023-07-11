import QtQuick
import QtQuick.Controls

import ThemeEngine

Drawer {
    width: (appWindow.screenOrientation === Qt.PortraitOrientation || appWindow.width < 480)
            ? 0.8 * appWindow.width : 0.5 * appWindow.width
    height: appWindow.height

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: Theme.colorBackground

        Rectangle { // left border
            x: parent.width
            width: 1
            height: parent.height
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

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
                    source: "qrc:/assets/logos/logo_black.svg"
                    //sourceSize: Qt.size(width, height)
                    color: Theme.colorIcon
                }
                Text {
                    id: textHeader
                    anchors.left: imageHeader.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 0

                    text: "MobileScanner"
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
                    highlighted: (appContent.state === "ScreenScanner")
                    text: qsTr("Scanner")
                    iconSource: "qrc:/assets/icons_material/duotone-qr_code_scanner-24px.svg"

                    onClicked: {
                        screenScanner.loadScreen()
                        appDrawer.close()
                    }
                }

                DrawerItem {
                    highlighted: (appContent.state === "ScreenBarcode")
                    text: qsTr("Generator")
                    iconSource: "qrc:/assets/icons_material/baseline-qr_code_2-24px.svg"

                    onClicked: {
                        screenBarcode.loadScreen()
                        appDrawer.close()
                    }
                }

                ////////

                ListSeparatorPadded { }

                ////////

                DrawerItem {
                    text: qsTr("Settings")
                    iconSource: "qrc:/assets/icons_material/outline-settings-24px.svg"
                    highlighted: (appContent.state === "ScreenSettings")

                    onClicked: {
                        screenSettings.loadScreen()
                        appDrawer.close()
                    }
                }

                DrawerItem {
                    text: qsTr("About")
                    iconSource: "qrc:/assets/icons_material/outline-info-24px.svg"
                    highlighted: (appContent.state === "ScreenAbout" ||
                                  appContent.state === "screenAboutPermissions")

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
    }

    ////////////////////////////////////////////////////////////////////////////
}
