import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Column {
    id: screensCol
    anchors.bottom: bottomemnus.top
    anchors.bottomMargin: Theme.componentMarginXL
    anchors.right: bottomemnus.right

    width: singleColumn ? screenBarcodeReader.width - Theme.componentMarginXL*2 : 320
    spacing: Theme.componentMargin
    visible: false

    Repeater {
        model: ListModel {
            ListElement { idx: 1; txt: "Barcode reader"; src: "qrc:/assets/icons/material-icons/duotone/qr_code_scanner.svg"; }
            ListElement { idx: 2; txt: "Barcode writer"; src: "qrc:/assets/icons/material-symbols/qr_code_2.svg"; }
            ListElement { idx: 3; txt: "Barcode history"; src: "qrc:/assets/icons/material-icons/duotone/list.svg"; }
            ListElement { idx: 4; txt: "Settings"; src: "qrc:/assets/icons/material-symbols/settings.svg"; }
            ListElement { idx: 5; txt: "About"; src: "qrc:/assets/icons/material-symbols/info.svg"; }
        }

        delegate: Item {
            width: parent.width
            height: 40

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: "black"
                opacity: 0.33
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter

                text: txt
                font.pixelSize: Theme.componentFontSize
                color: "white"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (idx === 1) screenBarcodeReader.loadScreen()
                    else if (idx === 2) screenBarcodeWriter.loadScreen()
                    else if (idx === 3) screenBarcodeHistory.loadScreen()
                    else if (idx === 4) screenSettings.loadScreen()
                    else if (idx === 5) screenAbout.loadScreen()
                    screensCol.visible = false
                }
            }

            IconSvg {
                width: parent.height * 0.5
                height: parent.height * 0.5
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                source: src
            }
        }
    }
}
