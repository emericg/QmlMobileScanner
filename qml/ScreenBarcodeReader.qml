import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls

import QtMultimedia

import ThemeEngine

Loader {
    id: screenBarcodeReader
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        appContent.state = "ScreenBarcodeReader"
        screenBarcodeReader.open_barcode()

        if (screenBarcodeReader.status === Loader.Ready)
            screenBarcodeReader.item.open()
    }

    function backAction() {
        if (screenBarcodeReader.status === Loader.Ready)
            screenBarcodeReader.item.backAction()
    }

    function open_barcode() {
        console.log("screenBarcodeReader::open_barcode()")

        mobileUI.setScreenAlwaysOn(true)
        active = true
    }

    function hide() {
        console.log("screenBarcodeReader::hide()")

        mobileUI.setScreenAlwaysOn(false)

        if (screenBarcodeReader.status === Loader.Ready) {
            screenBarcodeReader.item.close()
        }
    }
    function close() {
        console.log("screenBarcodeReader::close()")

        mobileUI.setScreenAlwaysOn(false)

        if (screenBarcodeReader.status === Loader.Ready) {
            screenBarcodeReader.item.close()
            screenBarcodeReader.active = false // crash ?!
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    active: false
    asynchronous: true

    sourceComponent: Rectangle {
        anchors.fill: parent
        color: "black"

        opacity: camera.active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 233 } }

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

            //camera.active = false // crash !!

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

            property int selectedDevice: 0
        }

        CaptureSession {
            id: captureSession

            videoOutput: videoOutput

            camera: Camera {
                id: camera
                active: true
                focusMode: Camera.FocusModeAutoNear

                cameraDevice: mediaDevices.videoInputs[mediaDevices.selectedDevice] ? mediaDevices.videoInputs[mediaDevices.selectedDevice] : mediaDevices.defaultVideoInput
                onErrorOccurred: console.log("CaptureSession::Camera ERROR " + errorString)
            }
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

            orientation: 0

            // Stretch / PreserveAspectFit / PreserveAspectCrop
            fillMode: VideoOutput.PreserveAspectCrop

            // Capture rectangle
            property double captureRectStartFactorX: 0.05
            property double captureRectStartFactorY: 0.25
            property double captureRectFactorWidth: 0.9
            property double captureRectFactorHeight: 0.5

            ////

            function printInfos() {
                console.log("> Camera > " + mediaDevices.selectedDevice.description)
                console.log("- videoOutput sz: " + videoOutput.x + "," + videoOutput.y + " - " + videoOutput.width + "x" + videoOutput.height)
                console.log("- sourceRect  sz: " + videoOutput.sourceRect.x.toFixed() + "," + videoOutput.sourceRect.y + " - " + videoOutput.sourceRect.width + "x" + videoOutput.sourceRect.height)
                console.log("- contentRect sz: " + videoOutput.contentRect.x.toFixed() + "," + videoOutput.contentRect.y.toFixed() + " - " +
                                                   videoOutput.contentRect.width.toFixed() + "x" + videoOutput.contentRect.height.toFixed())
                console.log("- captureRect sz: " + barcodeReader.captureRect.x.toFixed() + "," + barcodeReader.captureRect.y.toFixed() + " - " +
                                                   barcodeReader.captureRect.width.toFixed() + "x" + barcodeReader.captureRect.height.toFixed())
            }

            ////

            Repeater {
                model: barcodeManager.barcodes

                Shape {
                    anchors.fill: parent

                    antialiasing: true
                    opacity: modelData.lastVisible ? 0.80 : 0
                    Behavior on opacity { NumberAnimation { duration: 133 } }

                    ShapePath {
                        strokeWidth: 4
                        strokeColor: {
                            if (index === 0) return Theme.colorGreen
                            if (index === 1) return Theme.colorBlue
                            if (index === 2) return Theme.colorOrange
                            if (index === 3) return Theme.colorRed
                        }
                        strokeStyle: ShapePath.SolidLine
                        fillColor: "transparent"

                        startX: modelData.lastCoordinates[3].x
                        startY: modelData.lastCoordinates[3].y
                        PathLine { x: modelData.lastCoordinates[0].x; y: modelData.lastCoordinates[0].y; }
                        PathLine { x: modelData.lastCoordinates[1].x; y: modelData.lastCoordinates[1].y; }
                        PathLine { x: modelData.lastCoordinates[2].x; y: modelData.lastCoordinates[2].y; }
                        PathLine { x: modelData.lastCoordinates[3].x; y: modelData.lastCoordinates[3].y; }
                    }
                }
            }

            ////

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: "black"
                opacity: 0.4
                visible: !captureZone.visible
            }
            Item {
                id: captureZone
                anchors.fill: parent

                visible: !(menuDebug.visible || menuFormats.visible ||
                           menuCamera.visible || menuScreens.visible || appDrawer.visible)

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
                    x: parent.width * videoOutput.captureRectStartFactorX
                    y: parent.height * videoOutput.captureRectStartFactorY
                    width: parent.width * videoOutput.captureRectFactorWidth
                    height: parent.height * videoOutput.captureRectFactorHeight

                    property int gismowidth: screenBarcodeReader.width*videoOutput.captureRectFactorWidth

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

                    // Scanner (horizontal)
                    Rectangle {
                        id: scanBar
                        width: 2
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter

                        color: "white"
                        opacity: 0.66

                        SequentialAnimation {
                            running: visible
                            loops: -1
                            NumberAnimation { target: scanBar; property: "x"; from: 0; to: gismo.gismowidth; duration: 750; }
                            NumberAnimation { target: scanBar; property: "x"; from: gismo.gismowidth; to: 0; duration: 750; }
                        }
                    }
                }

                ////////
            }

            ////
        }

        ////////////////////////

        Item {
            id: overlays
            anchors.fill: parent

            ////////

            Item { // debug infos
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

            MouseArea {
                anchors.fill: parent
                enabled: menuDebug.visible || menuFormats.visible || menuCamera.visible || menuScreens.visible
                onClicked: {
                    menuDebug.visible = false
                    menuFormats.visible = false
                    menuCamera.visible = false
                    menuScreens.visible = false
                }
            }
            Row { // top/right menu
                id: toprightmenu
                anchors.top: parent.top
                anchors.topMargin: Theme.componentMargin + Math.max(screenPaddingStatusbar, screenPaddingTop)
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                height: 48

                spacing: Theme.componentMarginXL

                ////

                Item { // debug settings
                    id: debugItm
                    width: 48
                    height: 48

                    visible: settingsManager.showDebug

                    Rectangle {
                        anchors.fill: parent
                        radius: height
                        color: "black"
                        opacity: 0.33
                    }

                    IconSvg {
                        width: parent.height * 0.6
                        height: parent.height * 0.6
                        anchors.centerIn: parent
                        color: menuDebug.visible ? Theme.colorYellow : "white"
                        source: "qrc:/assets/icons_material/duotone-bug_report-24px.svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            menuDebug.visible = !menuDebug.visible
                            menuFormats.visible = false
                            menuCamera.visible = false
                            menuScreens.visible = false
                        }
                    }
                }

                ////

                Item { // format selector
                    id: formatItm
                    width: 48
                    height: 48

                    Rectangle {
                        anchors.fill: parent
                        radius: height
                        color: "black"
                        opacity: 0.33
                    }

                    IconSvg {
                        width: parent.height * 0.6
                        height: parent.height * 0.6
                        anchors.centerIn: parent
                        color: menuFormats.visible ? Theme.colorYellow : "white"
                        source: "qrc:/assets/icons_material/baseline-qr_code-24px.svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            menuDebug.visible = false
                            menuFormats.visible = !menuFormats.visible
                            menuCamera.visible = false
                            menuScreens.visible = false
                        }
                    }
                }

                ////

                Item { // camera selector
                    id: cameraItm
                    width: 48
                    height: 48

                    visible: (mediaDevices.videoInputs.length > 1)

                    Rectangle {
                        anchors.fill: parent
                        radius: height
                        color: "black"
                        opacity: 0.33
                    }

                    IconSvg {
                        width: parent.height * 0.66
                        height: parent.height * 0.66
                        anchors.centerIn: parent
                        color: menuCamera.visible ? Theme.colorYellow : "white"
                        source: "qrc:/assets/icons_material/duotone-cameraswitch-24px.svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            menuDebug.visible = false
                            menuFormats.visible = false
                            menuCamera.visible = !menuCamera.visible
                            menuScreens.visible = false
                        }
                    }
                }

                ////
            }

            MenuDebug {
                id: menuDebug
            }
            MenuFormats {
                id: menuFormats
            }
            MenuCamera {
                id: menuCamera
            }

            MenuScreens {
                id: menuScreens
            }

            ////////

            Column { // bottom menu
                id: bottomemnu
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginXL
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginXL
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.componentMarginXL + Math.max(screenPaddingBottom, screenPaddingNavbar)

                width: parent.width
                spacing: Theme.componentMarginXL

                ////

                Repeater { // barcode(s)
                    model: barcodeManager.barcodes

                    Item {
                        width: parent.width
                        height: 48

                        visible: modelData.lastVisible

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
                            source: modelData.isMatrix ? "qrc:/assets/icons_material/baseline-qr_code_2-24px.svg" :
                                                         "qrc:/assets/icons_bootstrap/upc.svg"
                        }

                        Text {
                            id: barcodeTxt
                            anchors.left: barcodeImg.right
                            anchors.leftMargin: Theme.componentMargin
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: modelData.data
                            color: "white"
                            font.pixelSize: Theme.fontSizeContent
                            elide: Text.ElideRight
                            //wrapMode: Text.WordWrap
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: modelData.format
                            color: "white"
                            opacity: 0.66
                            font.pixelSize: Theme.fontSizeContentSmall
                            elide: Text.ElideRight
                            //wrapMode: Text.WordWrap
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Qt.openUrlExternally(modelData.data)
                            }
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
                            color: (appDrawer.opened || menuScreens.visible) ? Theme.colorYellow : "white"
                            source: "qrc:/assets/icons_material/baseline-menu-24px.svg"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (isPhone) {
                                    appDrawer.open()
                                } else {
                                    menuDebug.visible = false
                                    menuFormats.visible = false
                                    menuCamera.visible = false
                                    menuScreens.visible = !menuScreens.visible
                                }
                            }
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

        ////////////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
