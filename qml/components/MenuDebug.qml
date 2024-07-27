import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0

Column {
    id: debugCol
    anchors.top: toprightmenus.bottom
    anchors.topMargin: Theme.componentMargin
    anchors.right: toprightmenus.right

    width: singleColumn ? screenBarcodeReader.width - Theme.componentMargin*2 : 300
    spacing: Theme.componentMargin / 2
    visible: false

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "black"
            opacity: 0.33
        }

        SwitchThemedDesktop {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("fullscreen")
            colorText: "white"
            colorSubText: "grey"
            checked: settingsManager.scan_fullscreen
            onClicked: settingsManager.scan_fullscreen = checked
        }
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "black"
            opacity: 0.33
        }

        SwitchThemedDesktop {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("tryHarder")
            colorText: "white"
            colorSubText: "grey"
            checked: settingsManager.scan_tryHarder
            onClicked: settingsManager.scan_tryHarder = checked
        }
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        visible: (settingsManager.backend_reader === "zxingcpp")

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "black"
            opacity: 0.33
        }

        SwitchThemedDesktop {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("tryRotate")
            colorText: "white"
            colorSubText: "grey"
            checked: settingsManager.scan_tryRotate
            onClicked: settingsManager.scan_tryRotate = checked
        }
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        visible: (settingsManager.backend_reader === "zxingcpp")

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "black"
            opacity: 0.33
        }

        SwitchThemedDesktop {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("tryInvert")
            colorText: "white"
            colorSubText: "grey"
            checked: settingsManager.scan_tryInvert
            onClicked: settingsManager.scan_tryInvert = checked
        }
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        visible: (settingsManager.backend_reader === "zxingcpp")

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "black"
            opacity: 0.33
        }

        SwitchThemedDesktop {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("tryDownscale")
            colorText: "white"
            colorSubText: "grey"
            checked: settingsManager.scan_tryDownscale
            onClicked: settingsManager.scan_tryDownscale = checked
        }
    }
}
