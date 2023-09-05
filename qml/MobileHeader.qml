import QtQuick

import ThemeEngine

Rectangle {
    id: appHeader
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    height: screenPaddingStatusbar + headerHeight
    color: Theme.colorHeader
    clip: true
    z: 10

    property int headerHeight: 52

    property int headerPosition: 64

    property string headerTitle: "MobileScanner"

    ////////////////////////////////////////////////////////////////////////////

    property string leftMenuMode: "drawer" // drawer / back / close
    signal leftMenuClicked()

    property string rightMenuMode: "off" // on / off
    signal rightMenuClicked()

    ////////////////////////////////////////////////////////////////////////////

    function rightMenuIsOpen() { return actionMenu.visible; }
    function rightMenuClose() { actionMenu.close(); }

    // prevent clicks below this area
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // OS statusbar area
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: screenPaddingStatusbar
        color: Theme.colorStatusbar
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        anchors.fill: parent
        anchors.topMargin: screenPaddingStatusbar

        ////////////

        Row { // left area
            id: leftArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.bottom: parent.bottom

            spacing: 4

            MouseArea { // left button
                width: headerHeight
                height: headerHeight

                visible: true
                onClicked: leftMenuClicked()

                RippleThemed {
                    anchor: parent
                    width: parent.width
                    height: parent.height

                    pressed: parent.pressed
                    //active: enabled && parent.down
                    color: Qt.rgba(Theme.colorForeground.r, Theme.colorForeground.g, Theme.colorForeground.b, 0.1)
                }

                IconSvg {
                    anchors.centerIn: parent
                    width: (headerHeight / 2)
                    height: (headerHeight / 2)

                    source: {
                        if (leftMenuMode === "drawer") return "qrc:/assets/icons_material/baseline-menu-24px.svg"
                        if (leftMenuMode === "close") return "qrc:/assets/icons_material/baseline-close-24px.svg"
                        if (leftMenuMode === "lock") return "qrc:/assets/icons_material/baseline-lock-24px.svg"
                        if (leftMenuMode === "login") return "qrc:/assets/icons_material/baseline-supervised_user_circle-24px.svg"
                        return "qrc:/assets/icons_material/baseline-arrow_back-24px.svg"
                    }
                    color: Theme.colorHeaderContent
                }
            }

            Text { // header title
                anchors.verticalCenter: parent.verticalCenter

                text: headerTitle
                font.bold: true
                font.pixelSize: Theme.fontSizeHeader
                color: Theme.colorHeaderContent
                elide: Text.ElideRight
            }
        }

        ////////////

        Row { // right area
            id: rightArea
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
