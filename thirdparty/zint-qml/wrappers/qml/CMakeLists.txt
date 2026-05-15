
set(SOURCES
    ZintQml.cpp ZintQml.h
    ZintImageProvider.cpp ZintImageProvider.h
)

add_library(ZintQml ${SOURCES})

if (BUILD_SHARED_LIBS)
    target_link_libraries(ZintQml PRIVATE zint)
else()
    target_link_libraries(ZintQml PRIVATE zint-static)
endif()

target_include_directories(ZintQml PRIVATE zint)

find_package(Qt6 REQUIRED COMPONENTS Core Quick)
target_link_libraries(ZintQml PRIVATE Qt6::Core Qt6::Quick)

target_include_directories(ZintQml PUBLIC ${CMAKE_CURRENT_LIST_DIR})
