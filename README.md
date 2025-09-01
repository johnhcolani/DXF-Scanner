
# DXF Scanner App 📱✏️

A Flutter application that converts handwriting and sketches captured via camera or selected from gallery into DXF format for use in CAD software.

## ✨ Features

### Core Functionality
- **📷 Camera Capture**: Take photos of handwriting/sketches using device camera
- **🖼️ Gallery Selection**: Choose existing images from device gallery
- **🔄 Image Processing**: Advanced image preprocessing with noise reduction and edge detection
- **📐 Vector Extraction**: Extract vector paths from processed images
- **📄 DXF Generation**: Convert vector paths to DXF format
- **📤 File Sharing**: Share generated DXF files via email, messaging, or cloud storage

### Technical Features
- **🌐 Cross-platform**: Works on iOS, Android, and web
- **⚡ Real-time Processing**: Background processing with progress indicators
- **🎨 Modern UI**: Material Design 3 with dark/light theme support
- **⚠️ Error Handling**: Comprehensive error handling and user feedback
- **🚀 Performance Optimized**: Efficient image processing algorithms

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/
│   └── image_data.dart       # Image data model
├── services/
│   ├── image_capture_service.dart  # Camera and gallery integration
│   ├── image_processor.dart        # Image processing algorithms
│   ├── dxf_generator.dart          # DXF file generation
│   └── file_manager.dart           # File operations and sharing
├── providers/
│   └── app_state.dart        # State management
├── screens/
│   └── home_screen.dart      # Main app screen
└── widgets/
    ├── camera_widget.dart    # Camera interface
    ├── image_preview.dart    # Image preview component
    └── progress_indicator.dart # Processing progress UI
```

### Key Components

#### Image Processing Pipeline
1. **Image Capture** → Camera/Gallery selection
2. **Preprocessing** → Grayscale conversion, noise reduction, contrast enhancement
3. **Edge Detection** → Sobel operator for edge detection
4. **Contour Extraction** → Boundary following algorithm
5. **Vector Simplification** → Douglas-Peucker algorithm
6. **DXF Generation** → Custom DXF writer

#### State Management
- Uses Provider pattern for state management
- Centralized app state with processing status tracking
- Real-time progress updates and error handling

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / VS Code
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/johncolani/dxf-scanner.git
   cd dxf-scanner
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Platform-specific setup**

   **Android:**
   - Add camera permissions to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   ```

   **iOS:**
   - Add camera permissions to `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access to capture handwriting and sketches.</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>This app needs photo library access to select images.</string>
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

### Basic Workflow

1. **Launch the app** - The home screen displays capture options
2. **Capture or select image**:
   - Tap "Camera" to take a photo
   - Tap "Gallery" to select from existing images
3. **Review image** - Preview the captured/selected image
4. **Convert to DXF** - Tap "Convert to DXF" to process the image
5. **Share file** - Use "Share DXF File" to send the generated file

### Image Requirements

For best results:
- **Resolution**: Minimum 512x512 pixels, recommended 1024x1024 or higher
- **Format**: JPEG or PNG
- **Content**: Clear handwriting or line drawings on contrasting background
- **Lighting**: Good lighting with minimal shadows
- **Angle**: Straight-on capture with minimal perspective distortion

## 🛠️ Development

### Dependencies

#### Core Dependencies
- `camera: ^0.10.5+9` - Camera functionality
- `image_picker: ^1.0.7` - Gallery image selection
- `image: ^4.1.7` - Image processing algorithms
- `path_provider: ^2.1.2` - File system access
- `permission_handler: ^11.3.1` - Permission management
- `share_plus: ^7.2.2` - File sharing
- `provider: ^6.1.2` - State management

#### Development Dependencies
- `flutter_lints: ^5.0.0` - Code quality
- `ffi: ^2.1.2` - Future C++ library integration

### Building for Release

#### iOS
```bash
flutter build ios --release
```

#### Android
```bash
flutter build apk --release
```

## 🔮 Future Enhancements

### Planned Features
- **FFI Integration**: C++ library integration for advanced processing
- **AI Enhancement**: Machine learning for better handwriting recognition
- **Cloud Processing**: Server-side processing for complex images
- **Batch Processing**: Multiple image processing
- **Advanced Settings**: User-configurable processing parameters

### Technical Improvements
- **Performance Optimization**: Faster processing algorithms
- **Memory Management**: Improved memory usage
- **Error Recovery**: Better error handling and recovery
- **Testing**: Comprehensive unit and integration tests

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex algorithms
- Maintain consistent formatting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the development plan document

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Image processing community for algorithms
- CAD software developers for DXF format documentation

---

**Made with ❤️ by John Colani**
