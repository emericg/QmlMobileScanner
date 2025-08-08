#
# qmake project file for zxing-cpp (with Qt/QML wrapper)
# version 2.3+
#

CONFIG += c++20
CONFIG += qt warn_on
CONFIG += build_readers build_writers # Config

build_readers {
    QT += multimedia concurrent
}

win32-msvc* {
    DEFINES += _SCL_SECURE_NO_WARNINGS
    DEFINES += _CRT_SECURE_NO_WARNINGS
    DEFINES += _CRT_NONSTDC_NO_WARNINGS
    DEFINES += NOMINMAX

    QMAKE_CXXFLAGS += /FS
} else {
    QMAKE_CXXFLAGS += -Wall -Wextra -Wno-missing-braces -Werror=undef -Werror=return-type
}

## Source files ################################################################

################# WRAPPER

SOURCES += $${PWD}/wrappers/qt/ZXingQt.cpp
HEADERS += $${PWD}/wrappers/qt/ZXingQt.h
INCLUDEPATH += $${PWD}/wrappers/qt/

build_readers {
    SOURCES += $${PWD}/wrappers/qt/ZXingQtVideoFilter.cpp
    HEADERS += $${PWD}/wrappers/qt/ZXingQtVideoFilter.h
}
build_writers {
    SOURCES += $${PWD}/wrappers/qt/ZXingQtImageProvider.cpp
    HEADERS += $${PWD}/wrappers/qt/ZXingQtImageProvider.h
}

################# COMMON_FILES

INCLUDEPATH += $${PWD}/core/src/

SOURCES += $${PWD}/core/src/Barcode.cpp \
           $${PWD}/core/src/BarcodeFormat.cpp \
           $${PWD}/core/src/BitArray.cpp \
           $${PWD}/core/src/BitMatrix.cpp \
           $${PWD}/core/src/BitMatrixIO.cpp \
           $${PWD}/core/src/CharacterSet.cpp \
           $${PWD}/core/src/ConcentricFinder.cpp \
           $${PWD}/core/src/ECI.cpp \
           $${PWD}/core/src/Error.cpp \
           $${PWD}/core/src/GenericGF.cpp \
           $${PWD}/core/src/GenericGFPoly.cpp \
           $${PWD}/core/src/GTIN.cpp \
           $${PWD}/core/src/Utf.cpp \
           $${PWD}/core/src/ZXingC.cpp \
           $${PWD}/core/src/ZXingCpp.cpp

HEADERS += $${PWD}/core/src/Barcode.h \
           $${PWD}/core/src/BarcodeFormat.h \
           $${PWD}/core/src/BitArray.h \
           $${PWD}/core/src/BitHacks.h \
           $${PWD}/core/src/BitMatrix.h \
           $${PWD}/core/src/BitMatrixCursor.h \
           $${PWD}/core/src/BitMatrixIO.h \
           $${PWD}/core/src/ByteArray.h \
           $${PWD}/core/src/ByteMatrix.h \
           $${PWD}/core/src/CharacterSet.h \
           $${PWD}/core/src/ConcentricFinder.h \
           $${PWD}/core/src/ECI.h \
           $${PWD}/core/src/Error.h \
           $${PWD}/core/src/Flags.h \
           $${PWD}/core/src/Generator.h \
           $${PWD}/core/src/GenericGF.h \
           $${PWD}/core/src/GenericGFPoly.h \
           $${PWD}/core/src/GTIN.h \
           $${PWD}/core/src/LogMatrix.h \
           $${PWD}/core/src/Matrix.h \
           $${PWD}/core/src/Pattern.h \
           $${PWD}/core/src/Point.h \
           $${PWD}/core/src/Quadrilateral.h \
           $${PWD}/core/src/Range.h \
           $${PWD}/core/src/RegressionLine.h \
           $${PWD}/core/src/Scope.h \
           $${PWD}/core/src/TritMatrix.h \
           $${PWD}/core/src/Utf.h \
           $${PWD}/core/src/ZXAlgorithms.h \
           $${PWD}/core/src/ZXConfig.h \
           $${PWD}/core/src/ZXTestSupport.h \
           $${PWD}/core/src/ZXVersion.h \
           $${PWD}/core/src/ZXingC.h \
           $${PWD}/core/src/ZXingCpp.h \
           $${PWD}/core/Version.h

build_readers {
    SOURCES += $${PWD}/core/src/BinaryBitmap.cpp \
               $${PWD}/core/src/BitSource.cpp \
               $${PWD}/core/src/Content.cpp \
               $${PWD}/core/src/DecodeHints.cpp \
               $${PWD}/core/src/GlobalHistogramBinarizer.cpp \
               $${PWD}/core/src/GridSampler.cpp \
               $${PWD}/core/src/HRI.cpp \
               $${PWD}/core/src/HybridBinarizer.cpp \
               $${PWD}/core/src/MultiFormatReader.cpp \
               $${PWD}/core/src/PerspectiveTransform.cpp \
               $${PWD}/core/src/ReadBarcode.cpp \
               $${PWD}/core/src/ReedSolomonDecoder.cpp \
               $${PWD}/core/src/ResultPoint.cpp \
               $${PWD}/core/src/TextDecoder.cpp \
               $${PWD}/core/src/WhiteRectDetector.cpp

    HEADERS += $${PWD}/core/src/BinaryBitmap.h \
               $${PWD}/core/src/BitSource.h \
               $${PWD}/core/src/Content.h \
               $${PWD}/core/src/DecodeHints.h \
               $${PWD}/core/src/DecoderResult.h \
               $${PWD}/core/src/DetectorResult.h \
               $${PWD}/core/src/GlobalHistogramBinarizer.h \
               $${PWD}/core/src/GridSampler.h \
               $${PWD}/core/src/HRI.h \
               $${PWD}/core/src/HybridBinarizer.h \
               $${PWD}/core/src/ImageView.h \
               $${PWD}/core/src/MultiFormatReader.h \
               $${PWD}/core/src/PerspectiveTransform.h \
               $${PWD}/core/src/Reader.h \
               $${PWD}/core/src/ReaderOptions.h \
               $${PWD}/core/src/ReadBarcode.h \
               $${PWD}/core/src/ReedSolomonDecoder.h \
               $${PWD}/core/src/Result.h \
               $${PWD}/core/src/ResultPoint.h \
               $${PWD}/core/src/StructuredAppend.h \
               $${PWD}/core/src/TextDecoder.h \
               $${PWD}/core/src/ThresholdBinarizer.h \
               $${PWD}/core/src/WhiteRectDetector.h
}

build_writers {
    SOURCES += $${PWD}/core/src/ReedSolomonEncoder.cpp \
               $${PWD}/core/src/TextEncoder.cpp \
               $${PWD}/core/src/MultiFormatWriter.cpp \
               $${PWD}/core/src/WriteBarcode.cpp

    HEADERS += $${PWD}/core/src/ByteMatrix.h \
               $${PWD}/core/src/ReedSolomonEncoder.h \
               $${PWD}/core/src/TextEncoder.h \
               $${PWD}/core/src/MultiFormatWriter.h \
               $${PWD}/core/src/WriteBarcode.h
}

build_writers_zint {
    SOURCES += $${PWD}/core/src/2of5.c \
               $${PWD}/core/src/aztec.c \
               $${PWD}/core/src/code128.c \
               $${PWD}/core/src/code.c \
               $${PWD}/core/src/common.c \
               $${PWD}/core/src/dmatrix.c \
               $${PWD}/core/src/dxfilmedge.c \
               $${PWD}/core/src/eci.c \
               $${PWD}/core/src/filemem.c \
               $${PWD}/core/src/general_field.c \
               $${PWD}/core/src/gs1.c \
               $${PWD}/core/src/large.c \
               $${PWD}/core/src/library.c \
               $${PWD}/core/src/maxicode.c \
               $${PWD}/core/src/medical.c \
               $${PWD}/core/src/output.c \
               $${PWD}/core/src/pdf417.c \
               $${PWD}/core/src/qr.c \
               $${PWD}/core/src/raster.c \
               $${PWD}/core/src/reedsol.c \
               $${PWD}/core/src/rss.c \
               $${PWD}/core/src/stubs.c \
               $${PWD}/core/src/svg.c \
               $${PWD}/core/src/upcean.c \
               $${PWD}/core/src/vector.c

    HEADERS += $${PWD}/core/src/aztec.h \
               $${PWD}/core/src/big5.h \
               $${PWD}/core/src/channel_precalcs.h \
               $${PWD}/core/src/code128.h \
               $${PWD}/core/src/common.h \
               $${PWD}/core/src/dmatrix.h \
               $${PWD}/core/src/dmatrix_trace.h \
               $${PWD}/core/src/eci.h \
               $${PWD}/core/src/eci_sb.h \
               $${PWD}/core/src/filemem.h \
               $${PWD}/core/src/gb18030.h \
               $${PWD}/core/src/gb2312.h \
               $${PWD}/core/src/gbk.h \
               $${PWD}/core/src/general_field.h \
               $${PWD}/core/src/gs1.h \
               $${PWD}/core/src/gs1_lint.h \
               $${PWD}/core/src/iso3166.h \
               $${PWD}/core/src/iso4217.h \
               $${PWD}/core/src/ksx1001.h \
               $${PWD}/core/src/large.h \
               $${PWD}/core/src/maxicode.h \
               $${PWD}/core/src/output.h \
               $${PWD}/core/src/pdf417.h \
               $${PWD}/core/src/pdf417_tabs.h \
               $${PWD}/core/src/pdf417_trace.h \
               $${PWD}/core/src/qr.h \
               $${PWD}/core/src/raster_font.h \
               $${PWD}/core/src/reedsol.h \
               $${PWD}/core/src/reedsol_logs.h \
               $${PWD}/core/src/rss.h \
               $${PWD}/core/src/sjis.h \
               $${PWD}/core/src/zfiletypes.h \
               $${PWD}/core/src/zintconfig.h \
               $${PWD}/core/src/zint.h
}

################# AZTEC_FILES

build_readers {
    SOURCES += $${PWD}/core/src/aztec/AZDecoder.cpp \
               $${PWD}/core/src/aztec/AZDetector.cpp \
               $${PWD}/core/src/aztec/AZReader.cpp

    HEADERS += $${PWD}/core/src/aztec/AZDecoder.h \
               $${PWD}/core/src/aztec/AZDetector.h \
               $${PWD}/core/src/aztec/AZDetectorResult.h \
               $${PWD}/core/src/aztec/AZReader.h
}

build_writers {
    SOURCES += $${PWD}/core/src/aztec/AZEncoder.cpp \
               $${PWD}/core/src/aztec/AZHighLevelEncoder.cpp \
               $${PWD}/core/src/aztec/AZToken.cpp \
               $${PWD}/core/src/aztec/AZWriter.cpp

    HEADERS += $${PWD}/core/src/aztec/AZEncodingState.h \
               $${PWD}/core/src/aztec/AZEncoder.h \
               $${PWD}/core/src/aztec/AZHighLevelEncoder.h \
               $${PWD}/core/src/aztec/AZToken.h \
               $${PWD}/core/src/aztec/AZWriter.h
}

################# DATAMATRIX_FILES

SOURCES += $${PWD}/core/src/datamatrix/DMBitLayout.cpp $${PWD}/core/src/datamatrix/DMVersion.cpp
HEADERS += $${PWD}/core/src/datamatrix/DMBitLayout.h $${PWD}/core/src/datamatrix/DMVersion.h

build_readers {
    SOURCES += $${PWD}/core/src/datamatrix/DMDataBlock.cpp \
               $${PWD}/core/src/datamatrix/DMDecoder.cpp \
               $${PWD}/core/src/datamatrix/DMDetector.cpp \
               $${PWD}/core/src/datamatrix/DMReader.cpp

    HEADERS += $${PWD}/core/src/datamatrix/DMDataBlock.h \
               $${PWD}/core/src/datamatrix/DMDecoder.h \
               $${PWD}/core/src/datamatrix/DMDetector.h \
               $${PWD}/core/src/datamatrix/DMReader.h
}

build_writers {
SOURCES += $${PWD}/core/src/datamatrix/DMECEncoder.cpp \
           $${PWD}/core/src/datamatrix/DMHighLevelEncoder.cpp \
           $${PWD}/core/src/datamatrix/DMSymbolInfo.cpp \
           $${PWD}/core/src/datamatrix/DMWriter.cpp

HEADERS += $${PWD}/core/src/datamatrix/DMECEncoder.h \
           $${PWD}/core/src/datamatrix/DMEncoderContext.h \
           $${PWD}/core/src/datamatrix/DMHighLevelEncoder.h \
           $${PWD}/core/src/datamatrix/DMSymbolInfo.h \
           $${PWD}/core/src/datamatrix/DMSymbolShape.h \
           $${PWD}/core/src/datamatrix/DMWriter.h
}

################# MAXICODE_FILES

build_readers {
    SOURCES += $${PWD}/core/src/maxicode/MCBitMatrixParser.cpp \
               $${PWD}/core/src/maxicode/MCDecoder.cpp \
               $${PWD}/core/src/maxicode/MCReader.cpp
    HEADERS += $${PWD}/core/src/maxicode/MCBitMatrixParser.h \
               $${PWD}/core/src/maxicode/MCDecoder.h \
               $${PWD}/core/src/maxicode/MCReader.h
}

################# ONED_FILES

SOURCES += $${PWD}/core/src/oned/ODUPCEANCommon.cpp $${PWD}/core/src/oned/ODCode128Patterns.cpp
HEADERS += $${PWD}/core/src/oned/ODUPCEANCommon.h $${PWD}/core/src/oned/ODCode128Patterns.h

build_readers {
SOURCES += $${PWD}/core/src/oned/ODCodabarReader.cpp \
           $${PWD}/core/src/oned/ODCode39Reader.cpp \
           $${PWD}/core/src/oned/ODCode93Reader.cpp \
           $${PWD}/core/src/oned/ODCode128Reader.cpp \
           $${PWD}/core/src/oned/ODDataBarCommon.cpp \
           $${PWD}/core/src/oned/ODDataBarReader.cpp \
           $${PWD}/core/src/oned/ODDataBarExpandedBitDecoder.cpp \
           $${PWD}/core/src/oned/ODDataBarExpandedReader.cpp \
           $${PWD}/core/src/oned/ODDataBarLimitedReader.cpp \
           $${PWD}/core/src/oned/ODDXFilmEdgeReader.cpp \
           $${PWD}/core/src/oned/ODITFReader.cpp \
           $${PWD}/core/src/oned/ODMultiUPCEANReader.cpp \
           $${PWD}/core/src/oned/ODReader.cpp

HEADERS += $${PWD}/core/src/oned/ODCodabarReader.h \
           $${PWD}/core/src/oned/ODCode39Reader.h \
           $${PWD}/core/src/oned/ODCode93Reader.h \
           $${PWD}/core/src/oned/ODCode128Reader.h \
           $${PWD}/core/src/oned/ODDataBarCommon.h \
           $${PWD}/core/src/oned/ODDataBarReader.h \
           $${PWD}/core/src/oned/ODDataBarExpandedBitDecoder.h \
           $${PWD}/core/src/oned/ODDataBarExpandedReader.h \
           $${PWD}/core/src/oned/ODDataBarLimitedReader.h \
           $${PWD}/core/src/oned/ODDXFilmEdgeReader.h \
           $${PWD}/core/src/oned/ODITFReader.h \
           $${PWD}/core/src/oned/ODMultiUPCEANReader.h \
           $${PWD}/core/src/oned/ODReader.h \
           $${PWD}/core/src/oned/ODRowReader.h
}

build_writers {
SOURCES += $${PWD}/core/src/oned/ODCodabarWriter.cpp \
           $${PWD}/core/src/oned/ODCode39Writer.cpp \
           $${PWD}/core/src/oned/ODCode93Writer.cpp \
           $${PWD}/core/src/oned/ODCode128Writer.cpp \
           $${PWD}/core/src/oned/ODEAN8Writer.cpp \
           $${PWD}/core/src/oned/ODEAN13Writer.cpp \
           $${PWD}/core/src/oned/ODITFWriter.cpp \
           $${PWD}/core/src/oned/ODUPCEWriter.cpp \
           $${PWD}/core/src/oned/ODUPCAWriter.cpp \
           $${PWD}/core/src/oned/ODWriterHelper.cpp

HEADERS += $${PWD}/core/src/oned/ODCodabarWriter.h \
           $${PWD}/core/src/oned/ODCode39Writer.h \
           $${PWD}/core/src/oned/ODCode93Writer.h \
           $${PWD}/core/src/oned/ODCode128Writer.h \
           $${PWD}/core/src/oned/ODEAN8Writer.h \
           $${PWD}/core/src/oned/ODEAN13Writer.h \
           $${PWD}/core/src/oned/ODITFWriter.h \
           $${PWD}/core/src/oned/ODUPCEWriter.h \
           $${PWD}/core/src/oned/ODUPCAWriter.h \
           $${PWD}/core/src/oned/ODWriterHelper.h
}

################# PDF417_FILES

build_readers {
SOURCES += $${PWD}/core/src/pdf417/PDFBarcodeValue.cpp \
           $${PWD}/core/src/pdf417/PDFBoundingBox.cpp \
           $${PWD}/core/src/pdf417/PDFCodewordDecoder.cpp \
           $${PWD}/core/src/pdf417/PDFDecoder.cpp \
           $${PWD}/core/src/pdf417/PDFDetectionResult.cpp \
           $${PWD}/core/src/pdf417/PDFDetectionResultColumn.cpp \
           $${PWD}/core/src/pdf417/PDFDetector.cpp \
           $${PWD}/core/src/pdf417/PDFModulusGF.cpp \
           $${PWD}/core/src/pdf417/PDFModulusPoly.cpp \
           $${PWD}/core/src/pdf417/PDFReader.cpp \
           $${PWD}/core/src/pdf417/PDFScanningDecoder.cpp \
           $${PWD}/core/src/pdf417/ZXBigInteger.cpp

HEADERS += $${PWD}/core/src/pdf417/CustomData.h \
           $${PWD}/core/src/pdf417/PDFBarcodeMetadata.h \
           $${PWD}/core/src/pdf417/PDFBarcodeValue.h \
           $${PWD}/core/src/pdf417/PDFBoundingBox.h \
           $${PWD}/core/src/pdf417/PDFCodeword.h \
           $${PWD}/core/src/pdf417/PDFCodewordDecoder.h \
           $${PWD}/core/src/pdf417/PDFDecoder.h \
           $${PWD}/core/src/pdf417/PDFDecoderResultExtra.h \
           $${PWD}/core/src/pdf417/PDFDetectionResult.h \
           $${PWD}/core/src/pdf417/PDFDetectionResultColumn.h \
           $${PWD}/core/src/pdf417/PDFDetector.h \
           $${PWD}/core/src/pdf417/PDFModulusGF.h \
           $${PWD}/core/src/pdf417/PDFModulusPoly.h \
           $${PWD}/core/src/pdf417/PDFReader.h \
           $${PWD}/core/src/pdf417/PDFScanningDecoder.h \
           $${PWD}/core/src/pdf417/ZXBigInteger.h \
           $${PWD}/core/src/pdf417/ZXNullable.h
}

build_writers {
SOURCES += $${PWD}/core/src/pdf417/PDFEncoder.cpp \
           $${PWD}/core/src/pdf417/PDFHighLevelEncoder.cpp \
           $${PWD}/core/src/pdf417/PDFWriter.cpp

HEADERS += $${PWD}/core/src/pdf417/PDFCompaction.h \
           $${PWD}/core/src/pdf417/PDFEncoder.h \
           $${PWD}/core/src/pdf417/PDFHighLevelEncoder.h \
           $${PWD}/core/src/pdf417/PDFWriter.h
}

################# QRCODE_FILES

SOURCES += $${PWD}/core/src/qrcode/QRCodecMode.cpp \
           $${PWD}/core/src/qrcode/QRErrorCorrectionLevel.cpp \
           $${PWD}/core/src/qrcode/QRVersion.cpp

HEADERS += $${PWD}/core/src/qrcode/QRCodecMode.h \
           $${PWD}/core/src/qrcode/QRErrorCorrectionLevel.h \
           $${PWD}/core/src/qrcode/QRVersion.h

build_readers {
SOURCES += $${PWD}/core/src/qrcode/QRBitMatrixParser.cpp \
           $${PWD}/core/src/qrcode/QRDataBlock.cpp \
           $${PWD}/core/src/qrcode/QRDecoder.cpp \
           $${PWD}/core/src/qrcode/QRDetector.cpp \
           $${PWD}/core/src/qrcode/QRFormatInformation.cpp \
           $${PWD}/core/src/qrcode/QRReader.cpp

HEADERS += $${PWD}/core/src/qrcode/QRBitMatrixParser.h \
           $${PWD}/core/src/qrcode/QRDataBlock.h \
           $${PWD}/core/src/qrcode/QRDataMask.h \
           $${PWD}/core/src/qrcode/QRDecoder.h \
           $${PWD}/core/src/qrcode/QRDetector.h \
           $${PWD}/core/src/qrcode/QRECB.h \
           $${PWD}/core/src/qrcode/QRFormatInformation.h \
           $${PWD}/core/src/qrcode/QRReader.h
}

build_writers {
SOURCES += $${PWD}/core/src/qrcode/QREncoder.cpp \
           $${PWD}/core/src/qrcode/QRMaskUtil.cpp \
           $${PWD}/core/src/qrcode/QRMatrixUtil.cpp \
           $${PWD}/core/src/qrcode/QRWriter.cpp

HEADERS += $${PWD}/core/src/qrcode/QREncoder.h \
           $${PWD}/core/src/qrcode/QREncodeResult.h \
           $${PWD}/core/src/qrcode/QRMaskUtil.h \
           $${PWD}/core/src/qrcode/QRMatrixUtil.h \
           $${PWD}/core/src/qrcode/QRWriter.h
}

################# LIBZUECI_FILES

SOURCES += $${PWD}/core/src/libzueci/zueci.c
HEADERS +=  $${PWD}/core/src/libzueci/zueci.h
