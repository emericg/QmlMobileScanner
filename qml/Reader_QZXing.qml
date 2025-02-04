import QtQuick

import QtMultimedia
import QZXing

import ComponentLibrary

QZXingFilter {
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

    decoder {
        tryHarder: settingsManager.scan_tryHarder
        enabledDecoders: settingsManager.formatsEnabled
/*
        enabledDecoders: QZXing.DecoderFormat_QR_CODE |
                         QZXing.DecoderFormat_Aztec |
                         QZXing.DecoderFormat_DATA_MATRIX |
                         QZXing.DecoderFormat_MAXICODE |
                         QZXing.DecoderFormat_PDF_417 |
                         QZXing.DecoderFormat_UPC_A | QZXing.DecoderFormat_UPC_E | QZXing.DecoderFormat_UPC_EAN_EXTENSION |
                         QZXing.DecoderFormat_RSS_14 | QZXing.DecoderFormat_RSS_EXPANDED |
                         QZXing.DecoderFormat_EAN_8 | QZXing.DecoderFormat_EAN_13 |
                         QZXing.DecoderFormat_CODE_39 | QZXing.DecoderFormat_CODE_93 | QZXing.DecoderFormat_CODE_128 |
                         QZXing.DecoderFormat_CODABAR |
                         QZXing.DecoderFormat_ITF
*/
        onTagFound: (tag) => {
            //console.log("onTagFound : " + tag + " | " + decoder.foundedFormat() + " | " + decoder.charSet())

            var newbarcode = barcodeManager.addBarcode(tag, decoder.foundedFormat(), decoder.charSet(), "",
                                                       Qt.point(0,0), Qt.point(0,0), Qt.point(0,0), Qt.point(0,0))

            if (newbarcode) {
                utilsApp.vibrate(33)

                if (settingsManager.save_barcodes) {
                    barcodeManager.addHistory(tag,
                                              decoder.foundedFormat(), decoder.charSet(), "",
                                              gps.coordinates)
                }
            }
        }
    }

    onDecodingFinished: (succeeded, decodeTime) => {
        if (framesDecodedTable.length >= 60) framesDecodedTotal -= framesDecodedTable.shift()
        framesDecodedTable.push(decodeTime)
        framesDecodedTotal += decodeTime

        timePerFrameDecode = framesDecodedTotal / framesDecodedTable.length
        //console.log("QZXing::onDecodingFinished(" + succeeded + " / " + decodeTime + " ms)")
    }
}
