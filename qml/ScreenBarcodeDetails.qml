import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt5Compat.GraphicalEffects

import ThemeEngine

Item {
    id: screenBarcodeDetails
    anchors.fill: parent

    property string entryPoint: "ScreenBarcodeHistory"

    property var barcode: null

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // change screen
        appContent.state = "ScreenBarcodeDetails"
    }

    function loadScreenFrom(screenname, bc) {
        entryPoint = screenname
        barcode = bc

        console.log("loadScreenFrom( " + entryPoint + " / " + barcode +")")

        loadScreen()
    }

    function backAction() {
        if (entryPoint === "ScreenBarcodeHistory")
            screenBarcodeHistory.loadScreen()
        else if (entryPoint === "ScreenBarcodeReader")
            screenBarcodeReader.loadScreen()
    }

    ////////////////////////////////////////////////////////////////////////////

    property string barcode_string: barcode.data
    property string barcode_settings: "?" + setting_format + "&" + setting_eccLevel + "&" + setting_margins

    property string setting_format: "format=" + barcode.format
    property string setting_eccLevel: "eccLevel=2"
    property string setting_margins: "margins=0"

    Column {
        anchors.fill: parent
        anchors.margins: Theme.componentMarginL
        spacing: Theme.componentMargin

        ////////

        Item { // qrcodearea
            id: qrcodearea
            width: parent.width
            height: barcode.isMatrix ? parent.width : parent.width / 2

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
                anchors.margins: Theme.componentMarginL

                cache: true
                sourceSize.width: width
                sourceSize.height: height
                //fillMode: Image.PreserveAspectFit

                source: (settingsManager.backend === "qzxing") ?
                            "image://QZXing/encode/" + screenBarcodeDetails.barcode_string :
                            "image://ZXingCpp/encode/" + screenBarcodeDetails.barcode_string + screenBarcodeDetails.barcode_settings
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

        ////////

        Text { // content
            anchors.left: parent.left
            anchors.right: parent.right

            text: barcode.data
            font.pixelSize: Theme.fontSizeContentBig
            color: Theme.colorText
            elide: Text.ElideRight
        }

        ////////

        Row { // date
            //visible: barcode.date
            height: 24
            spacing: 8

            IconSvg {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                color: Theme.colorIcon
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: barcode.date
                font.pixelSize: 15
                color: Theme.colorSubText
            }
        }

        ////////

        Row { // location
            //visible: (barcode.latitude != 0 && barcode.longitude != 0)
            height: 24
            spacing: 8

            IconSvg {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
                color: Theme.colorIcon
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: barcode.latitude + "°N " + barcode.longitude + "°E"
                font.pixelSize: 15
                color: Theme.colorSubText
            }
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
