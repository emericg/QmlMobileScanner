QmlMobileScanner
================

[![GitHub action](https://img.shields.io/github/actions/workflow/status/emericg/QmlMobileScanner/builds_mobile.yml?style=flat-square)](https://github.com/emericg/QmlMobileScanner/actions)
[![GitHub issues](https://img.shields.io/github/issues/emericg/QmlMobileScanner.svg?style=flat-square)](https://github.com/emericg/QmlMobileScanner/issues)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-brightgreen.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0)

Demo barcode & QR code scanner based on qzxing and zxing-cpp libraries to scan and generate barcodes, and zint to generate some extra formats.

> Works on Linux, macOS, Windows, Android and iOS!

### Features

- UIs
  - [x] Phone UI
  - [x] Tablet UI
  - [x] Desktop UI
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


## Supported Formats (zint)

[zint](https://github.com/zint/zint/) is a barcode encoding library supporting over 50 symbologies including Code 128, Data Matrix, USPS OneCode, EAN-128, UPC/EAN, ITF, QR Code, Code 16k, PDF417, MicroPDF417, LOGMARS, Maxicode, GS1 DataBar, Aztec, Composite Symbols and more.


## Documentation

#### Dependencies

You will need a C++17 compiler and Qt 6.5+ with the following 'additional librairies':  
- Qt Multimedia

For Android builds, you'll need the appropriates JDK (11) SDK (23+) and NDK (25+). You can customize Android build environment using the `assets/android/gradle.properties` file.  
For Windows builds, you'll need the MSVC 2019+ compiler. Bluetooth won't work with MinGW.  
For macOS and iOS builds, you'll need Xcode 13+ installed.  

#### Building QmlMobileScanner

```bash
$ git clone https://github.com/emericg/QmlMobileScanner.git
$ cd QmlMobileScanner/
$ qmake6
$ make
```


## Screenshots

![GUI_MOBILE](https://i.imgur.com/Yc5TCwk.png)

![GUI_DESKTOP](https://i.imgur.com/H4HYNdN.png)


## Third party projects used by QmlMobileScanner

* [Qt6](https://www.qt.io) ([LGPL v3](https://www.gnu.org/licenses/lgpl-3.0.txt))
* [MobileUI](src/thirdparty/MobileUI/) ([MIT](https://opensource.org/licenses/MIT))
* [MobileSharing](src/thirdparty/MobileSharing/) ([MIT](https://opensource.org/licenses/MIT))
* [QZXing](https://github.com/ftylitak/qzxing/) ([Apache v2](https://opensource.org/licenses/apache-2-0))
* [zxing-cpp](https://github.com/zxing-cpp/zxing-cpp/) ([Apache v2](https://opensource.org/licenses/apache-2-0))
* [zint](https://github.com/zint/zint) ([3-Clause BSD License](https://opensource.org/license/bsd-3-clause))
* Graphical resources: [assets/COPYING](assets/COPYING)


## Get involved!

#### Developers

You can browse the code on the GitHub page, submit patches and pull requests! Your help would be greatly appreciated ;-)

#### Users

You can help us find and report bugs, suggest new features, help with translation, documentation and more! Visit the Issues section of the GitHub page to start!


## License

QmlMobileScanner is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  
Read the [LICENSE](LICENSE) file or [consult the license on the FSF website](https://www.gnu.org/licenses/gpl-3.0.txt) directly.

> Emeric Grange <emeric.grange@gmail.com>
