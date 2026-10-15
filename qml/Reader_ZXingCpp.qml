import QtQuick

import QtMultimedia
import ZXingQml

import ComponentLibrary
import AppUtils

ZXingQmlVideoFilter {
    id: barcodeReader

    property real timePerFrameDecode: 0
    property int framesDecodedTotal: 0
    property var framesDecodedTable: []

    videoSink: videoOutput.videoSink
    orientation: videoOutput.orientation
    mirrored: videoOutput.mirrored ?? false // VideoOutput.mirrored is Qt 6.9+

    // capture zone, mapped from the VideoOutput item into the displayed video frame (contentRect)
    captureRect: {
        if (SettingsManager.scan_fullscreen || videoOutput.contentRect.width <= 0 || videoOutput.contentRect.height <= 0)
            return Qt.rect(0, 0, 1, 1)

        return Qt.rect((videoOutput.width * videoOutput.captureRectStartFactorX - videoOutput.contentRect.x) / videoOutput.contentRect.width,
                       (videoOutput.height * videoOutput.captureRectStartFactorY - videoOutput.contentRect.y) / videoOutput.contentRect.height,
                       videoOutput.width * videoOutput.captureRectFactorWidth / videoOutput.contentRect.width,
                       videoOutput.height * videoOutput.captureRectFactorHeight / videoOutput.contentRect.height)
    }

    tryHarder: SettingsManager.scan_tryHarder
    tryRotate: SettingsManager.scan_tryRotate
    tryInvert: SettingsManager.scan_tryInvert
    tryDownscale: SettingsManager.scan_tryDownscale

    formats: SettingsManager.formatsEnabled
/*
    formats: ZXingQml.LinearCodes | ZXingQml.MatrixCodes
    formats: ZXingQml.Codabar |
             ZXingQml.Code39 | ZXingQml.Code93 | ZXingQml.Code128 |
             ZXingQml.EAN8 | ZXingQml.EAN13 |
             ZXingQml.ITF |
             ZXingQml.DataBar | ZXingQml.DataBarExpanded |
             ZXingQml.UPCA | ZXingQml.UPCE |
             ZXingQml.Aztec |
             ZXingQml.DataMatrix |
             ZXingQml.MaxiCode |
             ZXingQml.PDF417 |
             ZXingQml.QRCode | ZXingQml.MicroQRCode
*/
    function mapPointToItem(point) {
        // point is in normalized coordinates of the displayed video frame
        return Qt.point(videoOutput.contentRect.x + point.x * videoOutput.contentRect.width,
                        videoOutput.contentRect.y + point.y * videoOutput.contentRect.height)
    }

    onTagFound: (result) => {
        //console.log("onTagFound : " + result)
        //console.log("> pos > " + result.positionPixels.topLeft + "," + result.positionPixels.topRight + "," +
        //                         result.positionPixels.bottomRight  + "," + result.positionPixels.bottomLeft)

        //console.log("contentRect : " + videoOutput.contentRect)
        //console.log("sourceRect : " + videoOutput.sourceRect)

        if (result.isValid && result.text !== "") {
            var newbarcode = BarcodeManager.addBarcode(result.text, result.formatName, result.contentTypeName, "",
                                                       mapPointToItem(result.positionNormalized.topLeft),
                                                       mapPointToItem(result.positionNormalized.topRight),
                                                       mapPointToItem(result.positionNormalized.bottomRight),
                                                       mapPointToItem(result.positionNormalized.bottomLeft))

            if (newbarcode) {
                UtilsOS.hapticFeedback(33)

                if (SettingsManager.save_barcodes) {
                    BarcodeManager.addHistory(result.text,
                                              result.formatName, result.contentTypeName, "",
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
        //console.log("ZXingQml::onDecodingFinished(" + result.isValid + " / " + result.runTime + " ms)")
    }
}
