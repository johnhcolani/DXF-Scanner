import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/image_data.dart';
import '../services/image_capture_service.dart';
import '../services/image_processor.dart';
import '../services/dxf_generator.dart';
import '../services/file_manager.dart';

class AppState extends ChangeNotifier {
  // Current image data
  ImageData? _currentImage;
  ImageData? get currentImage => _currentImage;

  // Processing status
  ProcessingStatus _processingStatus = ProcessingStatus.pending;
  ProcessingStatus get processingStatus => _processingStatus;

  // Processing progress (0.0 to 1.0)
  double _processingProgress = 0.0;
  double get processingProgress => _processingProgress;

  // Generated DXF file path
  String? _dxfFilePath;
  String? get dxfFilePath => _dxfFilePath;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Processing steps
  List<String> _processingSteps = [];
  List<String> get processingSteps => _processingSteps;

  // Services
  final ImageCaptureService _imageCaptureService = ImageCaptureService();
  final ImageProcessor _imageProcessor = ImageProcessor();
  final DXFGenerator _dxfGenerator = DXFGenerator();
  final FileManager _fileManager = FileManager();

  // Initialize app state
  Future<void> initialize() async {
    try {
      await _imageCaptureService.initializeCamera();
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize camera: $e');
    }
  }

  // Capture image from camera
  Future<void> captureImage() async {
    try {
      _setProcessingStatus(ProcessingStatus.processing);
      _clearError();
      _addProcessingStep('Requesting camera permission...');

      final bool hasPermission = await _imageCaptureService.requestCameraPermission();
      if (!hasPermission) {
        _setError('Camera permission denied');
        return;
      }

      _addProcessingStep('Capturing image...');
      final ImageData? imageData = await _imageCaptureService.captureImage();
      
      if (imageData == null) {
        _setError('Failed to capture image');
        return;
      }

      _currentImage = imageData;
      _setProcessingStatus(ProcessingStatus.completed);
      _addProcessingStep('Image captured successfully');
      notifyListeners();
    } catch (e) {
      _setError('Error capturing image: $e');
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      _setProcessingStatus(ProcessingStatus.processing);
      _clearError();
      _addProcessingStep('Opening gallery...');

      final ImageData? imageData = await _imageCaptureService.pickImageFromGallery();
      
      if (imageData == null) {
        _setProcessingStatus(ProcessingStatus.pending);
        _clearProcessingSteps();
        return;
      }

      _currentImage = imageData;
      _setProcessingStatus(ProcessingStatus.completed);
      _addProcessingStep('Image selected successfully');
      notifyListeners();
    } catch (e) {
      _setError('Error picking image: $e');
    }
  }

  // Process image and generate DXF
  Future<void> processImageToDXF() async {
    if (_currentImage == null || _currentImage!.imageBytes == null) {
      _setError('No image to process');
      return;
    }

    try {
      _setProcessingStatus(ProcessingStatus.processing);
      _clearError();
      _clearProcessingSteps();
      _setProgress(0.0);

      // Step 1: Preprocess image
      _addProcessingStep('Preprocessing image...');
      _setProgress(0.2);
      
      final processedImage = await _imageProcessor.processImage(_currentImage!.imageBytes!);
      if (processedImage == null) {
        _setError('Failed to process image');
        return;
      }

      // Step 2: Extract contours
      _addProcessingStep('Extracting contours...');
      _setProgress(0.5);
      
      final contours = _imageProcessor.extractContours(processedImage);
      if (contours.isEmpty) {
        _setError('No contours found in image');
        return;
      }

      // Step 3: Simplify contours
      _addProcessingStep('Simplifying contours...');
      _setProgress(0.7);
      
      final simplifiedContours = contours.map((contour) {
        return _imageProcessor.simplifyContour(contour, 2.0);
      }).toList();

      // Step 4: Generate DXF
      _addProcessingStep('Generating DXF file...');
      _setProgress(0.9);
      
      final fileName = 'dxf_${_currentImage!.id}';
      final dxfPath = await _dxfGenerator.generateDXF(simplifiedContours, fileName);
      
      if (dxfPath == null) {
        _setError('Failed to generate DXF file');
        return;
      }

      _dxfFilePath = dxfPath;
      _setProcessingStatus(ProcessingStatus.completed);
      _addProcessingStep('DXF file generated successfully');
      _setProgress(1.0);
      
      notifyListeners();
    } catch (e) {
      _setError('Error processing image: $e');
    }
  }

  // Share DXF file
  Future<void> shareDXFFile() async {
    if (_dxfFilePath == null) {
      _setError('No DXF file to share');
      return;
    }

    try {
      final bool success = await _fileManager.shareFile(
        _dxfFilePath!,
        subject: 'DXF File from Handwriting',
        text: 'Generated DXF file from handwriting/sketch',
      );

      if (!success) {
        _setError('Failed to share DXF file');
      }
    } catch (e) {
      _setError('Error sharing file: $e');
    }
  }

  // Clear current image and reset state
  void clearCurrentImage() {
    _currentImage = null;
    _dxfFilePath = null;
    _setProcessingStatus(ProcessingStatus.pending);
    _clearError();
    _clearProcessingSteps();
    _setProgress(0.0);
    notifyListeners();
  }

  // Get camera controller for UI
  CameraController? get cameraController => _imageCaptureService.cameraController;

  // Check if camera is available
  bool get isCameraAvailable => _imageCaptureService.isCameraAvailable;

  // Get camera preview widget
  Widget? getCameraPreview() => _imageCaptureService.getCameraPreview();

  // Private helper methods
  void _setProcessingStatus(ProcessingStatus status) {
    _processingStatus = status;
    notifyListeners();
  }

  void _setProgress(double progress) {
    _processingProgress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setProcessingStatus(ProcessingStatus.failed);
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _addProcessingStep(String step) {
    _processingSteps.add(step);
    notifyListeners();
  }

  void _clearProcessingSteps() {
    _processingSteps.clear();
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _imageCaptureService.dispose();
    super.dispose();
  }
}
