cmake_minimum_required (VERSION 3.8.12)

project ("google-dawn")

if( PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)

    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

    add_subdirectory ("./dawn-dist")
else()

    add_library("google-dawn" SHARED
         IMPORTED GLOBAL)

    # include ("./CMakeExports.raked")
endif()
