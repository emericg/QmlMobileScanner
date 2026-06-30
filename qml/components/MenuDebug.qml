import QtQuick
import QtQuick.Controls

import ComponentLibrary

Column {
    id: debugCol
    anchors.top: toprightmenus.bottom
    anchors.topMargin: Theme.componentMargin
    anchors.right: toprightmenus.right

    width: Theme.singleColumn ? screenBarcodeReader.width - Theme.componentMargin*2 : 300
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

        SwitchThemed {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("fullscreen")
            colorText: "white"
            colorSubText: "grey"
            checked: SettingsManager.scan_fullscreen
            onClicked: SettingsManager.scan_fullscreen = checked
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

        SwitchThemed {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("tryHarder")
            colorText: "white"
            colorSubText: "grey"
            checked: SettingsManager.scan_tryHarder
            onClicked: SettingsManager.scan_tryHarder = checked
        }
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        visible: (SettingsManager.backend_reader === "zxingcpp")

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "black"
            opacity: 0.33
        }

        SwitchThemed {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("tryRotate")
            colorText: "white"
            colorSubText: "grey"
            checked: SettingsManager.scan_tryRotate
            onClicked: SettingsManager.scan_tryRotate = checked
        }
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        visible: (SettingsManager.backend_reader === "zxingcpp")

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "black"
            opacity: 0.33
        }

        SwitchThemed {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("tryInvert")
            colorText: "white"
            colorSubText: "grey"
            checked: SettingsManager.scan_tryInvert
            onClicked: SettingsManager.scan_tryInvert = checked
        }
    }
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40

        visible: (SettingsManager.backend_reader === "zxingcpp")

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "black"
            opacity: 0.33
        }

        SwitchThemed {
            anchors.centerIn: parent
            width: parent.width - 16
            LayoutMirroring.enabled: true

            text: qsTr("tryDownscale")
            colorText: "white"
            colorSubText: "grey"
            checked: SettingsManager.scan_tryDownscale
            onClicked: SettingsManager.scan_tryDownscale = checked
        }
    }
}
