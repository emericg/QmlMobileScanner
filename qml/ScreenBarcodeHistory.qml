import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine

Loader {
    id: screenBarcodeHistory
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load screen
        screenBarcodeHistory.active = true

        // change screen
        appContent.state = "ScreenBarcodeHistory"
    }

    function backAction() {
        screenBarcodeHistory.loadScreen()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 233 } }

    sourceComponent: Item {
        anchors.fill: parent
        anchors.margins: 0

        ////////

        ListView {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width

            model: barcodeManager.barcodesHistory
            delegate: WidgetBarcode {
                //
            }
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
