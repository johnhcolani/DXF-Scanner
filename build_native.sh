#!/bin/bash

echo "Building C++ Corner Detector Library..."

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake ../native
if [ $? -ne 0 ]; then
    echo "CMake configuration failed!"
    exit 1
fi

# Build the project
make -j$(nproc)
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Copy the library to the Flutter project
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    cp libcorner_detector.dylib ../macos/Runner/
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    cp libcorner_detector.so ../linux/
fi

echo "Build completed successfully!"
echo "Library copied to Flutter project."


