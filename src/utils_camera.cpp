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

#include "utils_camera.h"

#include <QImage>
#include <QVideoFrame>
#include <QCameraFormat>
#include <QMediaDevices>

/* ************************************************************************** */

UtilsCamera *UtilsCamera::instance = nullptr;

UtilsCamera *UtilsCamera::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsCamera();
    }

    return instance;
}

/* ************************************************************************** */

QCameraFormat UtilsCamera::selectCameraFormat(int idx)
{
    QList <QCameraFormat> formats = QMediaDevices::defaultVideoInput().videoFormats();

    if (idx > 0 && idx < QMediaDevices::videoInputs().size())
    {
        formats = QMediaDevices::videoInputs().at(idx).videoFormats();
    }

    for (const auto &format : formats) {
        //qDebug() << "QCameraFormat(" << idx << ") res: " << format.resolution() << " pix: " << format.pixelFormat();

        // square

        if (format.resolution() == QSize(1080, 1080) &&
            format.pixelFormat() == QVideoFrameFormat::Format_NV21) return format;

        if (format.resolution() == QSize(1200, 1200) &&
            format.pixelFormat() == QVideoFrameFormat::Format_NV21) return format;

        if (format.resolution() == QSize(1440, 1440) &&
            format.pixelFormat() == QVideoFrameFormat::Format_NV21) return format;

        // non square

        if (format.resolution() == QSize(1440, 1080) &&
            format.pixelFormat() == QVideoFrameFormat::Format_NV21) return format;

        if (format.resolution() == QSize(2560, 1440) &&
            format.pixelFormat() == QVideoFrameFormat::Format_NV21) return format;
    }

    return QCameraFormat();
}

/* ************************************************************************** */
