import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/app_state.dart';
import '../models/image_data.dart';

class CameraWidget extends StatelessWidget {
  const CameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final cameraController = appState.cameraController;
        
        if (cameraController == null || !cameraController.value.isInitialized) {
          return _buildCameraNotAvailable(context);
        }

        return Card(
          child: Column(
            children: [
              // Camera preview with paper orientation overlay
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Camera preview
                        Positioned.fill(
                          child: _buildCameraPreview(cameraController, appState.paperOrientation),
                        ),
                        // Paper orientation overlay
                        _buildPaperOverlay(context, appState.paperOrientation),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Camera controls
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel button
                    IconButton(
                      onPressed: () {
                        // Close camera and go back to welcome screen
                        context.read<AppState>().clearCurrentImage();
                      },
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    
                    // Capture button - using regular ElevatedButton to avoid overflow
                    ElevatedButton(
                      onPressed: () => appState.captureImage(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.camera_alt, size: 24),
                    ),
                    
                    // Paper orientation toggle button
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            final newOrientation = appState.paperOrientation == PaperOrientation.portrait
                                ? PaperOrientation.landscape
                                : PaperOrientation.portrait;
                            appState.setPaperOrientation(newOrientation);
                          },
                          icon: Icon(
                            appState.paperOrientation == PaperOrientation.portrait
                                ? Icons.rotate_90_degrees_cw
                                : Icons.rotate_90_degrees_ccw,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                            foregroundColor: Colors.blue[800],
                          ),
                        ),
                        Text(
                          appState.paperOrientation == PaperOrientation.portrait ? 'Portrait' : 'Landscape',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    // Settings button
                    IconButton(
                      onPressed: () => _showCameraSettings(context, cameraController),
                      icon: const Icon(Icons.settings),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraNotAvailable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Not Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check camera permissions or try using gallery instead.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                // Request camera permissions
                final appState = context.read<AppState>();
                final hasPermission = await appState.requestCameraPermission();
                if (hasPermission) {
                  await appState.initialize();
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Enable Camera'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraController controller, PaperOrientation orientation) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the aspect ratio based on paper orientation
        double aspectRatio;
        if (orientation == PaperOrientation.portrait) {
          aspectRatio = 0.77; // Portrait aspect ratio (8.5:11)
        } else {
          aspectRatio = 1.29; // Landscape aspect ratio (11:8.5)
        }

        // Calculate the size to fit within the constraints
        double width = constraints.maxWidth;
        double height = width / aspectRatio;
        
        if (height > constraints.maxHeight) {
          height = constraints.maxHeight;
          width = height * aspectRatio;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaperOverlay(BuildContext context, PaperOrientation orientation) {
    return Positioned.fill(
      child: CustomPaint(
        painter: PaperOverlayPainter(orientation),
      ),
    );
  }

  void _showCameraSettings(BuildContext context, dynamic cameraController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Camera settings will be implemented in future versions.'),
            const SizedBox(height: 16),
            const Text('Current features:'),
            const Text('• Auto focus'),
            const Text('• Auto exposure'),
            const Text('• High resolution capture'),
            const Text('• Paper orientation overlay'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class PaperOverlayPainter extends CustomPainter {
  final PaperOrientation orientation;

  PaperOverlayPainter(this.orientation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Calculate paper frame based on orientation
    late Rect paperRect;
    late double cornerLength;

    if (orientation == PaperOrientation.portrait) {
      // Portrait: 8.5" x 11" ratio (approximately 0.77)
      final paperWidth = size.width * 0.8;
      final paperHeight = paperWidth / 0.77;
      
      if (paperHeight > size.height * 0.8) {
        final adjustedHeight = size.height * 0.8;
        final adjustedWidth = adjustedHeight * 0.77;
        paperRect = Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: adjustedWidth,
          height: adjustedHeight,
        );
      } else {
        paperRect = Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: paperWidth,
          height: paperHeight,
        );
      }
      cornerLength = 20.0;
    } else {
      // Landscape: 11" x 8.5" ratio (approximately 1.29)
      final paperHeight = size.height * 0.8;
      final paperWidth = paperHeight * 1.29;
      
      if (paperWidth > size.width * 0.8) {
        final adjustedWidth = size.width * 0.8;
        final adjustedHeight = adjustedWidth / 1.29;
        paperRect = Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: adjustedWidth,
          height: adjustedHeight,
        );
      } else {
        paperRect = Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: paperWidth,
          height: paperHeight,
        );
      }
      cornerLength = 20.0;
    }

    // Draw paper frame
    canvas.drawRect(paperRect, paint);

    // Draw corner markers
    final corners = [
      Offset(paperRect.left, paperRect.top),
      Offset(paperRect.right, paperRect.top),
      Offset(paperRect.left, paperRect.bottom),
      Offset(paperRect.right, paperRect.bottom),
    ];

    for (final corner in corners) {
      // Top-left corner
      if (corner == corners[0]) {
        canvas.drawLine(
          corner,
          Offset(corner.dx + cornerLength, corner.dy),
          cornerPaint,
        );
        canvas.drawLine(
          corner,
          Offset(corner.dx, corner.dy + cornerLength),
          cornerPaint,
        );
      }
      // Top-right corner
      else if (corner == corners[1]) {
        canvas.drawLine(
          corner,
          Offset(corner.dx - cornerLength, corner.dy),
          cornerPaint,
        );
        canvas.drawLine(
          corner,
          Offset(corner.dx, corner.dy + cornerLength),
          cornerPaint,
        );
      }
      // Bottom-left corner
      else if (corner == corners[2]) {
        canvas.drawLine(
          corner,
          Offset(corner.dx + cornerLength, corner.dy),
          cornerPaint,
        );
        canvas.drawLine(
          corner,
          Offset(corner.dx, corner.dy - cornerLength),
          cornerPaint,
        );
      }
      // Bottom-right corner
      else if (corner == corners[3]) {
        canvas.drawLine(
          corner,
          Offset(corner.dx - cornerLength, corner.dy),
          cornerPaint,
        );
        canvas.drawLine(
          corner,
          Offset(corner.dx, corner.dy - cornerLength),
          cornerPaint,
        );
      }
    }

    // Draw orientation label
    final textPainter = TextPainter(
      text: TextSpan(
        text: orientation == PaperOrientation.portrait ? 'Portrait' : 'Landscape',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        paperRect.left + 10,
        paperRect.top - textPainter.height - 10,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is PaperOverlayPainter && oldDelegate.orientation != orientation;
  }
}
