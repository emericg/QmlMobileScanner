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

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Concurrent Quick Multimedia)

qt_add_library(ZXingQml STATIC ${SOURCES})

target_link_libraries(ZXingQml PRIVATE ZXing::ZXing)
target_link_libraries(ZXingQml PRIVATE Qt6::Core Qt6::Concurrent Qt6::Quick Qt6::Multimedia)
#qt_add_ios_ffmpeg_libraries(ZXingQml)

target_include_directories(ZXingQml PRIVATE ZXing::ZXing)
target_include_directories(ZXingQml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################
