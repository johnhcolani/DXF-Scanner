import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../models/image_data.dart';

class ImageCaptureService {
  static final ImageCaptureService _instance = ImageCaptureService._internal();
  factory ImageCaptureService() => _instance;
  ImageCaptureService._internal();

  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  // Camera initialization
  Future<void> initializeCamera() async {
    if (_cameras != null) return;
    
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
    }
  }

  // Permission handling
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Camera capture
  Future<ImageData?> captureImage() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await initializeCamera();
      }

      final XFile image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      return ImageData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: image.path,
        imageBytes: imageBytes,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  // Gallery picker
  Future<ImageData?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      final File imageFile = File(image.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      return ImageData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: image.path,
        imageBytes: imageBytes,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Save image to app directory
  Future<String?> saveImageToAppDirectory(Uint8List imageBytes) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'captured_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${appDir.path}/$fileName';
      
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);
      
      return filePath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  // Get camera controller for UI
  CameraController? get cameraController => _cameraController;

  // Dispose camera resources
  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
    _cameras = null;
  }

  // Check if camera is available
  bool get isCameraAvailable => _cameras != null && _cameras!.isNotEmpty;

  // Get camera preview widget
  Widget? getCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }
    return CameraPreview(_cameraController!);
  }
}
