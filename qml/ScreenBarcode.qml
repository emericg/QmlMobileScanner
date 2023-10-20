import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import ThemeEngine

Loader {
    id: screenBarcode
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load screen
        screenBarcode.active = true

        // change screen
        appContent.state = "ScreenBarcode"
    }

    function backAction() {
        if (screenBarcode.status === Loader.Ready)
            screenBarcode.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: columnContent.height

        interactive: false
        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar { visible: false }

        function backAction() {
            if (barcodeTextField.focus) {
                barcodeTextField.focus = false
                return
            }

            // don't change screen
        }

        Column {
            id: columnContent
            anchors.left: parent.left
            anchors.leftMargin: Theme.componentMarginXL
            anchors.right: parent.right
            anchors.rightMargin: Theme.componentMarginXL

            topPadding: Theme.componentMarginXL
            bottomPadding: Theme.componentMarginXL
            spacing: Theme.componentMarginXL

            ////////////////

            TextFieldThemed {
                id: barcodeTextField
                anchors.left: parent.left
                anchors.right: parent.right
                height: 48

                property string settings
            }

            ////////////////

            Item {
                id: qrcodearea
                width: parent.width
                height: width

                PopupBarcodeFullscreen {
                    id: popupBarcodeFullscreen
                    barcode_string: barcodeImage.source
                }

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
                                "image://QZXing/encode/" + barcodeTextField.displayText :
                                "image://ZXingCpp/encode/" + barcodeTextField.displayText + barcodeTextField.settings
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

                    onClicked: {
                        if (isMobile && barcodeTextField.displayText) {
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

            ////////////////

            SelectorMenuThemed {
                id: selectorBarcode2D
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40

                currentSelection: 1
                model:  ListModel {
                    id: lmSelectorBarcode2D
                    ListElement { idx: 1; txt: "QR Code"; src: ""; sz: 0; }
                    ListElement { idx: 2; txt: "Aztec"; src: ""; sz: 0; }
                    ListElement { idx: 3; txt: "DataMatrix"; src: ""; sz: 0; }
                    //ListElement { idx: 4; txt: "PDF417"; src: ""; sz: 0; }
                }

                onMenuSelected: (index) => {
                    //console.log("SelectorMenu clicked #" + index)
                    currentSelection = index
                     selectorBarcode1D.currentSelection = 0

                    if (index === 1) barcodeTextField.settings = "?format=qrcode"
                    if (index === 2) barcodeTextField.settings = "?format=aztec"
                    if (index === 3) barcodeTextField.settings = "?format=datamatrix"
                    if (index === 4) barcodeTextField.settings = "?format=pdf417"
                }
            }
            SelectorMenuThemed {
                id: selectorBarcode1D
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40

                currentSelection: 0
                model:  ListModel {
                    id: lmSelectorBarcode1D
                    ListElement { idx: 1; txt: "EAN 8"; src: ""; sz: 0; }
                    ListElement { idx: 2; txt: "EAN 13"; src: ""; sz: 0; }
                    ListElement { idx: 3; txt: "Code 128"; src: ""; sz: 0; }
                }

                onMenuSelected: (index) => {
                    //console.log("SelectorMenu clicked #" + index)
                    currentSelection = index
                    selectorBarcode2D.currentSelection = 0

                    if (index === 1) barcodeTextField.settings = "?format=ean8"
                    if (index === 2) barcodeTextField.settings = "?format=ean13"
                    if (index === 3) barcodeTextField.settings = "?format=code128"
                }
            }

            ////////////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
