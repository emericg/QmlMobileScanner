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

    function loadBarcode(bc) {
        entryPoint = ""
        barcode = bc
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

    Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: gridContent.height

        interactive: singleColumn
        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar { visible: false }

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

            Column { // pane 1
                width: gridContent.www
                spacing: Theme.componentMargin

                ////

                Item {
                    id: qrcodearea
                    width: parent.width
                    height: barcode.isLinear ? (parent.width / 2) : parent.width

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

                        source: (settingsManager.backend_writer === "qzxing") ?
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

                ////

                Rectangle { // barcode content // single line
                    width: parent.width
                    height: barcodedata.height + Theme.componentMargin
                    radius: Theme.componentRadius
                    color: "white"
                    border.width: 2
                    border.color: Theme.colorComponentBorder

                    visible: barcode.isLinear

                    Text {
                        id: barcodedata
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Theme.componentMargin

                        text: barcode.data
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                        elide: Text.ElideRight
                    }
                }

                ////
            }

            ////////////////

            Column { // pane 2
                width: gridContent.www
                spacing: Theme.componentMargin

                ////

                Rectangle { // barcode content // multiple lines
                    width: parent.width
                    height: barcodedata2.contentHeight + Theme.componentMargin
                    radius: Theme.componentRadius
                    color: "white"
                    border.width: 2
                    border.color: Theme.colorComponentBorder

                    visible: barcode.isMatrix

                    IconSvg {
                        width: 24
                        height: 24
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        source: {
                            if (barcode.content === "URL") return "qrc:/assets/icons_material/duotone-launch-24px.svg"
                            if (barcode.content === "WiFi") return "qrc:/assets/icons_material/baseline-wifi-24px.svg"
                            if (barcode.content === "Email") return "qrc:/assets/icons_material/outline-mail_outline-24px.svg"
                            if (barcode.content === "Geolocation") return "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
                            if (barcode.content === "Phone") return "qrc:/assets/icons_material/baseline-phone-24px.svg"
                            if (barcode.content === "SMS") return "qrc:/assets/icons_material/duotone-question_answer-24px.svg"
                            return ""
                        }
                    }

                    Text {
                        id: barcodedata2
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Theme.componentMargin

                        text: barcode.data
                        color: Theme.colorText
                        wrapMode: Text.WrapAnywhere
                        font.pixelSize: Theme.fontSizeContentBig
                    }
                }

                ////

                Row { // format
                    //visible: barcode.format
                    height: 20
                    spacing: 8

                    IconSvg {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20

                        source: barcode.isMatrix ? "qrc:/assets/icons_material/baseline-qr_code_2-24px.svg" :
                                                   "qrc:/assets/icons_bootstrap/barcode.svg"
                        color: Theme.colorIcon
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: barcode.format
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                    }
                }

                ////

                Row { // date
                    //visible: barcode.date
                    height: 20
                    spacing: 8

                    IconSvg {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20

                        source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                        color: Theme.colorIcon
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: barcode.date.toLocaleString(Qt.locale(), "dddd d MMMM yyyy à hh:mm")
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                    }
                }

                ////

                Row { // location
                    //visible: (barcode.latitude != 0 && barcode.longitude != 0)
                    height: 20
                    spacing: 8

                    IconSvg {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20

                        source: "qrc:/assets/icons_material/duotone-pin_drop-24px.svg"
                        color: Theme.colorIcon
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: barcode.latitude + "°N " + barcode.longitude + "°E"
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorSubText
                    }
                }

                ////
            }

            ////////////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
