cmake_minimum_required (VERSION 3.8.12)

project ("oss-libpng")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if( PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    add_subdirectory ("./libpng")
else()
    include ("./CMakeExports.raked")
endif()
