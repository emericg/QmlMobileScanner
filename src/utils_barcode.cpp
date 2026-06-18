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

#include <QVariantMap>

#if defined(QMS_USE_ZXINGCPP)
#include <ZXingQt>
#endif
#if defined(QMS_USE_QZXING)
#include <QZXing>
#endif

/* ************************************************************************** */

UtilsBarcode *UtilsBarcode::instance = nullptr;

UtilsBarcode *UtilsBarcode::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsBarcode();
    }

    return instance;
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
    // Bit values come from ZXingQt::BarcodeFormat (ZXingQt.h), the canonical definition of the
    // legacy zxing-cpp formatsEnabled layout (also used by appBitmaskToZXingFormats() and usable
    // directly from QML, e.g. `formats: ZXingQt.QRCode | ZXingQt.Code39`).
    using BF = ZXingQt::BarcodeFormat;
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
