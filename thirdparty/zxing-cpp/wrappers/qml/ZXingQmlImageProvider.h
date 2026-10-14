/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2026 Emeric Grange
 */

#ifndef ZXING_QML_IMAGEPROVIDER_H
#define ZXING_QML_IMAGEPROVIDER_H
/* ************************************************************************** */

#include <QQuickImageProvider>
#include <QString>
#include <QImage>
#include <QSize>

/* ************************************************************************** */

class ZXingQmlImageProvider : public QQuickImageProvider
{
public:
    ZXingQmlImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

/* ************************************************************************** */
#endif // ZXING_QML_IMAGEPROVIDER_H
