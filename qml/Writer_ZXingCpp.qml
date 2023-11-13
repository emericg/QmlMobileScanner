import QtCore
import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls

import ZXingCpp
import ThemeEngine

Row {
    id: barcodeWriter

    width: 512
    height: 36

    spacing: Theme.componentMargin

    enabled: barcodeAdvanced.barcode_string

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: qsTr("Save to file")
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

    ButtonWireframeIcon {
        height: 36
        fullColor: true
        primaryColor: Theme.colorGrey
        font.bold: true

        text: qsTr("save")
        source: "qrc:/assets/icons_material/baseline-save-24px.svg"
        onClicked: fileSaveDialog.open()

        ZXingQt {
            id: zxingcpp_backend
        }

        FileDialog {
            id: fileSaveDialog

            fileMode: FileDialog.SaveFile
            nameFilters: ["Vector files (*.svg)", "PNG files (*.png)", "BMP files (*.bmp)", "JPEG files (*.jpg *.jpeg)", "WebP files (*.webp)"]
            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
            currentFile: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0] + "/barcode." + fileSaveExtension.currentText.toLowerCase()

            onAccepted: {
                console.log(" - " + fileSaveDialog.selectedFile)
                console.log(" - " + fileSaveDialog.selectedNameFilter.name[0])
                console.log(" - " + fileSaveDialog.selectedNameFilter.extensions[0])

                zxingcpp_backend.saveImage(barcodeAdvanced.barcode_string, 512, 512, 16,
                                           8192, 0, 0,
                                           barcodeAdvanced.colorBg, barcodeAdvanced.colorFg,
                                           fileSaveDialog.selectedFile)
            }
        }
    }
}
