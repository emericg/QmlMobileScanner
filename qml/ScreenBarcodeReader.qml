import QtCore
import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

import QtMultimedia
import ThemeEngine

Loader {
    id: screenBarcodeReader
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        appContent.state = "ScreenBarcodeReader"

        mobileUI.setScreenAlwaysOn(true)
        screenBarcodeReader.active = true

        if (screenBarcodeReader.status === Loader.Ready)
            screenBarcodeReader.item.open()
    }

    function backAction() {
        if (screenBarcodeReader.status === Loader.Ready)
            screenBarcodeReader.item.backAction()
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
            //if (isMobile) screenBarcodeReader.active = false // crash !?!
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Rectangle {
        anchors.fill: parent
        color: "black"

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 233 } }

        property string currentMode: "video"

        Component.onCompleted: open()

        function open() {
            //console.log(">> open()")

            opacity = 1

            if (currentMode === "video") open_video()
            else if (currentMode === "image") open_image()

            if (isMobile) {
                //appWindow.showFullScreen()
                //mobileUI.refreshUI()
            }
        }
        function open_video() {
            console.log(">> open_video()")
            currentMode = "video"

            camera.active = true
            videoOutput.visible = true
            imageOutput.visible = false
        }
        function open_image(file) {
            console.log(">> open_image()")
            currentMode = "image"

            if (file) imageOutput.source = file
            videoOutput.visible = false
            imageOutput.visible = true
        }
        function close() {
            //console.log(">> close()")

            camera.active = false // crash !?!

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

                active: false
                focusMode: Camera.FocusModeAutoNear

                cameraDevice: mediaDevices.videoInputs[mediaDevices.selectedDevice] ? mediaDevices.videoInputs[mediaDevices.selectedDevice] : mediaDevices.defaultVideoInput
                //cameraFormat: utilsCamera.selectCameraFormat(mediaDevices.selectedDevice)

                onCameraDeviceChanged: {
                    console.log("CaptureSession::onCameraDeviceChanged()")
                    //cameraFormat = utilsCamera.selectCameraFormat(mediaDevices.selectedDevice)
                }
                onErrorOccurred: (errorString) => {
                    console.log("CaptureSession::onErrorOccurred() " + errorString)
                }
            }
        }

        ////////////////////////

        Loader {
            id: backendLoader
            active: true
            asynchronous: true
            source: (settingsManager.backend_reader === "zxingcpp") ? "Reader_ZXingCpp.qml" : "Reader_QZXing.qml"
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
                console.log("- sourceRect  sz: " + videoOutput.sourceRect.x.toFixed() + "," + videoOutput.sourceRect.y + " - " +
                                                   videoOutput.sourceRect.width + "x" + videoOutput.sourceRect.height)
                console.log("- contentRect sz: " + videoOutput.contentRect.x.toFixed() + "," + videoOutput.contentRect.y.toFixed() + " - " +
                                                   videoOutput.contentRect.width.toFixed() + "x" + videoOutput.contentRect.height.toFixed())
                console.log("- captureRect sz: " + barcodeReader.captureRect.x.toFixed() + "," + barcodeReader.captureRect.y.toFixed() + " - " +
                                                   barcodeReader.captureRect.width.toFixed() + "x" + barcodeReader.captureRect.height.toFixed())
            }

            ////

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: "black"
                opacity: 0.4
                visible: !settingsManager.scan_fullscreen && !captureZone.visible
            }
            Item {
                id: captureZone
                anchors.fill: parent

                visible: !settingsManager.scan_fullscreen &&
                         !(appDrawer.visible ||
                           imageOutput.visible ||
                           menuDebug.visible || menuFormats.visible ||
                           menuCamera.visible || menuScreens.visible)

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

                    property int gismowidth: screenBarcodeReader.width * videoOutput.captureRectFactorWidth

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

                Repeater {
                    model: barcodeManager.barcodes

                    Shape {
                        anchors.fill: parent

                        antialiasing: true
                        opacity: modelData.isOnScreen ? 0.80 : 0
                        Behavior on opacity { NumberAnimation { duration: 133 } }

                        ShapePath {
                            strokeWidth: 4
                            strokeColor: modelData.color
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

                ////////
            }

            ////
        }

        ////////////////////////

        Image {
            id: imageOutput
            anchors.centerIn: parent

            visible: false
            source: ""

            // Stretch / PreserveAspectFit / PreserveAspectCrop
            fillMode: VideoOutput.PreserveAspectFit

            ////

            function printInfos() {
                console.log("> Image > " + imageOutput.source)
                console.log("- image sz: " + imageOutput.x + "," + imageOutput.y + " - " + imageOutput.width + "x" + imageOutput.height)
                console.log("- sourceSize  sz: " + imageOutput.sourceSize.x + "," + imageOutput.sourceSize.y + " - " +
                                                   imageOutput.sourceSize.width + "x" + imageOutput.sourceSize.height)
                console.log("- sourceClipRect sz: " + imageOutput.sourceClipRect.x + "," + imageOutput.sourceClipRect.y + " - " +
                                                      imageOutput.sourceClipRect.width + "x" + imageOutput.sourceClipRect.height)
            }

            ////

            Repeater {
                model: barcodeManager.barcodes

                Shape {
                    anchors.fill: parent

                    antialiasing: true
                    opacity: modelData.isOnScreen ? 0.80 : 0
                    Behavior on opacity { NumberAnimation { duration: 133 } }

                    ShapePath {
                        strokeWidth: 4
                        strokeColor: modelData.color
                        strokeStyle: ShapePath.SolidLine
                        fillColor: "transparent"

                        startX: modelData.lastCoordinates[3].x * imageOutput.sourceSize.width
                        startY: modelData.lastCoordinates[3].y * imageOutput.sourceSize.height
                        PathLine { x: modelData.lastCoordinates[0].x* imageOutput.sourceSize.width; y: modelData.lastCoordinates[0].y* imageOutput.sourceSize.height; }
                        PathLine { x: modelData.lastCoordinates[1].x* imageOutput.sourceSize.width; y: modelData.lastCoordinates[1].y* imageOutput.sourceSize.height; }
                        PathLine { x: modelData.lastCoordinates[2].x* imageOutput.sourceSize.width; y: modelData.lastCoordinates[2].y* imageOutput.sourceSize.height; }
                        PathLine { x: modelData.lastCoordinates[3].x* imageOutput.sourceSize.width; y: modelData.lastCoordinates[3].y* imageOutput.sourceSize.height; }
                    }
                }
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
                        visible: (currentMode === "video")
                        text: barcodeReader && barcodeReader.timePerFrameDecode.toFixed(0) + " ms"
                        color: "white"
                    }
                }
            }

            ////////

            MouseArea {
                anchors.fill: parent
                enabled: (menuDebug.visible || menuFormats.visible || menuCamera.visible || menuScreens.visible)
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

                Item { // drag and drop
                    id: dndItm
                    width: 48
                    height: 48

                    visible: isDesktop

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
                        color: fileOpenDialog.visible ? Theme.colorYellow : "white"
                        source: "qrc:/assets/icons_material/duotone-photo_library-24px.svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            menuDebug.visible = false
                            menuFormats.visible = false
                            menuCamera.visible = false
                            menuScreens.visible = false

                            if (fileOpenDialog.visible) fileOpenDialog.close()
                            else fileOpenDialog.open()
                        }
                    }

                    FileDialog {
                        id: fileOpenDialog

                        fileMode: FileDialog.OpenFile
                        nameFilters: ["Picture files (*.png *.bmp *.jpg *.jpeg *.webp)",
                                      "PNG files (*.png)", "BMP files (*.bmp)", "JPEG files (*.jpg *.jpeg)", "WebP files (*.webp)"]
                        currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

                        onAccepted: {
                            //console.log("fileOpenDialog: " + currentFile)

                            if (barcodeManager.loadImage(currentFile))
                            {
                                open_image(currentFile)
                            }
                        }
                    }
                }

                ////

                Item { // back to camera
                    id: camItm
                    width: 48
                    height: 48

                    visible: (currentMode === "image")

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
                        color: "white"
                        source: "qrc:/assets/icons_material/duotone-camera-24px.svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            menuDebug.visible = false
                            menuFormats.visible = false
                            menuCamera.visible = false
                            menuScreens.visible = false
                            fileOpenDialog.close()
                            open_video()
                        }
                    }
                }

                ////

                Item { // debug settings
                    id: debugItm
                    width: 48
                    height: 48

                    visible: (currentMode === "video" && settingsManager.showDebug)

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
                            fileOpenDialog.close()
                            menuDebug.visible = !menuDebug.visible
                            menuFormats.visible = false
                            menuCamera.visible = false
                            menuScreens.visible = false
                        }
                    }
                }

                ////

                Item { // debug format selector
                    id: formatItm
                    width: 48
                    height: 48

                    visible: (currentMode === "video" && settingsManager.showDebug)

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
                            fileOpenDialog.close()
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

                    visible: (currentMode === "video" && mediaDevices.videoInputs.length > 1)

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
                            fileOpenDialog.close()
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
                spacing: Theme.componentMargin

                ////

                Repeater { // barcode(s)
                    model: barcodeManager.barcodes

                    WidgetBarcodeResult {
                        width: parent.width
                        barcode: modelData
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
                            color: (camera.torchMode === Camera.TorchOn) ? Theme.colorYellow : "white"
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
