cmake_minimum_required(VERSION 3.20)

project(ZintQml LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

################################################################################

set(SOURCES
    ZintQml.cpp ZintQml.h
    ZintImageProvider.cpp ZintImageProvider.h
)

################################################################################

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Quick)

qt_add_library(ZintQml STATIC ${SOURCES})

if (BUILD_SHARED_LIBS)
    target_link_libraries(ZintQml PRIVATE zint)
else()
    target_link_libraries(ZintQml PRIVATE zint-static)
endif()

target_link_libraries(ZintQml PRIVATE Qt6::Core Qt6::Quick)

target_include_directories(ZintQml PRIVATE zint)
target_include_directories(ZintQml PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

################################################################################
