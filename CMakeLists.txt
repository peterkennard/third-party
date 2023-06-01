# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.8)

project ("third-party")

add_subdirectory ("./oss-zlib")
add_subdirectory ("./oss-libpng")
add_subdirectory ("./oss-glfw")
add_subdirectory ("./vk-spirv-reflect")
add_subdirectory ("./tinyobjloader")
add_subdirectory ("./google-dawn")

add_subdirectory ("./freetype")
