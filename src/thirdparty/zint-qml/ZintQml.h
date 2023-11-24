/*
 * Copyright 2023 Emeric Grange
 */

#ifndef ZINT_QML_H
#define ZINT_QML_H

#include <QObject>
#include <QQmlEngine>

class ZintQml : public QObject
{
    Q_OBJECT

public:
    explicit ZintQml(QObject *parent = nullptr) : QObject(parent) {}

    static void registerQMLTypes();
    static void registerQMLImageProvider(QQmlEngine &engine);
};

#endif // ZINT_QML_H
