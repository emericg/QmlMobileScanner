import QtQuick
import QtQuick.Controls

import ThemeEngine

Loader {
    id: screenAbout
    anchors.fill: parent

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // load screen
        screenAbout.active = true

        // change screen
        appContent.state = "ScreenAbout"
    }

    function backAction() {
        if (screenAbout.status === Loader.Ready)
            screenAbout.item.backAction()
    }

    ////////////////////////////////////////////////////////////////////////////

    active: false
    asynchronous: true

    sourceComponent: Flickable {
        anchors.fill: parent
        contentWidth: -1
        contentHeight: columnContent.height

        boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar { visible: false }

        function backAction() {
            screenBarcodeReader.loadScreen()
        }

        Column {
            id: columnContent
            anchors.left: parent.left
            anchors.right: parent.right

            ////////////////

            Rectangle { // header area
                anchors.left: parent.left
                anchors.right: parent.right

                height: 96
                color: Theme.colorForeground

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.verticalCenter: parent.verticalCenter

                    z: 2
                    height: 96
                    spacing: Theme.componentMargin

                    IconSvg { // logo
                        anchors.verticalCenter: parent.verticalCenter
                        width: 64
                        height: 64

                        color: Theme.colorIcon
                        source: "qrc:/assets/logos/logo_black.svg"
                        //sourceSize: Qt.size(width, height)
                    }

                    Column { // title
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -1

                        Text {
                            text: "MobileScanner"
                            color: Theme.colorText
                            font.pixelSize: Theme.fontSizeTitle
                        }
                        Text {
                            text: qsTr("version %1 %2").arg(utilsApp.appVersion()).arg(utilsApp.appBuildMode())
                            color: Theme.colorSubText
                            font.pixelSize: Theme.fontSizeContentBig
                        }
                    }
                }

                ////////

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
                    anchors.verticalCenter: parent.verticalCenter

                    visible: wideMode
                    spacing: Theme.componentMargin

                    ButtonWireframeIconCentered {
                        width: 160

                        text: qsTr("WEBSITE")
                        source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                        sourceSize: 28
                        fullColor: true
                        primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://emeric.io/MobileScanner")
                    }

                    ButtonWireframeIconCentered {
                        width: 160

                        text: qsTr("SUPPORT")
                        source: "qrc:/assets/icons_material/baseline-support-24px.svg"
                        sourceSize: 22
                        fullColor: true
                        primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://emeric.io/MobileScanner/support.html")
                    }

                    ButtonWireframeIconCentered {
                        width: 160
                        visible: (appWindow.width > 800)

                        text: qsTr("GitHub")
                        source: "qrc:/assets/logos/github.svg"
                        sourceSize: 22
                        fullColor: true
                        primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://github.com/emericg/MobileScanner")
                    }
                }

                Rectangle { // bottom separator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 2
                    visible: isDesktop
                    border.color: Theme.colorSeparator
                }
            }

            ////////////////

            Row { // buttons row
                height: 72

                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight + Theme.componentMargin

                visible: !wideMode
                spacing: Theme.componentMargin

                ButtonWireframeIconCentered {
                    anchors.verticalCenter: parent.verticalCenter
                    width: ((parent.width - parent.spacing) / 2)

                    text: qsTr("WEBSITE")
                    source: "qrc:/assets/icons_material/baseline-insert_link-24px.svg"
                    sourceSize: 28
                    fullColor: true
                    primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    onClicked: Qt.openUrlExternally("https://emeric.io/MobileScanner")
                }
                ButtonWireframeIconCentered {
                    anchors.verticalCenter: parent.verticalCenter
                    width: ((parent.width - parent.spacing) / 2)

                    text: qsTr("SUPPORT")
                    source: "qrc:/assets/icons_material/baseline-support-24px.svg"
                    sourceSize: 22
                    fullColor: true
                    primaryColor: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    onClicked: Qt.openUrlExternally("https://emeric.io/MobileScanner/support.html")
                }
            }

            Item { width: 12; height: 12; visible: wideMode; } // spacer

            ////////////////

            ListItem { // description
                width: parent.width
                text: qsTr("Demo barcode & qrcode scanner based on qzxing and zxing-cpp libraries.")
                iconSource: "qrc:/assets/icons_material/outline-info-24px.svg"
            }

            ListItemClickable { // authors
                width: parent.width

                text: qsTr("Application by <a href=\"https://emeric.io\">Emeric Grange</a>")
                iconSource: "qrc:/assets/icons_material/baseline-supervised_user_circle-24px.svg"
                indicatorSource: "qrc:/assets/icons_material/duotone-launch-24px.svg"

                onClicked: Qt.openUrlExternally("https://emeric.io")
            }

            ListItemClickable { // rate
                width: parent.width
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                text: qsTr("Rate the application")
                iconSource: "qrc:/assets/icons_material/baseline-stars-24px.svg"
                indicatorSource: "qrc:/assets/icons_material/duotone-launch-24px.svg"

                onClicked: {
                    if (Qt.platform.os === "android")
                        Qt.openUrlExternally("market://details?id=io.emeric.mobilescanner")
                    else if (Qt.platform.os === "ios")
                        Qt.openUrlExternally("itms-apps://itunes.apple.com/app/1476046123")
                    else
                        Qt.openUrlExternally("https://github.com/emericg/MobileScanner/stargazers")
                }
            }

            ListItemClickable { // release notes
                width: parent.width

                text: qsTr("Release notes")
                iconSource: "qrc:/assets/icons_material/outline-new_releases-24px.svg"
                iconSize: 28
                indicatorSource: "qrc:/assets/icons_material/duotone-launch-24px.svg"

                onClicked: Qt.openUrlExternally("https://github.com/emericg/MobileScanner/releases")
            }

            ////////

            ListSeparator { }

            ListItemClickable { // tutorial
                width: parent.width

                text: qsTr("Open the tutorial")
                iconSource: "qrc:/assets/icons_material/baseline-import_contacts-24px.svg"
                iconSize: 24
                indicatorSource: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"

                onClicked: screenTutorial.loadScreenFrom("ScreenAbout")
            }

            ////////

            ListSeparator { visible: (Qt.platform.os === "android") }

            ListItemClickable { // permissions
                width: parent.width
                visible: (Qt.platform.os === "android")

                text: qsTr("About app permissions")
                iconSource: "qrc:/assets/icons_material/baseline-flaky-24px.svg"
                iconSize: 24
                indicatorSource: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"

                onClicked: screenAboutPermissions.loadScreenFrom("ScreenAbout")
            }

            ListSeparator { }

            ListItemClickable { // supported formats
                width: parent.width

                text: qsTr("Supported barcode formats")
                iconSource: "qrc:/assets/icons_material/baseline-check_circle-24px.svg"
                iconSize: 24
                indicatorSource: "qrc:/assets/icons_material/baseline-chevron_right-24px.svg"

                onClicked: screenAboutFormats.loadScreenFrom("ScreenAbout")
            }

            ListSeparator { }

            ////////

            Item { // list dependencies
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight + Theme.componentMargin

                height: 40 + dependenciesText.height + dependenciesColumn.height

                IconSvg {
                    width: 24
                    height: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: dependenciesText.verticalCenter

                    source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                    color: Theme.colorSubText
                }

                Text {
                    id: dependenciesText
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    anchors.left: parent.left
                    anchors.leftMargin: appHeader.headerPosition - parent.anchors.leftMargin
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    text: qsTr("This application is made possible thanks to a couple of third party open source projects:")
                    textFormat: Text.PlainText
                    color: Theme.colorSubText
                    font.pixelSize: Theme.fontSizeContent
                    wrapMode: Text.WordWrap
                }

                Column {
                    id: dependenciesColumn
                    anchors.top: dependenciesText.bottom
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: appHeader.headerPosition - parent.anchors.leftMargin
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    spacing: 4

                    Repeater {
                        model: [
                            "Qt6 (LGPL v3)",
                            "MobileUI (MIT)",
                            "MobileSharing (MIT)",
                            "qzxing (Apache v2)",
                            "zxing-cpp (Apache v2)",
                            "Google Material Icons (MIT)",
                        ]
                        delegate: Text {
                            width: parent.width
                            text: "- " + modelData
                            textFormat: Text.PlainText
                            color: Theme.colorSubText
                            font.pixelSize: Theme.fontSizeContent
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            ////////

            ListSeparatorPadded { visible: settingsManager.showDebug }

            Column { // list debug stuff
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + appHeader.headerPosition
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight + Theme.componentMargin

                visible: settingsManager.showDebug
                spacing: Theme.componentMargin * 0.4

                Text {
                    color: Theme.colorSubText
                    text: "app name: %1".arg(utilsApp.appName())
                    font.pixelSize: Theme.fontSizeContent
                }
                Text {
                    color: Theme.colorSubText
                    text: "app version: %1".arg(utilsApp.appVersion())
                    font.pixelSize: Theme.fontSizeContent
                }
                Text {
                    color: Theme.colorSubText
                    text: "backend: %1".arg(settingsManager.backend)
                    font.pixelSize: Theme.fontSizeContent
                }
                Text {
                    color: Theme.colorSubText
                    text: "build mode: %1".arg(utilsApp.appBuildModeFull())
                    font.pixelSize: Theme.fontSizeContent
                }
                Text {
                    color: Theme.colorSubText
                    text: "build date: %1".arg(utilsApp.appBuildDateTime())
                    font.pixelSize: Theme.fontSizeContent
                }
                Text {
                    color: Theme.colorSubText
                    text: "Qt version: %1".arg(utilsApp.qtVersion())
                    font.pixelSize: Theme.fontSizeContent
                }
            }

            ListSeparatorPadded { visible: settingsManager.showDebug }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
