import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine

Item {
    id: widgetBarcodeResult

    implicitWidth: 256
    implicitHeight: 40

    clip: true

    property var barcode

    signal longPressed()

    /////////

    Rectangle {
        anchors.fill: parent
        radius: height

        color: "black"
        opacity: 0.33
        border.width: 2
        border.color: "grey"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Qt.openUrlExternally(barcode.data)
        }
        onPressAndHold: {
            widgetBarcodeResult.longPressed()
        }
    }

    /////////

    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter

        IconSvg { // barcodeImg
            Layout.preferredWidth: widgetBarcodeResult.height * 0.666
            Layout.preferredHeight: widgetBarcodeResult.height * 0.666
            Layout.alignment: Qt.AlignVCenter

            color: "white"
            source: barcode.isMatrix ? "qrc:/assets/icons/material-symbols/qr_code_2.svg" :
                                       "qrc:/assets/icons/material-symbols/barcode.svg"

            Rectangle {
                width: 12
                height: 12
                radius: 12
                z: -1
                color: barcode.color

                opacity: barcode.isOnScreen ? 0.80 : 0
                Behavior on opacity { NumberAnimation { duration: 133 } }
            }
        }

        Text { // barcodeTxt
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: barcode.data
            color: "white"
            font.pixelSize: Theme.fontSizeContent
            elide: Text.ElideRight
            //wrapMode: Text.WordWrap
        }

        Text { // barcodeFormat
            Layout.alignment: Qt.AlignVCenter

            text: barcode.format
            color: "white"
            opacity: 0.66
            font.pixelSize: Theme.fontSizeContentSmall
            elide: Text.ElideRight
            //wrapMode: Text.WordWrap
        }
    }

    /////////
}
