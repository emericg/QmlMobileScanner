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
            if (barcodeTextArea.focus) {
                barcodeTextArea.focus = false
                return
            }

            screenBarcodeReader.loadScreen()
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
                        color: barcodeAdvanced.colorBg // was "white"

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
                        anchors.margins: 4

                        cache: false
                        smooth: false

                        sourceSize.width: width
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectFit

                        source: {
                            if (settingsManager.backend_zint) return "image://ZintQml/encode/" + barcodeAdvanced.barcode_string + barcodeAdvanced.barcode_settings_zxingcpp
                            if (settingsManager.backend_zxingcpp) return "image://ZXingCpp/encode/" + barcodeAdvanced.barcode_string + barcodeAdvanced.barcode_settings_zxingcpp
                            if (settingsManager.backend_qzxing) return "image://QZXing/encode/" + barcodeAdvanced.barcode_string + barcodeAdvanced.barcode_settings_qzxing
                        }
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
                property string barcode_settings_qzxing: "?" + "format=" + format + "&"
                                                             + "border=" + border + "&"
                                                             + "correctionLevel=" + eccStr
                property string barcode_settings_zxingcpp: "?" + "format=" + format + "&"
                                                               + "eccLevel=" + eccLevel + "&"
                                                               + "margins=" + margins + "&"
                                                               + "backgroundColor=" + colorBg + "&"
                                                               + "foregroundColor=" + colorFg

                property string format: "qrcode"

                property string eccStr: "L"
                property bool border: true

                property int eccLevel: 0
                property int margins: 12
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

                        visible: (selectorBarcodes.currentMode == "1d") // linear
                        placeholderText: qsTr("type barcode content here")

                        maximumLength: 12
                        validator: IntValidator { bottom: 0; top: 999999999; }

                        onDisplayTextChanged: {
                            var code = "0"
                            var codesize = 7

                            if (barcodeAdvanced.format === "ean13") codesize = 12
                            if (barcodeAdvanced.format === "ean8") codesize = 7
                            if (barcodeAdvanced.format === "upca") codesize = 11
                            if (barcodeAdvanced.format === "upce") codesize = 7
                            if (barcodeAdvanced.format === "code39") codesize = 39
                            if (barcodeAdvanced.format === "code93") codesize = 93
                            if (barcodeAdvanced.format === "code128") codesize = 128
                            if (barcodeAdvanced.format === "codabar") codesize = 11
                            if (barcodeAdvanced.format === "itf") codesize = 10

                            code = displayText.slice(0, codesize)
                            code = code.padEnd(codesize, '0');
                            barcodeAdvanced.barcode_string = code
                        }
                        ButtonWireframe {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            fullColor: true
                            visible: barcodeTextField.text

                            text: qsTr("clear")
                            onClicked: barcodeTextField.clear()
                        }
                    }
                    TextAreaThemed {
                        id: barcodeTextArea
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: isPhone ? 96 : 128

                        visible: (selectorBarcodes.currentMode === "2d") // matrix
                        placeholderText: qsTr("type barcode content here")

                        wrapMode: "WrapAnywhere"
                        selectByMouse: true
                        onTextChanged: barcodeAdvanced.barcode_string = text

                        ButtonWireframe {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 36
                            fullColor: true
                            visible: barcodeTextArea.text

                            text: qsTr("clear")
                            onClicked: {
                                barcodeTextArea.clear()
                                barcodeTextArea.focus = false
                            }
                        }
                    }

                    ////

                    SelectorGrid {
                        id: selectorBarcodes
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: (settingsManager.backend === "zxingcpp")

                        ListModel {
                            id: lmSelectorBarcodes_zintqml

                            // matrix
                            ListElement { idx:  0; type: "2d"; txt: "QrCode"; format: "qrcode";             maxnum: 0; maxchar: 4296; maxbytes: 2953; ecc: 4; }
                            ListElement { idx:  1; type: "2d"; txt: "Micro QrCode"; format: "microqrcode";  maxnum: 0; maxchar: 21; maxbytes: 256; ecc: 4; }
                            ListElement { idx:  2; type: "2d"; txt: "Rect. Micro QrCode"; format: "rmqr";   maxnum: 0; maxchar: 21; maxbytes: 256; ecc: 4; }
                            ListElement { idx:  3; type: "2d"; txt: "Aztec"; format: "aztec";               maxnum: 0; maxchar: 3067; maxbytes: 3067; ecc: 8; }
                            ListElement { idx:  4; type: "2d"; txt: "DataMatrix"; format: "datamatrix";     maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            ListElement { idx:  5; type: "2d"; txt: "PDF417"; format: "pdf417";             maxnum: 0; maxchar: 1850; maxbytes: 1108; ecc: 8; }
                            ListElement { idx:  6; type: "2d"; txt: "Micro PDF417"; format: "micropdf417";  maxnum: 0; maxchar: 256; maxbytes: 1108; ecc: 8; }
                            ListElement { idx:  7; type: "2d"; txt: "GridMatrix"; format: "gridmatrix";     maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            // esoteric (but fun)
                            ListElement { idx: 8; type: "2d"; txt: "DotCode"; format: "dotcode";           maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            ListElement { idx: 9; type: "2d"; txt: "MaxiCode"; format: "maxicode";         maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            ListElement { idx: 10; type: "2d"; txt: "UltraCode"; format: "ultracode";       maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            ListElement { idx: 11; type: "2d"; txt: "Code One"; format: "codeone";          maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            // esoteric (but not particularly fun)
                            //ListElement { idx: 8; type: "2d"; txt: "HanXin"; format: "hanxin";             maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            //ListElement { idx: 9; type: "2d"; txt: "Code 49"; format: "code49";            maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            //ListElement { idx: 10; type: "2d"; txt: "Code 16k"; format: "code16k";          maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            //ListElement { idx: 11; type: "2d"; txt: "Codablock F"; format: "codablockf";    maxnum: 0; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                        }
                        ListModel {
                            id: lmSelectorBarcodes_zxingcpp

                            // matrix
                            ListElement { idx:  0; type: "2d"; txt: "QR Code"; format: "qrcode";        maxchar: 4296; maxbytes: 2953; ecc: 4; }
                            ListElement { idx:  1; type: "2d"; txt: "Aztec"; format: "aztec";           maxchar: 3067; maxbytes: 3067; ecc: 8; }
                            ListElement { idx:  2; type: "2d"; txt: "DataMatrix"; format: "datamatrix"; maxchar: 2335; maxbytes: 1556; ecc: 0; }
                            // linear
                            ListElement { idx:  3; type: "1d"; txt: "Codabar"; format: "codabar";       maxnum: 12; }
                            ListElement { idx:  4; type: "1d"; txt: "EAN 13"; format: "ean13";          maxnum: 12; }
                            ListElement { idx:  5; type: "1d"; txt: "EAN 8"; format: "ean8";            maxnum: 7; }
                            ListElement { idx:  6; type: "1d"; txt: "UPC-A"; format: "upca";            maxnum: 11; }
                            ListElement { idx:  7; type: "1d"; txt: "UPC-E"; format: "upce";            maxnum: 7; }
                            ListElement { idx:  8; type: "1d"; txt: "Code 39"; format: "code39";        maxnum: 39; }
                            ListElement { idx:  9; type: "1d"; txt: "Code 93"; format: "code93";        maxnum: 93; }
                            ListElement { idx: 10; type: "1d"; txt: "Code 128"; format: "code128";      maxnum: 128; }
                            ListElement { idx: 11; type: "1d"; txt: "ITF"; format: "itf";               maxnum: 10; }
                        }
                        model: {
                            if (settingsManager.backend_zint) return lmSelectorBarcodes_zintqml
                            if (settingsManager.backend_zxingcpp) return lmSelectorBarcodes_zxingcpp
                        }

                        currentSelection: 0
                        property string currentMode: "2d"

                        onMenuSelected: (index) => {
                            //console.log("SelectorMenu clicked #" + index)
                            currentSelection = index
                            currentMode = model.get(currentSelection).type
                            barcodeAdvanced.format = model.get(currentSelection).format
                            barcodeTextField.maximumLength = model.get(currentSelection).maxchar
                        }
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: (selectorBarcodes.currentSelection < 5) // matrix
                        spacing: 16

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Error correction:")
                            color: Theme.colorText
                            font.pixelSize: Theme.componentFontSize
                        }

                        SelectorMenuThemed {
                            id: barcodeEccSeclector
                            anchors.verticalCenter: parent.verticalCenter
                            height: 32

                            ListModel {
                                id: lmBarcodeEccQR
                                ListElement { idx: 0; txt: "L"; redondancy: 7; ecc: 2; }
                                ListElement { idx: 1; txt: "M"; redondancy: 15; ecc: 4; }
                                ListElement { idx: 2; txt: "Q"; redondancy: 25; ecc: 6; }
                                ListElement { idx: 3; txt: "H"; redondancy: 30; ecc: 8; }
                            }
                            ListModel {
                                id: lmBarcodeEccAz
                                ListElement { idx: 0; txt: "1%"; redondancy: 0; ecc: 0; }
                                ListElement { idx: 1; txt: "12%"; redondancy: 12; ecc: 1; }
                                ListElement { idx: 2; txt: "25%"; redondancy: 25; ecc: 2; }
                                ListElement { idx: 3; txt: "37%"; redondancy: 37; ecc: 3; }
                                ListElement { idx: 4; txt: "50%"; redondancy: 50; ecc: 4; }
                                ListElement { idx: 5; txt: "62%"; redondancy: 62; ecc: 5; }
                                ListElement { idx: 6; txt: "75%"; redondancy: 75; ecc: 6; }
                                ListElement { idx: 7; txt: "87%"; redondancy: 87; ecc: 7; }
                                ListElement { idx: 8; txt: "99%"; redondancy: 100; ecc: 8; }
                            }
                            ListModel {
                                id: lmBarcodeEccPdf
                                ListElement { idx: 0; txt: "0"; redondancy: 1; ecc: 0; }
                                ListElement { idx: 1; txt: "1"; redondancy: 1; ecc: 1; }
                                ListElement { idx: 2; txt: "2"; redondancy: 1; ecc: 2; }
                                ListElement { idx: 3; txt: "3"; redondancy: 1; ecc: 3; }
                                ListElement { idx: 4; txt: "4"; redondancy: 3; ecc: 4; }
                                ListElement { idx: 5; txt: "5"; redondancy: 7; ecc: 5; }
                                ListElement { idx: 6; txt: "6"; redondancy: 14; ecc: 6; }
                                ListElement { idx: 7; txt: "7"; redondancy: 28; ecc: 7; }
                                ListElement { idx: 8; txt: "8"; redondancy: 57; ecc: 8; }
                            }
                            ListModel {
                                id: lmBarcodeEccDM
                                ListElement { idx: 0; txt: "~25%"; redondancy: 0; ecc: 0; }
                            }

                            currentSelection: 0
                            model: {
                                if (barcodeAdvanced.format === "qrcode") return lmBarcodeEccQR
                                if (barcodeAdvanced.format === "aztec") return lmBarcodeEccAz
                                if (barcodeAdvanced.format === "datamatrix") return lmBarcodeEccDM
                                if (barcodeAdvanced.format === "pdf417") return lmBarcodeEccPdf
                            }

                            onModelChanged: {
                                //
                            }
                            onMenuSelected: (index) => {
                                //console.log("lmBarcodeEccPd[index].ecc : " + lmBarcodeEccQR.get(index).ecc)
                                currentSelection = index

                                var vvv = 0
                                if (barcodeAdvanced.format === "qrcode") vvv = lmBarcodeEccQR.get(index).ecc
                                if (barcodeAdvanced.format === "aztec") vvv = lmBarcodeEccAz.get(index).ecc
                                if (barcodeAdvanced.format === "datamatrix") vvv = lmBarcodeEccDM.get(index).ecc
                                if (barcodeAdvanced.format === "pdf417") vvv = lmBarcodeEccPdf.get(index).ecc

                                barcodeAdvanced.eccLevel = parseInt(vvv)
                                barcodeAdvanced.eccStr = (settingsManager.backend === "qzxing") ? lmBarcodeEccQR.get(index).txt : "L"
                            }
                        }
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        spacing: 16
                        visible: (settingsManager.backend === "qzxing")

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Borders:")
                            color: Theme.colorText
                            font.pixelSize: Theme.componentFontSize
                        }

                        SelectorMenuThemed {
                            id: barcodeBorderSeclector
                            anchors.verticalCenter: parent.verticalCenter
                            height: 32

                            currentSelection: 1
                            model: ListModel {
                                id: lmBoderSelector
                                ListElement { idx: 0; txt: "no"; }
                                ListElement { idx: 1; txt: "yes"; }
                            }

                            onMenuSelected: (index) => {
                                currentSelection = index
                                if (currentSelection === 1) barcodeAdvanced.border = true
                                else barcodeAdvanced.border = false
                            }
                        }
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        spacing: 16
                        visible: (settingsManager.backend === "zxingcpp")

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Margins:")
                            color: Theme.colorText
                            font.pixelSize: Theme.componentFontSize
                        }

                        SelectorMenuThemed {
                            id: barcodeMarginSeclector
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            currentSelection: 1
                            model: ListModel {
                                id: lmMarginSelector
                                ListElement { idx: 0; txt:  "0"; margin: 0; }
                                ListElement { idx: 1; txt: "12"; margin: 12; }
                                ListElement { idx: 2; txt: "24"; margin: 24; }
                                ListElement { idx: 3; txt: "32"; margin: 32; }
                            }

                            onMenuSelected: (index) => {
                                //console.log("lmMarginSelector[index].margin : " + lmMarginSelector.get(index).margin)
                                currentSelection = index
                                barcodeAdvanced.margins = parseInt(lmMarginSelector.get(index).margin)
                            }
                        }
                    }

                    Row {
                        spacing: Theme.componentMargin
                        visible: (settingsManager.backend === "zxingcpp")

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

                    Loader {
                        id: backendLoader
                        width: gridContent.www

                        active: true
                        asynchronous: true
                        source: {
                            if (settingsManager.backend === "zint") return "Writer_Zint.qml"
                            if (settingsManager.backend === "zxingcpp") return "Writer_ZXingCpp.qml"
                            if (settingsManager.backend === "qzxing") return "Writer_QZXing.qml"
                        }
                    }
                    property alias barcodeWriter: backendLoader.item
                }

                ////
            }

            ////////////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
