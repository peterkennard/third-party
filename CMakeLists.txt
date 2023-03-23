# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.8)

project ("third-party")

add_subdirectory ("./oss-zlib")
add_subdirectory ("./oss-libpng")
add_subdirectory("./oss-glfw")

if(WIN32)
    add_subdirectory ("./vulkan-sdk-windows")
elseif(APPLE)
    add_subdirectory ("./vulkan-sdk-macos")
endif()


# add_subdirectory ("./freetype")
