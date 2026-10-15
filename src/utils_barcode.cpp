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
 * \date      2026
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#include "utils_barcode.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QJSEngine>
#include <QVariantMap>
#include <QMimeDatabase>
#include <QFile>
#include <QDebug>

#if defined(QMS_USE_ZXINGCPP)
#include <ZXingQml>
#endif
#if defined(QMS_USE_QZXING)
#include <QZXing>
#endif

/* ************************************************************************** */

UtilsBarcode *UtilsBarcode::getInstance()
{
    static UtilsBarcode *instance = new UtilsBarcode(QCoreApplication::instance());
    return instance;
}

UtilsBarcode *UtilsBarcode::create(QQmlEngine *, QJSEngine *)
{
    UtilsBarcode *instance = getInstance();
    QJSEngine::setObjectOwnership(instance, QJSEngine::CppOwnership);
    return instance;
}

UtilsBarcode::UtilsBarcode(QObject *parent) : QObject(parent)
{
    //
}

/* ************************************************************************** */

QVariantList UtilsBarcode::getAvailableFormats()
{
    QVariantList formats;

    auto add = [&formats](const QString &text, unsigned value) {
        formats.append(QVariantMap{ {QStringLiteral("text"), text},
                                    {QStringLiteral("value"), value} });
    };

#if defined(QMS_USE_ZXINGCPP)
    // Bit values come from ZXingQml::BarcodeFormat (ZXingQml.h), the canonical definition of the
    // legacy zxing-cpp formatsEnabled layout (also used by appBitmaskToZXingFormats() and usable
    // directly from QML, e.g. `formats: ZXingQml.QRCode | ZXingQml.Code39`).
    using BF = ZXingQml::BarcodeFormat;
    add("Linear codes", (unsigned)BF::LinearCodes);
    add("Aztec",        (unsigned)BF::Aztec);
    add("Data Matrix",  (unsigned)BF::DataMatrix);
    add("MaxiCode",     (unsigned)BF::MaxiCode);
    add("PDF417",       (unsigned)BF::PDF417);
    add("QR Code",      (unsigned)BF::QRCode);
    add("µQR Code",     (unsigned)BF::MicroQRCode);

#elif defined(QMS_USE_QZXING)
    // Native QZXing::DecoderFormat bit values, passed straight through to enabledDecoders.
    add("Linear codes", QZXing::DecoderFormat::LinearCodes);
    add("Aztec",        QZXing::DecoderFormat::DecoderFormat_Aztec);
    add("Data Matrix",  QZXing::DecoderFormat::DecoderFormat_DATA_MATRIX);
    add("MaxiCode",     QZXing::DecoderFormat::DecoderFormat_MAXICODE);
    add("PDF417",       QZXing::DecoderFormat::DecoderFormat_PDF_417);
    add("QR Code",      QZXing::DecoderFormat::DecoderFormat_QR_CODE);
#endif

    return formats;
}

/* ************************************************************************** */

bool UtilsBarcode::isTextFile(const QUrl &fileUrl)
{
    if (!fileUrl.isLocalFile()) return false;

    return QMimeDatabase().mimeTypeForFile(fileUrl.toLocalFile()).inherits("text/plain");
}

QString UtilsBarcode::loadTextFile(const QUrl &fileUrl)
{
    static constexpr qint64 maxSize = 4 * 1024;

    if (!isTextFile(fileUrl))
    {
        qWarning() << "UtilsBarcode::loadTextFile() not a text file:" << fileUrl;
        return QString();
    }

    QFile file(fileUrl.toLocalFile());
    if (file.size() > maxSize)
    {
        qWarning() << "UtilsBarcode::loadTextFile() file too big:" << file.size() << "bytes";
        return QString();
    }
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qWarning() << "UtilsBarcode::loadTextFile() unable to open:" << file.errorString();
        return QString();
    }

    return QString::fromUtf8(file.readAll());
}

/* ************************************************************************** */
