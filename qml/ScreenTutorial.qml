import QtQuick
import QtQuick.Controls

import ComponentLibrary
import QmlMobileScanner

Rectangle {
    id: screenTutorial
    anchors.fill: parent

    color: Theme.colorHeader

    property string entryPoint: "ScreenBarcodeReader"
    property string entryPointDefault: "ScreenBarcodeReader"

    ////////////////////////////////////////////////////////////////////////////

    function loadScreen() {
        entryPoint = "ScreenBarcodeReader"
        appContent.state = "ScreenTutorial"
    }

    function loadScreenFrom(screenname) {
        entryPoint = screenname
        appContent.state = "ScreenTutorial"
    }

    function backAction() {
        if (entryPoint === entryPointDefault) {
            return // do nothing
        } else {
            appContent.state = entryPoint
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Loader {
        id: tutorialLoader
        anchors.fill: parent

        active: (appContent.state === "ScreenTutorial")
        asynchronous: true

        sourceComponent: Item {
            id: itemTutorial

            function reset() {
                tutorialPages.disableAnimation()
                tutorialPages.currentIndex = 0
                tutorialPages.enableAnimation()
            }

            ////////////////

            SwipeView {
                id: tutorialPages
                anchors.fill: parent
                anchors.leftMargin: screenPaddingLeft
                anchors.rightMargin: screenPaddingRight
                anchors.bottomMargin: 56
                property int margins: isPhone ? 24 : 40

                currentIndex: 0
                onCurrentIndexChanged: {
                    if (currentIndex < 0) currentIndex = 0
                    if (currentIndex > count-1) {
                        currentIndex = 0 // reset
                        appContent.state = entryPoint
                    }
                }

                function enableAnimation() {
                    contentItem.highlightMoveDuration = 333
                }
                function disableAnimation() {
                    contentItem.highlightMoveDuration = 0
                }

                ////////

                Item {
                    id: page1

                    Column {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 32

                        // TODO

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins

                            text: qsTr("Scan stuff")
                            textFormat: Text.PlainText
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHeaderContent
                            horizontalAlignment: Text.AlignHCenter
                        }
                        IconSvg {
                            width: tutorialPages.width * (tutorialPages.height > tutorialPages.width ? 0.8 : 0.4)
                            height: width*0.229
                            anchors.horizontalCenter: parent.horizontalCenter

                            source: "qrc:/assets/gfx/logos/logo_black.svg"
                            color: Theme.colorHeaderContent
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins

                            text: qsTr("and other stuff")
                            textFormat: Text.PlainText
                            color: Theme.colorHeaderContent
                            font.pixelSize: Theme.fontSizeContentBig
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                        ButtonFlat {
                            anchors.horizontalCenter: parent.horizontalCenter
                            layoutDirection: Qt.RightToLeft
                            color: Theme.colorHeaderHighlight
                            text: qsTr("A button")
                            source: "qrc:/IconLibrary/material-icons/duotone/launch.svg"
                        }
                    }
                }

                ////////

                Item {
                    id: page2

                    Column {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 32

                        // TODO

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins

                            text: qsTr("There is no tutorial...")
                            textFormat: Text.PlainText
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHeaderContent
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                ////////

                Item {
                    id: page3

                    Column {
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 32

                        // TODO

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: tutorialPages.margins
                            anchors.left: parent.left
                            anchors.leftMargin: tutorialPages.margins

                            text: qsTr("I lied...")
                            textFormat: Text.PlainText
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: Theme.fontSizeContentBig
                            color: Theme.colorHeaderContent
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                ////////
            }

            ////////////////

            Text {
                id: pagePrevious
                anchors.left: parent.left
                anchors.leftMargin: tutorialPages.margins
                anchors.verticalCenter: pageIndicator.verticalCenter

                visible: (tutorialPages.currentIndex !== 0)

                text: qsTr("Previous")
                textFormat: Text.PlainText
                color: Theme.colorHeaderContent
                font.bold: true
                font.pixelSize: Theme.fontSizeContent

                opacity: 0.8
                Behavior on opacity { OpacityAnimator { duration: 133 } }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.8
                    onCanceled: parent.opacity = 0.8
                    onClicked: tutorialPages.currentIndex--
                }
            }

            PageIndicatorThemed {
                id: pageIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: tutorialPages.margins/2

                count: tutorialPages.count
                currentIndex: tutorialPages.currentIndex
            }

            Text {
                id: pageNext
                anchors.right: parent.right
                anchors.rightMargin: tutorialPages.margins
                anchors.verticalCenter: pageIndicator.verticalCenter

                text: (tutorialPages.currentIndex === tutorialPages.count-1) ? qsTr("Start") : qsTr("Next")
                textFormat: Text.PlainText
                color: Theme.colorHeaderContent
                font.bold: true
                font.pixelSize: Theme.fontSizeContent

                opacity: 0.8
                Behavior on opacity { OpacityAnimator { duration: 133 } }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.8
                    onCanceled: parent.opacity = 0.8
                    onClicked: tutorialPages.currentIndex++
                }
            }

            ////////////////
        }
    }
}
