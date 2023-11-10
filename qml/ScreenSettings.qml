import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import ThemeEngine
import "qrc:/js/UtilsNumber.js" as UtilsNumber

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
            screenBarcodeReader.loadScreen()
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
                anchors.right: parent.right

                topPadding: 20
                bottomPadding: 20
                spacing: 8

                property int padIcon: singleColumn ? Theme.componentMarginL : Theme.componentMarginL
                property int padText: appHeader.headerPosition
                property int padMargin: singleColumn ? 0 : Theme.componentMargin

                ////////////////

                ListTitle {
                    text: qsTr("Application")
                    icon: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                }

                ////////////////

                Item {
                    id: element_appTheme
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 48

                    IconSvg {
                        id: image_appTheme
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-style-24px.svg"
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
                            color: (Theme.currentTheme === ThemeEngine.THEME_LIGHT) ? Theme.colorForeground : "#dddddd"
                            border.color: Theme.colorSecondary
                            border.width: (settingsManager.appTheme === "light") ? 2 : 0

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    settingsManager.appTheme = "light"
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: qsTr("light")
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
                            color: (Theme.currentTheme === ThemeEngine.THEME_DARK) ? Theme.colorForeground : "#313236"
                            border.color: Theme.colorSecondary
                            border.width: (settingsManager.appTheme === "dark") ? 2 : 0

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    settingsManager.appTheme = "dark"
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter

                                text: qsTr("dark")
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
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 48

                    IconSvg {
                        id: image_appThemeAuto
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-brightness_4-24px.svg"
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
                        anchors.rightMargin: 0
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
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin + 64
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
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 48

                    Item {
                        width: 56
                        height: 48

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/assets/icons_material/baseline-stars-24px.svg"
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 64
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Default tab")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SelectorMenu {
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

                ////////////////

                ListTitle {
                    text: qsTr("Scanner")
                    icon: "qrc:/assets/icons_material/duotone-qr_code_2-24px.svg"
                }

                ////////////////

                Item {
                    id: element_showDebug
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 48

                    IconSvg {
                        id: image_showDebug
                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        color: Theme.colorIcon
                        source: "qrc:/assets/icons_material/duotone-bug_report-24px.svg"
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
                        anchors.rightMargin: 0
                        anchors.verticalCenter: parent.verticalCenter
                        z: 1

                        checked: settingsManager.showDebug
                        onClicked: settingsManager.showDebug = checked
                    }
                }

                ////////

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/assets/icons_material/duotone-qr_code_2-24px.svg"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        text: qsTr("Fullscreen scan")
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.fontSizeContent
                        color: Theme.colorText
                        wrapMode: Text.WordWrap
                    }

                    SwitchThemed {
                        Layout.alignment: Qt.AlignVCenter
                        z: 1

                        checked: settingsManager.scan_fullscreen
                        onClicked: settingsManager.scan_fullscreen = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/assets/icons_material/duotone-qr_code_2-24px.svg"
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
                        z: 1

                        checked: settingsManager.scan_tryHarder
                        onClicked: settingsManager.scan_tryHarder = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/assets/icons_material/duotone-qr_code_2-24px.svg"
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
                        z: 1

                        checked: settingsManager.scan_tryRotate
                        onClicked: settingsManager.scan_tryRotate = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/assets/icons_material/duotone-qr_code_2-24px.svg"
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
                        z: 1

                        checked: settingsManager.scan_tryInvert
                        onClicked: settingsManager.scan_tryInvert = checked
                    }
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft + contentColumn.padMargin
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight + contentColumn.padMargin
                    height: 36

                    visible: settingsManager.showDebug

                    Item {
                        Layout.preferredWidth: 56

                        IconSvg {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            color: Theme.colorIcon
                            source: "qrc:/assets/icons_material/duotone-qr_code_2-24px.svg"
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
