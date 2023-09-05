import QtQuick
import QtQuick.Controls

import ThemeEngine 1.0
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

        Flickable {
            anchors.fill: parent

            contentWidth: -1
            contentHeight: column.height

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right

                topPadding: 12
                bottomPadding: 12
                spacing: 8

                ////////////////

                SectionTitle {
                    anchors.left: parent.left
                    text: qsTr("Application")
                    source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                }

                ////////////////

                Item {
                    id: element_appTheme
                    height: 48
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

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
                        height: 40
                        anchors.left: image_appTheme.right
                        anchors.leftMargin: 24
                        anchors.right: appTheme_selector.left
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        text: qsTr("Thème")
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

                                text: qsTr("claire")
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

                                text: qsTr("sombre")
                                color: "#ddd"
                                font.pixelSize: Theme.fontSizeContentSmall
                            }
                        }
                    }
                }

                ////////

                Item {
                    id: element_appThemeAuto
                    height: 48
                    anchors.left: parent.left
                    anchors.leftMargin: screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: screenPaddingRight

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

                        text: qsTr("Mode sombre automatique")
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
                    anchors.leftMargin: screenPaddingLeft + 64
                    anchors.right: parent.right
                    anchors.rightMargin: 12

                    topPadding: -12
                    bottomPadding: 0
                    visible: element_appThemeAuto.visible

                    text: settingsManager.appThemeAuto ?
                              qsTr("Le mode sombre s'activera automatiquement entre 21h et 8h.") :
                              qsTr("Le mode sombre automatique est désactivé.")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContentSmall
                }
            }

            ////////////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////

}