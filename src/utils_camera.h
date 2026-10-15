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
#include <QCameraDevice>
#include <QCameraFormat>
#include <QVideoFrameFormat>
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

    /*!
     * \brief Select the best capture format for barcode scanning.
     * \param device: The camera device to select a format for, the default camera if null.
     * \param fullResolution: Maximize resolution, instead of capping it around 1080p.
     * \return The selected format, or a null QCameraFormat if the device exposes no format.
     *
     * Candidates are ranked by, in order: reaching 20 fps, resolution, pixel format score,
     * square aspect ratio, and maximum frame rate.
     * In balanced mode, resolutions above 1920x1080 pixel count rank below every smaller one,
     * the closest to the cap first.
     */
    static Q_INVOKABLE QCameraFormat selectCameraFormat(const QCameraDevice &device, bool fullResolution = false);

    /*!
     * \brief Describe a camera format, for debug display.
     * \param format: The camera format.
     * \return A "WIDTHxHEIGHT PIXELFORMAT FPS" string, or an empty string if the format is null.
     */
    static Q_INVOKABLE QString cameraFormatToString(const QCameraFormat &format);

private:
    /*!
     * \brief Rank a pixel format by how cheaply ZXing can read it.
     * \param pixelFormat: The video frame pixel format.
     * \return 2 for luma-readable YUV formats, 1 for 32 bits RGB formats,
     *         0 for formats requiring a full conversion (JPEG, textures...).
     */
    static int pixelFormatScore(QVideoFrameFormat::PixelFormat pixelFormat);
};

/* ************************************************************************** */
#endif // CAMERA_UTILS_H
