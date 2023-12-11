import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Column {
    id: formatsCol
    anchors.top: toprightmenu.bottom
    anchors.topMargin: Theme.componentMargin
    anchors.right: toprightmenu.right

    width: singleColumn ? screenBarcodeReader.width - Theme.componentMargin*2 : 300
    spacing: Theme.componentMargin /2
    visible: false

    ListModel {
        id: formatsAvailable_zxingcpp
        ListElement { text: "Linear codes"; value: 51070; }
        ListElement { text: "Aztec"; value: 1; }
        ListElement { text: "DataMatrix"; value: 128; }
        ListElement { text: "MaxiCode"; value: 2048; }
        ListElement { text: "PDF417"; value: 4096; }
        ListElement { text: "QRCode"; value: 8192; }
        ListElement { text: "MicroQRCode"; value: 65536; }
    }
    ListModel {
        id: formatsAvailable_qzxing
        ListElement { text: "Linear codes"; value: 517052; }
        ListElement { text: "Aztec"; value: 2; }
        ListElement { text: "DataMatrix"; value: 64; }
        ListElement { text: "MaxiCode"; value: 1024; }
        ListElement { text: "PDF417"; value: 2048; }
        ListElement { text: "QRCode"; value: 4096; }
    }

    Repeater {
        model: (settingsManager.backend === "zxingcpp") ? formatsAvailable_zxingcpp : formatsAvailable_qzxing

        Item {
            width: parent.width
            height: 40

            required property var modelData

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: "black"
                opacity: 0.33
            }

            SwitchThemed {
                anchors.centerIn: parent
                width: parent.width - 16
                LayoutMirroring.enabled: true

                text: modelData.text
                colorText: "white"
                colorSubText: "grey"
                checked: (settingsManager.formatsEnabled & modelData.value)
                onClicked: {
                    if (settingsManager.formatsEnabled & modelData.value)
                        settingsManager.formatsEnabled -= modelData.value
                    else
                        settingsManager.formatsEnabled += modelData.value
                }
            }
        }
    }
}
