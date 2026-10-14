/*!
 * This file is part of QmlMobileScanner.
 * Copyright (c) 2023 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2024
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef CAMERA_UTILS_H
#define CAMERA_UTILS_H
/* ************************************************************************** */

#include <QtQml/qqmlregistration.h>

#include <QObject>

#include <QMediaDevices>
#include <QCameraFormat>
#include <QVideoFrame>
#include <QImage>

class QQmlEngine;
class QJSEngine;

/* ************************************************************************** */

/*!
 * \brief The UtilsCamera class
 */
class UtilsCamera: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // Singleton
    explicit UtilsCamera(QObject *parent = nullptr);

public:
    static UtilsCamera *getInstance();
    static UtilsCamera *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    static Q_INVOKABLE QCameraFormat selectCameraFormat(int idx = 0);
};

/* ************************************************************************** */
#endif // CAMERA_UTILS_H
