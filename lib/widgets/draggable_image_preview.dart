import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/image_data.dart';
import 'image_crop_widget.dart';

class DraggableImagePreview extends StatefulWidget {
  final ImageData imageData;

  const DraggableImagePreview({
    super.key,
    required this.imageData,
  });

  @override
  State<DraggableImagePreview> createState() => _DraggableImagePreviewState();
}

class _DraggableImagePreviewState extends State<DraggableImagePreview>
    with TickerProviderStateMixin {
  img.Image? _decodedImage;
  bool _isLoading = true;
  
  // Animation controllers
  late AnimationController _heightController;
  late AnimationController _dragController;
  late Animation<double> _heightAnimation;
  late Animation<double> _dragAnimation;
  
  // Draggable state
  bool _isDragging = false;
  double _dragOffset = 0.0;
  double _maxDragDistance = 0.0;
  
  // Heights
  double _collapsedHeight = 200.0;
  double _expandedHeight = 0.0;
  double _currentHeight = 200.0;

  @override
  void initState() {
    super.initState();
    _decodeImage();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _heightController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _dragController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _heightAnimation = Tween<double>(
      begin: _collapsedHeight,
      end: _expandedHeight,
    ).animate(CurvedAnimation(
      parent: _heightController,
      curve: Curves.easeInOut,
    ));
    
    _dragAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    // Set responsive heights - expanded height now fills entire screen
    _collapsedHeight = isLandscape ? 150.0 : 200.0;
    _expandedHeight = screenSize.height; // Fill entire screen height
    _maxDragDistance = _expandedHeight - _collapsedHeight;
    
    _currentHeight = _collapsedHeight;
    
    // Update animation values
    _heightAnimation = Tween<double>(
      begin: _collapsedHeight,
      end: _expandedHeight,
    ).animate(CurvedAnimation(
      parent: _heightController,
      curve: Curves.easeInOut,
    ));
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

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _dragController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    setState(() {
      _dragOffset += details.delta.dy;
      _dragOffset = _dragOffset.clamp(-_maxDragDistance, 0.0);
      _currentHeight = _collapsedHeight - _dragOffset;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    _isDragging = false;
    
    // Determine if we should expand or collapse based on drag distance and velocity
    final velocity = details.velocity.pixelsPerSecond.dy;
    final shouldExpand = _dragOffset.abs() > _maxDragDistance * 0.3 || velocity < -500;
    
    if (shouldExpand) {
      _expandPreview();
    } else {
      _collapsePreview();
    }
  }

  void _expandPreview() {
    _heightController.forward();
    setState(() {
      _currentHeight = _expandedHeight;
      _dragOffset = -_maxDragDistance;
    });
  }

  void _collapsePreview() {
    _heightController.reverse();
    setState(() {
      _currentHeight = _collapsedHeight;
      _dragOffset = 0.0;
    });
  }

  void _togglePreview() {
    if (_heightController.isCompleted) {
      _collapsePreview();
    } else {
      _expandPreview();
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        final height = _isDragging ? _currentHeight : _heightAnimation.value;
        final screenSize = MediaQuery.of(context).size;
        final isFullscreen = height > screenSize.height * 0.8;
        
        if (isFullscreen) {
          // Fullscreen modal overlay
          return Stack(
            children: [
              // Backdrop
              Positioned.fill(
                child: GestureDetector(
                  onTap: _collapsePreview,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
              // Modal content
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        _buildDragHandle(),
                        
                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                _buildHeader(),
                                
                                const SizedBox(height: 20),
                                
                                // Image display
                                _buildImageDisplay(height),
                                
                                const SizedBox(height: 20),
                                
                                // Image details
                                _buildImageDetails(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Normal card view
          return GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              height: height,
              child: Card(
                elevation: _isDragging ? 8.0 : 2.0,
                child: Column(
                  children: [
                    // Drag handle
                    _buildDragHandle(),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            _buildHeader(),
                            
                            const SizedBox(height: 16),
                            
                            // Image display
                            _buildImageDisplay(height),
                            
                            const SizedBox(height: 16),
                            
                            // Image details (only show when expanded)
                            if (height > _collapsedHeight + 50)
                              _buildImageDetails(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDragHandle() {
    final isFullscreen = _heightController.isCompleted;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isFullscreen ? 12.0 : 8.0),
      decoration: isFullscreen ? BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ) : null,
      child: Center(
        child: Container(
          width: isFullscreen ? 60 : 40,
          height: isFullscreen ? 6 : 4,
          decoration: BoxDecoration(
            color: isFullscreen ? Colors.grey[600] : Colors.grey[400],
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isFullscreen = _heightController.isCompleted;
    
    return Row(
      children: [
        const Icon(Icons.image, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isFullscreen ? 'Fullscreen Preview' : 'Image Preview',
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
        if (isFullscreen) ...[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _collapsePreview,
            tooltip: 'Close Fullscreen',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
            ),
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _expandPreview,
            tooltip: 'Fullscreen',
          ),
        ],
      ],
    );
  }

  Widget _buildImageDisplay(double containerHeight) {
    // Use more space when in fullscreen mode
    final isFullscreen = containerHeight > MediaQuery.of(context).size.height * 0.8;
    final imageHeight = isFullscreen 
        ? (containerHeight - 80).clamp(100.0, double.infinity) // More space in fullscreen
        : (containerHeight - 120).clamp(100.0, 400.0); // Original behavior for collapsed
    
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: imageHeight,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_decodedImage == null) {
      return Container(
        width: double.infinity,
        height: imageHeight,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
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
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: imageHeight,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.memory(
            widget.imageData.imageBytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
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
            setState(() {
              widget.imageData.imageBytes = croppedImageBytes;
              _isLoading = true;
            });
            _decodeImage();
            Navigator.of(context).pop();
            
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
