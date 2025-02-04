/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2024 Emeric Grange
 */

#ifndef ZXING_QT_IMAGEPROVIDER_H
#define ZXING_QT_IMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QString>
#include <QImage>
#include <QSize>

class ZXingQtImageProvider : public QQuickImageProvider
{
public:
    ZXingQtImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // ZXING_QT_IMAGEPROVIDER_H
