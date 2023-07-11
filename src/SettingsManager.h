
#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QDateTime>

/* ************************************************************************** */

/*!
 * \brief The SettingsManager class
 */
class SettingsManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool firstLaunch READ isFirstLaunch NOTIFY firstLaunchChanged)
    Q_PROPERTY(QString appTheme READ getAppTheme WRITE setAppTheme NOTIFY appThemeChanged)
    Q_PROPERTY(bool appThemeAuto READ getAppThemeAuto WRITE setAppThemeAuto NOTIFY appThemeAutoChanged)

    bool m_firstlaunch = false;
    QString m_appTheme = "light";
    bool m_appThemeAuto = false;

    static SettingsManager *instance;
    SettingsManager();
    ~SettingsManager();

    bool readSettings();
    bool writeSettings();

Q_SIGNALS:
    void firstLaunchChanged();
    void appThemeChanged();
    void appThemeAutoChanged();

    void userCodeChanged();
    void lastSendChanged();

public:
    static SettingsManager *getInstance();

    bool isFirstLaunch() const { return m_firstlaunch; }

    //
    QString getAppTheme() const { return m_appTheme; }
    void setAppTheme(const QString &value);

    bool getAppThemeAuto() const { return m_appThemeAuto; }
    void setAppThemeAuto(const bool value);

    // Utils
    Q_INVOKABLE void resetSettings();
};

/* ************************************************************************** */
#endif // SETTINGS_MANAGER_H
