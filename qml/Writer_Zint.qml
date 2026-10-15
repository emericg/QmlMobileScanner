import QtCore
import QtQuick
import QtQuick.Dialogs

import ZintQml
import ComponentLibrary

Row {
    id: barcodeWriter_zint

    width: 512
    height: 36

    spacing: Theme.componentMargin

    enabled: barcodeAdvanced.barcode_string

    // current export settings, shared by the save dialog and the drag to export
    readonly property string fileExtension: fileSaveExtension.currentText.toLowerCase()

    function exportToFile(fileUrl) {
        return zint_backend.saveImage(barcodeAdvanced.barcode_string,
                                      barcodeAdvanced.exportSize, barcodeAdvanced.exportSize, barcodeAdvanced.margins,
                                      zint_backend.stringToFormat(barcodeAdvanced.format), 0, barcodeAdvanced.eccLevel,
                                      barcodeAdvanced.colorBg, barcodeAdvanced.colorFg,
                                      fileUrl)
    }

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
        font.bold: true
        color: barcodeAdvanced.barcode_string ? Theme.colorPrimary : Theme.colorGrey

        text: qsTr("save")
        source: "qrc:/IconLibrary/material-symbols/save.svg"
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
            currentFile: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0] + "/barcode." + barcodeWriter_zint.fileExtension

            onAccepted: {
                console.log("fileSaveDialog: ACCEPTED: " + selectedFile)
                barcodeWriter_zint.exportToFile(fileSaveDialog.selectedFile)
            }
            onRejected: {
                console.log("fileSaveDialog: REJECTED: " + selectedFile)
            }
        }
    }
}
