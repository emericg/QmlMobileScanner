import QtQuick 2.15

import ThemeEngine 1.0

Rectangle {
    id: control
    implicitWidth: 56
    implicitHeight: 24

    width: contentText.contentWidth + 8
    radius: Theme.componentRadius
    color: Theme.colorForeground

    // settings
    property string text: "TAG"
    property string textColor: Theme.colorText
    property int textSize: Theme.componentFontSize
    property int textCapitalization: Font.Normal
    property bool textBold: false

    Text {
        id: contentText
        anchors.centerIn: parent

        text: control.text
        textFormat: Text.PlainText

        color: control.textColor
        font.bold: control.textBold
        font.pixelSize: control.textSize
        font.capitalization: control.textCapitalization
    }
}
