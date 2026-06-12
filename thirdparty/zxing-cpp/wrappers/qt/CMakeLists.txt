cmake_minimum_required(VERSION 3.20)

project(ZXingQt LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

################################################################################

set(SOURCES
    ZXingQt.cpp
    ZXingQt.h
)

if(ZXING_READERS)
    set(SOURCES ${SOURCES}
        ZXingQtVideoFilter.cpp
        ZXingQtVideoFilter.h
    )
endif()

if(ZXING_WRITERS)
    set(SOURCES ${SOURCES}
        ZXingQtImageProvider.cpp
        ZXingQtImageProvider.h
    )
endif()

################################################################################

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Concurrent Quick Multimedia)

qt_add_library(ZXingQt STATIC ${SOURCES})

target_link_libraries(ZXingQt PRIVATE ZXing::ZXing)
target_link_libraries(ZXingQt PRIVATE Qt6::Core Qt6::Concurrent Qt6::Quick Qt6::Multimedia)
#qt_add_ios_ffmpeg_libraries(ZXingQt)

target_include_directories(ZXingQt PRIVATE ZXing::ZXing)
target_include_directories(ZXingQt PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################
