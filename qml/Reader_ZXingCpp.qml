import QtQuick

import QtMultimedia
import ZXingCpp

import ThemeEngine

ZXingCppVideoFilter {
    id: barcodeReader

    property real timePerFrameDecode: 0
    property int framesDecodedTotal: 0
    property var framesDecodedTable: []

    videoSink: videoOutput.videoSink
    captureRect: settingsManager.scan_fullscreen ?
                     Qt.rect(videoOutput.sourceRect.x, videoOutput.sourceRect.y,
                             videoOutput.sourceRect.width, videoOutput.sourceRect.height) :
                     Qt.rect(videoOutput.sourceRect.width * videoOutput.captureRectStartFactorX,
                             videoOutput.sourceRect.height * videoOutput.captureRectStartFactorY,
                             videoOutput.sourceRect.width * videoOutput.captureRectFactorWidth,
                             videoOutput.sourceRect.height * videoOutput.captureRectFactorHeight)

    tryHarder: settingsManager.scan_tryHarder
    tryRotate: settingsManager.scan_tryRotate
    tryInvert: settingsManager.scan_tryInvert
    tryDownscale: settingsManager.scan_tryDownscale

    formats: settingsManager.formatsEnabled
/*
    formats: ZXingCpp.LinearCodes | ZXingCpp.MatrixCodes
    formats: ZXingCpp.Codabar |
             ZXingCpp.Code39 | ZXingCpp.Code93 | ZXingCpp.Code128 |
             ZXingCpp.EAN8 | ZXingCpp.EAN13 |
             ZXingCpp.ITF |
             ZXingCpp.DataBar | ZXingCpp.DataBarExpanded |
             ZXingCpp.UPCA | ZXingCpp.UPCE |
             ZXingCpp.Aztec |
             ZXingCpp.DataMatrix |
             ZXingCpp.MaxiCode |
             ZXingCpp.PDF417 |
             ZXingCpp.QRCode | ZXingCpp.MicroQRCode
*/
    function mapPointToItem(point) {
        //console.log("mapPointToItem(" + point + ")")

        if (videoOutput.sourceRect.width === 0 || videoOutput.sourceRect.height === 0) return Qt.point(0, 0)

        let dx = point.x + barcodeReader.captureRect.x
        let dy = point.y + barcodeReader.captureRect.y

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
            var newbarcode = barcodeManager.addBarcode(result.text, result.formatName, result.contentType, "",
                                                       mapPointToItem(result.position.topLeft),
                                                       mapPointToItem(result.position.topRight),
                                                       mapPointToItem(result.position.bottomRight),
                                                       mapPointToItem(result.position.bottomLeft))

            if (newbarcode) {
                utilsApp.vibrate(33)
                barcodeManager.addHistory(result.text, result.formatName, result.contentType, "",
                                          gps.coordinates)
            }
        }
    }

    onDecodingFinished: (result) => {
        if (framesDecodedTable.length >= 60) framesDecodedTotal -= framesDecodedTable.shift()
        framesDecodedTable.push(result.runTime)
        framesDecodedTotal += result.runTime

        timePerFrameDecode = framesDecodedTotal / framesDecodedTable.length
        //console.log("ZXingCpp::onDecodingFinished(" + result.isValid + " / " + result.runTime + " ms)")
    }
}
