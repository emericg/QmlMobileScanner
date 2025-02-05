import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls

import ComponentLibrary
import QmlMobileScanner

Rectangle {
    id: screenBarcodeDetails

    anchors.fill: parent
    visible: false

    color: Theme.colorBackground

    property string entryPoint: "ScreenBarcodeHistory"

    property var barcode: null

    ////////////////////////////////////////////////////////////////////////////
/*
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
*/
    function loadBarcode(bc) {
        barcode = bc
        visible = true
    }

    function backAction() {
        if (entryPoint === "ScreenBarcodeHistory") {
            if (stackView.depth > 1) {
                stackView.pop()
            }
        } else if (entryPoint === "ScreenBarcodeReader") {
            visible = false
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    PopupHistoryDelete {
        id: popupHistoryDelete

        onConfirmed: {
            utilsApp.vibrate(33)
            barcodeManager.removeHistory(barcode.data)
            backAction()
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    property string barcode_string: barcode.data
    property string barcode_settings_qzxing: "?" + "format=" + barcode.format +
                                             "&"  + "correctionLevel=" + "L" +
                                             "&"  + "border=" + 0
    property string barcode_settings_zxingcpp: "?" + "format=" + barcode.format +
                                               "&" + "eccLevel=" + 0 +
                                               "&" + "margins=" + 0

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
            anchors.leftMargin: screenPaddingLeft + columnSpacing
            anchors.right: parent.right
            anchors.rightMargin: screenPaddingRight + columnSpacing

            columns: singleColumn ? 1 : 2
            columnSpacing: Theme.componentMarginXL * (singleColumn ? 1 : 2)
            rows: 2
            rowSpacing: Theme.componentMarginXL * (singleColumn ? 1 : 2)

            topPadding: columnSpacing
            bottomPadding: columnSpacing
            spacing: columnSpacing

            property int www: singleColumn ? gridContent.width : (gridContent.width - columnSpacing) / 2
            property int hhh: screenBarcodeDetails.height - columnSpacing*2

            ////////////////////////////////

            Item { // pane 1
                width: gridContent.www
                height: singleColumn ? barcodeView.height : gridContent.hhh

                ////////

                Column {
                    id: barcodeView
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: Theme.componentMarginXL

                    Item {
                        id: qrcodearea

                        width: Math.min(gridContent.www, gridContent.hhh)
                        height: (barcode && barcode.isLinear) ? (width / 2) : width

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
                            anchors.margins: Theme.componentMargin

                            cache: false
                            smooth: false

                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit

                            source: {
                                if (settingsManager.backend_writer === "zint") return "image://ZintQml/encode/" + screenBarcodeDetails.barcode_string + screenBarcodeDetails.barcode_settings_zxingcpp
                                if (settingsManager.backend_writer === "zxingcpp") return "image://ZXingQt/encode/" + screenBarcodeDetails.barcode_string + screenBarcodeDetails.barcode_settings_zxingcpp
                                if (settingsManager.backend_writer === "qzxing") return "image://QZXing/encode/" + screenBarcodeDetails.barcode_string + screenBarcodeDetails.barcode_settings_qzxing
                                return ""
                            }
                        }

                        Rectangle {
                            id: errorarea
                            anchors.fill: parent

                            radius: Theme.componentRadius
                            color: Theme.colorWarning

                            opacity: (barcodeImage.status == Image.Error && barcode.data) ? 0.5 : 0
                            Behavior on opacity { NumberAnimation { duration: 233 } }

                            border.width: 2
                            border.color: Theme.colorError

                            IconSvg {
                                width: 80
                                height: 80
                                anchors.centerIn: parent
                                source: "qrc:/IconLibrary/material-symbols/media/broken_image.svg"
                                color: Theme.colorError
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
                                if (isMobile && screenBarcodeDetails.barcode_string) {
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
                                Behavior on opacity { NumberAnimation { duration: 333 } }
                                Behavior on width { NumberAnimation { duration: 333 } }
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

                    ////////

                    TextAreaThemed { // barcode content // single line
                        id: barcodedata
                        anchors.left: parent.left
                        anchors.right: parent.right

                        visible: barcode.isLinear
                        height: barcode.isLinear ? (contentHeight + padding*2) : 0

                        readOnly: true
                        selectByMouse: true

                        text: barcode.data
                        font.pixelSize: Theme.fontSizeContentBig
                        color: Theme.colorText
                    }

                    ////////
                }
            }

            ////////////////////////////////

            Item { // pane 2
                width: gridContent.www
                height: singleColumn ? barcodeDetails.height : gridContent.hhh

                Column {
                    id: barcodeDetails
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    height: singleColumn ? undefined : barcodeView.height

                    spacing: Theme.componentMarginXL

                    ////////

                    Rectangle { // barcode content // multiple lines
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: barcodecontent.contentHeight + Theme.componentMargin*2
                        radius: Theme.componentRadius

                        color: Theme.colorComponentBackground
                        border.width: 2
                        border.color: Theme.colorComponentBorder

                        visible: barcode.isMatrix

                        RowLayout {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.componentMargin
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            TextAreaThemed {
                                id: barcodecontent
                                Layout.fillWidth: true
                                Layout.maximumHeight: barcodeDetails.height

                                padding: 0
                                background: Item {}
                                readOnly: true
                                selectByMouse: true

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

                                color: mm.containsMouse ? Theme.colorPrimary : Theme.colorIcon
                                source: {
                                    if (barcode.content === "URL") return "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                                    if (barcode.content === "WiFi") return "qrc:/IconLibrary/material-symbols/wifi.svg"
                                    if (barcode.content === "Email") return "qrc:/IconLibrary/material-symbols/outline-mail_outline.svg"
                                    if (barcode.content === "Geolocation") return "qrc:/IconLibrary/material-icons/duotone/pin_drop.svg"
                                    if (barcode.content === "Phone") return "qrc:/IconLibrary/material-symbols/phone.svg"
                                    if (barcode.content === "SMS") return "qrc:/IconLibrary/material-icons/duotone/question_answer.svg"
                                    return ""
                                }

                                MouseArea {
                                    id: mm
                                    anchors.fill: parent

                                    hoverEnabled: isDesktop
                                    onClicked: {
                                        Qt.openUrlExternally(barcode.data)
                                    }
                                }
                            }
                        }
                    }

                    ////////

                    Row { // format
                        height: 20
                        spacing: 8

                        //visible: barcode.format

                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20

                            source: barcode.isMatrix ? "qrc:/IconLibrary/material-symbols/qr_code_2.svg" :
                                                       "qrc:/IconLibrary/material-symbols/barcode.svg"
                            color: Theme.colorIcon
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: barcode.format
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                        }
                    }

                    ////////

                    Row { // date
                        height: 20
                        spacing: 8

                        //visible: barcode.date

                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20

                            source: "qrc:/IconLibrary/material-icons/duotone/date_range.svg"
                            color: Theme.colorIcon
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: barcode.date.toLocaleString(Qt.locale(), "dddd d MMMM yyyy à hh:mm")
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                        }
                    }

                    ////////

                    Row { // location
                        height: 20
                        spacing: 8

                        visible: barcode.hasPosition

                        IconSvg {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20

                            source: "qrc:/IconLibrary/material-icons/duotone/pin_drop.svg"
                            color: Theme.colorIcon
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: barcode.latitude + "°N " + barcode.longitude + "°E"
                            font.pixelSize: Theme.fontSizeContent
                            color: Theme.colorSubText
                        }
                    }

                    ////////

                    RowLayout { // action icons
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 12

                        SquareButtonClear {
                            color: Theme.colorBlue
                            tooltipText: qsTr("Open")
                            source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"

                            onClicked: {
                                Qt.openUrlExternally(barcode.data)
                            }
                        }

                        SquareButtonClear {
                            visible: isMobile

                            color: Theme.colorGreen
                            tooltipText: qsTr("Share")
                            source: "qrc:/IconLibrary/material-symbols/share-fill.svg"

                            onClicked: {
                                utilsShare.sendText(barcode.data, "subject", "")
                            }
                        }

                        SquareButtonClear {
                            color: Theme.colorYellow
                            tooltipText: qsTr("Copy to clipboard")
                            source: "qrc:/IconLibrary/material-symbols/content_copy.svg"

                            onClicked: {
                                utilsClipboard.setText(barcode.data)
                            }
                        }

                        SquareButtonClear {
                            color: Theme.colorPrimary
                            visible: barcode.hasPosition

                            tooltipText: qsTr("See on map")
                            source: "qrc:/IconLibrary/material-icons/duotone/pin_drop.svg"

                            onClicked: {
                                Qt.openUrlExternally("https://www.openstreetmap.org/" +
                                                     "?mlat=" + barcode.latitude + "&mlon=" + barcode.longitude +
                                                     "#map=8/")
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        SquareButtonClear {
                            color: Theme.colorRed

                            tooltipText: qsTr("Delete entry")
                            source: "qrc:/IconLibrary/material-symbols/delete-fill.svg"

                            onClicked: {
                                popupHistoryDelete.open()
                            }
                        }
                    }

                    ////////
                }
            }

            ////////////////////////////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
