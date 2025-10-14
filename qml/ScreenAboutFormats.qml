import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary
import QmlMobileScanner

Flickable {
    id: screenAboutFormats

    anchors.fill: parent

    contentWidth: -1
    contentHeight: columnContent.height

    boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
    ScrollBar.vertical: ScrollBar { visible: false }

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

    enum SupportLevel {
        None,
        Supported,
        Incomplete
    }

    Column {
        id: columnContent

        anchors.left: parent.left
        anchors.leftMargin: isDesktop ? Theme.componentMarginL : Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: isDesktop ? Theme.componentMarginL : Theme.componentMargin

        ////////

        ListModel {
            id: qzxing
            property string name: "QZXing"
            property string version: "3.3.0"
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
            property string name: "zxing-cpp"
            property string version: "2.3.0"
            ListElement { type: "linear"; name: "UPC-A"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "UPC-E"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "EAN-8"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "EAN-13"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "DataBar"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "DataBar Expanded"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "DataBar Limited"; decode: 1; encode: 0; }
            ListElement { type: "linear"; name: "Code 39"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "Code 93"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "Code 128"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "Codabar"; decode: 1; encode: 1; }
            ListElement { type: "linear"; name: "ITF"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "QR Code"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "Micro QR Code"; decode: 1; encode: 0; }
            ListElement { type: "matrix"; name: "Aztec"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "Aztec Runes"; decode: 1; encode: 0; }
            ListElement { type: "matrix"; name: "Data Matrix"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "DX Film Edge"; decode: 1; encode: 0; }
            ListElement { type: "matrix"; name: "PDF 417"; decode: 1; encode: 1; }
            ListElement { type: "matrix"; name: "MaxiCode"; decode: 2; encode: 0; }
        }
        ListModel {
            id: zint
            property string name: "zint"
            property string version: "2.15"
            ListElement { type: "linear"; name: "Channel Code"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Codabar"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Code 11"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Code 128"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Code 2 of 5 (many variants)"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Code 32 (Italian pharmacode)"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Code 3 of 9 (Code 39)"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Code 3 of 9 Extended (Code 39 Extended)"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Code 93"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Code One"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "EAN-13"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "EAN-8"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "GS1 DataBar"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "GS1 DataBar Stacked"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "GS1 DataBar Expanded"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "GS1 DataBar Expanded Stacked"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "GS1 DataBar Limited"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Japan Post"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Korea Post"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "LOGMARS"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "MSI (Modified Plessey)"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Pharmacode"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Pharmacode Two-Track"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Pharmazentralnummer"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "Telepen"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "UPC-A"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "UPC-E"; decode: 0; encode: 1; }
            ListElement { type: "linear"; name: "UPNQR"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "Australia Post (many variants)"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "Codablock F"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "Code 16k"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "Code 49"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "Dutch Post KIX Code"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "POSTNET / PLANET"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "Royal Mail 4-State (RM4SCC)"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "Royal Mail 4-State Mailmark"; decode: 0; encode: 1; }
            ListElement { type: "2d"; name: "USPS OneCode (Intelligent Mail)"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "Aztec Code"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "Aztec Runes"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "Data Matrix ECC200"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "DotCode"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "Grid Matrix"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "Han Xin"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "MaxiCode"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "Micro PDF417"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "PDF417 Truncated"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "PDF417"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "QR Code"; decode: 0; encode: 1; }
            ListElement { type: "matrix"; name: "rMQR"; decode: 0; encode: 1; }
        }

        ////////

        ListView {
            anchors.left: parent.left
            anchors.leftMargin: screenPaddingLeft
            anchors.right: parent.right
            anchors.rightMargin: screenPaddingRight

            topMargin: Theme.componentMarginL
            bottomMargin: Theme.componentMarginL

            height: count * 32 + 3*48 + Theme.componentMarginL
            interactive: false

            ////

            header: GridHeader {
                textTitle: (settingsManager.backend_reader === "zxingcpp") ? zxingcpp.name : qzxing.name
                textVersion: qsTr("version %1").arg((settingsManager.backend_reader === "zxingcpp") ? zxingcpp.version : qzxing.version)
            }

            ////

            model: (settingsManager.backend_reader === "zxingcpp") ? zxingcpp : qzxing
            delegate: GridDelegate {
                //
            }

            ////

            section.property: "type"
            section.criteria: ViewSection.FullString
            section.delegate: GridSection {
                //
            }

            ////
        }

        ////////

        ListView {
            anchors.left: parent.left
            anchors.leftMargin: screenPaddingLeft
            anchors.right: parent.right
            anchors.rightMargin: screenPaddingRight

            topMargin: Theme.componentMarginL
            bottomMargin: Theme.componentMarginL

            height: count * 32 + 3*48 + Theme.componentMarginL
            interactive: false

            ////

            header: GridHeader {
                textTitle: zint.name
                textVersion: qsTr("version %1").arg(zint.version)
            }

            ////

            model: zint
            delegate: GridDelegate {
                //
            }

            ////

            section.property: ""
            section.criteria: ViewSection.FullString
            section.delegate: GridSection {
                //
            }

            ////
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////

    component GridHeader: Item {
        width: ListView.view.width
        height: 48

        required property string textTitle
        required property string textVersion

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.bottomMargin: 4

            radius: 4
            color: Theme.colorForeground

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.componentMargin
                anchors.rightMargin: 4
                height: 32

                Text {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 128
                    Layout.preferredHeight: 32

                    text: textTitle
                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContent
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle {
                    Layout.preferredWidth: 128
                    Layout.preferredHeight: 28
                    Layout.margins: 2
                    radius: 4
                    color: Qt.darker(Theme.colorForeground, 1.02)

                    Text {
                        anchors.centerIn: parent
                        text: textVersion
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContentSmall
                    }
                }
            }
        }
    }

    ////////

    component GridDelegate: RowLayout {
        width: ListView.view.width
        height: 32

        anchors.left: parent.left
        anchors.leftMargin: Theme.componentMargin
        anchors.right: parent.right
        anchors.rightMargin: 4

        required property string name
        required property var decode
        required property var encode

        Text {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 128

            text: name
            textFormat: Text.PlainText
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeContent
            wrapMode: Text.Wrap
            lineHeight: 0.72
            color: Theme.colorText
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: singleColumn ? 48 : 64
            Layout.margins: 2
            radius: 4

            color: {
                if (parent.decode === ScreenAboutFormats.SupportLevel.Supported) return Theme.colorGreen
                if (parent.decode === ScreenAboutFormats.SupportLevel.Incomplete) return Theme.colorOrange
                return Theme.colorBackground
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: singleColumn ? 48 : 64
            Layout.margins: 2
            radius: 4

            color: {
                if (parent.encode === ScreenAboutFormats.SupportLevel.Supported) return Theme.colorGreen
                if (parent.encode === ScreenAboutFormats.SupportLevel.Incomplete) return Theme.colorOrange
                return Theme.colorBackground
            }
        }
    }

    ////////

    component GridSection: Item {
        width: ListView.view.width
        height: 48

        required property string section

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.bottomMargin: 4

            radius: 4
            color: Theme.colorForeground

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.componentMargin
                anchors.rightMargin: 4
                height: 32

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 128

                    text: section
                    textFormat: Text.PlainText
                    color: Theme.colorText
                    font.bold: true
                    font.pixelSize: Theme.fontSizeContent
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: singleColumn ? 48 : 64
                    Layout.preferredHeight: 28
                    Layout.margins: 2
                    radius: 4
                    color: Qt.darker(Theme.colorForeground, 1.02)

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("read")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContentSmall
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: singleColumn ? 48 : 64
                    Layout.preferredHeight: 28
                    Layout.margins: 2
                    radius: 4
                    color: Qt.darker(Theme.colorForeground, 1.02)

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("write")
                        textFormat: Text.PlainText
                        color: Theme.colorSubText
                        font.pixelSize: Theme.fontSizeContentSmall
                    }
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
