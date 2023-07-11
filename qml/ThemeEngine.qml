pragma Singleton

import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Item {
    enum ThemeNames {
        THEME_LIGHT = 0,
        THEME_DARK = 1,

        THEME_LAST
    }
    property int currentTheme: -1

    ////////////////

    property bool isHdpi: (utilsScreen.screenDpi >= 128 || utilsScreen.screenPar >= 2.0)
    property bool isDesktop: (Qt.platform.os !== "ios" && Qt.platform.os !== "android")
    property bool isMobile: (Qt.platform.os === "ios" || Qt.platform.os === "android")
    property bool isPhone: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize < 7.0))
    property bool isTablet: ((Qt.platform.os === "ios" || Qt.platform.os === "android") && (utilsScreen.screenSize >= 7.0))

    ////////////////

    property int themeStatusbar
    property string colorStatusbar

    // Header
    property string colorHeader
    property string colorHeaderContent
    property string colorHeaderHighlight

    // Sidebar
    property string colorSidebar
    property string colorSidebarContent
    property string colorSidebarHighlight

    // Action bar
    property string colorActionbar
    property string colorActionbarContent
    property string colorActionbarHighlight

    // Tablet bar
    property string colorTabletmenu
    property string colorTabletmenuContent
    property string colorTabletmenuHighlight

    // Content
    property string colorBackground
    property string colorForeground

    property string colorPrimary
    property string colorSecondary
    property string colorSuccess
    property string colorWarning
    property string colorError

    property string colorText
    property string colorSubText
    property string colorIcon
    property string colorSeparator

    property string colorLowContrast
    property string colorHighContrast

    // App specific
    property string colorRipple

    ////////////////

    // Palette colors
    property string colorLightGreen: "#09debc"
    property string colorGreen
    property string colorDarkGreen: "#1ea892"
    property string colorBlue
    property string colorYellow
    property string colorOrange
    property string colorRed
    property string colorGrey: "#555151"
    property string colorLightGrey: "#a9bcb8"

    // Fixed colors
    readonly property color colorMaterialBlue: "#2196f3"
    readonly property color colorMaterialThisblue: "#448aff"
    readonly property color colorMaterialIndigo: "#3f51b5"
    readonly property color colorMaterialPurple: "#9c27b0"
    readonly property color colorMaterialDeepPurple: "#673ab7"
    readonly property color colorMaterialRed: "#f44336"
    readonly property color colorMaterialOrange: "#ff9800"
    readonly property color colorMaterialLightGreen: "#8bc34a"

    readonly property color colorMaterialLightGrey: "#f8f8f8"
    readonly property color colorMaterialGrey: "#eeeeee"
    readonly property color colorMaterialDarkGrey: "#ececec"

    readonly property color colorNeutralDay: "#e4e4e4"
    readonly property color colorNeutralNight: "#ffb300"

    ////////////////

    // Qt Quick controls & theming
    property color colorComponent
    property color colorComponentText
    property color colorComponentContent
    property color colorComponentBorder
    property color colorComponentDown
    property color colorComponentBackground

    property int componentMargin: isHdpi ? 12 : 16
    property int componentMarginL: isHdpi ? 16 : 20
    property int componentMarginXL: isHdpi ? 20 : 24

    property int componentHeight: (isDesktop && isHdpi) ? 36 : 40
    property int componentHeightL: (isDesktop && isHdpi) ? 44 : 48
    property int componentHeightXL: (isDesktop && isHdpi) ? 48 : 56

    property int componentRadius: 4
    property int componentBorderWidth: 2

    property int componentFontSize: isMobile ? 14 : 15

    ////////////////

    // Fonts (sizes in pixel)
    readonly property int fontSizeHeader: isMobile ? 22 : 26
    readonly property int fontSizeTitle: isMobile ? 24 : 28
    readonly property int fontSizeContentVeryVerySmall: 10
    readonly property int fontSizeContentVerySmall: 12
    readonly property int fontSizeContentSmall: 14
    readonly property int fontSizeContent: 16
    readonly property int fontSizeContentBig: 18
    readonly property int fontSizeContentVeryBig: 20
    readonly property int fontSizeContentVeryVeryBig: 22

    ////////////////////////////////////////////////////////////////////////////

    Component.onCompleted: loadTheme(settingsManager.appTheme)
    Connections {
        target: settingsManager
        function onAppThemeChanged() { loadTheme(settingsManager.appTheme) }
    }

    function loadTheme(themeIndex) {
        //console.log("ThemeEngine.loadTheme(" + themeIndex + ")")

        if (themeIndex === "light") themeIndex = ThemeEngine.THEME_LIGHT
        if (themeIndex === "dark") themeIndex = ThemeEngine.THEME_DARK
        if (themeIndex >= ThemeEngine.THEME_LAST) themeIndex = 0

        if (settingsManager.autoDark) {
            var rightnow = new Date()
            var hour = Qt.formatDateTime(rightnow, "hh")
            if (hour >= 21 || hour <= 8) {
                themeIndex = ThemeEngine.THEME_DARK
            }
        }

        if (themeIndex === currentTheme) return

        if (themeIndex === ThemeEngine.THEME_LIGHT) {

            themeStatusbar = Material.Light
            colorStatusbar = "#E9E9E9"

            colorHeader =               "#E9E9E9"
            colorHeaderContent =        "#353637"
            colorHeaderHighlight =      Qt.darker(colorHeader, 1.1)

            colorSidebar =              "#3A3A3A"
            colorSidebarContent =       "white"
            colorSidebarHighlight =     Qt.lighter(colorSidebar, 1.5)

            colorActionbar =            "#8CD200"
            colorActionbarContent =     "white"
            colorActionbarHighlight =   "#73AD00"

            colorTabletmenu =           "#f3f3f3"
            colorTabletmenuContent =    "#9d9d9d"
            colorTabletmenuHighlight =  "#0079fe"

            colorBackground =           "#F4F4F4"
            colorForeground =           "#E9E9E9"

            colorPrimary =              "#FFCA28"
            colorSecondary =            "#FFDD28"
            colorSuccess =              "#8CD200"
            colorWarning =              "#FFAC00"
            colorError =                "#E64B39"

            colorText =                 "#222"
            colorSubText =              "#555"
            colorIcon =                 "#333"
            colorSeparator =            "#E4E4E4"
            colorLowContrast =          "white"
            colorHighContrast =         "black"

            colorComponent =            "#EAEAEA"
            colorComponentText =        "black"
            colorComponentContent =     "black"
            colorComponentBorder =      "#DDD"
            colorComponentDown =        "#E6E6E6"
            colorComponentBackground =  "#FAFAFA"

            componentRadius = 6
            colorRipple = "#f8f8f8"

        } else if (themeIndex === ThemeEngine.THEME_DARK) {

            colorGreen = "#58CF77"
            colorBlue = "#4dceeb"
            colorYellow = "#fcc632"
            colorOrange = "#ff7657"
            colorRed = "#e8635a"

            themeStatusbar = Material.Dark
            colorStatusbar = "#944197"

            colorHeader = "#944197"
            colorHeaderContent = "#fff"
            colorHeaderHighlight = Qt.darker(colorHeader, 1.1)

            colorActionbar = colorGreen
            colorActionbarContent = "white"
            colorActionbarHighlight = "#00a27d"

            colorTabletmenu = "#292929"
            colorTabletmenuContent = "#808080"
            colorTabletmenuHighlight = "#ff9f1a"

            colorBackground = "#313236"
            colorForeground = "#292929"

            colorPrimary = "#ff9f1a"
            colorSecondary = "#ffb81a"

            colorText = "white"
            colorSubText = "#bbb"
            colorIcon = "#ccc"
            colorSeparator = "#404040"

            colorSuccess = colorGreen
            colorWarning = colorOrange
            colorError = colorRed

            colorLowContrast = "#141414"
            colorHighContrast = "white"

            colorComponent = "#666666"
            colorComponentText = "white"
            colorComponentContent = "white"
            colorComponentBorder = "#666666"
            colorComponentDown = "#444444"
            colorComponentBackground = "#505050"

            colorRipple = "#292929"

        }

        // This will emit the signal 'onCurrentThemeChanged'
        currentTheme = themeIndex
    }
}
