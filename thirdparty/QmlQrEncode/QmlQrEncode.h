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

#ifndef QMLQRENCODE_H
#define QMLQRENCODE_H
/* ************************************************************************** */

#include <QColor>
#include <QImage>
#include <QQuickItem>
#include <QString>
#include <QUrl>

/* ************************************************************************** */

/*!
 * \brief QR Code QML generator, backed by libqrencode.
 *
 * The symbol is encoded at one pixel per module, then drawn as a nearest-neighbour texture,
 * scaled by the largest integer factor that fits the item (in device pixels) and centred,
 * so every module keeps the same width.
 * An item smaller than one device pixel per module gets the symbol stretched to fit instead.
 * Resizing the item or changing its colors never re-encodes the symbol.
 */
class QmlQrEncode : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(Format format READ format WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(EccLevel eccLevel READ eccLevel WRITE setEccLevel NOTIFY eccLevelChanged)
    Q_PROPERTY(int margins READ margins WRITE setMargins NOTIFY marginsChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor foregroundColor READ foregroundColor WRITE setForegroundColor NOTIFY foregroundColorChanged)

    Q_PROPERTY(bool valid READ isValid NOTIFY symbolChanged)
    Q_PROPERTY(int moduleCount READ moduleCount NOTIFY symbolChanged)

public:
    enum Format {
        QrCode = 0,     //!< QR Code, versions 1 to 40
        MicroQrCode,    //!< Micro QR Code, versions M1 to M4
    };
    Q_ENUM(Format)

    enum EccLevel {
        EccLow = 0,     //!< ~7% recovery
        EccMedium,      //!< ~15% recovery
        EccQuartile,    //!< ~25% recovery
        EccHigh,        //!< ~30% recovery
    };
    Q_ENUM(EccLevel)

    explicit QmlQrEncode(QQuickItem *parent = nullptr);

    QString text() const { return m_text; }
    void setText(const QString &text);

    Format format() const { return m_format; }
    void setFormat(const Format format);

    /*!
     * \brief Error correction level.
     *
     * Micro QR Code has no H level, EccHigh falls back to EccQuartile.
     */
    EccLevel eccLevel() const { return m_eccLevel; }
    void setEccLevel(const EccLevel eccLevel);

    /*!
     * \brief Quiet zone around the symbol, in modules.
     */
    int margins() const { return m_margins; }
    void setMargins(const int margins);

    QColor backgroundColor() const { return m_backgroundColor; }
    void setBackgroundColor(const QColor &color);

    QColor foregroundColor() const { return m_foregroundColor; }
    void setForegroundColor(const QColor &color);

    /*!
     * \brief Whether the text could be encoded (false when empty, or too large for the selected format).
     */
    bool isValid() const { return !m_symbol.isNull(); }

    /*!
     * \brief Symbol width in modules, quiet zone included. Also the item's implicit size.
     */
    int moduleCount() const { return m_symbol.width(); }

    /*!
     * \brief Save the current symbol to a file.
     * \param fileUrl: Destination file, its suffix selects the format (svg, or any raster format QImage can write).
     * \param size: Image size in pixels.
     * \return true on success.
     *
     * Raster images are scaled by the largest integer factor that fits,
     * and centred on a background canvas of the requested size.
     * A symbol larger than the requested size is saved at 1x, on a canvas of its own size.
     */
    Q_INVOKABLE bool saveImage(const QUrl &fileUrl, const int size) const;

Q_SIGNALS:
    void textChanged();
    void formatChanged();
    void eccLevelChanged();
    void marginsChanged();
    void backgroundColorChanged();
    void foregroundColorChanged();
    void symbolChanged();

protected:
    void componentComplete() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;

private:
    /*!
     * \brief Re-encode the symbol from the current text, format, eccLevel and margins.
     */
    void updateSymbol();

    /*!
     * \brief Apply the current colors to the symbol color table.
     */
    void updateColors();

    /*!
     * \brief Area the symbol is drawn into, in item coordinates.
     * \return An integer multiple of the module count in device pixels, centred and pixel aligned,
     * or the largest square that fits when the item is smaller than one device pixel per module.
     * Empty when there is no symbol or no window.
     */
    QRectF symbolRect() const;

    QString m_text;
    Format m_format = QrCode;
    EccLevel m_eccLevel = EccLow;
    int m_margins = 0;
    QColor m_backgroundColor = Qt::transparent;
    QColor m_foregroundColor = Qt::black;

    QImage m_symbol;            //!< One pixel per module, indexed (0: background, 1: foreground)
    bool m_textureDirty = true;
};

/* ************************************************************************** */
#endif // QMLQRENCODE_H
