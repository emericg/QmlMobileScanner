import QtQuick
import QtQuick.Layouts

import ZintQml
import ThemeEngine

Item {
    id: barcodeWriter_zint

    width: 512
    height: 32

    RowLayout {
        width: parent.width
        spacing: Theme.componentMargin

        IconSvg {
            width: 24
            height: 24
            Layout.alignment: Qt.AlignVCenter
            color: Theme.colorWarning
            source: "qrc:/assets/icons_material/baseline-warning-24px.svg"
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            text: qsTr("Zint backend cannot save barcodes to file YET")
            textFormat: Text.PlainText
            color: Theme.colorText
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.componentFontSize
        }
    }
}
