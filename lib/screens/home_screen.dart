import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/image_data.dart';
import '../widgets/camera_widget.dart';
import '../widgets/image_preview.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/image_crop_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize app state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'DXF Scanner',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isLandscape ? 12.0 : 16.0),
              child: Column(
                children: [
                  // Status card - smaller in landscape
                  if (!isLandscape) ...[
                    _buildStatusCard(context, appState),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildCompactStatusCard(context, appState),
                    const SizedBox(height: 12),
                  ],

                  // Main content area - using expanded for better space management
                  Expanded(child: _buildMainContent(context, appState)),

                  SizedBox(height: isLandscape ? 12 : 16),

                  // Action buttons - now with better positioning
                  _buildActionButtons(context, appState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(appState.processingStatus),
                  color: _getStatusColor(appState.processingStatus),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusText(appState.processingStatus),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (appState.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                appState.errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
            ],
            if (appState.processingSteps.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...appState.processingSteps.map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatusCard(BuildContext context, AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(appState.processingStatus),
              color: _getStatusColor(appState.processingStatus),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getStatusText(appState.processingStatus),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (appState.errorMessage != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AppState appState) {
    if (appState.processingStatus == ProcessingStatus.processing) {
      return const ProcessingProgressWidget();
    }

    if (appState.currentImage != null) {
      return ImagePreviewWidget(imageData: appState.currentImage!);
    }

    // Show camera preview if available, otherwise show direct image selection interface
    if (appState.isCameraAvailable && appState.cameraController != null) {
      return const CameraWidget();
    }

    return _buildImageSelectionInterface(context, appState);
  }

  Widget _buildImageSelectionInterface(BuildContext context, AppState appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Direct action buttons without welcome text
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => appState.pickImageFromGallery(),
              icon: const Icon(Icons.photo_library, size: 24),
              label: const Text('Select from Gallery', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Camera button (if available) or disabled state
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: appState.isCameraAvailable 
                ? () => appState.captureImage()
                : null,
              icon: const Icon(Icons.camera_alt, size: 24),
              label: Text(
                appState.isCameraAvailable ? 'Take Photo' : 'Camera Not Available',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: appState.isCameraAvailable 
                  ? Colors.green 
                  : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          if (!appState.isCameraAvailable) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use Gallery to select images',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppState appState) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isLandscape ? 4 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (appState.currentImage != null) ...[
            // First row - Convert to DXF button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    appState.processingStatus == ProcessingStatus.processing
                    ? null
                    : () => appState.processImageToDXF(),
                icon: const Icon(Icons.transform),
                label: const Text('Convert to DXF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Second row - Crop and New Image buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCropDialog(context, appState),
                    icon: const Icon(Icons.crop),
                    label: const Text('Crop'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => appState.clearCurrentImage(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Image'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                    ),
                  ),
                ),
              ],
            ),
            if (appState.dxfFilePath != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => appState.shareDXFFile(),
                  icon: const Icon(Icons.share),
                  label: const Text('Share DXF File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: appState.isCameraAvailable
                        ? () => appState.captureImage()
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => appState.pickImageFromGallery(),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.pending:
        return Icons.pending;
      case ProcessingStatus.processing:
        return Icons.hourglass_empty;
      case ProcessingStatus.completed:
        return Icons.check_circle;
      case ProcessingStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.pending:
        return Colors.grey;
      case ProcessingStatus.processing:
        return Colors.blue;
      case ProcessingStatus.completed:
        return Colors.green;
      case ProcessingStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.pending:
        return 'Ready to capture';
      case ProcessingStatus.processing:
        return 'Processing...';
      case ProcessingStatus.completed:
        return 'Processing completed';
      case ProcessingStatus.failed:
        return 'Processing failed';
    }
  }

  void _showCropDialog(BuildContext context, AppState appState) {
    if (appState.currentImage == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageCropWidget(
          imageData: appState.currentImage!,
          onCropComplete: (croppedImageBytes) {
            // Update the image data with cropped version
            appState.currentImage!.imageBytes = croppedImageBytes;
            Navigator.of(context).pop();
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image cropped successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About DXF Scanner'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DXF Scanner converts field sketches and drawings into DXF format for use in CAD software.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Camera capture and gallery selection'),
            Text('• Image cropping and preprocessing'),
            Text('• Vector path extraction'),
            Text('• DXF file generation'),
            Text('• File sharing capabilities'),
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
