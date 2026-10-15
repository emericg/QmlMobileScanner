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
#include <QCameraDevice>
#include <QCameraFormat>
#include <QVideoFrame>
#include <QImage>

#include <tuple>

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

int UtilsCamera::pixelFormatScore(QVideoFrameFormat::PixelFormat pixelFormat)
{
    switch (pixelFormat)
    {
    case QVideoFrameFormat::Format_NV12:
    case QVideoFrameFormat::Format_NV21:
    case QVideoFrameFormat::Format_YUV420P:
    case QVideoFrameFormat::Format_YUV422P:
    case QVideoFrameFormat::Format_YV12:
    case QVideoFrameFormat::Format_IMC1:
    case QVideoFrameFormat::Format_IMC2:
    case QVideoFrameFormat::Format_IMC3:
    case QVideoFrameFormat::Format_IMC4:
    case QVideoFrameFormat::Format_P010:
    case QVideoFrameFormat::Format_P016:
    case QVideoFrameFormat::Format_Y8:
    case QVideoFrameFormat::Format_Y16:
    case QVideoFrameFormat::Format_YUYV:
    case QVideoFrameFormat::Format_UYVY:
    case QVideoFrameFormat::Format_AYUV:
    case QVideoFrameFormat::Format_AYUV_Premultiplied:
        return 2;

    case QVideoFrameFormat::Format_ARGB8888:
    case QVideoFrameFormat::Format_ARGB8888_Premultiplied:
    case QVideoFrameFormat::Format_XRGB8888:
    case QVideoFrameFormat::Format_BGRA8888:
    case QVideoFrameFormat::Format_BGRA8888_Premultiplied:
    case QVideoFrameFormat::Format_BGRX8888:
    case QVideoFrameFormat::Format_ABGR8888:
    case QVideoFrameFormat::Format_XBGR8888:
    case QVideoFrameFormat::Format_RGBA8888:
    case QVideoFrameFormat::Format_RGBX8888:
        return 1;

    default:
        return 0;
    }
}

QCameraFormat UtilsCamera::selectCameraFormat(const QCameraDevice &device, bool fullResolution)
{
    static constexpr float minimumFrameRate = 20.f;
    static constexpr qint64 balancedPixelCount = 1920 * 1080;

    const QCameraDevice dev = device.isNull() ? QMediaDevices::defaultVideoInput() : device;

    QCameraFormat bestFormat;
    std::tuple<bool, qint64, int, bool, float> bestScore;

    for (const auto &format : dev.videoFormats())
    {
        //qWarning() << "QCameraFormat(" << dev.description() << ") res: " << format.resolution() << " pix: " << format.pixelFormat() << " fps: " << format.maxFrameRate();

        const qint64 pixelCount = qint64(format.resolution().width()) * format.resolution().height();
        const qint64 resolutionScore = (fullResolution || pixelCount <= balancedPixelCount) ? pixelCount : -pixelCount;

        const std::tuple<bool, qint64, int, bool, float> score = {
            format.maxFrameRate() >= minimumFrameRate,
            resolutionScore,
            pixelFormatScore(format.pixelFormat()),
            format.resolution().width() == format.resolution().height(),
            format.maxFrameRate(),
        };

        if (bestFormat.isNull() || score > bestScore)
        {
            bestFormat = format;
            bestScore = score;
        }
    }

    if (!bestFormat.isNull())
    {
        qWarning() << "SELECTED FORMAT res: " << bestFormat.resolution() << " pix: " << bestFormat.pixelFormat() << " fps: " << bestFormat.maxFrameRate();
    }

    return bestFormat;
}

QString UtilsCamera::cameraFormatToString(const QCameraFormat &format)
{
    if (format.isNull()) return QString();

    return QStringLiteral("%1x%2 %3 %4 fps")
        .arg(format.resolution().width())
        .arg(format.resolution().height())
        .arg(QVideoFrameFormat::pixelFormatToString(format.pixelFormat()))
        .arg(format.maxFrameRate(), 0, 'f', 0);
}

/* ************************************************************************** */
