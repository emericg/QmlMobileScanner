import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine

Item {
    id: screenBarcodeHistory
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // change screen
        appContent.state = "ScreenBarcodeHistory"
    }

    function backAction() {
        screenBarcodeHistory.loadScreen()
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
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
