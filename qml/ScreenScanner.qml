import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls

import QtMultimedia

import ThemeEngine

Loader {
    id: screenScanner
    anchors.fill: parent
    z: 24

    ////////////////////////////////////////////////////////////////////////////

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
        active = true
    }

    function hide() {
        console.log("screenScanner::hide()")

        mobileUI.setScreenAlwaysOn(false)

        if (screenScanner.status === Loader.Ready) {
            screenScanner.item.close()
        }
    }
    function close() {
        console.log("screenScanner::close()")

        mobileUI.setScreenAlwaysOn(false)

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
            //console.log(">> open()")

            camera.active = true
            if (isMobile) {
                //appWindow.showFullScreen()
                //mobileUI.refreshUI()
            }
        }
        function close() {
            //console.log(">> close()")

            //camera.active = false // crash ?!

            if (isMobile) {
                //appWindow.showNormal()
                //mobileUI.refreshUI()
            }
        }

        function backAction() {
            //console.log(">> backAction()")

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

        MediaDevices {
            id: mediaDevices
        }

        CaptureSession {
            id: captureSession

            camera: Camera {
                id: camera
                active: true
                focusMode: Camera.FocusModeAutoNear

                //cameraDevice: mediaDevices.videoInputs[0] ? mediaDevices.videoInputs[0] : mediaDevices.defaultVideoInput
                onErrorOccurred: console.log("camera error:" + errorString)
            }

            videoOutput: videoOutput
        }

        ////////////////////////

        Loader {
            id: backendLoader
            active: true
            asynchronous: true

            source: (settingsManager.backend === "qzxing") ? "Reader_QZXing.qml" : "Reader_ZXingCpp.qml"
        }
        property alias barcodeReader: backendLoader.item

        ////////////////////////

        VideoOutput {
            id: videoOutput
            anchors.fill: parent

            // PreserveAspectFit / PreserveAspectCrop / Stretch
            fillMode: VideoOutput.PreserveAspectCrop

            // Capture rectangle
            property double captureRectStartFactorX: 0.05
            property double captureRectStartFactorY: 0.25
            property double captureRectFactorWidth: 0.9
            property double captureRectFactorHeight: 0.5

            ////
            Shape {
                anchors.fill: parent
                visible: (barcodeReader && barcodeReader.points.length === 4)
                opacity: 0.66

                ShapePath {
                    strokeWidth: 4
                    strokeColor: Theme.colorOrange
                    strokeStyle: ShapePath.SolidLine
                    fillColor: "transparent"

                    startX: barcodeReader.points[3].x
                    startY: barcodeReader.points[3].y
                    PathLine { x: barcodeReader.points[0].x; y: barcodeReader.points[0].y; }
                    PathLine { x: barcodeReader.points[1].x; y: barcodeReader.points[1].y; }
                    PathLine { x: barcodeReader.points[2].x; y: barcodeReader.points[2].y; }
                    PathLine { x: barcodeReader.points[3].x; y: barcodeReader.points[3].y; }
                }
            }
            ////

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

                Item { // debug panel
                    anchors.top: parent.top
                    anchors.topMargin: Theme.componentMargin + Math.max(screenPaddingTop, screenPaddingStatusbar)
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    visible: settingsManager.showDebug

                    Column {
                        anchors.top: parent.top
                        anchors.left: parent.left

                        SwitchThemed {
                            text: qsTr("tryHarder")
                            checked: settingsManager.scan_tryHarder
                            onClicked: settingsManager.scan_tryHarder = checked
                        }
                        SwitchThemed {
                            text: qsTr("tryRotate")
                            checked: settingsManager.scan_tryRotate
                            onClicked: settingsManager.scan_tryRotate = checked
                        }
                        SwitchThemed {
                            text: qsTr("tryDownscale")
                            visible: (settingsManager.backend === "zxingcpp")
                            checked: settingsManager.scan_tryDownscale
                            onClicked: settingsManager.scan_tryDownscale = checked
                        }
                    }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right

                        Text {
                            id: fpsCounter
                            text: utilsFpsMonitor.fps.toFixed(0) + " fps"
                            color: "white"
                        }
                        Text {
                            id: msPerFrame
                            text: barcodeReader.timePerFrameDecode.toFixed(0) + " ms"
                            color: "white"
                        }
                    }
                }

                ////////

                Item {
                    id: gismo
                    x: parent.width * videoOutput.captureRectStartFactorX
                    y: parent.height * videoOutput.captureRectStartFactorY
                    width: parent.width * videoOutput.captureRectFactorWidth
                    height: parent.height * videoOutput.captureRectFactorHeight

                    property int gismowidth: screenScanner.width*videoOutput.captureRectFactorWidth

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
                            running: true
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
                            running: true
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
                    anchors.bottomMargin: Theme.componentMarginXL + Math.max(screenPaddingBottom, screenPaddingNavbar)

                    width: parent.width
                    spacing: Theme.componentMarginXL

                    ////

                    Item { // barcode
                        id: barcodeItem
                        width: parent.width
                        height: 48

                        visible: barcodeReader && barcodeReader.tagText

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
                                if (barcodeReader) {
                                    if (barcodeReader.tagFormat === "QR_CODE" || barcodeReader.tagFormat === "QRCode" ||
                                        barcodeReader.tagFormat === "DATA_MATRIX" || barcodeReader.tagFormat === "DataMatrix" ||
                                        barcodeReader.tagFormat === "Aztec" ||
                                        barcodeReader.tagFormat === "MicroQRCode" ||
                                        barcodeReader.tagFormat === "PDF417" ||
                                        barcodeReader.tagFormat === "MaxiCode") {
                                        return "qrc:/assets/icons_material/baseline-qr_code_2-24px.svg"
                                    }
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

                            text: barcodeReader && barcodeReader.tagText
                            color: "white"
                            font.pixelSize: Theme.fontSizeContent
                            elide: Text.ElideRight
                            //wrapMode: Text.WordWrap
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: barcodeReader && barcodeReader.tagFormat
                            color: "white"
                            opacity: 0.66
                            font.pixelSize: Theme.fontSizeContentSmall
                            elide: Text.ElideRight
                            //wrapMode: Text.WordWrap
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Qt.openUrlExternally(barcodeReader.tagText)
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
                                    running: true
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
