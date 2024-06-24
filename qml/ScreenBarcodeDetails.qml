import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

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

                        layer.enabled: true
                        layer.effect:  MultiEffect {
                            autoPaddingEnabled: true
                            shadowEnabled: true
                            shadowColor: "#20000000"
                        }
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
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskInverted: false
                            maskThresholdMin: 0.5
                            maskSpreadAtMin: 1.0
                            maskSpreadAtMax: 0.0
                            maskSource: ShaderEffectSource {
                                sourceItem: Rectangle {
                                    x: qrcodearea.x
                                    y: qrcodearea.y
                                    width: qrcodearea.width
                                    height: qrcodearea.height
                                    radius: Theme.componentRadius
                                }
                            }
                        }
                    }
                }

                ////

                Rectangle { // barcode content // single line
                    width: parent.width
                    height: barcodedata.height + Theme.componentMargin
                    radius: Theme.componentRadius
                    color: Theme.colorComponentBackground
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
                    height: barcodecontent.contentHeight + Theme.componentMargin
                    radius: Theme.componentRadius
                    color: Theme.colorComponentBackground
                    border.width: 2
                    border.color: Theme.colorComponentBorder

                    visible: barcode.isMatrix

                    RowLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.componentMargin
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.componentMargin / 2
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: barcodecontent
                            Layout.fillWidth: true

                            text: barcode.data
                            color: Theme.colorText
                            wrapMode: Text.WrapAnywhere
                            font.pixelSize: Theme.fontSizeContentBig
                        }

                        IconSvg {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignVCenter
                            visible: source.toString().length

                            color: Theme.colorIcon
                            source: {
                                if (barcode.content === "URL") return "qrc:/assets/icons/material-icons/duotone/launch.svg"
                                if (barcode.content === "WiFi") return "qrc:/assets/icons/material-symbols/wifi.svg"
                                if (barcode.content === "Email") return "qrc:/assets/icons/material-symbols/outline-mail_outline.svg"
                                if (barcode.content === "Geolocation") return "qrc:/assets/icons/material-icons/duotone/pin_drop.svg"
                                if (barcode.content === "Phone") return "qrc:/assets/icons/material-symbols/phone.svg"
                                if (barcode.content === "SMS") return "qrc:/assets/icons/material-icons/duotone/question_answer.svg"
                                return ""
                            }
                        }
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

                        source: barcode.isMatrix ? "qrc:/assets/icons/material-symbols/qr_code_2.svg" :
                                                   "qrc:/assets/icons/material-symbols/barcode.svg"
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

                        source: "qrc:/assets/icons/material-icons/duotone/date_range.svg"
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

                        source: "qrc:/assets/icons/material-icons/duotone/pin_drop.svg"
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
