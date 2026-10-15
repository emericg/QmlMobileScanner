import QtCore

import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Dialogs

import QtPositioning
import QtMultimedia

import ComponentLibrary
import MobileUI
import AppUtils

Loader {
    id: screenBarcodeReader
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        appContent.state = "ScreenBarcodeReader"

        MobileUI.setScreenAlwaysOn(true)

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

        MobileUI.setScreenAlwaysOn(false)

        if (screenBarcodeReader.status === Loader.Ready) {
            screenBarcodeReader.item.close()
        }
    }
    function close() {
        console.log("screenBarcodeReader::close()")

        MobileUI.setScreenAlwaysOn(false)

        if (screenBarcodeReader.status === Loader.Ready) {
            screenBarcodeReader.item.close()
            if (isMobile) screenBarcodeReader.active = false // crash !?!
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    PositionSource {
        id: gps

        property geoCoordinate coordinates: QtPositioning.coordinate(0, 0)

        active: (isMobile && SettingsManager.save_gps)
        updateInterval: 3333

        onSupportedPositioningMethodsChanged: {
            //console.log("Positioning method: " + supportedPositioningMethods)
        }
        onPositionChanged: {
            //console.log("Coordinate: ", position.coordinate.longitude, position.coordinate.latitude)
            gps.coordinates = position.coordinate
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle {
            anchors.fill: parent
            color: "black"
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 233 } }

        property string currentMode: "video"

        Component.onCompleted: open()

        function open() {
            //console.log(">> open()")

            screenBarcodeDetails.visible = false
            opacity = 1

            if (currentMode === "video") open_video()
            else if (currentMode === "image") open_image()

            if (isMobile) {
                //appWindow.showFullScreen()
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
            }
        }

        function backAction() {
            //console.log(">> backAction()")

            if (screenBarcodeDetails.visible) {
                screenBarcodeDetails.backAction()
                return
            }

            // change screen?
            if (SettingsManager.defaultTab === "writer")
                screenBarcodeWriter.loadScreen()
        }

        ////////////////////////

        IconSvg {
            width: 64; height: 64;
            anchors.centerIn: parent
            color: "#ccc"
            source: "qrc:/IconLibrary/material-icons/outlined/hourglass_empty.svg"
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
                cameraFormat: UtilsCamera.selectCameraFormat(cameraDevice)
                //cameraFormat: (SettingsManager.scanFullres) ? UtilsCamera.selectCameraFormat(cameraDevice) : undefined

                onCameraDeviceChanged: {
                    console.log("CaptureSession::onCameraDeviceChanged()")
                    console.log("- description: " + cameraDevice.description)
                    console.log("- correctionAngle: " + cameraDevice.correctionAngle)
                }
                onCameraFormatChanged: {
                    console.log("CaptureSession::onCameraFormatChanged()")
                    console.log("- cameraFormat: " + cameraFormat)
                }
                onErrorOccurred: (error, errorString) => {
                    console.log("CaptureSession::onErrorOccurred() " + errorString)
                }
            }
        }

        ////////////////////////

        Loader {
            id: backendLoader
            active: true
            asynchronous: true
            source: (SettingsManager.backend_reader === "zxingcpp") ? "Reader_ZXingCpp.qml" : "Reader_QZXing.qml"
        }
        property alias barcodeReader: backendLoader.item

        ////////////////////////

        VideoOutput {
            id: videoOutput
            anchors.fill: parent

            orientation: 0

            fillMode: VideoOutput.PreserveAspectCrop
            //fillMode: VideoOutput.PreserveAspectFit

            // Capture rectangle
            property double captureRectStartFactorX: 0.05
            property double captureRectStartFactorY: 0.20
            property double captureRectFactorWidth: 0.9
            property double captureRectFactorHeight: 0.45

            // Capture rectangles
            property rect captureRect

            property rect captureRect_mobile_top: Qt.rect(0.05, 0.20, 0.9, 0.45) // default
            property rect captureRect_mobile_mid: Qt.rect(0.05, 0.25, 0.9, 0.5)
            property rect captureRect_wide_left: Qt.rect(0.10, 0.12, 0.5, 0.76)
            property rect captureRect_wide_right: Qt.rect(0.4, 0.12, 0.5, 0.76)

            // Select capture rectangle
            onWidthChanged: {
                if (Theme.isTablet) {
                    videoOutput.mapCaptureRect(videoOutput.captureRect_wide_left)
                }
                if (Theme.isPhone) {
                    videoOutput.mapCaptureRect(videoOutput.captureRect_mobile_top)
                }
                if (Theme.isDesktop) {
                    if (Theme.singleColumn) {
                        videoOutput.mapCaptureRect(videoOutput.captureRect_mobile_mid)
                    } else {
                        videoOutput.mapCaptureRect(videoOutput.captureRect_wide_left)
                    }
                }
            }

            ////

            function mapCaptureRect(newrect) {
                videoOutput.captureRect = newrect

                videoOutput.captureRectStartFactorX = videoOutput.captureRect.x
                videoOutput.captureRectStartFactorY = videoOutput.captureRect.y
                videoOutput.captureRectFactorWidth  = videoOutput.captureRect.width
                videoOutput.captureRectFactorHeight = videoOutput.captureRect.height

                videoOutput.printInfos()
            }

            ////

            function printInfos() {
                console.log("> Camera > " + mediaDevices.videoInputs[mediaDevices.selectedDevice].description)

                console.log("- videoOutput sz: " + videoOutput.x + "," + videoOutput.y + " - " + videoOutput.width + "x" + videoOutput.height)
                console.log("- videoOutput2sz: (SCALED) " + videoOutput.x*UtilsScreen.screenPar + "," + videoOutput.y*UtilsScreen.screenPar + " - " +
                                                            videoOutput.width*UtilsScreen.screenPar + "x" + videoOutput.height*UtilsScreen.screenPar)
                console.log("- contentRect sz: " + videoOutput.contentRect.x.toFixed() + "," + videoOutput.contentRect.y.toFixed() + " - " +
                                                   videoOutput.contentRect.width.toFixed() + "x" + videoOutput.contentRect.height.toFixed())
                console.log("- contentRect sz: (SCALED) " + videoOutput.contentRect.x.toFixed()*UtilsScreen.screenPar + "," + videoOutput.contentRect.y.toFixed()*UtilsScreen.screenPar + " - " +
                                                            videoOutput.contentRect.width.toFixed()*UtilsScreen.screenPar + "x" + videoOutput.contentRect.height.toFixed()*UtilsScreen.screenPar)
                console.log("- captureRect sz: " + barcodeReader.captureRect)
            }

            ////

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                visible: !SettingsManager.scan_fullscreen && !captureZone.visible
                color: "black"
                opacity: 0.4
            }

            Item {
                id: captureZone
                anchors.fill: parent

                visible: !SettingsManager.scan_fullscreen &&
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
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
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

            ////////

            Repeater {
                model: BarcodeManager.barcodes

                Shape {
                    anchors.fill: parent

                    opacity: modelData.isOnScreen ? 0.80 : 0
                    Behavior on opacity { NumberAnimation { duration: 133 } }

                    layer.enabled: Theme.isDesktop
                    layer.samples: 4

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

            ////
        }

        ////////////////////////

        Image {
            id: imageOutput
            anchors.fill: parent

            visible: false
            source: ""

            fillMode: Image.PreserveAspectFit
            autoTransform: true // apply EXIF orientation, as BarcodeManager.loadImage() does

            // area where the picture is painted, centered by default alignment
            readonly property real contentX: (width - paintedWidth) / 2
            readonly property real contentY: (height - paintedHeight) / 2

            ////

            function printInfos() {
                console.log("> Image > " + imageOutput.source)
                console.log("- image sz: " + imageOutput.x + "," + imageOutput.y + " - " + imageOutput.width + "x" + imageOutput.height)
                console.log("- sourceSize  sz: " + imageOutput.sourceSize.width + "x" + imageOutput.sourceSize.height)
                console.log("- painted sz: " + imageOutput.contentX + "," + imageOutput.contentY + " - " +
                                               imageOutput.paintedWidth + "x" + imageOutput.paintedHeight)
                console.log("- sourceClipRect sz: " + imageOutput.sourceClipRect.x + "," + imageOutput.sourceClipRect.y + " - " +
                                                      imageOutput.sourceClipRect.width + "x" + imageOutput.sourceClipRect.height)
            }

            ////

            Repeater {
                model: BarcodeManager.barcodes

                Shape {
                    anchors.fill: parent

                    opacity: modelData.isOnScreen ? 0.80 : 0
                    Behavior on opacity { NumberAnimation { duration: 133 } }

                    ShapePath {
                        strokeWidth: 4
                        strokeColor: modelData.color
                        strokeStyle: ShapePath.SolidLine
                        fillColor: "transparent"

                        // normalized coordinates -> painted picture area
                        startX: imageOutput.contentX + modelData.lastCoordinates[3].x * imageOutput.paintedWidth
                        startY: imageOutput.contentY + modelData.lastCoordinates[3].y * imageOutput.paintedHeight
                        PathLine { x: imageOutput.contentX + modelData.lastCoordinates[0].x * imageOutput.paintedWidth; y: imageOutput.contentY + modelData.lastCoordinates[0].y * imageOutput.paintedHeight; }
                        PathLine { x: imageOutput.contentX + modelData.lastCoordinates[1].x * imageOutput.paintedWidth; y: imageOutput.contentY + modelData.lastCoordinates[1].y * imageOutput.paintedHeight; }
                        PathLine { x: imageOutput.contentX + modelData.lastCoordinates[2].x * imageOutput.paintedWidth; y: imageOutput.contentY + modelData.lastCoordinates[2].y * imageOutput.paintedHeight; }
                        PathLine { x: imageOutput.contentX + modelData.lastCoordinates[3].x * imageOutput.paintedWidth; y: imageOutput.contentY + modelData.lastCoordinates[3].y * imageOutput.paintedHeight; }
                    }
                }
            }

            ////
        }

        ////////////////////////

        Item {
            id: overlays
            anchors.fill: parent
            anchors.leftMargin: screenPaddingLeft
            anchors.rightMargin: screenPaddingRight

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

            ////////

            Item { // debug infos (top/left)
                anchors.top: parent.top
                anchors.topMargin: Theme.componentMargin + Math.max(screenPaddingTop, screenPaddingStatusbar)
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                height: 48

                visible: SettingsManager.showDebug

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

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

            Row { // menus (top/right)
                id: toprightmenus
                anchors.top: parent.top
                anchors.topMargin: Theme.componentMargin + Math.max(screenPaddingStatusbar, screenPaddingTop)
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin
                height: 48

                spacing: Theme.componentMarginL

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
                        source: "qrc:/IconLibrary/material-icons/duotone/photo_library.svg"
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
                            console.log("fileOpenDialog: ACCEPTED: " + selectedFile)

                            if (BarcodeManager.loadImage(selectedFile)) {
                                open_image(selectedFile)
                            }
                        }
                        onRejected: {
                            console.log("fileOpenDialog: REJECTED: " + selectedFile)
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
                        source: "qrc:/IconLibrary/material-icons/duotone/camera.svg"
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

                    visible: (currentMode === "video" && SettingsManager.showDebug)

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
                        source: "qrc:/IconLibrary/material-icons/duotone/bug_report.svg"
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

                    visible: (currentMode === "video")

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
                        source: "qrc:/IconLibrary/material-symbols/qr_code.svg"
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
                        source: "qrc:/IconLibrary/material-icons/duotone/cameraswitch.svg"
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
/*
            Row { // debug row 2 (top/left)
                anchors.top: toprightmenus.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin

                visible: (currentMode === "video" && SettingsManager.showDebug)

                RoundButton {
                    text: "1"
                    onClicked: videoOutput.mapCaptureRect(videoOutput.captureRect_mobile_mid)
                }
                RoundButton {
                    text: "2"
                    onClicked: videoOutput.mapCaptureRect(videoOutput.captureRect_mobile_top)
                }
                RoundButton {
                    text: "3"
                    onClicked: videoOutput.mapCaptureRect(videoOutput.captureRect_wide_left)
                }
                RoundButton {
                    text: "4"
                    onClicked: videoOutput.mapCaptureRect(videoOutput.captureRect_wide_right)
                }
            }
*/
            ////////

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

            Column { // bottom menus
                id: bottomemnus
                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMarginL
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMarginL
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.componentMarginL + Math.max(screenPaddingBottom, screenPaddingNavbar)

                spacing: Theme.componentMargin

                ////

                Repeater { // barcode(s)
                    model: BarcodeManager.barcodes

                    WidgetBarcodeResult {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        barcode: modelData

                        onLongPressed: {
                            screenBarcodeDetails.loadBarcode(modelData)
                        }
                    }
                }

                ////

                RowLayout { // buttons bar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 48

                    spacing: Theme.componentMarginL

                    visible: !exitTimer.running

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
                            source: "qrc:/IconLibrary/material-symbols/search.svg"

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
                            textFormat: Text.PlainText
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
                                    return "qrc:/IconLibrary/material-symbols/media/flash_on.svg"
                                else
                                    return "qrc:/IconLibrary/material-symbols/media/flash_off.svg"
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
                            source: "qrc:/IconLibrary/material-symbols/menu.svg"
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
                    anchors.left: parent.left
                    anchors.right: parent.right
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
                anchors.leftMargin: -screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: -screenPaddingRight
                height: screenPaddingStatusbar

                color: "black"
                opacity: 0.33
                visible: true
            }

            Rectangle { // navbar area
                anchors.left: parent.left
                anchors.leftMargin: -screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: -screenPaddingRight
                anchors.bottom: parent.bottom
                height: screenPaddingNavbar

                color: "black"
                opacity: 0.33
                visible: true
            }

            ////////
        }

        ////////////////////////

        DropArea { // drag and drop an image, same as the file dialog
            id: imageDropArea
            anchors.fill: parent

            enabled: isDesktop && !screenBarcodeDetails.visible
            keys: ["text/uri-list"]

            readonly property var imageSuffixes: ["png", "bmp", "jpg", "jpeg", "webp"]

            function firstImage(urls) {
                for (let i = 0; i < urls.length; i++) {
                    const url = urls[i].toString()
                    const suffix = url.substring(url.lastIndexOf('.') + 1).toLowerCase()
                    if (url.startsWith("file:") && imageSuffixes.includes(suffix)) return urls[i]
                }
                return ""
            }

            onEntered: (drag) => {
                drag.accepted = drag.hasUrls && firstImage(drag.urls) !== ""
            }
            onDropped: (drop) => {
                const file = firstImage(drop.urls)
                if (file !== "" && BarcodeManager.loadImage(file)) {
                    drop.accept()
                    open_image(file)
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 8
                radius: 8

                visible: imageDropArea.containsDrag
                color: "transparent"
                border.width: 4
                border.color: Theme.colorPrimary
            }
        }

        ////////////////////////

        ScreenBarcodeDetails {
            id: screenBarcodeDetails
            entryPoint: "ScreenBarcodeReader"
        }

        ////////////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
