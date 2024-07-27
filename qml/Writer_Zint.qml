import QtCore
import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls

import ZintQml
import ThemeEngine

Row {
    id: barcodeWriter_zint

    width: 512
    height: 36

    spacing: Theme.componentMargin

    enabled: barcodeAdvanced.barcode_string

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: qsTr("Save to file")
        textFormat: Text.PlainText
        color: Theme.colorText
        font.pixelSize: Theme.componentFontSize
    }

    ComboBoxThemed {
        id: fileSaveExtension
        width: 128
        height: 36

        model: ListModel {
            ListElement { text: "PNG"; }
            ListElement { text: "BMP"; }
            ListElement { text: "JPEG"; }
            ListElement { text: "WEBP"; }
            ListElement { text: "SVG"; }
        }
    }

    ButtonFlat {
        height: 36
        color: Theme.colorGrey
        font.bold: true

        text: qsTr("save")
        source: "qrc:/assets/icons/material-symbols/save.svg"
        onClicked: fileSaveDialog.open()

        ZintQml {
            id: zint_backend
        }

        FileDialog {
            id: fileSaveDialog

            fileMode: FileDialog.SaveFile
            nameFilters: ["Pictures (*.png *.bmp *.jpg *.jpeg *.webp *.svg)",
                          "PNG files (*.png)", "BMP files (*.bmp)", "JPEG files (*.jpg *.jpeg)", "WebP files (*.webp)", "Vector files (*.svg)"]
            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
            currentFile: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0] + "/barcode." + fileSaveExtension.currentText.toLowerCase()

            onAccepted: {

                zint_backend.saveImage(barcodeAdvanced.barcode_string,
                                       barcodeAdvanced.exportSize, barcodeAdvanced.exportSize, barcodeAdvanced.margins,
                                       zint_backend.stringToFormat(barcodeAdvanced.format), 0, barcodeAdvanced.eccLevel,
                                       barcodeAdvanced.colorBg, barcodeAdvanced.colorFg,
                                       fileSaveDialog.selectedFile)
            }
        }
    }
}
