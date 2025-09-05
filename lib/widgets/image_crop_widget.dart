import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/image_data.dart';

class ImageCropWidget extends StatefulWidget {
  final ImageData imageData;
  final Function(Uint8List croppedImageBytes) onCropComplete;

  const ImageCropWidget({
    super.key,
    required this.imageData,
    required this.onCropComplete,
  });

  @override
  State<ImageCropWidget> createState() => _ImageCropWidgetState();
}

class _ImageCropWidgetState extends State<ImageCropWidget> {
  late Rect _cropRect;
  bool _isDragging = false;
  String? _draggedCorner;
  late double _imageWidth;
  late double _imageHeight;
  late double _displayWidth;
  late double _displayHeight;
  late double _scaleX;
  late double _scaleY;

  @override
  void initState() {
    super.initState();
    _initializeCropArea();
  }

  void _initializeCropArea() {
    // Initialize crop area to cover most of the image
    _cropRect = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _cropImage,
            child: const Text(
              'CROP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildCropInterface(constraints);
          },
        ),
      ),
    );
  }

  Widget _buildCropInterface(BoxConstraints constraints) {
    if (widget.imageData.imageBytes == null) {
      return const Center(
        child: Text(
          'No image data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Calculate display dimensions
    final maxWidth = constraints.maxWidth;
    final maxHeight = constraints.maxHeight - 100; // Account for app bar

    _displayWidth = maxWidth;
    _displayHeight = maxHeight;

    // Calculate scale factors
    final image = img.decodeImage(widget.imageData.imageBytes!);
    if (image == null) {
      return const Center(
        child: Text(
          'Failed to decode image',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    _imageWidth = image.width.toDouble();
    _imageHeight = image.height.toDouble();

    // Calculate scale to fit image in display area
    final scaleX = _displayWidth / _imageWidth;
    final scaleY = _displayHeight / _imageHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    _scaleX = scale;
    _scaleY = scale;

    final scaledImageWidth = _imageWidth * scale;
    final scaledImageHeight = _imageHeight * scale;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Drag the corners to select the area to convert',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: Stack(
              children: [
                // Image
                Positioned(
                  left: (_displayWidth - scaledImageWidth) / 2,
                  top: (_displayHeight - scaledImageHeight) / 2,
                  child: Image.memory(
                    widget.imageData.imageBytes!,
                    width: scaledImageWidth,
                    height: scaledImageHeight,
                    fit: BoxFit.contain,
                  ),
                ),
                // Crop overlay
                Positioned(
                  left: (_displayWidth - scaledImageWidth) / 2,
                  top: (_displayHeight - scaledImageHeight) / 2,
                  child: SizedBox(
                    width: scaledImageWidth,
                    height: scaledImageHeight,
                    child: _buildCropOverlay(scaledImageWidth, scaledImageHeight),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildCropControls(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCropOverlay(double imageWidth, double imageHeight) {
    final cropLeft = _cropRect.left * imageWidth;
    final cropTop = _cropRect.top * imageHeight;
    final cropRight = _cropRect.right * imageWidth;
    final cropBottom = _cropRect.bottom * imageHeight;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: CropOverlayPainter(
          cropRect: Rect.fromLTRB(cropLeft, cropTop, cropRight, cropBottom),
          imageSize: Size(imageWidth, imageHeight),
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildCropControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _resetCrop,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _cropImage,
          icon: const Icon(Icons.crop),
          label: const Text('Crop & Convert'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    
    // Calculate actual image dimensions on screen
    final scaledImageWidth = _imageWidth * _scaleX;
    final scaledImageHeight = _imageHeight * _scaleY;
    
    final cropLeft = _cropRect.left * scaledImageWidth;
    final cropTop = _cropRect.top * scaledImageHeight;
    final cropRight = _cropRect.right * scaledImageWidth;
    final cropBottom = _cropRect.bottom * scaledImageHeight;

    const cornerSize = 30.0;

    // Check which corner is being dragged
    if ((localPosition - Offset(cropLeft, cropTop)).distance < cornerSize) {
      _draggedCorner = 'topLeft';
    } else if ((localPosition - Offset(cropRight, cropTop)).distance < cornerSize) {
      _draggedCorner = 'topRight';
    } else if ((localPosition - Offset(cropLeft, cropBottom)).distance < cornerSize) {
      _draggedCorner = 'bottomLeft';
    } else if ((localPosition - Offset(cropRight, cropBottom)).distance < cornerSize) {
      _draggedCorner = 'bottomRight';
    } else {
      _draggedCorner = 'move';
    }

    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final delta = details.delta;
    
    // Calculate actual image dimensions on screen
    final scaledImageWidth = _imageWidth * _scaleX;
    final scaledImageHeight = _imageHeight * _scaleY;

    setState(() {
      switch (_draggedCorner) {
        case 'topLeft':
          _cropRect = Rect.fromLTRB(
            (_cropRect.left + delta.dx / scaledImageWidth).clamp(0.0, _cropRect.right - 0.1),
            (_cropRect.top + delta.dy / scaledImageHeight).clamp(0.0, _cropRect.bottom - 0.1),
            _cropRect.right,
            _cropRect.bottom,
          );
          break;
        case 'topRight':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            (_cropRect.top + delta.dy / scaledImageHeight).clamp(0.0, _cropRect.bottom - 0.1),
            (_cropRect.right + delta.dx / scaledImageWidth).clamp(_cropRect.left + 0.1, 1.0),
            _cropRect.bottom,
          );
          break;
        case 'bottomLeft':
          _cropRect = Rect.fromLTRB(
            (_cropRect.left + delta.dx / scaledImageWidth).clamp(0.0, _cropRect.right - 0.1),
            _cropRect.top,
            _cropRect.right,
            (_cropRect.bottom + delta.dy / scaledImageHeight).clamp(_cropRect.top + 0.1, 1.0),
          );
          break;
        case 'bottomRight':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            (_cropRect.right + delta.dx / scaledImageWidth).clamp(_cropRect.left + 0.1, 1.0),
            (_cropRect.bottom + delta.dy / scaledImageHeight).clamp(_cropRect.top + 0.1, 1.0),
          );
          break;
        case 'move':
          final newLeft = (_cropRect.left + delta.dx / scaledImageWidth).clamp(0.0, 1.0 - _cropRect.width);
          final newTop = (_cropRect.top + delta.dy / scaledImageHeight).clamp(0.0, 1.0 - _cropRect.height);
          _cropRect = Rect.fromLTWH(newLeft, newTop, _cropRect.width, _cropRect.height);
          break;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _draggedCorner = null;
  }

  void _resetCrop() {
    setState(() {
      _cropRect = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    });
  }

  void _cropImage() async {
    if (widget.imageData.imageBytes == null) return;

    try {
      // Decode the original image
      final originalImage = img.decodeImage(widget.imageData.imageBytes!);
      if (originalImage == null) return;

      // Calculate crop coordinates in original image space
      final cropLeft = (_cropRect.left * _imageWidth).round();
      final cropTop = (_cropRect.top * _imageHeight).round();
      final cropRight = (_cropRect.right * _imageWidth).round();
      final cropBottom = (_cropRect.bottom * _imageHeight).round();

      // Ensure crop coordinates are within image bounds
      final left = cropLeft.clamp(0, originalImage.width);
      final top = cropTop.clamp(0, originalImage.height);
      final right = cropRight.clamp(left, originalImage.width);
      final bottom = cropBottom.clamp(top, originalImage.height);

      // Crop the image
      final croppedImage = img.copyCrop(
        originalImage,
        x: left,
        y: top,
        width: right - left,
        height: bottom - top,
      );

      // Encode the cropped image
      final croppedBytes = Uint8List.fromList(img.encodeJpg(croppedImage));

      // Call the callback with the cropped image
      widget.onCropComplete(croppedBytes);
    } catch (e) {
      print('Error cropping image: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cropping image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Size imageSize;

  CropOverlayPainter({
    required this.cropRect,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw dark overlay outside crop area
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, paint);

    // Draw crop border
    canvas.drawRect(cropRect, borderPaint);

    // Draw corner handles
    const cornerSize = 20.0;
    final corners = [
      Offset(cropRect.left, cropRect.top),
      Offset(cropRect.right, cropRect.top),
      Offset(cropRect.left, cropRect.bottom),
      Offset(cropRect.right, cropRect.bottom),
    ];

    for (final corner in corners) {
      canvas.drawRect(
        Rect.fromCenter(
          center: corner,
          width: cornerSize,
          height: cornerSize,
        ),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is CropOverlayPainter && oldDelegate.cropRect != cropRect;
  }
}
