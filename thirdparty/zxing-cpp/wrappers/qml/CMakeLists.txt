cmake_minimum_required(VERSION 3.24)

project(ZXingQml LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL ON)

################################################################################

set(SOURCES
    ZXingQml.cpp
    ZXingQml.h
)

if(ZXING_READERS)
    set(SOURCES ${SOURCES}
        ZXingQmlVideoFilter.cpp
        ZXingQmlVideoFilter.h
    )
endif()

if(ZXING_WRITERS)
    set(SOURCES ${SOURCES}
        ZXingQmlImageProvider.cpp
        ZXingQmlImageProvider.h
    )
endif()

################################################################################

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Concurrent Qml Quick Multimedia)

qt_add_library(ZXingQml STATIC)
qt_add_qml_module(ZXingQml
    URI ZXingQml
    VERSION 1.0
    PLUGIN_TARGET ZXingQml_plugin
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/ZXingQml
    SOURCES ${SOURCES}
)

target_link_libraries(ZXingQml PUBLIC ZXing::ZXing)
target_link_libraries(ZXingQml PUBLIC Qt6::Core Qt6::Qml Qt6::Quick Qt6::Multimedia)
target_link_libraries(ZXingQml PRIVATE Qt6::Concurrent)
#qt_add_ios_ffmpeg_libraries(ZXingQml)

target_include_directories(ZXingQml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################
