cmake_minimum_required (VERSION 3.8)

project ("oss-zlib")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if( PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    add_subdirectory("./zlib")
else()
    include ("./CMakeExports.raked")
    # include ("./CmakeBuild.raked")
endif()

#    target_include_directories("oss-zlib" BEFORE PUBLIC "." "../../build/include")
