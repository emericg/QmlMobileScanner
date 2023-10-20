#include "ImageHandler.h"

#include <QImage>
#include <QPainter>
#include <QDebug>
#include <QThread>
#include <QElapsedTimer>

#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QQuickWindow>

ImageHandler::ImageHandler(QObject *parent) :
    QObject(parent)
{
}

QImage ImageHandler::extractQImage(QObject *imageObj, int offsetX, int offsetY, int width, int height)
{
    QImage img;

    QQuickItem *item = qobject_cast<QQuickItem *>(imageObj);

    if (!item || !item->window()->isVisible()) {
        qWarning() << "ImageHandler: item is NULL";
        return QImage();
    }

    QElapsedTimer timer;
    timer.start();
    QSharedPointer<QQuickItemGrabResult> result = item->grabToImage();
    if (result) {
        pendingGrabbersLocker.lockForWrite();
        pendingGrabbers << result.data();
        pendingGrabbersLocker.unlock();

        connect(result.data(), &QQuickItemGrabResult::ready, this, &ImageHandler::imageGrabberReady);
        while (timer.elapsed() < 1000) {
            pendingGrabbersLocker.lockForRead();
            if (!pendingGrabbers.contains(result.data())) {
                pendingGrabbersLocker.unlock();
                break;
            }
            pendingGrabbersLocker.unlock();
            qApp->processEvents();
            QThread::yieldCurrentThread();
        }
        img = result->image();
    }

    if (offsetX < 0)
        offsetX = 0;
    if (offsetY < 0)
        offsetY = 0;
    if (width < 0)
        width = 0;
    if (height < 0)
        height = 0;

    if (offsetX || offsetY || width || height)
        return img.copy(offsetX, offsetY, width, height);

    return img;
}

void ImageHandler::save(QObject *imageObj, const QString &path,
                        const int offsetX, const int offsetY,
                        const int width, const int height)
{
    QImage img = extractQImage(imageObj, offsetX, offsetY, width, height);
    img.save(path);
}

void ImageHandler::imageGrabberReady()
{
    pendingGrabbersLocker.lockForWrite();
    pendingGrabbers.remove(sender());
    pendingGrabbersLocker.unlock();
}
