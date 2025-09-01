import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/app_state.dart';

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
              // Camera preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CameraPreview(cameraController),
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
                        // TODO: Navigate back or close camera
                      },
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    
                    // Capture button
                    FloatingActionButton(
                      onPressed: () => appState.captureImage(),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.camera_alt),
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
              onPressed: () {
                // TODO: Request camera permissions
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Enable Camera'),
            ),
          ],
        ),
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
