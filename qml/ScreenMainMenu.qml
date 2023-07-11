import QtQuick
import QtQuick.Controls

import ThemeEngine

Rectangle {
    id: screenMainMenu
    anchors.fill: parent

    color: Theme.colorBackground

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        appContent.state = "ScreenMainMenu"
    }

    ////////////////////////////////////////////////////////////////////////////
}
