/*!
 * COPYRIGHT (C) 2026 Emeric Grange - All Rights Reserved
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "QmlQrEncode.h"

#include "libqrencode/qrencode.h"

#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QPainter>
#include <QQuickWindow>
#include <QSGImageNode>
#include <QSGTexture>

#include <cerrno>
#include <cmath>

/* ************************************************************************** */

/*!
 * \brief Encode text into a QR Code or Micro QR Code symbol.
 * \param text: Text to encode, converted to UTF-8 and truncated at the first NUL character.
 * \param format: Symbol format (0: QR Code, 1: Micro QR Code).
 * \param eccLevel: Error correction level (0: L, 1: M, 2: Q, 3: H), H falls back to Q for Micro QR Code.
 * \param margins: Quiet zone around the symbol, in modules.
 * \return An indexed image at one pixel per module (0: background, 1: foreground),
 * without color table. Null on failure.
 *
 * The text is split into numeric, alphanumeric and 8-bit segments for a smaller symbol,
 * the decoded text is unchanged.
 */
static QImage encodeSymbol(const QString &text, const int format, const int eccLevel, const int margins)
{
    if (text.isEmpty()) return QImage();

    const bool micro = (format == QmlQrEncode::MicroQrCode);

    QRecLevel level = QR_ECLEVEL_L;
    if (eccLevel == 1) level = QR_ECLEVEL_M;
    else if (eccLevel == 2) level = QR_ECLEVEL_Q;
    else if (eccLevel == 3) level = micro ? QR_ECLEVEL_Q : QR_ECLEVEL_H;

    // Version 0 auto-selects the symbol size.
    // The QR_MODE_8 hint keeps non-ASCII UTF-8 bytes out of Kanji mode, case sensitive keeps the text as is.
    const QByteArray utf8 = text.toUtf8();
    QRcode *qr = micro ? QRcode_encodeStringMQR(utf8.constData(), 0, level, QR_MODE_8, 1)
                       : QRcode_encodeString(utf8.constData(), 0, level, QR_MODE_8, 1);
    if (!qr)
    {
        qWarning() << "QmlQrEncode: cannot encode" << utf8.size() << "bytes:" << qt_error_string(errno);
        return QImage();
    }

    const int qrWidth = qr->width;
    const int symbolSize = qrWidth + 2 * margins;

    QImage symbol(symbolSize, symbolSize, QImage::Format_Indexed8);
    symbol.setColorCount(2);
    symbol.fill(0);

    for (int y = 0; y < qrWidth; ++y)
    {
        const unsigned char *row = qr->data + y * qrWidth;
        uchar *line = symbol.scanLine(y + margins) + margins;
        for (int x = 0; x < qrWidth; ++x)
        {
            // The least significant bit is set for dark modules
            line[x] = row[x] & 0x01;
        }
    }

    QRcode_free(qr);
    return symbol;
}

/*!
 * \brief Render a symbol on a square canvas.
 * \param symbol: Symbol at one pixel per module, with its color table set.
 * \param size: Canvas size, in pixels.
 * \return The symbol scaled by the largest integer factor that fits (at least 1x),
 * centred on a background-filled canvas.
 */
static QImage renderSymbol(const QImage &symbol, const int size)
{
    const int factor = qMax(1, size / symbol.width());
    const int scaledSize = symbol.width() * factor;
    const int canvasSize = qMax(size, scaledSize);
    const int offset = (canvasSize - scaledSize) / 2;

    QImage canvas(canvasSize, canvasSize, QImage::Format_ARGB32);
    canvas.fill(QColor::fromRgba(symbol.color(0)));

    QPainter painter(&canvas);
    painter.setCompositionMode(QPainter::CompositionMode_Source);
    painter.drawImage(offset, offset, symbol.scaled(scaledSize, scaledSize,
                                                    Qt::IgnoreAspectRatio, Qt::FastTransformation));
    painter.end();

    return canvas;
}

/*!
 * \brief SVG fill attributes for a color, with a separate opacity when translucent.
 */
static QString svgFill(const QColor &color)
{
    QString fill = QStringLiteral("fill=\"%1\"").arg(color.name(QColor::HexRgb));
    if (color.alpha() < 255) fill += QStringLiteral(" fill-opacity=\"%1\"").arg(color.alphaF());
    return fill;
}

/*!
 * \brief Convert a symbol to an SVG document.
 * \param symbol: Symbol at one pixel per module, with its color table set.
 * \param size: Document width and height, in pixels.
 * \return The SVG document, one module per user unit, dark modules merged into horizontal runs.
 */
static QByteArray symbolToSvg(const QImage &symbol, const int size)
{
    const int modules = symbol.width();
    const QColor bg = QColor::fromRgba(symbol.color(0));
    const QColor fg = QColor::fromRgba(symbol.color(1));

    QString path;
    for (int y = 0; y < modules; ++y)
    {
        const uchar *line = symbol.constScanLine(y);
        for (int x = 0; x < modules; )
        {
            if (!line[x]) { ++x; continue; }

            const int start = x;
            while (x < modules && line[x]) ++x;
            path += QStringLiteral("M%1 %2h%3v1h-%3z").arg(start).arg(y).arg(x - start);
        }
    }

    QString svg = QStringLiteral("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%1\" height=\"%1\" "
                                 "viewBox=\"0 0 %2 %2\" shape-rendering=\"crispEdges\">\n").arg(size).arg(modules);
    if (bg.alpha() > 0) svg += QStringLiteral("<rect width=\"%1\" height=\"%1\" %2/>\n").arg(modules).arg(svgFill(bg));
    svg += QStringLiteral("<path d=\"%1\" %2/>\n").arg(path, svgFill(fg));
    svg += QStringLiteral("</svg>\n");

    return svg.toUtf8();
}

/* ************************************************************************** */

QmlQrEncode::QmlQrEncode(QQuickItem *parent) : QQuickItem(parent)
{
    setFlag(ItemHasContents, true);
}

void QmlQrEncode::setText(const QString &text)
{
    if (m_text == text) return;
    m_text = text;
    Q_EMIT textChanged();
    updateSymbol();
}

void QmlQrEncode::setFormat(const Format format)
{
    if (m_format == format) return;
    m_format = format;
    Q_EMIT formatChanged();
    updateSymbol();
}

void QmlQrEncode::setEccLevel(const EccLevel eccLevel)
{
    if (m_eccLevel == eccLevel) return;
    m_eccLevel = eccLevel;
    Q_EMIT eccLevelChanged();
    updateSymbol();
}

void QmlQrEncode::setMargins(const int margins)
{
    const int m = qMax(0, margins);
    if (m_margins == m) return;
    m_margins = m;
    Q_EMIT marginsChanged();
    updateSymbol();
}

void QmlQrEncode::setBackgroundColor(const QColor &color)
{
    if (m_backgroundColor == color) return;
    m_backgroundColor = color;
    Q_EMIT backgroundColorChanged();
    updateColors();
}

void QmlQrEncode::setForegroundColor(const QColor &color)
{
    if (m_foregroundColor == color) return;
    m_foregroundColor = color;
    Q_EMIT foregroundColorChanged();
    updateColors();
}

/* ************************************************************************** */

void QmlQrEncode::componentComplete()
{
    QQuickItem::componentComplete();
    updateSymbol();
}

void QmlQrEncode::updateSymbol()
{
    // Properties set at creation are encoded once, from componentComplete()
    if (!isComponentComplete()) return;

    //qDebug() << "QmlQrEncode::updateSymbol(" << m_text << ") format" << m_format << "eccLevel" << m_eccLevel << "margins" << m_margins;

    m_symbol = encodeSymbol(m_text, m_format, m_eccLevel, m_margins);
    setImplicitSize(m_symbol.width(), m_symbol.height());
    updateColors();

    Q_EMIT symbolChanged();
}

void QmlQrEncode::updateColors()
{
    if (!m_symbol.isNull()) m_symbol.setColorTable({m_backgroundColor.rgba(), m_foregroundColor.rgba()});
    m_textureDirty = true;
    update();
}

QRectF QmlQrEncode::symbolRect() const
{
    if (m_symbol.isNull() || !window()) return QRectF();

    const qreal dpr = window()->effectiveDevicePixelRatio();
    const int devicePixels = static_cast<int>(std::floor(qMin(width(), height()) * dpr));
    if (devicePixels <= 0) return QRectF();

    const int factor = devicePixels / m_symbol.width();
    const qreal side = (factor > 0 ? factor * m_symbol.width() : devicePixels) / dpr;

    const qreal x = std::round((width() - side) * 0.5 * dpr) / dpr;
    const qreal y = std::round((height() - side) * 0.5 * dpr) / dpr;

    return QRectF(x, y, side, side);
}

void QmlQrEncode::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    if (newGeometry.size() != oldGeometry.size()) update();
}

void QmlQrEncode::itemChange(ItemChange change, const ItemChangeData &value)
{
    QQuickItem::itemChange(change, value);
    if (change == ItemDevicePixelRatioHasChanged) update();
}

QSGNode *QmlQrEncode::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    auto *node = static_cast<QSGImageNode *>(oldNode);

    const QRectF rect = symbolRect();
    if (rect.isEmpty())
    {
        delete node;
        return nullptr;
    }

    // A new texture comes with a new node, which owns it
    if (node && m_textureDirty)
    {
        delete node;
        node = nullptr;
    }

    if (!node)
    {
        QSGTexture *texture = window()->createTextureFromImage(m_symbol.convertToFormat(QImage::Format_ARGB32_Premultiplied));

        node = window()->createImageNode();
        node->setTexture(texture);
        node->setOwnsTexture(true);
        node->setFiltering(QSGTexture::Nearest);
        node->setSourceRect(QRectF(QPointF(0, 0), texture->textureSize()));
        m_textureDirty = false;
    }

    node->setRect(rect);
    return node;
}

/* ************************************************************************** */

bool QmlQrEncode::saveImage(const QUrl &fileUrl, const int size) const
{
    if (m_symbol.isNull() || fileUrl.isEmpty() || size <= 0) return false;

    QString filePath = fileUrl.toLocalFile();
    if (filePath.isEmpty()) filePath = fileUrl.toString();

    if (QFileInfo(filePath).suffix().compare(QLatin1String("svg"), Qt::CaseInsensitive) == 0)
    {
        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            qWarning() << "QmlQrEncode::saveImage() cannot open" << filePath << ":" << file.errorString();
            return false;
        }

        const QByteArray svg = symbolToSvg(m_symbol, size);
        return (file.write(svg) == svg.size());
    }

    const bool status = renderSymbol(m_symbol, size).save(filePath);
    if (!status) qWarning() << "QmlQrEncode::saveImage() cannot write" << filePath;

    return status;
}

/* ************************************************************************** */
