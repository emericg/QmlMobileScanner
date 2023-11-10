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
        if (screenBarcodeHistory.status === Loader.Ready)
            screenBarcodeHistory.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 233 } }

    sourceComponent: Item {
        anchors.fill: parent
        anchors.margins: 0

        function backAction() {
            if (stackView.depth > 1) {
                stackView.pop()
                return
            }

            screenBarcodeReader.loadScreen()
        }

        ////////

        StackView {
            id: stackView
            anchors.fill: parent

            initialItem: mainView
        }

        ////////

        Component {
            id: mainView

            ListView {
                model: barcodeManager.barcodesHistory
                delegate: WidgetBarcodeHistory {
                    width: parent.width
                    onClicked: {
                        stackView.push(detailsView)
                        stackView.get(1).loadBarcode(modelData)
                    }
                }
            }
        }

        Component {
            id: detailsView

            ScreenBarcodeDetails {
                anchors.fill: undefined
            }
        }

        ////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
