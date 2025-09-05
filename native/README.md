# C++ Corner Detection Library

This directory contains a C++ library that uses OpenCV for advanced corner detection and geometric primitive extraction from images.

## Features

- **Harris Corner Detection**: Detects corners using OpenCV's Harris corner detector
- **Line Detection**: Uses Hough transform to detect straight lines
- **Circle Detection**: Uses HoughCircles to detect circular shapes
- **Arc Detection**: Analyzes corner relationships to detect arcs
- **Geometric Primitives**: Outputs clean geometric data (lines, arcs, circles)

## Dependencies

- **OpenCV 4.x**: Computer vision library
- **CMake 3.10+**: Build system
- **C++17**: Modern C++ standard

## Building the Library

### Windows

```bash
# Install OpenCV (using vcpkg recommended)
vcpkg install opencv4:x64-windows

# Build the library
cd native
mkdir build
cd build
cmake -G "Visual Studio 16 2019" -A x64 ..
cmake --build . --config Release

# Copy to Flutter project
copy "Release\corner_detector.dll" "..\..\windows\runner\Release\"
```

### Linux

```bash
# Install OpenCV
sudo apt-get install libopencv-dev

# Build the library
cd native
mkdir build
cd build
cmake ..
make -j$(nproc)

# Copy to Flutter project
cp libcorner_detector.so ../linux/
```

### macOS

```bash
# Install OpenCV
brew install opencv

# Build the library
cd native
mkdir build
cd build
cmake ..
make -j$(sysctl -n hw.ncpu)

# Copy to Flutter project
cp libcorner_detector.dylib ../macos/Runner/
```

## Usage

The library provides a C-style interface for FFI integration with Flutter:

```cpp
// Create detector
CornerDetector* detector = createCornerDetector();

// Process image
GeometricPrimitives* primitives = processImageFFI(
    detector,
    imageData,
    width,
    height,
    channels
);

// Extract results
int lineCount = getLineCount(primitives);
int arcCount = getArcCount(primitives);
int circleCount = getCircleCount(primitives);

// Cleanup
destroyGeometricPrimitives(primitives);
destroyCornerDetector(detector);
```

## Algorithm Details

### Corner Detection

- Uses Harris corner detector with configurable parameters
- Applies Gaussian blur to reduce noise
- Filters corners by quality level and minimum distance

### Line Detection

- Canny edge detection for edge extraction
- Hough transform for line detection
- Configurable parameters for line length and gap tolerance

### Circle Detection

- Gaussian blur preprocessing
- HoughCircles with configurable parameters
- Radius range filtering

### Arc Detection

- Analyzes triplets of corners
- Calculates angles to determine arc likelihood
- Computes circle center and radius from three points

## Parameters

The library uses configurable parameters for all detection algorithms:

- **Corner Detection**: Quality level, minimum distance, block size
- **Line Detection**: Rho, theta, threshold, minimum line length, maximum gap
- **Circle Detection**: DP, minimum distance, parameter thresholds, radius range

## Integration with Flutter

The library is integrated with Flutter using FFI (Foreign Function Interface):

1. **Dart FFI Bindings**: `corner_detector_ffi.dart`
2. **Geometric DXF Generator**: `geometric_dxf_generator.dart`
3. **Native Library**: Built C++ library with OpenCV

## Benefits

1. **Better Accuracy**: OpenCV provides robust computer vision algorithms
2. **Geometric Primitives**: Outputs clean geometric data instead of pixel contours
3. **AutoCAD Compatibility**: Proper LINE, ARC, and CIRCLE entities
4. **Performance**: C++ implementation is faster than Dart image processing
5. **Stability**: Well-tested OpenCV algorithms reduce crashes

## Troubleshooting

### Build Issues

- Ensure OpenCV is properly installed and CMake can find it
- Check that C++17 compiler is available
- Verify all dependencies are installed

### Runtime Issues

- Ensure the native library is in the correct location
- Check that OpenCV runtime libraries are available
- Verify image data format matches expected channels

### Performance Issues

- Adjust detection parameters for your specific use case
- Consider image preprocessing to improve detection quality
- Monitor memory usage with large images


