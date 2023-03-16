# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.8)

project ("oss-libs")

if(APPLE)
    add_subdirectory ("./oss-glfw")
endif()

# add_subdirectory ("./zlib")
# add_subdirectory ("./oss-libpng")
# add_subdirectory ("./freetype")
