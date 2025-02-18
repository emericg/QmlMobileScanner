import QtQuick
import QtQuick.Controls

import ComponentLibrary

Column {
    id: cameraCol
    anchors.top: toprightmenus.bottom
    anchors.topMargin: Theme.componentMargin
    anchors.right: toprightmenus.right

    width: singleColumn ? screenBarcodeReader.width - Theme.componentMargin*2 : 320
    spacing: Theme.componentMargin
    visible: false

    Repeater {
        model: mediaDevices.videoInputs

        delegate: Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40

            //required property var modelData

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

                text: modelData.description
                font.pixelSize: Theme.componentFontSize
                color: (index === mediaDevices.selectedDevice) ? Theme.colorPrimary : "white"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mediaDevices.selectedDevice = index
                    cameraCol.visible = false
                }
            }

            IconSvg {
                width: parent.height * 0.5
                height: parent.height * 0.5
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                anchors.verticalCenter: parent.verticalCenter
                color: (index === mediaDevices.selectedDevice) ? Theme.colorPrimary : "white"
                source: {
                    if (index === mediaDevices.selectedDevice) return  "qrc:/IconLibrary/material-symbols/check_circle.svg"
                    if (modelData.isDefault) return  "qrc:/IconLibrary/material-symbols/stars-fill.svg"
                    return ""
                }
            }
        }
    }
}
