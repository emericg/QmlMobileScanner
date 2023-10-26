import QtQuick

import QtMultimedia
import QZXing

import ThemeEngine

QZXingFilter {
    id: barcodeReader

    videoSink: videoOutput.videoSink
    captureRect: Qt.rect(videoOutput.sourceRect.width * videoOutput.captureRectStartFactorX,
                         videoOutput.sourceRect.height * videoOutput.captureRectStartFactorY,
                         videoOutput.sourceRect.width * videoOutput.captureRectFactorWidth,
                         videoOutput.sourceRect.height * videoOutput.captureRectFactorHeight)

    property string tagText
    property string tagFormat
    property string tagEncoding

    property real timePerFrameDecode: 0
    property int framesDecodedTotal: 0
    property var framesDecodedTable: []

    decoder {
        tryHarder: settingsManager.scan_tryHarder

        enabledDecoders: QZXing.DecoderFormat_QR_CODE |
                         QZXing.DecoderFormat_DATA_MATRIX |
                         QZXing.DecoderFormat_UPC_E |
                         QZXing.DecoderFormat_UPC_A |
                         QZXing.DecoderFormat_UPC_EAN_EXTENSION |
                         QZXing.DecoderFormat_RSS_14 |
                         QZXing.DecoderFormat_RSS_EXPANDED |
                         QZXing.DecoderFormat_PDF_417 |
                         QZXing.DecoderFormat_MAXICODE |
                         QZXing.DecoderFormat_EAN_8 |
                         QZXing.DecoderFormat_EAN_13 |
                         QZXing.DecoderFormat_CODE_128 |
                         QZXing.DecoderFormat_CODE_93 |
                         QZXing.DecoderFormat_CODE_39 |
                         QZXing.DecoderFormat_CODABAR |
                         QZXing.DecoderFormat_ITF |
                         QZXing.DecoderFormat_Aztec

        onTagFound: (tag) => {
            console.log(tag + " | " + decoder.foundedFormat() + " | " + decoder.charSet())

            if (tag != tagText) {
                utilsApp.vibrate(33)

                barcodeReader.tagText = tag
                barcodeReader.tagFormat = decoder.foundedFormat()
                barcodeReader.tagEncoding = decoder.charSet()
            }

            //barcodeItem.visible = true
            //barcodeTxt.text = tag + " | " + decoder.foundedFormat()
            //if (decoder.charSet()) + " | " + decoder.charSet()
        }
    }

    onDecodingStarted: {
        //console.log("QZXing::onDecodingStarted()")
    }
    onDecodingFinished: (succeeded, decodeTime) => {
        if (framesDecodedTable.length >= 120) framesDecodedTotal -= framesDecodedTable.shift()
        framesDecodedTable.push(decodeTime)
        framesDecodedTotal += decodeTime

        timePerFrameDecode = framesDecodedTotal / framesDecodedTable.length
        //console.log("QZXing::onDecodingFinished(" + succeeded + " / " + decodeTime + " ms)")
    }
}
