cmake_minimum_required(VERSION 3.24)

project(QmlQrEncode LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

################################################################################

# libqrencode 4.1.1 (LGPL-2.1), trimmed down to the library sources
add_library(QmlQrEncode_libqrencode OBJECT
    libqrencode/qrencode.c libqrencode/qrencode.h libqrencode/qrencode_inner.h
    libqrencode/qrinput.c libqrencode/qrinput.h
    libqrencode/bitstream.c libqrencode/bitstream.h
    libqrencode/qrspec.c libqrencode/qrspec.h
    libqrencode/rsecc.c libqrencode/rsecc.h
    libqrencode/split.c libqrencode/split.h
    libqrencode/mask.c libqrencode/mask.h
    libqrencode/mqrspec.c libqrencode/mqrspec.h
    libqrencode/mmask.c libqrencode/mmask.h
)

set_target_properties(QmlQrEncode_libqrencode PROPERTIES POSITION_INDEPENDENT_CODE ON)

target_compile_definitions(QmlQrEncode_libqrencode PRIVATE
    MAJOR_VERSION=4 MINOR_VERSION=1 MICRO_VERSION=1 VERSION="4.1.1"
    STATIC_IN_RELEASE=static
    HAVE_STRDUP=1
    $<$<C_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE>
)

# Thread-safe lazy initialization of the Reed-Solomon tables
if(NOT WIN32)
    find_package(Threads REQUIRED)
    target_compile_definitions(QmlQrEncode_libqrencode PRIVATE HAVE_LIBPTHREAD=1)
    target_link_libraries(QmlQrEncode_libqrencode PRIVATE Threads::Threads)
endif()

################################################################################

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_add_library(QmlQrEncode STATIC)
qt_add_qml_module(QmlQrEncode
    URI QmlQrEncode
    VERSION 1.0
    DEPENDENCIES QtQuick
    PLUGIN_TARGET QmlQrEncode_plugin
    SOURCES QmlQrEncode.cpp QmlQrEncode.h
)

target_link_libraries(QmlQrEncode PRIVATE QmlQrEncode_libqrencode)
target_link_libraries(QmlQrEncode PUBLIC Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick)

################################################################################
