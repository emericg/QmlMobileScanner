import QtQuick

import QtMultimedia
import ZXing

import ThemeEngine

BarcodeReader {
    id: barcodeReader
    videoSink: videoOutput.videoSink

    formats: ZXing.LinearCodes | ZXing.MatrixCodes // ZXing.None

    tryRotate: settingsManager.tryRotate
    tryHarder: settingsManager.tryHarder
    tryDownscale: settingsManager.tryDownscale

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

        //console.log(result)
    }
}
