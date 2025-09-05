import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../services/corner_detector.dart';

class CornerDetectionOverlay extends StatefulWidget {
  final Uint8List imageBytes;
  final double scaleFactor;

  const CornerDetectionOverlay({
    super.key,
    required this.imageBytes,
    this.scaleFactor = 1.0,
  });

  @override
  State<CornerDetectionOverlay> createState() => _CornerDetectionOverlayState();
}

class _CornerDetectionOverlayState extends State<CornerDetectionOverlay> {
  List<Corner> _corners = [];
  List<Line> _lines = [];
  List<Shape> _shapes = [];
  List<ShapeMeasurement> _measurements = [];
  bool _isProcessing = false;
  bool _showCorners = true;
  bool _showLines = true;
  bool _showMeasurements = true;

  @override
  void initState() {
    super.initState();
    _detectCornersAndShapes();
  }

  Future<void> _detectCornersAndShapes() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Decode image
      final img.Image? image = img.decodeImage(widget.imageBytes);
      if (image == null) return;

      // Detect corners
      final detector = CornerDetector();
      final corners = detector.detectCorners(image, threshold: 0.01);
      
      // Connect corners to form lines
      final lines = detector.connectCorners(corners, maxDistance: 150);
      
      // Create shapes from lines
      final shapes = detector.createShapes(lines);
      
      // Calculate measurements
      final measurements = shapes.map((shape) => 
        detector.measureShape(shape, scaleFactor: widget.scaleFactor)
      ).toList();

      setState(() {
        _corners = corners;
        _lines = lines;
        _shapes = shapes;
        _measurements = measurements;
        _isProcessing = false;
      });
    } catch (e) {
      print('Error in corner detection: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image
        Image.memory(
          widget.imageBytes,
          fit: BoxFit.contain,
        ),
        
        // Processing indicator
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Detecting corners and measuring...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        
        // Overlay controls
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleButton(
                  'Corners',
                  _showCorners,
                  Icons.crop_free,
                  () => setState(() => _showCorners = !_showCorners),
                ),
                const SizedBox(height: 4),
                _buildToggleButton(
                  'Lines',
                  _showLines,
                  Icons.show_chart,
                  () => setState(() => _showLines = !_showLines),
                ),
                const SizedBox(height: 4),
                _buildToggleButton(
                  'Measurements',
                  _showMeasurements,
                  Icons.straighten,
                  () => setState(() => _showMeasurements = !_showMeasurements),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _detectCornersAndShapes,
                  tooltip: 'Re-detect corners',
                ),
              ],
            ),
          ),
        ),
        
        // Statistics
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detection Results',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Corners: ${_corners.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Lines: ${_lines.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Shapes: ${_shapes.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                if (_measurements.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Total Perimeter: ${_measurements.first.totalPerimeter.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Custom painter for overlays
        CustomPaint(
          painter: CornerDetectionPainter(
            corners: _showCorners ? _corners : [],
            lines: _showLines ? _lines : [],
            measurements: _showMeasurements ? _measurements : [],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isActive, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class CornerDetectionPainter extends CustomPainter {
  final List<Corner> corners;
  final List<Line> lines;
  final List<ShapeMeasurement> measurements;

  CornerDetectionPainter({
    required this.corners,
    required this.lines,
    required this.measurements,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw corners
    for (final corner in corners) {
      paint.color = Colors.red;
      canvas.drawCircle(
        Offset(corner.x, corner.y),
        4,
        paint..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(corner.x, corner.y),
        8,
        paint..style = PaintingStyle.stroke,
      );
    }

    // Draw lines
    for (final line in lines) {
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(line.start.x, line.start.y),
        Offset(line.end.x, line.end.y),
        paint,
      );
    }

    // Draw measurements
    for (final measurement in measurements) {
      for (final lineMeasurement in measurement.measurements) {
        // Draw measurement text
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${lineMeasurement.length.toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        // Position text at midpoint of line
        final textOffset = Offset(
          lineMeasurement.midpoint.x - textPainter.width / 2,
          lineMeasurement.midpoint.y - textPainter.height / 2,
        );
        
        // Draw background rectangle
        final backgroundRect = Rect.fromLTWH(
          textOffset.dx - 2,
          textOffset.dy - 2,
          textPainter.width + 4,
          textPainter.height + 4,
        );
        
        canvas.drawRect(
          backgroundRect,
          Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..style = PaintingStyle.fill,
        );
        
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

