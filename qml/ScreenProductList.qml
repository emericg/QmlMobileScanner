import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Item {
    id: screenProductList
    width: 480
    height: 720
    anchors.fill: parent
    anchors.leftMargin: screenPaddingLeft
    anchors.rightMargin: screenPaddingRight

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        productsManager.loadProductsList()
        appContent.state = "ScreenProductList"
    }
    function reloadScreen() {
        appContent.state = "ScreenProductList"
    }

    function backAction() {
        if (appContent.state !== "ScreenProductList") return
        appContent.state = "ScreenMainMenu"
    }

    ////////////////////////////////////////////////////////////////////////////

    IconSvg {
        width: 128
        height: 128
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -(appHeader.headerHeight / 2)

        visible: (productsManager.productListCount <= 0)
        color: Theme.colorIcon
        source: "qrc:/assets/icons_material/baseline-search-24px.svg"

        Text {
            anchors.top: parent.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Pas de produit !"
            textFormat: Text.PlainText
            font.pixelSize: Theme.fontSizeContent
            color: Theme.colorText
        }
    }

    ListView {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0

        topMargin: 0
        bottomMargin: 96
        spacing: 0

        model: productsManager.productsList
        delegate: WidgetProduct {}
    }

    ////////////////////////////////////////////////////////////////////////////
}
