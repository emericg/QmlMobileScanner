
set(SOURCES
    ZintQml.cpp ZintQml.h
    ZintImageProvider.cpp ZintImageProvider.h
)

add_library (ZintQml ${SOURCES})

#target_link_libraries (ZintQml PRIVATE zint-package::zint)
#target_include_directories (ZintQml PRIVATE zint-package::zint)

find_package (Qt6 REQUIRED COMPONENTS Core Quick)
target_link_libraries (ZintQml PRIVATE Qt6::Core Qt6::Quick)

target_include_directories (ZintQml PUBLIC ${CMAKE_CURRENT_LIST_DIR})
