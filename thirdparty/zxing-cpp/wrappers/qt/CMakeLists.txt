
set(SOURCES
    ZXingQt.cpp
    ZXingQt.h
)

if (BUILD_READERS)
    set(SOURCES ${SOURCES}
        ZXingQtVideoFilter.cpp
        ZXingQtVideoFilter.h
    )
endif()

if (BUILD_WRITERS)
    set(SOURCES ${SOURCES}
        ZXingQtImageProvider.cpp
        ZXingQtImageProvider.h
    )
endif()

add_library (ZXingQt ${SOURCES})

target_link_libraries (ZXingQt PRIVATE ZXing::ZXing)
target_include_directories (ZXingQt PRIVATE ZXing::ZXing)

find_package (Qt6 REQUIRED COMPONENTS Core Concurrent Quick Multimedia)
target_link_libraries (ZXingQt PRIVATE Qt6::Core Qt6::Concurrent Qt6::Quick Qt6::Multimedia)

target_include_directories (ZXingQt PUBLIC ${CMAKE_CURRENT_LIST_DIR})
