import QtQuick

import ComponentLibrary

Rectangle {
    id: appHeader

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    height: headerHeight + Math.max(screenPaddingStatusbar, screenPaddingTop)
    color: Theme.colorHeader
    clip: true
    z: 10

    property int headerHeight: 52

    property int headerPosition: 60

    property string headerTitle: utilsApp.appName()

    ////////////////////////////////////////////////////////////////////////////

    property string leftMenuMode: "drawer" // drawer / back / close
    signal leftMenuClicked()

    property string rightMenuMode: "off" // on / off
    signal rightMenuClicked()

    function rightMenuIsOpen() { return actionMenu.visible; }
    function rightMenuClose() { actionMenu.close(); }

    ////////////////////////////////////////////////////////////////////////////

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // OS statusbar area
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: Math.max(screenPaddingStatusbar, screenPaddingTop)
        color: Theme.colorStatusbar
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: Math.max(screenPaddingStatusbar, screenPaddingTop)

        ////////////

        Row { // left area
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.bottom: parent.bottom

            spacing: 4

            MouseArea { // left button
                width: appHeader.headerHeight
                height: appHeader.headerHeight

                visible: true
                onClicked: appHeader.leftMenuClicked()

                RippleThemed {
                    anchors.fill: parent
                    anchor: parent

                    pressed: parent.pressed
                    //active: enabled && parent.down
                    color: Qt.rgba(Theme.colorHeaderHighlight.r, Theme.colorHeaderHighlight.g, Theme.colorHeaderHighlight.b, 0.33)
                }

                IconSvg {
                    anchors.centerIn: parent
                    width: (appHeader.headerHeight / 2)
                    height: (appHeader.headerHeight / 2)

                    source: {
                        if (appHeader.leftMenuMode === "drawer") return "qrc:/IconLibrary/material-symbols/menu.svg"
                        if (appHeader.leftMenuMode === "close") return "qrc:/IconLibrary/material-symbols/close.svg"
                        if (appHeader.leftMenuMode === "lock") return "qrc:/IconLibrary/material-symbols/lock.svg"
                        if (appHeader.leftMenuMode === "login") return "qrc:/IconLibrary/material-symbols/supervised_user_circle.svg"
                        return "qrc:/IconLibrary/material-symbols/arrow_back.svg"
                    }
                    color: Theme.colorHeaderContent
                }
            }

            Text { // header title
                anchors.verticalCenter: parent.verticalCenter

                text: headerTitle
                textFormat: Text.PlainText
                color: Theme.colorHeaderContent
                font.bold: true
                font.pixelSize: Theme.fontSizeHeader
                font.capitalization: Font.Capitalize
            }
        }

        ////////////

        Row { // right area
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.bottom: parent.bottom

            spacing: 4

            // empty
        }

        ////////////
    }

    Rectangle { // bottom separator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 2
        opacity: 0.66

        color: Theme.colorHeaderHighlight
        visible: (appContent.state !== "ScreenTutorial")
    }

    ////////////////////////////////////////////////////////////////////////////
}
