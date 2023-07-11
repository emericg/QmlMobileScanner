import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import QZXing

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

                //onDisplayTextChanged: {
                //    popupCertificate.barcode = displayText
                //    barcodeImage.source = displayText
                //    popupCertificate.barcode = displayText
                //}
            }

            ////////////////

            Item {
                id: qrcodearea
                width: parent.width
                height: width

                PopupCertificate {
                    id: popupCertificate
                    barcode: barcodeTextField.displayText
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

                    sourceSize.width: width
                    sourceSize.height: height

                    source: "image://QZXing/encode/" + barcodeTextField.displayText
                    cache: false
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
                        if (barcodeTextField.displayText) {
                            popupCertificate.open()
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
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
