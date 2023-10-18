/*
 * Copyright 2020 Axel Waggershauser
 * Copyright 2023 ApiTracer developer
 * Copyright 2023 Emeric Grange
 */

#pragma once

#include <QQuickImageProvider>
#include <QImage>

namespace ZXingQt {

class ZXingQtImageProvider : public QQuickImageProvider
{
public:
    ZXingQtImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

} // namespace ZXingQt
