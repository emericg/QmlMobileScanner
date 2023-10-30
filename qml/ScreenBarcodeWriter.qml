import QtCore
import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls

import Qt5Compat.GraphicalEffects

import ThemeEngine

Loader {
    id: screenBarcodeWriter
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load screen
        screenBarcodeWriter.active = true

        // change screen
        appContent.state = "ScreenBarcodeWriter"
    }

    function backAction() {
        if (screenBarcodeWriter.status === Loader.Ready)
            screenBarcodeWriter.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: gridContent.height

        interactive: singleColumn
        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar { visible: false }

        function backAction() {
            if (barcodeTextField.focus) {
                barcodeTextField.focus = false
                return
            }

            // don't change screen
        }

        Grid {
            id: gridContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: columnSpacing

            columns: singleColumn ? 1 : 2
            columnSpacing: Theme.componentMarginXL * (singleColumn ? 1 : 2)
            rows: 2
            rowSpacing: Theme.componentMarginXL * (singleColumn ? 1 : 2)

            topPadding: columnSpacing
            bottomPadding: columnSpacing
            spacing: columnSpacing

            property int www: singleColumn ? gridContent.width : (gridContent.width - columnSpacing) / 2
            property int hhh: screenBarcodeWriter.height - columnSpacing*2

            ////////////////

            Item { // pane 1
                id: barcodeView
                width: gridContent.www
                height: singleColumn ? qrcodearea.height : gridContent.hhh

                ////

                Item {
                    id: qrcodearea
                    anchors.centerIn: parent

                    width: Math.min(gridContent.www, gridContent.hhh)
                    height: width

                    Rectangle {
                        id: shadowarea
                        anchors.fill: parent

                        radius: Theme.componentRadius
                        color: "white"

                        border.width: 2
                        border.color: Theme.colorComponentBorder
                    }
                    DropShadow {
                        anchors.fill: shadowarea
                        cached: true
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 6.0
                        samples: 12
                        color: "#20000000"
                        source: shadowarea
                    }

                    Image {
                        id: barcodeImage
                        anchors.fill: parent
                        anchors.margins: Theme.componentMargin

                        cache: false
                        sourceSize.width: width
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectFit

                        source: (settingsManager.backend === "qzxing") ?
                                    "image://QZXing/encode/" + barcodeAdvanced.barcode_string :
                                    "image://ZXingCpp/encode/" + barcodeAdvanced.barcode_string + barcodeAdvanced.barcode_settings
                    }

                    MouseArea {
                        id: mmmm
                        anchors.fill: parent
                        anchors.margins: 0

                        clip: true
                        enabled: true
                        visible: true
                        hoverEnabled: false
                        acceptedButtons: Qt.LeftButton

                        PopupBarcodeFullscreen {
                            id: popupBarcodeFullscreen
                            barcode_string: barcodeImage.source
                        }

                        onClicked: {
                            if (isMobile && barcodeAdvanced.barcode_string) {
                                popupBarcodeFullscreen.open()
                            }
                        }

                        onPressed: {
                            mouseBackground.width = mmmm.width*3
                            mouseBackground.opacity = 0.1
                        }
                        onReleased: {
                            mouseBackground.width = 0
                            mouseBackground.opacity = 0
                        }
                        onCanceled: {
                            mouseBackground.width = 0
                            mouseBackground.opacity = 0
                        }

                        Rectangle {
                            id: mouseBackground
                            width: 0; height: width; radius: width;
                            x: mmmm.mouseX + 4 - (mouseBackground.width / 2)
                            y: mmmm.mouseY + 4 - (mouseBackground.width / 2)
                            color: "#333"
                            opacity: 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            Behavior on width { NumberAnimation { duration: 200 } }
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                x: qrcodearea.x
                                y: qrcodearea.y
                                width: qrcodearea.width
                                height: qrcodearea.height
                                radius: Theme.componentRadius
                            }
                        }
                    }
                }

                ////
            }

            ////////////////

            Item { // pane 2
                id: barcodeAdvanced
                width: gridContent.www
                height: singleColumn ? settingsarea.height : gridContent.hhh

                property string barcode_string
                property string barcode_settings: "?" + setting_format + "&" + setting_eccLevel + "&"
                                                      + setting_margins + "&" + setting_colorBg + "&" + setting_colorFg

                property string setting_format: "format=qrcode"
                property string setting_eccLevel: "eccLevel=0"
                property string setting_margins: "margins=0"
                property string setting_colorBg: "backgroundColor=" + colorBg
                property string setting_colorFg: "foregroundColor=" + colorFg
                property color colorBg: "#fff"
                property color colorFg: "#000"

                Column {
                    id: settingsarea
                    anchors.centerIn: parent

                    width: gridContent.www
                    spacing: Theme.componentMarginXL

                    ////

                    TextFieldThemed {
                        id: barcodeTextField
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 40
                        visible: singleColumn

                        onDisplayTextChanged: barcodeAdvanced.barcode_string = displayText
                    }
                    TextAreaThemed {
                        id: barcodeTextArea
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 128
                        visible: !singleColumn

                        wrapMode: "WrapAnywhere"
                        selectByMouse: true
                        onTextChanged: barcodeAdvanced.barcode_string = text
                    }

                    ////

                    SelectorGrid {
                        id: selectorBarcodes
                        anchors.left: parent.left
                        anchors.right: parent.right

                        currentSelection: 1
                        model: ListModel {
                            id: lmSelectorBarcodes

                            // matrix
                            ListElement { idx: 1; txt: "QR Code"; src: ""; sz: 0;       maxchar: 4296; maxbytes: 2953; ecc: 4; }
                            ListElement { idx: 2; txt: "Aztec"; src: ""; sz: 0;         maxchar: 3067; maxbytes: 3067; ecc: 8;}
                            ListElement { idx: 3; txt: "DataMatrix"; src: ""; sz: 0; }
                            //ListElement { idx: 4; txt: "PDF417"; src: ""; sz: 0; }
                            // linear
                            ListElement { idx: 5; txt: "EAN 13"; src: ""; sz: 0; }
                            ListElement { idx: 6; txt: "EAN 8"; src: ""; sz: 0; }
                            ListElement { idx: 7; txt: "UPC-A"; src: ""; sz: 0; }
                            ListElement { idx: 8; txt: "UPC-E"; src: ""; sz: 0; }
                            ListElement { idx: 9; txt: "Code 39"; src: ""; sz: 0; }
                            ListElement { idx: 10; txt: "Code 93"; src: ""; sz: 0; }
                            ListElement { idx: 11; txt: "Code 128"; src: ""; sz: 0; }
                            ListElement { idx: 12; txt: "Codabar"; src: ""; sz: 0; }
                            ListElement { idx: 13; txt: "ITF"; src: ""; sz: 0; }
                        }

                        onMenuSelected: (index) => {
                            //console.log("SelectorMenu clicked #" + index)

                            currentSelection = index
                            var selection = ""

                            if (index === 1) selection = "format=qrcode"
                            else if (index === 2) selection = "format=aztec"
                            else if (index === 3) selection = "format=datamatrix"
                            else if (index === 4) selection = "format=pdf417"
                            else if (index === 5) selection = "format=ean13"
                            else if (index === 6) selection = "format=ean8"
                            else if (index === 7) selection = "format=upca"
                            else if (index === 8) selection = "format=upce"
                            else if (index === 9) selection = "format=code39"
                            else if (index === 10) selection = "format=code93"
                            else if (index === 11) selection = "format=code128"
                            else if (index === 12) selection = "format=codabar"
                            else if (index === 13) selection = "format=itf"

                            barcodeAdvanced.setting_format = selection
                        }
                    }

                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: qsTr("Error correction:")
                            color: Theme.colorText
                            font.pixelSize: Theme.componentFontSize
                        }

                        SliderThemed {
                            id: barcodeEccSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            snapMode: Slider.SnapAlways
                            stepSize: 2
                            value: 1
                            from: 0
                            to: 8

                            onMoved: barcodeAdvanced.setting_eccLevel = "eccLevel=" + parseInt(value)
                        }
                    }

                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: qsTr("Margins:")
                            color: Theme.colorText
                            font.pixelSize: Theme.componentFontSize
                        }

                        SliderThemed {
                            id: barcodeBorderSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            snapMode: Slider.SnapAlways
                            stepSize: 8
                            value: 0
                            from: 0
                            to: 32

                            onMoved: barcodeAdvanced.setting_margins = "margins=" + parseInt(value)
                        }
                    }

                    Row {
                        spacing: Theme.componentMargin

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Colors:")
                            color: Theme.colorText
                            font.pixelSize: Theme.componentFontSize
                        }

                        ButtonWireframe {
                            height: 36
                            fullColor: true
                            primaryColor: barcodeAdvanced.colorBg
                            fulltextColor: utilsApp.isQColorLight(barcodeAdvanced.colorBg) ? "#333" : "#f4f4f4"
                            font.bold: true

                            text: qsTr("background color")
                            onClicked: colorDialogBg.open()

                            ColorDialog {
                                id: colorDialogBg
                                selectedColor: barcodeAdvanced.colorBg
                                onAccepted: barcodeAdvanced.colorBg = selectedColor
                            }
                        }

                        ButtonWireframe {
                            height: 36
                            fullColor: true
                            primaryColor: barcodeAdvanced.colorFg
                            fulltextColor: utilsApp.isQColorLight(barcodeAdvanced.colorFg) ? "#333" : "#f4f4f4"
                            font.bold: true

                            text: qsTr("foreground color")
                            onClicked: colorDialogFg.open()

                            ColorDialog {
                                id: colorDialogFg
                                selectedColor: barcodeAdvanced.colorFg
                                onAccepted: barcodeAdvanced.colorFg = selectedColor
                            }
                        }
                    }

                    ////

                    Row {
                        spacing: Theme.componentMargin

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Save to file")
                            color: Theme.colorText
                            font.pixelSize: Theme.componentFontSize
                        }

                        ComboBoxThemed {
                            height: 36

                            model: ListModel {
                                ListElement { text: "SVG"; }
                                ListElement { text: "PNG"; }
                                ListElement { text: "JPEG"; }
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

                            FileDialog {
                                id: fileSaveDialog

                                fileMode: FileDialog.SaveFile
                                nameFilters: ["Vector files (*.svg)", "PNG files (*.png)", "JPEG files (*.jpg *.jpeg)"]
                                currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
                                currentFile: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0] + "/barcode"

                                onAccepted: {
                                    console.log(" - " + fileSaveDialog.selectedNameFilter.name[0])
                                    console.log(" - " + fileSaveDialog.selectedNameFilter.extensions[0])
                                }
                            }
                        }
                    }
                }

                ////
            }

            ////////////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
