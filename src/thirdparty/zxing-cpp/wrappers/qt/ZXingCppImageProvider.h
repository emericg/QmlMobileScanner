/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#ifndef ZXING_QT_IMAGEPROVIDER_H
#define ZXING_QT_IMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QString>
#include <QImage>
#include <QSize>

class ZXingCppImageProvider : public QQuickImageProvider
{
public:
    ZXingCppImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // ZXING_QT_IMAGEPROVIDER_H
