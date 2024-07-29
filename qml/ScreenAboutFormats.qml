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

    enum SupportLevel {
        None,
        Supported,
        Incomplete
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: isDesktop ? Theme.componentMarginL : Theme.componentMargin
        anchors.rightMargin: isDesktop ? Theme.componentMarginL : Theme.componentMargin

        ////////

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
        ListModel {
            id: zint
            ListElement { type: "linear"; name: "UPC-A"; decode: 0; encode: 1; }
        }

        ////////

        ListView {
            anchors.fill: parent

            topMargin: Theme.componentMarginL
            bottomMargin: Theme.componentMarginL

            ////

            model: (settingsManager.backend_reader === "zxingcpp") ? zxingcpp : qzxing
            delegate: RowLayout {
                required property string name
                required property var decode
                required property var encode

                anchors.left: parent.left
                anchors.leftMargin: Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: 4
                height: 32

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
                        if (decode === ScreenAboutFormats.SupportLevel.Supported) return Theme.colorGreen
                        if (decode === ScreenAboutFormats.SupportLevel.Incomplete) return Theme.colorOrange
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
                        if (encode === ScreenAboutFormats.SupportLevel.Supported) return Theme.colorGreen
                        if (encode === ScreenAboutFormats.SupportLevel.Incomplete) return Theme.colorOrange
                        return Theme.colorBackground
                    }
                }
            }

            ////

            section.property: "type"
            section.criteria: ViewSection.FullString
            section.delegate: Item { // SECTION
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
                            Layout.preferredWidth: 64
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
                            Layout.preferredWidth: 64
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

            ////
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
