cmake_minimum_required(VERSION 3.10)
project(native_opencv VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
set(SOURCES
    src/native_opencv.cpp
    src/aruco_detector.cpp
    src/homography_warper.cpp
    src/macbeth_ccm.cpp
    src/color_space.cpp
)

# Headers
set(HEADERS
    src/native_opencv.h
    src/aruco_detector.h
    src/homography_warper.h
    src/macbeth_ccm.h
    src/color_space.h
)

# Optional OpenCV integration if installed via NDK or local system
find_package(OpenCV QUIET)
if (OpenCV_FOUND)
    message(STATUS "OpenCV found: ${OpenCV_VERSION}")
    include_directories(${OpenCV_INCLUDE_DIRS})
    add_definitions(-DHAVE_OPENCV=1)
else()
    message(STATUS "Building with built-in optimized C++ computer vision engine")
    add_definitions(-DHAVE_OPENCV=0)
endif()

add_library(native_opencv SHARED
    ${SOURCES}
    ${HEADERS}
)

target_include_directories(native_opencv PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

if (OpenCV_FOUND)
    target_link_libraries(native_opencv PRIVATE ${OpenCV_LIBS})
endif()

# Compiler definitions for exporting symbols
if (WIN32)
    target_compile_definitions(native_opencv PRIVATE BUILDING_NATIVE_OPENCV_DLL)
endif()
