import QtCore
import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls

import QZXing
import ComponentLibrary

Row {
    id: barcodeWriter_qzxing

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
        }
    }

    ButtonFlat {
        height: 36
        color: Theme.colorGrey
        font.bold: true

        text: qsTr("save")
        source: "qrc:/IconLibrary/material-symbols/save.svg"
        onClicked: fileSaveDialog.open()

        QZXing {
            id: qzxing_backend
        }

        FileDialog {
            id: fileSaveDialog

            fileMode: FileDialog.SaveFile
            nameFilters: ["Pictures (*.png *.bmp *.jpg *.jpeg *.webp)",
                          "PNG files (*.png)", "BMP files (*.bmp)", "JPEG files (*.jpg *.jpeg)", "WebP files (*.webp)"]
            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
            currentFile: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0] + "/barcode." + fileSaveExtension.currentText.toLowerCase()

            onAccepted: {
                console.log("fileSaveDialog: ACCEPTED: " + selectedFile)

                var eccLevel = 0
                if (barcodeAdvanced.eccStr === "M") eccLevel = 1
                if (barcodeAdvanced.eccStr === "Q") eccLevel = 2
                if (barcodeAdvanced.eccStr === "H") eccLevel = 3

                qzxing_backend.saveImage(barcodeAdvanced.barcode_string,
                                         barcodeAdvanced.exportSize, barcodeAdvanced.exportSize, barcodeAdvanced.border,
                                         eccLevel,
                                         fileSaveDialog.selectedFile)
            }
            onRejected: {
                console.log("fileSaveDialog: REJECTED: " + selectedFile)
            }
        }
    }
}
