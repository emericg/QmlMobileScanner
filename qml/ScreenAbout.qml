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
            if (appContent.state === "ScreenAboutPermissions") {
                screenAboutPermissions.backAction()
                return
            }
            if (appContent.state === "ScreenAboutFormats") {
                screenAboutFormats.backAction()
                return
            }

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
                        source: "qrc:/assets/gfx/logos/logo_black.svg"
                        //sourceSize: Qt.size(width, height)
                    }

                    Column { // title
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -1

                        Text {
                            text: utilsApp.appName()
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

                    ButtonSolid {
                        width: 160

                        text: qsTr("WEBSITE")
                        source: "qrc:/assets/icons/material-symbols/link.svg"
                        sourceSize: 28
                        color: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner")
                    }

                    ButtonSolid {
                        width: 160

                        text: qsTr("SUPPORT")
                        source: "qrc:/assets/icons/material-symbols/support.svg"
                        sourceSize: 22
                        color: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner/issues")
                    }

                    ButtonSolid {
                        width: 160
                        visible: (appWindow.width > 800)

                        text: qsTr("GitHub")
                        source: "qrc:/assets/gfx/logos/github.svg"
                        sourceSize: 22
                        color: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner")
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

                ButtonSolid {
                    anchors.verticalCenter: parent.verticalCenter
                    width: ((parent.width - parent.spacing) / 2)

                    text: qsTr("WEBSITE")
                    source: "qrc:/assets/icons/material-symbols/link.svg"
                    sourceSize: 28
                    color: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner")
                    //onClicked: Qt.openUrlExternally("https://emeric.io/QmlMobileScanner")
                }
                ButtonSolid {
                    anchors.verticalCenter: parent.verticalCenter
                    width: ((parent.width - parent.spacing) / 2)

                    text: qsTr("SUPPORT")
                    source: "qrc:/assets/icons/material-symbols/support.svg"
                    sourceSize: 22
                    color: (Theme.currentTheme === ThemeEngine.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                    onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner/issues")
                    //onClicked: Qt.openUrlExternally("https://emeric.io/QmlMobileScanner/support.html")
                }
            }

            Item { width: 12; height: 12; visible: wideMode; } // spacer

            ////////////////

            ListItem { // description
                width: parent.width
                text: qsTr("Barcode & QRcode scanner reader/writer based on qzxing and zxing-cpp libraries.")
                source: "qrc:/assets/icons/material-symbols/info.svg"
            }

            ListItemClickable { // authors
                width: parent.width

                text: qsTr("Application by <a href=\"https://emeric.io\">Emeric Grange</a>")
                source: "qrc:/assets/icons/material-symbols/supervised_user_circle.svg"
                indicatorSource: "qrc:/assets/icons/material-icons/duotone/launch.svg"

                onClicked: Qt.openUrlExternally("https://emeric.io")
            }

            ListItemClickable { // rate
                width: parent.width
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                text: qsTr("Rate the application")
                source: "qrc:/assets/icons/material-symbols/stars-fill.svg"
                indicatorSource: "qrc:/assets/icons/material-icons/duotone/launch.svg"

                onClicked: {
                    if (Qt.platform.os === "android")
                        Qt.openUrlExternally("market://details?id=io.emeric.qmlmobilescanner")
                    else if (Qt.platform.os === "ios")
                        Qt.openUrlExternally("itms-apps://itunes.apple.com/app/1476046123")
                    else
                        Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner/stargazers")
                }
            }

            ListItemClickable { // release notes
                width: parent.width

                text: qsTr("Release notes")
                source: "qrc:/assets/icons/material-symbols/new_releases.svg"
                sourceSize: 28
                indicatorSource: "qrc:/assets/icons/material-icons/duotone/launch.svg"

                onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner/releases")
            }

            ////////

            ListSeparator { }

            ListItemClickable { // tutorial
                width: parent.width

                text: qsTr("Open the tutorial")
                source: "qrc:/assets/icons/material-symbols/import_contacts-fill.svg"
                sourceSize: 24
                indicatorSource: "qrc:/assets/icons/material-symbols/chevron_right.svg"

                onClicked: screenTutorial.loadScreenFrom("ScreenAbout")
            }

            ////////

            ListSeparator { visible: (Qt.platform.os === "android" || Qt.platform.os === "ios") }

            ListItemClickable { // permissions
                width: parent.width
                visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                text: qsTr("About app permissions")
                source: "qrc:/assets/icons/material-symbols/flaky.svg"
                sourceSize: 24
                indicatorSource: "qrc:/assets/icons/material-symbols/chevron_right.svg"

                onClicked: screenAboutPermissions.loadScreenFrom("ScreenAbout")
            }

            ListSeparator { }

            ListItemClickable { // supported formats
                width: parent.width

                text: qsTr("Supported barcode formats")
                source: "qrc:/assets/icons/material-symbols/check_circle.svg"
                sourceSize: 24
                indicatorSource: "qrc:/assets/icons/material-symbols/chevron_right.svg"

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

                    source: "qrc:/assets/icons/material-symbols/settings.svg"
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
                            "zint (BSD 3 clause)",
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

            Item { // list debug stuff
                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight + Theme.componentMargin

                visible: settingsManager.showDebug
                height: 16 + debugColumn.height

                IconSvg {
                    width: 24
                    height: 24
                    anchors.top: debugColumn.top
                    anchors.topMargin: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 4

                    source: "qrc:/assets/icons/material-icons/duotone/info.svg"
                    color: Theme.colorSubText
                }

                Column {
                    id: debugColumn
                    anchors.left: parent.left
                    anchors.leftMargin: appHeader.headerPosition - parent.anchors.leftMargin
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: Theme.componentMargin * 0.4

                    Text {
                        color: Theme.colorSubText
                        text: "App name: %1".arg(utilsApp.appName())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "App version: %1".arg(utilsApp.appVersion())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "Backend(s): %1".arg(settingsManager.backend_reader) + (settingsManager.backend_zint ? " + zint" : "")
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "Build mode: %1".arg(utilsApp.appBuildModeFull())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "Build date: %1".arg(utilsApp.appBuildDateTime())
                        font.pixelSize: Theme.fontSizeContent
                    }
                    Text {
                        color: Theme.colorSubText
                        text: "Qt version: %1".arg(utilsApp.qtVersion())
                        font.pixelSize: Theme.fontSizeContent
                    }
                }
            }

            ListSeparatorPadded { visible: settingsManager.showDebug }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
