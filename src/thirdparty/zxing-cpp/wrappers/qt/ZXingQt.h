/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#pragma once

#include "ZXingQtVideoFilter.h"
#include "ZXingQtImageProvider.h"

#include <QImage>
#include <QDebug>
#include <QMetaType>
#include <QScopeGuard>
#include <QQmlEngine>

namespace ZXingQt {

Q_NAMESPACE

inline void registerQMLTypes()
{
    qRegisterMetaType<ZXingQt::BarcodeFormat>("BarcodeFormat");
    qRegisterMetaType<ZXingQt::ContentType>("ContentType");

    // supposedly the Q_DECLARE_METATYPE should be used with the overload without a custom name
    // but then the qml side complains about "unregistered type"
    qRegisterMetaType<ZXingQt::Position>("Position");
    qRegisterMetaType<ZXingQt::Result>("Result");

    qmlRegisterUncreatableMetaObject(ZXingQt::staticMetaObject, "ZXingCpp", 1, 0, "ZXingCpp", "Access to enums & flags only");
    qmlRegisterType<ZXingQt::ZXingQtVideoFilter>("ZXingCpp", 1, 0, "ZXingQtVideoFilter");
}

inline void registerQMLImageProvider(QQmlEngine &engine)
{
    engine.addImageProvider(QLatin1String("ZXingCpp"), new ZXingQtImageProvider());
}

} // namespace ZXingQt
