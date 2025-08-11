/*!
 * This file is part of QmlMobileScanner.
 * Copyright (c) 2025 Emeric Grange - All Rights Reserved
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
 * \date      2025
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "PermissionManager.h"

#include <QCoreApplication>
#include <QDebug>

#if QT_CONFIG(permissions)
#include <QPermission>
#include <QThread>
#else
#error "QtPermission is not available. Qt 6.6 is required!"
#endif

/* ************************************************************************** */
/* ************************************************************************** */

PermissionManager *PermissionManager::instance = nullptr;

PermissionManager *PermissionManager::getInstance()
{
    if (instance == nullptr)
    {
        instance = new PermissionManager();
        return instance;
    }

    return instance;
}

PermissionManager::PermissionManager()
{
    //
}

PermissionManager::~PermissionManager()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

bool PermissionManager::requestCameraPermission()
{
    QCameraPermission cameraPermission;
    switch (qApp->checkPermission(cameraPermission))
    {
    case Qt::PermissionStatus::Granted:
        qDebug() << "Camera permission is granted!";
        return true;
    case Qt::PermissionStatus::Denied:
        qDebug() << "Camera permission is not granted!";
        return false;
    case Qt::PermissionStatus::Undetermined:
        qDebug() << "Requesting camera permission...";
        qApp->requestPermission(QCameraPermission{}, [this](const QPermission &permission) {
            Q_EMIT cameraPermissionChanged();
        });
        return false;
    }

    return false;
}

bool PermissionManager::checkCameraPermission()
{
    QCameraPermission cameraPermission;
    switch (qApp->checkPermission(cameraPermission))
    {
    case Qt::PermissionStatus::Granted:
        return true;
    case Qt::PermissionStatus::Denied:
        return false;
    case Qt::PermissionStatus::Undetermined:
        return false;
    }

    return false;
}

bool PermissionManager::waitCameraPermission()
{
    int timeout = 1000;

    QCameraPermission cameraPermission;
    while (true)
    {
        QThread::msleep(4);
        timeout -= 4;

        switch (qApp->checkPermission(cameraPermission))
        {
        case Qt::PermissionStatus::Granted:
            return true;
        case Qt::PermissionStatus::Denied:
            return false;
        case Qt::PermissionStatus::Undetermined:
            if (timeout < 0) return false;
            continue;
        }
    }

    return false;
}

/* ************************************************************************** */
/* ************************************************************************** */
