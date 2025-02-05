import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ComponentLibrary
import QmlMobileScanner

Loader {
    id: screenSettings
    anchors.fill: parent

    function loadScreen() {
        // load screen
        screenSettings.active = true

        // change screen
        appContent.state = "ScreenSettings"
    }

    function backAction() {
        if (screenSettings.status === Loader.Ready)
            screenSettings.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Item {
        anchors.fill: parent

        function backAction() {
            appWindow.backAction_default()
        }

        Flickable {
            anchors.fill: parent

            contentWidth: -1
            contentHeight: contentColumn.height

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight

                topPadding: 20
                bottomPadding: 20
                spacing: 8

                property int padIcon: singleColumn ? Theme.componentMarginL : Theme.componentMarginL
                property int padText: appHeader.headerPosition
                property int padMargin: singleColumn ? 0 : Theme.componentMargin

                ////////////////

                ListTitle {
                    text: qsTr("User interface")
                    source: "qrc:/IconLibrary/material-symbols/settings.svg"
                }

                ////////////////

                Item {
                    id: element_appTheme
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    IconSvg {
                        id: image_appTheme
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/style.svg"
                    }

                    Text {
                        id: text_appTheme
                        anchors.left: image_appTheme.right
                        anchors.leftMargin: 24
                        anchors.right: appTheme_selector.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        height: 40

                        text: qsTr("Theme")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }

                    Row {
                        id: appTheme_selector
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        z: 1
                        spacing: 10

                        Rectangle {
                            id: rectangleLight
                            width: 64
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: (Theme.currentTheme === Theme.THEME_MOBILE_LIGHT) ? Theme.colorForeground : "#dddddd"
                            border.color: Theme.colorSecondary
                            border.width: (settingsManager.appTheme === "THEME_MOBILE_LIGHT") ? 2 : 0

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    settingsManager.appTheme = "THEME_MOBILE_LIGHT"
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: qsTr("light")
                                textFormat: Text.PlainText
                                color: "#313236"
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                        }

                        Rectangle {
                            id: rectangleDark
                            width: 64
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            radius: 2
                            color: (Theme.currentTheme === Theme.THEME_MOBILE_DARK) ? Theme.colorForeground : "#313236"
                            border.color: Theme.colorSecondary
                            border.width: (settingsManager.appTheme === "THEME_MOBILE_DARK") ? 2 : 0

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    settingsManager.appTheme = "THEME_MOBILE_DARK"
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("dark")
                                textFormat: Text.PlainText
                                color: "#ddd"
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                        }
                    }
                }

                ////////

                Item {
                    id: element_appThemeAuto
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    IconSvg {
                        id: image_appThemeAuto
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/brightness_4.svg"
                    }

                    Text {
                        id: text_appThemeAuto
                        height: 40
                        anchors.left: image_appThemeAuto.right
                        anchors.leftMargin: 24
                        anchors.right: switch_appThemeAuto.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Automatic dark mode")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }

                    SwitchThemed {
                        id: switch_appThemeAuto
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.appThemeAuto
                        onClicked: {
                            settingsManager.appThemeAuto = checked
                            Theme.loadTheme(settingsManager.appTheme)
                        }
                    }
                }
                Text {
                    id: legend_appThemeAuto
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin + 64
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    topPadding: -12
                    bottomPadding: 0
                    visible: element_appThemeAuto.visible

                    text: settingsManager.appThemeAuto ?
                              qsTr("Dark mode will switch on automatically between 9 PM and 9 AM.") :
                              qsTr("Dark mode schedule is disabled.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }

                ////////

                Item {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    Item {
                        width: 56
                        height: 48

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-symbols/stars-fill.svg"
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.right: menuDefTab.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Default tab")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SelectorMenuColorful {
                        id: menuDefTab
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        model: ListModel {
                            ListElement { idx: 1; txt: "Reader"; src: ""; sz: 0; }
                            ListElement { idx: 2; txt: "Writer"; src: ""; sz: 0; }
                        }
                        currentSelection: {
                            if (settingsManager.defaultTab === "writer") return 2
                            return 1
                        }

                        onMenuSelected: (index) => {
                            console.log("SelectorMenu clicked #" + index)
                            currentSelection = index

                            if (index === 1) settingsManager.defaultTab = "reader"
                            else if (index === 2) settingsManager.defaultTab = "writer"
                        }
                    }
                }

                Item {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    Item {
                        width: 56
                        height: 48

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-symbols/stars-fill.svg"
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.right: menuDefReader.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Default reader")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SelectorMenuColorful {
                        id: menuDefReader
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1
                        enabled: false

                        model: ListModel {
                            ListElement { idx: 1; txt: "qzxing"; src: ""; sz: 0; }
                            ListElement { idx: 2; txt: "zxingcpp"; src: ""; sz: 0; }
                        }
                        currentSelection: {
                            if (settingsManager.backend_reader === "qzxing") return 1
                            if (settingsManager.backend_reader === "zxingcpp") return 2
                            return 0
                        }
                    }
                }

                Item {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    Item {
                        width: 56
                        height: 48

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-symbols/stars-fill.svg"
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.right: menuDefWriter.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Default writer")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SelectorMenuColorful {
                        id: menuDefWriter
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        model: ListModel {
                            ListElement { idx: 1; txt: "qzxing"; src: ""; sz: 0; }
                            ListElement { idx: 2; txt: "zxingcpp"; src: ""; sz: 0; }
                            ListElement { idx: 3; txt: "zint"; src: ""; sz: 0; }
                        }
                        currentSelection: {
                            if (settingsManager.backend_writer === "qzxing") return 1
                            if (settingsManager.backend_writer === "zxingcpp") return 2
                            if (settingsManager.backend_writer === "zint") return 3
                            return 3
                        }

                        onMenuSelected: (index) => {
                            console.log("SelectorMenu clicked #" + index)
                            currentSelection = index

                            if (index === 1) settingsManager.backend_writer = "qzxing"
                            else if (index === 2) settingsManager.backend_writer = "zxingcpp"
                            else if (index === 3) settingsManager.backend_writer = "zint"
                        }
                    }
                }

                ////////////////

                ListTitle {
                    text: qsTr("Scanner")
                    source: "qrc:/IconLibrary/material-icons/duotone/qr_code_2.svg"
                }

                ////////////////

                RowLayout { // save barcodes
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-symbols/save.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Save barcode automatically")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: settingsManager.save_barcodes
                        onClicked: settingsManager.save_barcodes = checked
                    }
                }

                RowLayout { // save camera
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    enabled: false

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-icons/duotone/camera.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Save camera picture")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: settingsManager.save_camera
                        onClicked: settingsManager.save_camera = checked
                    }
                }

                RowLayout { // save GPS position
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-icons/duotone/pin_drop.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Save GPS position")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: {
                            if (!utilsApp.checkMobileLocationPermission()) return false
                            if (settingsManager.save_gps) return true
                            return false
                        }
                        onClicked: {
                            utilsApp.getMobileLocationPermission()
                            settingsManager.save_gps = checked
                        }
                    }
                }

                ////////////////

                ListTitle {
                    text: qsTr("Debug")
                    source: "qrc:/IconLibrary/material-icons/duotone/bug_report.svg"
                }

                ////////////////

                Item {
                    id: element_showDebug
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 48

                    IconSvg {
                        id: image_showDebug
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        source: "qrc:/IconLibrary/material-icons/duotone/bug_report.svg"
                    }

                    Text {
                        id: text_showDebug
                        height: 40
                        anchors.left: image_showDebug.right
                        anchors.leftMargin: 24
                        anchors.right: switch_showDebug.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Show debug info")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                    }

                    SwitchThemed {
                        id: switch_showDebug
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.showDebug
                        onClicked: settingsManager.showDebug = checked
                    }
                }

                ////////

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-icons/duotone/qr_code_2.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Full resolution scan")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: settingsManager.scan_fullres
                        onClicked: settingsManager.scan_fullres = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-icons/duotone/qr_code_2.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Full screen scan")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: settingsManager.scan_fullscreen
                        onClicked: settingsManager.scan_fullscreen = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-icons/duotone/qr_code_2.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Try harder")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: settingsManager.scan_tryHarder
                        onClicked: settingsManager.scan_tryHarder = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-icons/duotone/qr_code_2.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Try rotate")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: settingsManager.scan_tryRotate
                        onClicked: settingsManager.scan_tryRotate = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-icons/duotone/qr_code_2.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Try invert")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: settingsManager.scan_tryInvert
                        onClicked: settingsManager.scan_tryInvert = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/IconLibrary/material-icons/duotone/qr_code_2.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Try downscale")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 12
                        z: 1

                        checked: settingsManager.scan_tryDownscale
                        onClicked: settingsManager.scan_tryDownscale = checked
                    }
                }

                ////////
            }

            ////////////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////

}
