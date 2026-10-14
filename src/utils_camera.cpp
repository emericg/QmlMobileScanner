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

#include <QCoreApplication>
#include <QQmlEngine>
#include <QJSEngine>

#include <QMediaDevices>
#include <QCameraFormat>
#include <QVideoFrame>
#include <QImage>

/* ************************************************************************** */

UtilsCamera *UtilsCamera::getInstance()
{
    static UtilsCamera *instance = new UtilsCamera(QCoreApplication::instance());
    return instance;
}

UtilsCamera *UtilsCamera::create(QQmlEngine *, QJSEngine *)
{
    UtilsCamera *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

UtilsCamera::UtilsCamera(QObject *parent) : QObject(parent)
{
    //
}

/* ************************************************************************** */

QCameraFormat UtilsCamera::selectCameraFormat(int idx)
{
    QList <QCameraFormat> formats = QMediaDevices::defaultVideoInput().videoFormats();

    if (idx > 0 && idx < QMediaDevices::videoInputs().size())
    {
        formats = QMediaDevices::videoInputs().at(idx).videoFormats();
    }

    int optimalPixelFormat = QVideoFrameFormat::Format_Invalid;

    // square formats
    for (const auto &format : std::as_const(formats))
    {
        qWarning() << "QCameraFormat(" << idx << ") res: " << format.resolution() << " pix: " << format.pixelFormat();

        if (format.resolution() == QSize(1440, 1440) &&
            (!optimalPixelFormat || (optimalPixelFormat && format.pixelFormat() == optimalPixelFormat)))
        {
            qWarning() << "SELECTED FORMAT res: " << format.resolution() << " pix: " << format.pixelFormat();
            return format;
        }
        if (format.resolution() == QSize(1200, 1200) &&
            (!optimalPixelFormat || (optimalPixelFormat && format.pixelFormat() == optimalPixelFormat)))
        {
            qWarning() << "SELECTED FORMAT res: " << format.resolution() << " pix: " << format.pixelFormat();
            return format;
        }
        if (format.resolution() == QSize(1080, 1080) &&
            (!optimalPixelFormat || (optimalPixelFormat && format.pixelFormat() == optimalPixelFormat)))
        {
            qWarning() << "SELECTED FORMAT res: " << format.resolution() << " pix: " << format.pixelFormat();
            return format;
        }
    }

    // non square formats
    for (const auto &format : std::as_const(formats))
    {
        qWarning() << "QCameraFormat(" << idx << ") res: " << format.resolution() << " pix: " << format.pixelFormat();

        if (format.resolution() == QSize(1280, 720) &&
            (!optimalPixelFormat || (optimalPixelFormat && format.pixelFormat() == optimalPixelFormat)))
        {
            qWarning() << "SELECTED FORMAT res: " << format.resolution() << " pix: " << format.pixelFormat();
            return format;
        }

        if (format.resolution() == QSize(1440, 1080) &&
            (!optimalPixelFormat || (optimalPixelFormat && format.pixelFormat() == optimalPixelFormat)))
        {
            qWarning() << "SELECTED FORMAT res: " << format.resolution() << " pix: " << format.pixelFormat();
            return format;
        }

        if (format.resolution() == QSize(1920, 1080) &&
            (!optimalPixelFormat || (optimalPixelFormat && format.pixelFormat() == optimalPixelFormat)))
        {
            qWarning() << "SELECTED FORMAT res: " << format.resolution() << " pix: " << format.pixelFormat();
            return format;
        }

        if (format.resolution() == QSize(2560, 1440) &&
            (!optimalPixelFormat || (optimalPixelFormat && format.pixelFormat() == optimalPixelFormat)))
        {
            qWarning() << "SELECTED FORMAT res: " << format.resolution() << " pix: " << format.pixelFormat();
            return format;
        }
    }

    return QCameraFormat();
}

/* ************************************************************************** */
