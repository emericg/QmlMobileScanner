import QtQuick

import QtMultimedia
import ZXingCpp

import ThemeEngine

ZXingQtVideoFilter {
    id: barcodeReader

    videoSink: videoOutput.videoSink
    formats: settingsManager.formatsEnabled // ZXingCpp.LinearCodes | ZXingCpp.MatrixCodes

    tryRotate: settingsManager.scan_tryRotate
    tryHarder: settingsManager.scan_tryHarder
    tryDownscale: settingsManager.scan_tryDownscale

    property string tagText
    property string tagFormat
    property string tagEncoding

    property real timePerFrameDecode: 0
    property int framesDecodedTotal: 0
    property var framesDecodedTable: []

    property var nullPoints: [Qt.point(0,0), Qt.point(0,0), Qt.point(0,0), Qt.point(0,0)]
    property var points: nullPoints

    function mapPointToItem(point) {
        if (videoOutput.sourceRect.width === 0 || videoOutput.sourceRect.height === 0) return Qt.point(0, 0)

        let dx = point.x
        let dy = point.y

        if ((videoOutput.orientation % 180) == 0) {
            dx = dx * videoOutput.contentRect.width / videoOutput.sourceRect.width
            dy = dy * videoOutput.contentRect.height / videoOutput.sourceRect.height
        } else {
            dx = dx * videoOutput.contentRect.height / videoOutput.sourceRect.height
            dy = dx * videoOutput.contentRect.width / videoOutput.sourceRect.width
        }

        switch ((videoOutput.orientation + 360) % 360) {
            default:
            case 0:
                return Qt.point(videoOutput.contentRect.x + dx, videoOutput.contentRect.y + dy)
            case 90:
                return Qt.point(videoOutput.contentRect.x + dy, videoOutput.contentRect.y + videoOutput.contentRect.height - dx)
            case 180:
                return Qt.point(videoOutput.contentRect.x + videoOutput.contentRect.width - dx, videoOutput.contentRect.y + videoOutput.contentRect.height -dy)
            case 270:
                return Qt.point(videoOutput.contentRect.x + videoOutput.contentRect.width - dy, videoOutput.contentRect.y + dx)
        }
    }

    onTagFound: (result) => {
        //console.log("onTagFound : " + result)

        if (result.isValid && result.text !== "") {
            points = [mapPointToItem(result.position.topLeft), mapPointToItem(result.position.topRight),
                      mapPointToItem(result.position.bottomRight), mapPointToItem(result.position.bottomLeft)]

            barcodeVisibleTimer.start()

            if (result.text !== tagText) {
                utilsApp.vibrate(33)

                //barcodeManager.addBarcode(result.text, result.formatName, result.contentType, "")
                barcodeManager.addHistory(result.text, result.formatName, result.contentType, "")

                barcodeReader.tagText = result.text
                barcodeReader.tagFormat = result.formatName
            }
        } else {
            points = nullPoints
        }
    }

    onDecodingStarted: {
        //console.log("ZXingCpp::onDecodingStarted()")
    }
    onDecodingFinished: (result) => {
        if (framesDecodedTable.length >= 120) framesDecodedTotal -= framesDecodedTable.shift()
        framesDecodedTable.push(result.runTime)
        framesDecodedTotal += result.runTime

        timePerFrameDecode = framesDecodedTotal / framesDecodedTable.length
        //console.log("ZXingCpp::onDecodingFinished(" + result.isValid + " / " + result.runTime + " ms)")
    }
}
