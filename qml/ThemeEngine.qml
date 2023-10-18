pragma Singleton

import QtQuick
import QtQuick.Controls.Material

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

    // Status bar (mobile)
    property int themeStatusbar
    property color colorStatusbar

    // Header
    property color colorHeader
    property color colorHeaderContent
    property color colorHeaderHighlight

    // Side bar (desktop)
    property color colorSidebar
    property color colorSidebarContent
    property color colorSidebarHighlight

    // Action bar
    property color colorActionbar
    property color colorActionbarContent
    property color colorActionbarHighlight

    // Tablet bar (mobile)
    property color colorTabletmenu
    property color colorTabletmenuContent
    property color colorTabletmenuHighlight

    // Content
    property color colorBackground
    property color colorForeground

    property color colorPrimary
    property color colorSecondary
    property color colorSuccess
    property color colorWarning
    property color colorError

    property color colorText
    property color colorSubText
    property color colorIcon
    property color colorSeparator

    property color colorLowContrast
    property color colorHighContrast

    // App specific
    property color colorRipple

    ////////////////

    // Palette colors
    property color colorRed: "#ff7657"
    property color colorGreen: "#8cd200"
    property color colorBlue: "#4cafe9"
    property color colorYellow: "#ffcf00"
    property color colorOrange: "#ffa635"
    property color colorGrey: "#555151"

    // Material colors
    readonly property color colorMaterialRed: "#F44336"
    readonly property color colorMaterialPink: "#E91E63"
    readonly property color colorMaterialPurple: "#9C27B0"
    readonly property color colorMaterialDeepPurple: "#673AB7"
    readonly property color colorMaterialIndigo: "#3F51B5"
    readonly property color colorMaterialBlue: "#2196F3"
    readonly property color colorMaterialLightBlue: "#03A9F4"
    readonly property color colorMaterialCyan: "#00BCD4"
    readonly property color colorMaterialTeal: "#009688"
    readonly property color colorMaterialGreen: "#4CAF50"
    readonly property color colorMaterialLightGreen: "#8BC34A"
    readonly property color colorMaterialLime: "#CDDC39"
    readonly property color colorMaterialYellow: "#FFEB3B"
    readonly property color colorMaterialAmber: "#FFC107"
    readonly property color colorMaterialOrange: "#FF9800"
    readonly property color colorMaterialDeepOrange: "#FF5722"
    readonly property color colorMaterialBrown: "#795548"
    readonly property color colorMaterialGrey: "#9E9E9E"

    ////////////////

    // Qt Quick Controls & theming
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

        // Validate the result
        if (themeIndex < 0 || themeIndex >= ThemeEngine.THEME_LAST) {
            themeIndex = ThemeEngine.THEME_LIGHT // default theme for this app
        }

        // Handle day/night themes
        if (settingsManager.appThemeAuto) {
            var rightnow = new Date()
            var hour = Qt.formatDateTime(rightnow, "hh")
            if (hour >= 21 || hour <= 8) {
                themeIndex = ThemeEngine.THEME_DARK
            }
        }

        // Do not reload the same theme
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
