MobileScanner
=============

[![GitHub action](https://img.shields.io/github/actions/workflow/status/emericg/MobileScanner/builds_desktop.yml?style=flat-square)](https://github.com/emericg/MobileScanner/actions)
[![GitHub issues](https://img.shields.io/github/issues/emericg/MobileScanner.svg?style=flat-square)](https://github.com/emericg/MobileScanner/issues)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-brightgreen.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)

Demo barcode & QR code scanner based on qzxing and zxing-cpp libraries.

### Features

- UIs
  - [x] Phone UI
  - [ ] Tablet (WIP)
  - [x] Desktop UI (WIP)
- General features
  - [x] Barcode reader
    - [x] Multi camera support
    - [x] Read from picture (WIP)
  - [x] Barcode writer
    - [x] Save to picture (WIP)
    - [x] Save to vector (WIP)
  - [x] Barcodes history


## Supported Formats (QZXing)

[QZXing](https://github.com/ftylitak/qzxing/) is a Qt/QML wrapper library for the ZXing barcode image processing library.

| Linear / 1D barcodes | Matrix / 2D barcodes |
| -------------------- | -------------------- |
| UPC-A                | QR Code              |
| UPC-E                | Data Matrix          |
| EAN-8                | PDF 417              |
| EAN-13               | Aztec (beta)         |
| Code 39              |                      |
| Code 93              |                      |
| Code 128 (GS1)       |                      |
| Codabar              |                      |
| ITF                  |                      |


## Supported Formats (zxing-cpp)

[zxing-cpp](https://github.com/zxing-cpp/zxing-cpp/) is an open-source, multi-format linear/matrix barcode image processing library implemented in C++.

| Linear / 1D barcodes | Matrix / 2D barcodes |
| -------------------- | -------------------- |
| UPC-A                | QR Code              |
| UPC-E                | Micro QR Code        |
| EAN-8                | Aztec                |
| EAN-13               | DataMatrix           |
| DataBar              | PDF417               |
| DataBar Expanded     | MaxiCode (partial)   |
| Code 39              |                      |
| Code 93              |                      |
| Code 128 (GS1)       |                      |
| Codabar              |                      |
| ITF                  |                      |


## Third party projects used by MobileScanner

* [Qt6](https://www.qt.io) ([LGPL v3](https://www.gnu.org/licenses/lgpl-3.0.txt))
* [MobileUI](src/thirdparty/MobileUI/) ([MIT](https://opensource.org/licenses/MIT))
* [MobileSharing](src/thirdparty/MobileSharing/) ([MIT](https://opensource.org/licenses/MIT))
* [QZXing](https://github.com/ftylitak/qzxing/) ([Apache v2](https://opensource.org/licenses/apache-2-0))
* [zxing-cpp](https://github.com/zxing-cpp/zxing-cpp/) ([Apache v2](https://opensource.org/licenses/apache-2-0))
* Graphical resources: [assets/COPYING](assets/COPYING)


## Get involved!

#### Developers

You can browse the code on the GitHub page, submit patches and pull requests! Your help would be greatly appreciated ;-)

#### Users

You can help us find and report bugs, suggest new features, help with translation, documentation and more! Visit the Issues section of the GitHub page to start!


## License

MobileScanner is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read the [LICENSE](LICENSE) file or [consult the license on the FSF website](https://www.gnu.org/licenses/gpl-3.0.txt) directly.

> Emeric Grange <emeric.grange@gmail.com>
