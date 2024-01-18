import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine

Item {
    id: screenAboutFormats
    anchors.fill: parent

    property string entryPoint: "ScreenAbout"

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // change screen
        appContent.state = "ScreenAboutFormats"
    }

    function loadScreenFrom(screenname) {
        entryPoint = screenname
        loadScreen()
    }

    function backAction() {
        screenAbout.loadScreen()
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        anchors.fill: parent
        anchors.margins: Theme.componentMarginL

        ////////

        enum SupportLevel {
            None,
            Supported,
            Incomplete
        }

        ListModel {
            id: qzxing
            ListElement { type: "linear"; name: "UPC-A"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "UPC-E"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "EAN-8"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "EAN-13"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "Code 39"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "Code 93"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "Code 128 (GS1)"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "ITF"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "Codabar"; decode: 1; encode: 0; }
            ListElement { type: "matrix"; name: "QR Code"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "Data Matrix"; decode: 1; encode: 0; }
            ListElement { type: "matrix"; name: "Aztec"; decode: 1; encode: 0; }
            ListElement { type: "matrix"; name: "PDF 417"; decode: 1; encode: 0; }
        }
        ListModel {
            id: zxingcpp
            ListElement { type: "linear"; name: "UPC-A"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "UPC-E"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "EAN-8"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "EAN-13"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "DataBar"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "DataBar Expanded"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "Code 39"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "Code 93"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "Code 128"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "Codabar"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "ITF"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "QR Code"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "Micro QR Code"; decode: 1; encode: 0; }
            ListElement { type: "matrix"; name: "Aztec"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "Data Matrix"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "PDF 417"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "MaxiCode"; decode: 2; encode: 0; }
        }

        ////////

        ListView {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width

            model: (settingsManager.backend_reader === "zxingcpp") ? zxingcpp : qzxing
            delegate: RowLayout {
                required property string name
                required property var decode
                required property var encode

                height: 32
                width: parent.width

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 128

                    text: name
                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeContent
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64
                    Layout.margins: 2
                    radius: 4

                    color: {
                        if (decode === 1) return Theme.colorGreen
                        if (decode === 2) return Theme.colorOrange
                        return Theme.colorBackground
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64
                    Layout.margins: 2
                    radius: 4

                    color: {
                        if (encode === 1) return Theme.colorGreen
                        if (encode === 2) return Theme.colorOrange
                        return Theme.colorBackground
                    }
                }
            }

            section.property: "type"
            section.criteria: ViewSection.FullString
            section.delegate: Item {
                width: ListView.view.width
                height: 48

                required property string section

                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.bottomMargin: 4

                    radius: 4
                    color: Theme.colorForeground

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        text: section
                        color: Theme.colorText
                        font.bold: true
                        font.pixelSize: Theme.fontSizeContent
                        font.capitalization: Font.Capitalize
                    }
                }
            }
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
