/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#pragma once

#include <QObject>
#include <QMetaType>
#include <QScopeGuard>
#include <QQmlEngine>

namespace ZXingQt {

Q_NAMESPACE

void registerQMLTypes();
void registerQMLImageProvider(QQmlEngine &engine);

} // namespace ZXingQt
