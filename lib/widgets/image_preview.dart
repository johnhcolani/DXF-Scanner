import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/image_data.dart';
import 'image_crop_widget.dart';

class ImagePreviewWidget extends StatefulWidget {
  final ImageData imageData;

  const ImagePreviewWidget({
    super.key,
    required this.imageData,
  });

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  img.Image? _decodedImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  Future<void> _decodeImage() async {
    if (widget.imageData.imageBytes != null) {
      try {
        final image = img.decodeImage(widget.imageData.imageBytes!);
        setState(() {
          _decodedImage = image;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.image, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Image Preview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.crop),
                  onPressed: () => _showCropDialog(context),
                  tooltip: 'Crop Image',
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showImageInfo(context),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Image display - using flexible height
            SizedBox(
              height: 300, // Fixed height to prevent overflow
              child: _buildImageDisplay(),
            ),
            
            const SizedBox(height: 16),
            
            // Image details
            _buildImageDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_decodedImage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          child: Image.memory(
            widget.imageData.imageBytes!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading image',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image Details',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_decodedImage != null) ...[
            _buildDetailRow('Dimensions', '${_decodedImage!.width} × ${_decodedImage!.height}'),
            _buildDetailRow('File Size', _formatFileSize(widget.imageData.imageBytes!.length)),
          ] else ...[
            _buildDetailRow('File Size', _formatFileSize(widget.imageData.imageBytes?.length ?? 0)),
          ],
          _buildDetailRow('Captured', _formatDateTime(widget.imageData.createdAt)),
          if (widget.imageData.filePath != null)
            _buildDetailRow('Source', _getSourceType(widget.imageData.filePath!)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getSourceType(String filePath) {
    if (filePath.contains('camera')) return 'Camera';
    if (filePath.contains('gallery')) return 'Gallery';
    return 'File';
  }

  void _showCropDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageCropWidget(
          imageData: widget.imageData,
          onCropComplete: (Uint8List croppedImageBytes) {
            // Update the image data with cropped version
            setState(() {
              widget.imageData.imageBytes = croppedImageBytes;
              _isLoading = true;
            });
            _decodeImage();
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

  void _showImageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_decodedImage != null) ...[
              Text('Width: ${_decodedImage!.width} pixels'),
              Text('Height: ${_decodedImage!.height} pixels'),
              Text('Aspect Ratio: ${(_decodedImage!.width / _decodedImage!.height).toStringAsFixed(2)}'),
            ],
            Text('File Size: ${_formatFileSize(widget.imageData.imageBytes?.length ?? 0)}'),
            Text('Format: JPEG'),
            Text('Captured: ${_formatDateTime(widget.imageData.createdAt)}'),
            if (widget.imageData.filePath != null)
              Text('Path: ${widget.imageData.filePath}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

