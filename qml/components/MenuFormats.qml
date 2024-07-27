import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Column {
    id: formatsCol
    anchors.top: toprightmenus.bottom
    anchors.topMargin: Theme.componentMargin
    anchors.right: toprightmenus.right

    width: singleColumn ? screenBarcodeReader.width - Theme.componentMargin*2 : 300
    spacing: Theme.componentMargin /2
    visible: false

    ListModel {
        id: formatsAvailable_zxingcpp
        ListElement { txt: "Linear codes"; value: 51070; }
        ListElement { txt: "Aztec"; value: 1; }
        ListElement { txt: "DataMatrix"; value: 128; }
        ListElement { txt: "MaxiCode"; value: 2048; }
        ListElement { txt: "PDF417"; value: 4096; }
        ListElement { txt: "QRCode"; value: 8192; }
        ListElement { txt: "µQRCode"; value: 65536; }
    }
    ListModel {
        id: formatsAvailable_qzxing
        ListElement { txt: "Linear codes"; value: 517052; }
        ListElement { txt: "Aztec"; value: 2; }
        ListElement { txt: "DataMatrix"; value: 64; }
        ListElement { txt: "MaxiCode"; value: 1024; }
        ListElement { txt: "PDF417"; value: 2048; }
        ListElement { txt: "QRCode"; value: 4096; }
    }

    Repeater {
        model: (settingsManager.backend_reader === "zxingcpp") ? formatsAvailable_zxingcpp : formatsAvailable_qzxing

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

            SwitchThemedDesktop {
                anchors.centerIn: parent
                width: parent.width - 16
                LayoutMirroring.enabled: true

                text: txt
                colorText: "white"
                colorSubText: "grey"
                checked: (settingsManager.formatsEnabled & value)
                onClicked: {
                    if (settingsManager.formatsEnabled & value)
                        settingsManager.formatsEnabled -= value
                    else
                        settingsManager.formatsEnabled += value
                }
            }
        }
    }
}
