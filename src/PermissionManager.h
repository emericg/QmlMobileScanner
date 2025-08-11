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

#ifndef PERMISSION_MANAGER_H
#define PERMISSION_MANAGER_H
/* ************************************************************************** */

#include <QObject>
#include <QString>
#include <QDateTime>

/* ************************************************************************** */

/*!
 * \brief The PermissionManager class
 *
 * https://doc.qt.io/qt-6/permissions.html
 *
 * - https://doc.qt.io/qt-6/qbluetoothpermission.html
 * - https://doc.qt.io/qt-6/qcalendarpermission.html
 * - https://doc.qt.io/qt-6/qcamerapermission.html
 * - https://doc.qt.io/qt-6/qcontactpermission.html
 * - https://doc.qt.io/qt-6/qlocationpermission.html
 * - https://doc.qt.io/qt-6/qmicrophonepermission.html
 */
class PermissionManager: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool bluetoothPermission READ hasBluetoothPermission NOTIFY bluetoothPermissionChanged)
    Q_PROPERTY(bool calendarPermission READ hasCalendarPermission NOTIFY calendarPermissionChanged)
    Q_PROPERTY(bool cameraPermission READ checkCameraPermission NOTIFY cameraPermissionChanged)
    Q_PROPERTY(bool contactsPermission READ hasContactsPermission NOTIFY contactsPermissionChanged)
    Q_PROPERTY(bool locationPermission READ hasLocationPermission NOTIFY locationPermissionChanged)
    Q_PROPERTY(bool microphonePermission READ hasMicrophonePermission NOTIFY microphonePermissionChanged)

    static PermissionManager *instance;
    PermissionManager();
    ~PermissionManager();

Q_SIGNALS:
    void bluetoothPermissionChanged();
    void calendarPermissionChanged();
    void cameraPermissionChanged();
    void contactsPermissionChanged();
    void locationPermissionChanged();
    void microphonePermissionChanged();

public:
    static PermissionManager *getInstance();

    bool hasBluetoothPermission() const { return false; }
    bool hasCalendarPermission() const { return false; }
    bool hasCameraPermission() const { return false; }
    bool hasContactsPermission() const { return false; }
    bool hasLocationPermission() const { return false; }
    bool hasMicrophonePermission() const { return false; }

    Q_INVOKABLE bool requestCameraPermission();
    Q_INVOKABLE bool checkCameraPermission();
    Q_INVOKABLE bool waitCameraPermission();
};

/* ************************************************************************** */
#endif // PERMISSION_MANAGER_H
