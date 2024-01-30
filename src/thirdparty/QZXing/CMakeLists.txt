cmake_minimum_required(VERSION 3.3)
project(QZXing)

option(BUILD_SHARED "Build as shared library" ON)

if(BUILD_SHARED)
    set(SOVERSION_MAJOR 3)
    set(SOVERSION_MINOR 3)
    set(SOVERSION_PATCH 0)

    OPTION(QZXING_MULTIMEDIA "" ON)
    OPTION(QZXING_USE_QML "" ON)
    OPTION(QZXING_USE_ENCODER "" ON)
    OPTION(QZXING_MULTIMEDIA "" ON)
    OPTION(QZXING_USE_QML "" ON)
    OPTION(QZXING_USE_ENCODER "" ON)
    OPTION(QZXING_USE_DECODER_QR_CODE "" ON)
    OPTION(QZXING_USE_DECODER_1D_BARCODES "" ON)
    OPTION(QZXING_USE_DECODER_DATA_MATRIX "" ON)
    OPTION(QZXING_USE_DECODER_AZTEC "" ON)
    OPTION(QZXING_USE_DECODER_PDF17 "" ON)
    OPTION(QZXING_USE_DECODER_1D_BARCODES "" ON)
endif()

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2)
find_package(Qt6 COMPONENTS Core REQUIRED)
find_package(Qt6 COMPONENTS Gui REQUIRED)
find_package(Qt6 COMPONENTS Multimedia)
find_package(Qt6 REQUIRED Quick QuickControls2)

set(BIGINT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/zxing/bigint)
set(WIN32_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/zxing/win32/zxing)
set(ZXING_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/zxing/zxing)

set(CMAKE_AUTOMOC ON)
set(CMAKE_WARN_ON)

set(QZXING_MULTIMEDIA ON)
set(QZXING_USE_QML ON)
set(QZXING_USE_ENCODER ON)

set(PUBLIC_HEADERS
    QZXing.h
    QZXing_global.h
    )

set(SOURCES
    CameraImageWrapper.cpp
    CameraImageWrapper.h
    ImageHandler.cpp
    ImageHandler.h
    QZXing.cpp
    ${PUBLIC_HEADERS}
    )

if(QZXING_MULTIMEDIA)
    LIST(APPEND SOURCES QZXingFilterVideoSink.cpp QZXingFilterVideoSink.h)
    LIST(APPEND PUBLIC_HEADERS QZXingFilter.h)
    add_definitions(-DQZXING_MULTIMEDIA)
endif(QZXING_MULTIMEDIA)

if(QZXING_USE_QML)
    LIST(APPEND SOURCES QZXingImageProvider.cpp QZXingImageProvider.h)
    LIST(APPEND PUBLIC_HEADERS QZXingImageProvider.h)
    add_definitions(-DQZXING_QML)
endif(QZXING_USE_QML)

if(QZXING_USE_ENCODER)
    add_definitions(-DENABLE_ENCODER_GENERIC -DENABLE_ENCODER_QR_CODE)
endif(QZXING_USE_ENCODER)

if(BUILD_SHARED)
    add_library(qzxing SHARED ${SOURCES})
    set_target_properties(qzxing
        PROPERTIES
        VERSION ${SOVERSION_MAJOR}.${SOVERSION_MINOR}.${SOVERSION_PATCH}
        SOVERSION ${SOVERSION_MAJOR}
    )
else()
    add_library(qzxing "" ${SOURCES})
endif()

if(WIN32)
    add_subdirectory(zxing/win32)
    if(MSVC)
        add_definitions(-D__STDC_LIMIT_MACROS)
    endif(MSVC)

    add_definitions(-DNO_ICONV)
endif(WIN32)

if(ANDROID)
    add_definitions(-DNO_ICONV)
endif()

if(APPLE)
    add_definitions(-DNO_ICONV)
endif()

if(VS_WINRT_COMPONENT)
    add_definitions(-DNO_ICONV)
endif(VS_WINRT_COMPONENT)

add_subdirectory(zxing/bigint)

add_subdirectory(zxing/zxing)

target_link_libraries(qzxing Qt6::Core Qt6::Gui)

if(QZXING_MULTIMEDIA)
    target_link_libraries(qzxing Qt6::Multimedia)
    target_compile_definitions(qzxing PUBLIC -DQZXING_MULTIMEDIA)
endif(QZXING_MULTIMEDIA)

if(QZXING_USE_QML)
    target_link_libraries(qzxing
        Qt6::Quick
        Qt6::QuickControls2)
    target_compile_definitions(qzxing PUBLIC -DQZXING_QML)
endif(QZXING_USE_QML)

if(QZXING_USE_ENCODER)
    target_compile_definitions(qzxing PUBLIC -DENABLE_ENCODER_GENERIC -DENABLE_ENCODER_QR_CODE)
endif(QZXING_USE_ENCODER)

if(QZXING_USE_DECODER_QR_CODE)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_QR_CODE)
endif()

if(QZXING_USE_DECODER_1D_BARCODES)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_1D_BARCODES)
endif()

if(QZXING_USE_DECODER_DATA_MATRIX)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_DATA_MATRIX)
endif()

if(QZXING_USE_DECODER_AZTEC)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_AZTEC)
endif()

if(QZXING_USE_DECODER_PDF17)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_PDF17)
endif()

if(QZXING_USE_DECODER_1D_BARCODES)
    target_compile_definitions(qzxing PRIVATE -DENABLE_DECODER_1D_BARCODES)
endif()

if(!BUILD_SHARED)
    # Change Global Definitions depending on how you want to use the library
    target_compile_definitions(qzxing PUBLIC DISABLE_LIBRARY_FEATURES)
endif()

# Target includes
target_include_directories(qzxing
    PRIVATE
        .
        zxing
        zxing/win32/zxing
        zxing/zxing
        zxing/bigint
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

if(BUILD_SHARED)
    include (GNUInstallDirs)

    set(QZXING_INSTALL_TARGETS qzxing)

    install (
        TARGETS ${QZXING_INSTALL_TARGETS} EXPORT QZXingTargets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    install (
        FILES ${PUBLIC_HEADERS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/qzxing"
    )
endif()
