/*
 * Copyright 2023 Emeric Grange
 */

#ifndef ZINT_QML_H
#define ZINT_QML_H

#include <QObject>
#include <QUrl>
#include <QColor>
#include <QImage>
#include <QString>
#include <QQmlEngine>

class ZintQml : public QObject
{
    Q_OBJECT

public:
    explicit ZintQml(QObject *parent = nullptr) : QObject(parent) {}

    static void registerQMLTypes();
    static void registerQMLImageProvider(QQmlEngine &engine);

    ///

    Q_INVOKABLE static int stringToFormat(const QString &str);
    Q_INVOKABLE static QString formatToString(const int fmt);

    ///

    Q_INVOKABLE static QImage generateImage(const QString &data, const int width, const int height, const int margins,
                                            const int format, const int encoding, const int eccLevel,
                                            const QColor backgroundColor, const QColor foregroundColor);

    Q_INVOKABLE static bool saveImage(const QString &data, const int width, const int height, const int margins,
                                      const int format, const int encoding, const int eccLevel,
                                      const QColor backgroundColor, const QColor foregroundColor,
                                      const QUrl &fileurl);

    ///
};

#endif // ZINT_QML_H
