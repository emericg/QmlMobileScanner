import QtQuick

import QtMultimedia
import ZXingCpp

import ThemeEngine

ZXingQtVideoFilter {
    id: barcodeReader

    videoSink: videoOutput.videoSink
    captureRect: Qt.rect(0,
                         videoOutput.sourceRect.height*0.25,
                         videoOutput.sourceRect.width,
                         videoOutput.sourceRect.height*0.50)

    formats: ZXingCpp.LinearCodes | ZXingCpp.MatrixCodes // ZXingCpp.None

    tryRotate: settingsManager.scan_tryRotate
    tryHarder: settingsManager.scan_tryHarder
    tryDownscale: settingsManager.scan_tryDownscale

    property string tagText
    property string tagFormat
    property string tagEncoding

    // callback with parameter 'result', called for every successfully processed frame
    onFoundBarcode: (result) => {
       //console.log("onFoundBarcode : " + result)

        if (result.isValid && result.text !== "") {
            if (result.text !== tagText) {
                utilsApp.vibrate(33)

                barcodeReader.tagText = result.text
            }
        }
    }

    // callback with parameter 'result', called for every processed frame
    onNewResult: (result) => {
        //console.log("onNewResult : " + result)
    }
}
