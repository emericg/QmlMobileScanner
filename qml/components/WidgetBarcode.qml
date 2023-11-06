import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine

SwipeDelegate {
    id: widgetBarcode

    width: parent.width
    height: 96
    clip: true
    padding: Theme.componentMargin

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        color: widgetBarcode.pressed ? Qt.darker(Theme.colorLowContrast, 1.05) : Theme.colorLowContrast

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: -12
            anchors.verticalCenter: parent.verticalCenter

            width: parent.height*0.33
            height: parent.height*1.33
            rotation: 10
            antialiasing: true
            color: parent.color
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.colorSeparator
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.componentMargin

            ////////

            Item {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignVCenter

                IconSvg {
                    anchors.centerIn: parent
                    width: modelData.isMatrix ? 48 : 32
                    height: modelData.isMatrix ? 48 : 32
                    color: Theme.colorText
                    source: modelData.isMatrix ? "qrc:/assets/icons_material/baseline-qr_code_2-24px.svg" :
                                                 "qrc:/assets/icons_bootstrap/barcode.svg"
                }
            }

            ////////

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Theme.componentMargin / 3

                ////

                RowLayout { // content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 8

                    Text {
                        visible: modelData.content
                        text: modelData.content
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorSubText
                    }
                    Text {
                        text: modelData.data
                        Layout.fillWidth: true
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                        elide: Text.ElideRight
                    }
                }

                ////

                Row { // info
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 8

                    ////

                    Row { // date
                        visible: modelData.date
                        height: 16
                        spacing: 6

                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                            color: Theme.colorSubText
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.date.toLocaleString(Qt.locale(), "dddd, MMMM d, yyyy hh:mm")
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorSubText
                        }
                    }

                    ////

                    Row { // location
                        visible: (modelData.latitude != 0 && modelData.longitude != 0)
                        height: 16
                        spacing: 6

                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            source: "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
                            color: Theme.colorSubText
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.latitude + "°N " + modelData.longitude + "°E"
                            font.pixelSize: Theme.fontSizeContentSmall
                            color: Theme.colorSubText
                        }
                    }

                    ////
                }

                ////
            }

            ////////

            Item {
                Layout.preferredWidth: modelData.isStarred ? 48 : 0
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignVCenter

                IconSvg {
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    visible: modelData.isStarred
                    color: Theme.colorSubText
                    source: "qrc:/assets/icons_material/baseline-stars-24px.svg"
                }
            }

            ////////
        }
    }

    onClicked: {
        console.log("onClicked()")
        screenBarcodeDetails.loadScreenFrom("ScreenBarcodeHistory", modelData)
    }

    ////////////////////////////////////////////////////////////////////////////

    swipe.right: Row {
        anchors.right: parent.right
        height: parent.height

        Item {
            id: deleteLabel
            width: parent.height*1.33
            height: parent.height

            Rectangle {
                anchors.fill: parent
                color: widgetBarcode.background.color
            }

            Rectangle {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 10

                width: parent.height*1.33
                height: parent.height*2
                rotation: 10
                antialiasing: true

                color: deleteLabel.SwipeDelegate.pressed ? Qt.darker(Theme.colorMaterialOrange, 1.1) : Theme.colorMaterialOrange
                border.width: 2
                border.color: Qt.darker(color, 1.1)
            }

            Column {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 8

                IconSvg {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "qrc:/assets/icons_material/baseline-delete-24px.svg"
                    color: "white"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Supprimer")
                    font.bold: true
                    color: "white"
                }
            }

            SwipeDelegate.onClicked: {
                utilsApp.vibrate(33)
                barcodeManager.removeHistory(modelData.data)
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
