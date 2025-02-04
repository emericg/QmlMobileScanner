import QtQuick

import QtMultimedia
import ZXingQt

import ComponentLibrary

ZXingQtVideoFilter {
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
    formats: ZXingQt.LinearCodes | ZXingQt.MatrixCodes
    formats: ZXingQt.Codabar |
             ZXingQt.Code39 | ZXingQt.Code93 | ZXingQt.Code128 |
             ZXingQt.EAN8 | ZXingQt.EAN13 |
             ZXingQt.ITF |
             ZXingQt.DataBar | ZXingQt.DataBarExpanded |
             ZXingQt.UPCA | ZXingQt.UPCE |
             ZXingQt.Aztec |
             ZXingQt.DataMatrix |
             ZXingQt.MaxiCode |
             ZXingQt.PDF417 |
             ZXingQt.QRCode | ZXingQt.MicroQRCode
*/
    function mapPointToItem(point) {
        //console.log("-------------------------------------")
        //console.log("mapPointToItem(" + point + ") orientation: " + videoOutput.orientation)
        //videoOutput.printInfos()

        if (videoOutput.sourceRect.width === 0 || videoOutput.sourceRect.height === 0) return Qt.point(0, 0)

        // V0 // old mechanism for Qt 6.5.3
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
        //console.log("> pos > " + result.position.topLeft + "," + result.position.topRight + "," +
        //                         result.position.bottomRight  + "," + result.position.bottomLeft)

        //console.log("contentRect : " + videoOutput.contentRect)
        //console.log("sourceRect : " + videoOutput.sourceRect)

        if (result.isValid && result.text !== "") {
            var newbarcode = barcodeManager.addBarcode(result.text, result.formatName, result.contentType, "",
                                                       mapPointToItem(result.position.topLeft),
                                                       mapPointToItem(result.position.topRight),
                                                       mapPointToItem(result.position.bottomRight),
                                                       mapPointToItem(result.position.bottomLeft))

            if (newbarcode) {
                utilsApp.vibrate(33)

                if (settingsManager.save_barcodes) {
                    barcodeManager.addHistory(result.text,
                                              result.formatName, result.contentType, "",
                                              gps.coordinates)
                }
            }
        }
    }

    onDecodingFinished: (result) => {
        if (framesDecodedTable.length >= 60) framesDecodedTotal -= framesDecodedTable.shift()
        framesDecodedTable.push(result.runTime)
        framesDecodedTotal += result.runTime

        timePerFrameDecode = framesDecodedTotal / framesDecodedTable.length
        //console.log("ZXingQt::onDecodingFinished(" + result.isValid + " / " + result.runTime + " ms)")
    }
}
