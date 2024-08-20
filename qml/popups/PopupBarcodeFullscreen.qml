import QtQuick
import QtQuick.Controls

import ThemeEngine

Popup {
    id: popupBarcodeFullscreen
    x: 0
    y: 0

    width: appWindow.width
    height: appWindow.height
    margins: 0
    padding: 0

    dim: false
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay

    property string barcode_string

    ////////

    background: Rectangle {
        anchors.fill: parent
        color: "white"
    }

    ////////

    RoundButtonIcon {
        anchors.top: parent.top
        anchors.topMargin: screenPaddingStatusbar
        anchors.left: parent.left
        anchors.leftMargin: 4

        width: appHeader.headerHeight
        height: appHeader.headerHeight

        source: "qrc:/assets/icons/material-symbols/arrow_back.svg"
        sourceSize: 28
        iconColor: Theme.colorHeaderContent

        onClicked: popupBarcodeFullscreen.close()
    }

    ////////

    Image {
        anchors.centerIn: parent

        width: parent.width - 64 - screenPaddingLeft - screenPaddingRight
        height: width

        cache: false
        sourceSize.width: width
        sourceSize.height: width
        fillMode: Image.PreserveAspectFit

        source: popupBarcodeFullscreen.barcode_string
    }

    ////////
}
