import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtMultimedia
import QZXing

import ThemeEngine

Loader {
    id: screenScanner
    anchors.fill: parent
    z: 24

    ////////////////////////////////////////////////////////////////////////////

    signal newBarCode(var barcode)

    property bool opened_barcode: false

    function loadScreen() {
        appContent.state = "ScreenScanner"
        screenScanner.open_barcode()

        if (screenScanner.status === Loader.Ready)
            screenScanner.item.open()
    }

    function backAction() {
        if (screenScanner.status === Loader.Ready)
            screenScanner.item.backAction()
    }

    function open_barcode() {
        console.log("screenScanner::open_barcode()")

        mobileUI.setScreenAlwaysOn(true)
        opened_barcode = true
        active = true
    }

    function hide() {
        console.log("screenScanner::hide()")

        mobileUI.setScreenAlwaysOn(false)
        opened_barcode = false

        if (screenScanner.status === Loader.Ready) {
            screenScanner.item.close()
        }
    }
    function close() {
        console.log("screenScanner::close()")

        mobileUI.setScreenAlwaysOn(false)
        opened_barcode = false

        if (screenScanner.status === Loader.Ready) {
            screenScanner.item.close()
            screenScanner.active = false
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 333 } }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    sourceComponent: Rectangle {
        anchors.fill: parent
        color: "black"

        Component.onCompleted: open()

        function open() {
            console.log(">> open()")

            camera.active = true
            if (isMobile) {
                //appWindow.showFullScreen()
                //mobileUI.refreshUI()
            }
        }
        function close() {
            console.log(">> close()")

            camera.active = false
            if (isMobile) {
                //appWindow.showNormal()
                //mobileUI.refreshUI()
            }
        }

        function backAction() {
            console.log(">> backAction()")

            // don't change screen
        }

        ////////////////////////

        IconSvg {
            width: 64; height: 64;
            anchors.centerIn: parent
            color: "#ccc"
            source: "qrc:/assets/icons_material/baseline-hourglass_empty-24px.svg"
        }

        ////////////////////////

        CaptureSession {
            id: captureSession

            camera: Camera {
                id: camera
                active: true
                focusMode: Camera.FocusModeAutoNear
            }

            videoOutput: videoOutput
        }

        ////////////////////////

        QZXingFilter {
            id: zxingFilter
            videoSink: videoOutput.videoSink

            captureRect: {
                videoOutput.contentRect
                videoOutput.sourceRect
                return Qt.rect(videoOutput.sourceRect.width * videoOutput.captureRectStartFactorX,
                               videoOutput.sourceRect.height * videoOutput.captureRectStartFactorY,
                               videoOutput.sourceRect.width * videoOutput.captureRectFactorWidth,
                               videoOutput.sourceRect.height * videoOutput.captureRectFactorHeight)
            }

            decoder {
                tryHarder: false

                enabledDecoders: QZXing.DecoderFormat_QR_CODE |
                                 QZXing.DecoderFormat_DATA_MATRIX |
                                 QZXing.DecoderFormat_UPC_E |
                                 QZXing.DecoderFormat_UPC_A |
                                 QZXing.DecoderFormat_UPC_EAN_EXTENSION |
                                 QZXing.DecoderFormat_RSS_14 |
                                 QZXing.DecoderFormat_RSS_EXPANDED |
                                 QZXing.DecoderFormat_PDF_417 |
                                 QZXing.DecoderFormat_MAXICODE |
                                 QZXing.DecoderFormat_EAN_8 |
                                 QZXing.DecoderFormat_EAN_13 |
                                 QZXing.DecoderFormat_CODE_128 |
                                 QZXing.DecoderFormat_CODE_93 |
                                 QZXing.DecoderFormat_CODE_39 |
                                 QZXing.DecoderFormat_CODABAR |
                                 QZXing.DecoderFormat_ITF |
                                 QZXing.DecoderFormat_Aztec

                onTagFound: (tag) => {
                    console.log(tag + " | " + decoder.foundedFormat() + " | " + decoder.charSet())

                    if (tag != tagText) {
                        utilsApp.vibrate(33)

                        zxingFilter.tagText = tag
                        zxingFilter.tagFormat = decoder.foundedFormat()
                        zxingFilter.tagEncoding = decoder.charSet()
                    }

                    //barcodeItem.visible = true
                    //barcodeTxt.text = tag + " | " + decoder.foundedFormat()
                    //if (decoder.charSet()) + " | " + decoder.charSet()
                }
            }

            property string tagText
            property string tagFormat
            property string tagEncoding

            property int framesDecoded: 0
            property real timePerFrameDecode: 0

            onDecodingStarted: {
                //console.log("onDecodingStarted()")
            }

            onDecodingFinished: (succeeded, decodeTime) => {
                //console.log("onDecodingFinished()")
                return

                timePerFrameDecode = (decodeTime + framesDecoded * timePerFrameDecode) / (framesDecoded + 1)
                framesDecoded++

                if (succeeded) {
                    console.log("frame finished: " + succeeded, decodeTime, timePerFrameDecode, framesDecoded)
                }
            }
        }

        ////////////////////////

        VideoOutput {
            id: videoOutput
            anchors.fill: parent

            // PreserveAspectFit / PreserveAspectCrop / Stretch
            fillMode: VideoOutput.PreserveAspectCrop

            property double captureRectStartFactorX: 0.1
            property double captureRectStartFactorY: 0.25
            property double captureRectFactorWidth: 0.9
            property double captureRectFactorHeight: 0.5

            Item {
                id: captureZone
                anchors.fill: parent

                ////////

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: gismo.top
                    color: "black"
                    opacity: 0.4
                }
                Rectangle {
                    anchors.top: gismo.top
                    anchors.left: parent.left
                    anchors.right: gismo.left
                    anchors.bottom: gismo.bottom
                    color: "black"
                    opacity: 0.4
                }
                Rectangle {
                    anchors.top: gismo.top
                    anchors.left: gismo.right
                    anchors.right: parent.right
                    anchors.bottom: gismo.bottom
                    color: "black"
                    opacity: 0.4
                }
                Rectangle {
                    anchors.top: gismo.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: "black"
                    opacity: 0.4
                }

                ////////

                Item {
                    id: gismo
                    x: parent.width * 0.05
                    y: parent.height * 0.33
                    width: parent.width * 0.9
                    height: parent.height * 0.33

                    property int gismowidth: screenScanner.width*0.9

                    // Borders
                    Item {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        width: 16; height: 16;

                        Rectangle { width: 16; height: 4; color: "white"; }
                        Rectangle { width: 4; height: 16; color: "white"; }
                    }
                    Item {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        width: 16; height: 16;

                        Rectangle { width: 16; height: 4; color: "white"; }
                        Rectangle { width: 4; height: 16; color: "white";
                                    anchors.right: parent.right; }
                    }
                    Item {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: 16; height: 16;

                        Rectangle { width: 16; height: 4; color: "white";
                            anchors.bottom: parent.bottom; }
                        Rectangle { width: 4; height: 16; color: "white";
                            anchors.bottom: parent.bottom; }
                    }
                    Item {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: 16; height: 16;

                        Rectangle { width: 16; height: 4; color: "white";
                                    anchors.bottom: parent.bottom; }
                        Rectangle { width: 4; height: 16; color: "white";
                                    anchors.bottom: parent.bottom; anchors.right: parent.right; }
                    }
/*
                    // Scanner (vertical)
                    Rectangle {
                        id: scanBar
                        width: parent.width + 0
                        height: 2
                        anchors.horizontalCenter: parent.horizontalCenter

                        color: "white"
                        opacity: 0.66

                        SequentialAnimation {
                            running: (screenScanner.opened_barcode)
                            loops: -1
                            NumberAnimation { target: scanBar; property: "y"; from: 0; to: gismo.height; duration: 750; }
                            NumberAnimation { target: scanBar; property: "y"; from: gismo.height; to: 0; duration: 750; }
                        }
                    }
*/
                    // Scanner (horizontal)
                    Rectangle {
                        id: scanBar
                        width: 2
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter

                        color: "white"
                        opacity: 0.66

                        SequentialAnimation {
                            running: (screenScanner.opened_barcode)
                            loops: -1
                            NumberAnimation { target: scanBar; property: "x"; from: 0; to: gismo.gismowidth; duration: 750; }
                            NumberAnimation { target: scanBar; property: "x"; from: gismo.gismowidth; to: 0; duration: 750; }
                        }
                    }
                }

                ////////

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMarginXL
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMarginXL
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.componentMarginXL + screenPaddingNavbar

                    width: parent.width
                    spacing: Theme.componentMarginXL

                    ////

                    Item { // barcode
                        id: barcodeItem
                        width: parent.width
                        height: 48

                        visible: zxingFilter.tagText

                        Rectangle {
                            anchors.fill: parent
                            radius: height
                            color: "black"
                            opacity: 0.33
                        }

                        IconSvg {
                            id: barcodeImg
                            width: parent.height * 0.666
                            height: parent.height * 0.666
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            source: {
                                if (zxingFilter.tagFormat === "QR_CODE" ||
                                    zxingFilter.tagFormat === "DATA_MATRIX" ||
                                    zxingFilter.tagFormat === "Aztec") {
                                    return "qrc:/assets/icons_material/baseline-qr_code_2-24px.svg"
                                }

                                return "qrc:/assets/icons_bootstrap/upc.svg"
                            }
                        }

                        Text {
                            id: barcodeTxt
                            anchors.left: barcodeImg.right
                            anchors.leftMargin: Theme.componentMargin
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: zxingFilter.tagText
                            color: "white"
                            font.pixelSize: Theme.fontSizeContent
                            elide: Text.ElideRight
                            //wrapMode: Text.WordWrap
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: zxingFilter.tagFormat
                            color: "white"
                            opacity: 0.66
                            font.pixelSize: Theme.fontSizeContentSmall
                            elide: Text.ElideRight
                            //wrapMode: Text.WordWrap
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Qt.openUrlExternally(zxingFilter.tagText)
                            }
                        }
                    }

                    ////

                    RowLayout { // buttons bar
                        visible: !exitTimer.running

                        width: parent.width
                        height: 48
                        spacing: Theme.componentMarginXL

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48

                            Rectangle {
                                anchors.fill: parent
                                radius: height
                                color: "black"
                                opacity: 0.33
                            }

                            IconSvg {
                                id: scanImg
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter

                                width: parent.height * 0.666
                                height: parent.height * 0.666
                                color: "white"
                                source: "qrc:/assets/icons_material/baseline-search-24px.svg"

                                SequentialAnimation {
                                    running: (screenScanner.opened_barcode)
                                    loops: -1
                                    NumberAnimation { target: scanImg; property: "opacity"; from: 0.33; to: 1; duration: 500; }
                                    NumberAnimation { target: scanImg; property: "opacity"; from: 1; to: 0.33; duration: 500; }
                                }
                            }
                            Text {
                                anchors.left: scanImg.right
                                anchors.leftMargin: Theme.componentMargin
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Scanning...")
                                color: "white"
                                font.pixelSize: Theme.fontSizeContentBig
                            }
                        }

                        Item {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48

                            visible: isMobile

                            Rectangle {
                                anchors.fill: parent
                                radius: height
                                color: "black"
                                opacity: 0.33
                            }

                            IconSvg {
                                width: parent.height * 0.5
                                height: parent.height * 0.5
                                anchors.centerIn: parent
                                color: "white"
                                source: {
                                    if (camera.torchMode !== Camera.TorchOn)
                                        return "qrc:/assets/icons_material/baseline-flash_off-24px.svg"
                                    else
                                        return "qrc:/assets/icons_material/baseline-flash_on-24px.svg"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (camera.torchMode !== Camera.TorchOn)
                                        camera.torchMode = Camera.TorchOn
                                    else
                                        camera.torchMode = Camera.TorchOff
                                }
                            }
                        }

                        Item {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48

                            Rectangle {
                                anchors.fill: parent
                                radius: height
                                color: "black"
                                opacity: 0.33
                            }

                            IconSvg {
                                width: parent.height * 0.666
                                height: parent.height * 0.666
                                anchors.centerIn: parent
                                color: "white"
                                source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: appDrawer.open()
                            }
                        }
                    }

                    ////

                    Item { // exit warning
                        width: parent.width
                        height: 48

                        visible: exitTimer.running
                        opacity: exitTimer.running ? 1 : 0
                        Behavior on opacity { OpacityAnimator { duration: 333 } }

                        Rectangle {
                            anchors.fill: parent
                            radius: height
                            color: "black"
                            opacity: 0.33
                        }

                        Text {
                            anchors.centerIn: parent

                            text: qsTr("Press one more time to exit...")
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                            color: "white"
                        }
                    }

                    ////
                }

                ////////

                Rectangle { // statusbar area
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    height: screenPaddingStatusbar
                    color: "black"
                    opacity: 0.33
                    visible: true
                }

                Rectangle { // navbar area
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: screenPaddingNavbar
                    color: "black"
                    opacity: 0.33
                    visible: true
                }

                ////////
            }
        }

        ////////////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
