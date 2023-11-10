import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine

Item {
    id: widgetBarcodeResult

    implicitWidth: 256
    implicitHeight: 40

    property var barcode: null

    Rectangle {
        anchors.fill: parent
        radius: height
        color: "black"
        opacity: 0.33
    }

    IconSvg {
        id: barcodeImg
        width: parent.height * 0.666
        height: parent.height * 0.666
        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        source: barcode.isMatrix ? "qrc:/assets/icons_material/baseline-qr_code_2-24px.svg" :
                                   "qrc:/assets/icons_bootstrap/upc.svg"

        Rectangle {
            width: 12
            height: 12
            radius: 12
            z: -1
            opacity: 0.85
            color: barcode.color
        }
    }

    Text {
        id: barcodeTxt
        anchors.left: barcodeImg.right
        anchors.leftMargin: Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter

        text: barcode.data
        color: "white"
        font.pixelSize: Theme.fontSizeContent
        elide: Text.ElideRight
        //wrapMode: Text.WordWrap
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: Theme.componentMargin
        anchors.verticalCenter: parent.verticalCenter

        text: barcode.format
        color: "white"
        opacity: 0.66
        font.pixelSize: Theme.fontSizeContentSmall
        elide: Text.ElideRight
        //wrapMode: Text.WordWrap
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Qt.openUrlExternally(barcode.data)
        }
    }
}
