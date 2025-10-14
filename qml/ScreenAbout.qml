import QtQuick
import QtQuick.Controls

import ComponentLibrary
import QmlMobileScanner

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

    sourceComponent: Item {
        anchors.fill: parent

        ////////////////

        function backAction() {
            if (appContent.state === "ScreenAboutPermissions") {
                screenAboutPermissions.backAction()
                return
            }
            if (appContent.state === "ScreenAboutFormats") {
                screenAboutFormats.backAction()
                return
            }

            appWindow.backAction_default()
        }

        Rectangle { // hide the space between the top of the screen and the top of scanWidget
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            height: contentHeader.height - contentFlickable.contentY
            color: contentHeader.color
            visible: singleColumn
        }

        ////////////////

        Flickable {
            id: contentFlickable
            anchors.fill: parent

            contentWidth: -1
            contentHeight: columnContent.height

            boundsBehavior: isDesktop ? Flickable.OvershootBounds : Flickable.DragAndOvershootBounds
            ScrollBar.vertical: ScrollBar { visible: false }

            Column {
                id: columnContent

                anchors.left: parent.left
                anchors.leftMargin: screenPaddingLeft + ((singleColumn || isPhone) ? 0 : parent.width * 0.12)
                anchors.right: parent.right
                anchors.rightMargin: screenPaddingRight + ((singleColumn || isPhone) ? 0 : parent.width * 0.12)

                ////////

                Item { width: 16; height: 16; visible: !(singleColumn || isPhone); }

                Rectangle { // header area
                    id: contentHeader
                    anchors.left: parent.left
                    anchors.leftMargin: -screenPaddingLeft
                    anchors.right: parent.right
                    anchors.rightMargin: -screenPaddingRight

                    height: 112
                    radius: (singleColumn || isPhone) ? 0 : 8
                    color: Theme.colorForeground

                    border.width: (singleColumn || isPhone) ? 0 : Theme.componentBorderWidth
                    border.color: Theme.colorSeparator

                    property int availableWidth: (contentHeader.width - rowTitle.width)

                    Row {
                        id: rowTitle
                        anchors.left: parent.left
                        anchors.leftMargin: screenPaddingLeft + Theme.componentMargin
                        anchors.verticalCenter: parent.verticalCenter

                        z: 2
                        height: 112
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
                                textFormat: Text.PlainText
                                color: Theme.colorSubText
                                font.pixelSize: Theme.fontSizeContentBig
                            }
                        }
                    }

                    ////////

                    Row { // desktop buttons row
                        anchors.right: parent.right
                        anchors.rightMargin: screenPaddingRight + Theme.componentMarginL
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.componentMargin

                        ButtonSolid {
                            visible: (width*3.3 < contentHeader.availableWidth)
                            width: isPhone ? 150 : 160
                            height: 40

                            text: qsTr("WEBSITE")
                            source: "qrc:/IconLibrary/material-symbols/link.svg"
                            sourceSize: 28
                            color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                            onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner")
                        }

                        ButtonSolid {
                            visible: (width*2.2 < contentHeader.availableWidth)
                            width: isPhone ? 150 : 160
                            height: 40

                            text: qsTr("SUPPORT")
                            source: "qrc:/IconLibrary/material-symbols/support.svg"
                            sourceSize: 22
                            color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                            onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner/issues")
                        }

                        ButtonSolid {
                            visible: (width*1.1 < contentHeader.availableWidth)
                            width: isPhone ? 150 : 160
                            height: 40

                            text: qsTr("GitHub")
                            source: "qrc:/assets/gfx/logos/github.svg"
                            sourceSize: 22
                            color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                            onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner")
                        }
                    }

                    Rectangle { // bottom separator
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 2
                        visible: singleColumn
                        border.color: Theme.colorSeparator
                    }
                }

                Item { width: 16; height: 16; visible: !(singleColumn || isPhone); }

                ////////

                Row { // buttons row
                    height: 72

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    visible: !wideMode
                    spacing: Theme.componentMargin

                    ButtonSolid {
                        anchors.verticalCenter: parent.verticalCenter
                        width: ((parent.width - parent.spacing) / 2)

                        text: qsTr("WEBSITE")
                        source: "qrc:/IconLibrary/material-symbols/link.svg"
                        sourceSize: 28
                        color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner")
                        //onClicked: Qt.openUrlExternally("https://emeric.io/QmlMobileScanner")
                    }
                    ButtonSolid {
                        anchors.verticalCenter: parent.verticalCenter
                        width: ((parent.width - parent.spacing) / 2)

                        text: qsTr("SUPPORT")
                        source: "qrc:/IconLibrary/material-symbols/support.svg"
                        sourceSize: 22
                        color: (Theme.currentTheme === Theme.THEME_NIGHT) ? Theme.colorHeader : "#5483EF"

                        onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner/issues")
                        //onClicked: Qt.openUrlExternally("https://emeric.io/QmlMobileScanner/support.html")
                    }
                }

                Item { width: 12; height: 12; visible: wideMode; } // spacer

                ////////

                ListItem { // description
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Barcode & QR code scanner reader/writer based on qzxing and zxing-cpp libraries.")
                    source: "qrc:/IconLibrary/material-symbols/info.svg"
                }

                ListItemClickable { // authors
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Application by <a href=\"https://emeric.io\">Emeric Grange</a>")
                    source: "qrc:/IconLibrary/material-symbols/supervised_user_circle.svg"
                    indicatorSource: "qrc:/IconLibrary/material-icons/duotone/launch.svg"

                    onClicked: Qt.openUrlExternally("https://emeric.io")
                }

                ListItemClickable { // rate
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                    text: qsTr("Rate the application")
                    source: "qrc:/IconLibrary/material-symbols/stars-fill.svg"
                    indicatorSource: "qrc:/IconLibrary/material-icons/duotone/launch.svg"

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
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Release notes")
                    source: "qrc:/IconLibrary/material-symbols/new_releases.svg"
                    sourceSize: 28
                    indicatorSource: "qrc:/IconLibrary/material-icons/duotone/launch.svg"

                    onClicked: Qt.openUrlExternally("https://github.com/emericg/QmlMobileScanner/releases")
                }

                ////////

                ListSeparator { }

                ListItemClickable { // tutorial
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Open the tutorial")
                    source: "qrc:/IconLibrary/material-symbols/import_contacts-fill.svg"
                    sourceSize: 24
                    indicatorSource: "qrc:/IconLibrary/material-symbols/chevron_right.svg"

                    onClicked: screenTutorial.loadScreenFrom("ScreenAbout")
                }

                ////////

                ListSeparator { visible: (Qt.platform.os === "android" || Qt.platform.os === "ios") }

                ListItemClickable { // permissions
                    anchors.left: parent.left
                    anchors.right: parent.right

                    visible: (Qt.platform.os === "android" || Qt.platform.os === "ios")

                    text: qsTr("About app permissions")
                    source: "qrc:/IconLibrary/material-symbols/flaky.svg"
                    sourceSize: 24
                    indicatorSource: "qrc:/IconLibrary/material-symbols/chevron_right.svg"

                    onClicked: screenAboutPermissions.loadScreenFrom("ScreenAbout")
                }

                ListSeparator { }

                ListItemClickable { // supported formats
                    anchors.left: parent.left
                    anchors.right: parent.right

                    text: qsTr("Supported barcode formats")
                    source: "qrc:/IconLibrary/material-symbols/check_circle.svg"
                    sourceSize: 24
                    indicatorSource: "qrc:/IconLibrary/material-symbols/chevron_right.svg"

                    onClicked: screenAboutFormats.loadScreenFrom("ScreenAbout")
                }

                ListSeparator { }

                ////////

                Item { // list dependencies
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    height: 40 + dependenciesText.height + dependenciesColumn.height

                    IconSvg {
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.verticalCenter: dependenciesText.verticalCenter
                        width: 24
                        height: 24

                        source: "qrc:/IconLibrary/material-symbols/settings.svg"
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
                                "Google Material Icons (Apache v2)",
                            ]
                            delegate: Text {
                                anchors.left: parent.left
                                anchors.right: parent.right

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

                Item { // debug infos
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin

                    height: 16 + debugColumn.height
                    visible: settingsManager.showDebug

                    IconSvg {
                        anchors.top: debugColumn.top
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        width: 24
                        height: 24

                        source: "qrc:/IconLibrary/material-icons/duotone/info.svg"
                        color: Theme.colorSubText
                    }

                    Column {
                        id: debugColumn
                        anchors.left: parent.left
                        anchors.leftMargin: appHeader.headerPosition - parent.anchors.leftMargin
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: Theme.componentMargin * 0.33

                        Text {
                            color: Theme.colorSubText
                            text: "App name: %1".arg(utilsApp.appName())
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                        }
                        Text {
                            color: Theme.colorSubText
                            text: "App version: %1".arg(utilsApp.appVersion())
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                        }
                        Text {
                            color: Theme.colorSubText
                            text: "Backend(s): %1".arg(settingsManager.backend_reader) + (settingsManager.backend_zint ? " + zint" : "")
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                        }
                        Text {
                            color: Theme.colorSubText
                            text: "Build mode: %1".arg(utilsApp.appBuildModeFull())
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                        }
                        Text {
                            color: Theme.colorSubText
                            text: "Build architecture: %1".arg(utilsApp.qtArchitecture())
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                        }
                        Text {
                            color: Theme.colorSubText
                            text: "Build date: %1".arg(utilsApp.appBuildDateTime())
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                        }
                        Text {
                            color: Theme.colorSubText
                            text: "Qt version: %1".arg(utilsApp.qtVersion())
                            textFormat: Text.PlainText
                            font.pixelSize: Theme.fontSizeContent
                        }
                    }
                }

                ListSeparatorPadded { visible: settingsManager.showDebug }

                ////////
            }
        }

        ////////////////
    }

    ////////////////////////////////////////////////////////////////////////////
}
