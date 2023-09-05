import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Popup {
    id: popupCertificate
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

    property string barcode

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

        source: "qrc:/assets/icons_material/baseline-arrow_back-24px.svg"
        sourceSize: 28
        iconColor: Theme.colorHeaderContent

        onClicked: popupCertificate.close()
    }

    ////////

    Image {
        anchors.centerIn: parent

        width: parent.width - 64
        height: width
        sourceSize.width: width
        sourceSize.height: width

        source: "image://QZXing/encode/" + popupCertificate.barcode
        cache: false
    }

    ////////
}