import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls

import QtMultimedia
import ZXing

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

        property var nullPoints: [Qt.point(0,0), Qt.point(0,0), Qt.point(0,0), Qt.point(0,0)]
        property var points: nullPoints

        Timer {
            id: resetInfo
            interval: 2000
        }

        BarcodeReader {
            id: barcodeReader
            videoSink: videoOutput.videoSink

            formats: (linearSwitch.checked ? (ZXing.LinearCodes) : ZXing.None) | (matrixSwitch.checked ? (ZXing.MatrixCodes) : ZXing.None)
            tryRotate: tryRotateSwitch.checked
            tryHarder: tryHarderSwitch.checked
            tryDownscale: tryDownscaleSwitch.checked

            // callback with parameter 'result', called for every successfully processed frame
            // onFoundBarcode: {}

            // callback with parameter 'result', called for every processed frame
            onNewResult: (result)=> {
                points = result.isValid
                        ? [result.position.topLeft, result.position.topRight, result.position.bottomRight, result.position.bottomLeft]
                        : nullPoints

                if (result.isValid)
                    resetInfo.restart()

                if (result.isValid || !resetInfo.running)
                    info.text = qsTr("Format: \t %1 \nText: \t %2 \nError: \t %3 \nTime: \t %4 ms").arg(result.formatName).arg(result.text).arg(result.status).arg(result.runTime)

    //            console.log(result)
            }
        }

        MediaDevices {
            id: devices
        }

        Camera {
            id: camera
            cameraDevice: devices.videoInputs[camerasComboBox.currentIndex] ? devices.videoInputs[camerasComboBox.currentIndex] : devices.defaultVideoInput
            focusMode: Camera.FocusModeAutoNear
            onErrorOccurred: console.log("camera error:" + errorString)
            active: true
        }

        CaptureSession {
            id: captureSession
            camera: camera
            videoOutput: videoOutput
        }

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: false
                visible: devices.videoInputs.length > 1
                Label {
                    text: qsTr("Camera: ")
                    Layout.fillWidth: false
                }
                ComboBox {
                    id: camerasComboBox
                    Layout.fillWidth: true
                    model: devices.videoInputs
                    textRole: "description"
                    currentIndex: 0
                }
            }

            VideoOutput {
                id: videoOutput
                Layout.fillHeight: true
                Layout.fillWidth: true

                function mapPointToItem(point)
                {
                    if (videoOutput.sourceRect.width === 0 || videoOutput.sourceRect.height === 0)
                        return Qt.point(0, 0);

                    let dx = point.x;
                    let dy = point.y;

                    if ((videoOutput.orientation % 180) == 0)
                    {
                        dx = dx * videoOutput.contentRect.width / videoOutput.sourceRect.width;
                        dy = dy * videoOutput.contentRect.height / videoOutput.sourceRect.height;
                    }
                    else
                    {
                        dx = dx * videoOutput.contentRect.height / videoOutput.sourceRect.height;
                        dy = dx * videoOutput.contentRect.width / videoOutput.sourceRect.width;
                    }

                    switch ((videoOutput.orientation + 360) % 360)
                    {
                        case 0:
                        default:
                            return Qt.point(videoOutput.contentRect.x + dx, videoOutput.contentRect.y + dy);
                        case 90:
                            return Qt.point(videoOutput.contentRect.x + dy, videoOutput.contentRect.y + videoOutput.contentRect.height - dx);
                        case 180:
                            return Qt.point(videoOutput.contentRect.x + videoOutput.contentRect.width - dx, videoOutput.contentRect.y + videoOutput.contentRect.height -dy);
                        case 270:
                            return Qt.point(videoOutput.contentRect.x + videoOutput.contentRect.width - dy, videoOutput.contentRect.y + dx);
                    }
                }

                Shape {
                    id: polygon
                    anchors.fill: parent
                    visible: points.length === 4

                    ShapePath {
                        strokeWidth: 3
                        strokeColor: "red"
                        strokeStyle: ShapePath.SolidLine
                        fillColor: "transparent"
                        //TODO: really? I don't know qml...
                        startX: videoOutput.mapPointToItem(points[3]).x
                        startY: videoOutput.mapPointToItem(points[3]).y

                        PathLine {
                            x: videoOutput.mapPointToItem(points[0]).x
                            y: videoOutput.mapPointToItem(points[0]).y
                        }
                        PathLine {
                            x: videoOutput.mapPointToItem(points[1]).x
                            y: videoOutput.mapPointToItem(points[1]).y
                        }
                        PathLine {
                            x: videoOutput.mapPointToItem(points[2]).x
                            y: videoOutput.mapPointToItem(points[2]).y
                        }
                        PathLine {
                            x: videoOutput.mapPointToItem(points[3]).x
                            y: videoOutput.mapPointToItem(points[3]).y
                        }
                    }
                }

                Label {
                    id: info
                    color: "white"
                    padding: 10
                    background: Rectangle { color: "#80808080" }
                }

                ColumnLayout {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    SwitchThemed {id: tryRotateSwitch; text: qsTr("Try Rotate"); checked: true }
                    SwitchThemed {id: tryHarderSwitch; text: qsTr("Try Harder"); checked: true }
                    SwitchThemed {id: tryDownscaleSwitch; text: qsTr("Try Downscale"); checked: true }
                    SwitchThemed {id: linearSwitch; text: qsTr("Linear Codes"); checked: true }
                    SwitchThemed {id: matrixSwitch; text: qsTr("Matrix Codes"); checked: true }
                }
            }
        }

        ////////////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
