/*
 * Copyright 2023 Emeric Grange
 */

#ifndef ZINT_IMAGEPROVIDER_H
#define ZINT_IMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QString>
#include <QImage>
#include <QSize>

class ZintImageProvider : public QQuickImageProvider
{
public:
    ZintImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // ZINT_IMAGEPROVIDER_H
