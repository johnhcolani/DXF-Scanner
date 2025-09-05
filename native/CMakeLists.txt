cmake_minimum_required(VERSION 3.10)
project(CornerDetector)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find OpenCV
find_package(OpenCV REQUIRED)

# Include directories
include_directories(${OpenCV_INCLUDE_DIRS})

# Create shared library
add_library(corner_detector SHARED
    corner_detector.cpp
    corner_detector.h
)

# Link OpenCV libraries
target_link_libraries(corner_detector ${OpenCV_LIBS})

# Set output directory
set_target_properties(corner_detector PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Platform-specific settings
if(WIN32)
    set_target_properties(corner_detector PROPERTIES
        OUTPUT_NAME "corner_detector"
        SUFFIX ".dll"
    )
elseif(APPLE)
    set_target_properties(corner_detector PROPERTIES
        OUTPUT_NAME "corner_detector"
        SUFFIX ".dylib"
    )
else()
    set_target_properties(corner_detector PROPERTIES
        OUTPUT_NAME "corner_detector"
        SUFFIX ".so"
    )
endif()

# Compiler-specific options
if(MSVC)
    target_compile_options(corner_detector PRIVATE /W4)
else()
    target_compile_options(corner_detector PRIVATE -Wall -Wextra -pedantic)
endif()


