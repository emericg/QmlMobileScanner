import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls

import QtMultimedia

import ThemeEngine

Loader {
    id: screenBarcodeReader
    anchors.fill: parent
    z: 24

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
            //screenBarcodeReader.active = false // crash ?!
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

            camera: Camera {
                id: camera
                active: true
                focusMode: Camera.FocusModeAutoNear

                cameraDevice: mediaDevices.videoInputs[mediaDevices.selectedDevice] ? mediaDevices.videoInputs[mediaDevices.selectedDevice] : mediaDevices.defaultVideoInput
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

                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 133 } }

                Timer {
                    id: barcodeVisibleTimer
                    interval: 2500
                    onRunningChanged: {
                        if (running && barcodeReader && barcodeReader.points.length === 4) {
                            parent.opacity = 0.66
                        }
                    }
                    onTriggered: parent.opacity = 0
                }

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

                visible: (!debugCol.visible && !formatCol.visible && !cameraCol.visible && !appDrawer.visible)

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
                        color: debugCol.visible ? Theme.colorYellow : "white"
                        source: "qrc:/assets/icons_material/duotone-bug_report-24px.svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            debugCol.visible = !debugCol.visible
                            formatCol.visible = false
                            cameraCol.visible = false
                        }
                    }
                }

                ////

                Item { // format selector
                    id: formatItm
                    width: 48
                    height: 48

                    visible: (settingsManager.backend === "zxingcpp")

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
                        color: formatCol.visible ? Theme.colorYellow : "white"
                        source: "qrc:/assets/icons_material/baseline-qr_code-24px.svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            debugCol.visible = false
                            formatCol.visible = !formatCol.visible
                            cameraCol.visible = false
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
                        color: cameraCol.visible ? Theme.colorYellow : "white"
                        source: "qrc:/assets/icons_material/duotone-cameraswitch-24px.svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            debugCol.visible = false
                            formatCol.visible = false
                            cameraCol.visible = !cameraCol.visible
                        }
                    }
                }

                ////
            }

            Column { // top/right menu content
                id: debugCol
                anchors.top: toprightmenu.bottom
                anchors.topMargin: Theme.componentMargin
                anchors.right: toprightmenu.right

                width: singleColumn ? screenBarcodeReader.width - Theme.componentMargin*2 : 300
                spacing: Theme.componentMargin / 2
                visible: false

                Item {
                    width: parent.width
                    height: 40

                    Rectangle {
                        anchors.fill: parent
                        radius: 24
                        color: "black"
                        opacity: 0.33
                    }

                    SwitchThemed {
                        anchors.centerIn: parent
                        width: parent.width - 16
                        LayoutMirroring.enabled: true

                        text: qsTr("tryHarder")
                        colorText: "white"
                        checked: settingsManager.scan_tryHarder
                        onClicked: settingsManager.scan_tryHarder = checked
                    }
                }
                Item {
                    width: parent.width
                    height: 40

                    Rectangle {
                        anchors.fill: parent
                        radius: 24
                        color: "black"
                        opacity: 0.33
                    }

                    SwitchThemed {
                        anchors.centerIn: parent
                        width: parent.width - 16
                        LayoutMirroring.enabled: true

                        text: qsTr("tryRotate")
                        colorText: "white"
                        checked: settingsManager.scan_tryRotate
                        onClicked: settingsManager.scan_tryRotate = checked
                    }
                }
                Item {
                    width: parent.width
                    height: 40

                    Rectangle {
                        anchors.fill: parent
                        radius: 24
                        color: "black"
                        opacity: 0.33
                    }

                    SwitchThemed {
                        anchors.centerIn: parent
                        width: parent.width - 16
                        LayoutMirroring.enabled: true

                        text: qsTr("tryDownscale")
                        colorText: "white"
                        visible: (settingsManager.backend === "zxingcpp")
                        checked: settingsManager.scan_tryDownscale
                        onClicked: settingsManager.scan_tryDownscale = checked
                    }
                }
            }
            Column { // top/right menu content
                id: formatCol
                anchors.top: toprightmenu.bottom
                anchors.topMargin: Theme.componentMargin
                anchors.right: toprightmenu.right

                width: singleColumn ? screenBarcodeReader.width - Theme.componentMargin*2 : 300
                spacing: Theme.componentMargin /2
                visible: false

                Repeater {
                    model: ListModel {
                        id: formatsAvailable
                        ListElement { text: "Linear codes"; value: 51070; }
                        ListElement { text: "Aztec"; value: 1; }
                        ListElement { text: "DataMatrix"; value: 128; }
                        ListElement { text: "MaxiCode"; value: 2048; }
                        ListElement { text: "PDF417"; value: 4096; }
                        ListElement { text: "QRCode"; value: 8192; }
                        ListElement { text: "MicroQRCode"; value: 65536; }
                    }

                    Item {
                        width: parent.width
                        height: 40

                        required property var modelData

                        Rectangle {
                            anchors.fill: parent
                            radius: 24
                            color: "black"
                            opacity: 0.33
                        }

                        SwitchThemed {
                            anchors.centerIn: parent
                            width: parent.width - 16
                            LayoutMirroring.enabled: true

                            text: modelData.text
                            colorText: "white"
                            checked: (settingsManager.formatsEnabled & modelData.value)
                            onClicked: {
                                if (settingsManager.formatsEnabled & modelData.value)
                                    settingsManager.formatsEnabled -= modelData.value
                                else
                                    settingsManager.formatsEnabled += modelData.value
                            }
                        }
                    }
                }
            }
            Column { // top/right menu content
                id: cameraCol
                anchors.top: toprightmenu.bottom
                anchors.topMargin: Theme.componentMargin
                anchors.right: toprightmenu.right

                width: singleColumn ? screenBarcodeReader.width - Theme.componentMargin*2 : 320
                spacing: Theme.componentMargin
                visible: false

                Repeater {
                    model: mediaDevices.videoInputs

                    Item {
                        width: parent.width
                        height: 40

                        Rectangle {
                            anchors.fill: parent
                            radius: 24
                            color: "black"
                            opacity: 0.33
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter

                            text: modelData.description
                            font.pixelSize: Theme.componentFontSize
                            color: "white"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                mediaDevices.selectedDevice = index
                                cameraCol.visible = false
                            }
                        }

                        IconSvg {
                            width: parent.height * 0.5
                            height: parent.height * 0.5
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.componentMargin
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            source: {
                                if (index === mediaDevices.selectedDevice) return  "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                                if (modelData.isDefault) return  "qrc:/assets/icons_material/baseline-stars-24px.svg"
                                return ""
                            }
                        }
                    }
                }
            }

            ////////

            Column { // bottom menu
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

        ////////////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
