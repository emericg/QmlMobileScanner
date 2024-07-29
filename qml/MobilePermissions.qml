import QtQuick
import QtQuick.Controls

import ThemeEngine

Item {
    id: screenAboutPermissions
    anchors.fill: parent

    property string entryPoint: "ScreenAbout"

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        // Refresh permissions
        refreshPermissions()

        // Change screen
        appContent.state = "ScreenAboutPermissions"
    }

    function loadScreenFrom(screenname) {
        entryPoint = screenname
        loadScreen()
    }

    function backAction() {
        screenAbout.loadScreen()
    }

    function refreshPermissions() {
        // Refresh permissions
        button_network_test.validperm = true
        button_location_test.validperm = utilsApp.checkMobileBleLocationPermission()
        button_camera_test.validperm = utilsApp.checkMobileCameraPermission()
    }

    Timer {
        id: retryPermissions
        interval: 333
        repeat: false
        onTriggered: refreshPermissions()
    }

    ////////////////////////////////////////////////////////////////////////////

    Flickable {
        anchors.fill: parent

        contentWidth: -1
        contentHeight: contentColumn.height

        anchors.leftMargin: screenPaddingLeft
        anchors.rightMargin: screenPaddingRight

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right

            topPadding: 24
            bottomPadding: 24
            spacing: 16

            ////////

            Item { // element_network
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20

                RoundButtonIcon {
                    id: button_network_test
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    width: 32
                    height: 32
                    z: 1

                    property bool validperm: true

                    source: (validperm) ? "qrc:/assets/icons/material-symbols/check.svg" : "qrc:/assets/icons/material-symbols/close.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorSuccess : Theme.colorSubText
                    backgroundVisible: true

                    onClicked: {
                        refreshPermissions.start()
                    }
                }

                Text { // text_network
                    anchors.left: parent.left
                    anchors.leftMargin: 64
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    height: 16

                    text: qsTr("Network access")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Text { // legend_network
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.right: parent.right
                anchors.rightMargin: 16

                text: qsTr("Network access is used to try and interpret what the barcodes are.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item { // element_camera
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20

                RoundButtonIcon {
                    id: button_camera_test
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    width: 32
                    height: 32
                    z: 1

                    property bool validperm: true

                    source: (validperm) ? "qrc:/assets/icons/material-symbols/check.svg" : "qrc:/assets/icons/material-symbols/close.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorSuccess : Theme.colorSubText
                    backgroundVisible: true

                    onClicked: {
                        utilsApp.vibrate(25)
                        utilsApp.getMobileCameraPermission()
                        retryPermissions.start()
                    }
                }

                Text { // text_camera
                    anchors.left: parent.left
                    anchors.leftMargin: 64
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    height: 16

                    text: qsTr("Camera")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Text { // legend_camera
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.right: parent.right
                anchors.rightMargin: 16

                text: qsTr("Camera is in fact quite useful for a barcode scanner application.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            Item { // element_position
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20

                RoundButtonIcon {
                    id: button_location_test
                    width: 32
                    height: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1

                    property bool validperm: true

                    source: (validperm) ? "qrc:/assets/icons/material-symbols/check.svg" : "qrc:/assets/icons/material-symbols/close.svg"
                    iconColor: (validperm) ? "white" : "white"
                    backgroundColor: (validperm) ? Theme.colorSuccess : Theme.colorSubText
                    backgroundVisible: true

                    onClicked: {
                        utilsApp.vibrate(25)
                        utilsApp.getMobileLocationPermission()
                        retryPermissions.start()
                    }
                }

                Text { // text_position
                    anchors.left: parent.left
                    anchors.leftMargin: 64
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    height: 16

                    text: qsTr("Position (GPS)")
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeContentBig
                    color: Theme.colorText
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Text { // legend_position
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.right: parent.right
                anchors.rightMargin: 16

                text: qsTr("You can save GPS position along with scanned barcodes.")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ////////

            ListSeparatorPadded { height: 16+1 }

            ////////

            Item { // element_infos
                anchors.left: parent.left
                anchors.right: parent.right
                height: 32

                IconSvg {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.componentMargin + 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 32

                    opacity: 0.66
                    color: Theme.colorSubText
                    source: "qrc:/assets/icons/material-icons/duotone/info.svg"
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: appHeader.headerPosition
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.componentMargin
                    anchors.verticalCenter: parent.verticalCenter

                    text: qsTr("Click on the checkmarks to request missing permissions.")
                    textFormat: Text.StyledText
                    lineHeight : 0.8
                    wrapMode: Text.WordWrap
                    color: Theme.colorText
                    font.pixelSize: Theme.fontSizeContent
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: appHeader.headerPosition
                anchors.right: parent.right
                anchors.rightMargin: Theme.componentMargin

                visible: (Qt.platform.os === "android")

                text: qsTr("If it has no effect, you may have previously refused a permission and clicked on \"don't ask again\".") + "<br>" +
                      qsTr("You can go to the Android \"application info\" panel to change a permission manually.")
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                color: Theme.colorSubText
                font.pixelSize: Theme.fontSizeContentSmall
            }

            ButtonWireframe {
                anchors.left: parent.left
                anchors.leftMargin: appHeader.headerPosition
                height: 38

                visible: (Qt.platform.os === "android")
                colorBackground: Theme.colorForeground

                text: qsTr("Application info")
                source: "qrc:/assets/icons/material-icons/duotone/tune.svg"
                sourceSize: 20

                onClicked: utilsApp.openAndroidAppInfo("io.emeric.qmlmobilescanner")
            }

            ////////
        }
    }

    ////////////////////////////////////////////////////////////////////////////
}
