import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class SimpleCornerDetection extends StatefulWidget {
  final Uint8List imageBytes;

  const SimpleCornerDetection({
    super.key,
    required this.imageBytes,
  });

  @override
  State<SimpleCornerDetection> createState() => _SimpleCornerDetectionState();
}

class _SimpleCornerDetectionState extends State<SimpleCornerDetection> {
  List<Point> _corners = [];
  List<Line> _lines = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _detectCorners();
  }

  Future<void> _detectCorners() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Decode image
      final img.Image? image = img.decodeImage(widget.imageBytes);
      if (image == null) return;

      // Simple corner detection using edge detection
      final corners = _findSimpleCorners(image);
      final lines = _connectCorners(corners);

      setState(() {
        _corners = corners;
        _lines = lines;
        _isProcessing = false;
      });
    } catch (e) {
      print('Error in simple corner detection: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  List<Point> _findSimpleCorners(img.Image image) {
    final List<Point> corners = [];
    
    // Convert to grayscale
    final grayImage = img.grayscale(image);
    
    // Apply edge detection
    final edgeImage = _detectEdges(grayImage);
    
    // Find corners by looking for intersections of edges
    for (int y = 2; y < edgeImage.height - 2; y++) {
      for (int x = 2; x < edgeImage.width - 2; x++) {
        if (_isCorner(edgeImage, x, y)) {
          corners.add(Point(x.toDouble(), y.toDouble()));
        }
      }
    }
    
    // Remove close corners
    return _removeClosePoints(corners, minDistance: 30);
  }

  img.Image _detectEdges(img.Image image) {
    final edgeImage = img.Image(width: image.width, height: image.height);
    
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final center = image.getPixel(x, y).r;
        final right = image.getPixel(x + 1, y).r;
        final bottom = image.getPixel(x, y + 1).r;
        
        final gx = (right - center).abs();
        final gy = (bottom - center).abs();
        final magnitude = (gx + gy).round();
        
        final edgeValue = magnitude > 50 ? 255 : 0;
        edgeImage.setPixel(x, y, img.ColorRgb8(edgeValue, edgeValue, edgeValue));
      }
    }
    
    return edgeImage;
  }

  bool _isCorner(img.Image edgeImage, int x, int y) {
    int edgeCount = 0;
    
    // Check 8 directions around the point
    final directions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1],
    ];
    
    for (final dir in directions) {
      final px = x + dir[0];
      final py = y + dir[1];
      if (px >= 0 && px < edgeImage.width && py >= 0 && py < edgeImage.height) {
        if (edgeImage.getPixel(px, py).r > 128) {
          edgeCount++;
        }
      }
    }
    
    // Consider it a corner if it has 2-6 edge neighbors (not too few, not too many)
    return edgeCount >= 2 && edgeCount <= 6;
  }

  List<Point> _removeClosePoints(List<Point> points, {double minDistance = 30}) {
    final List<Point> filtered = [];
    
    for (final point in points) {
      bool tooClose = false;
      
      for (final existing in filtered) {
        final distance = _distance(point, existing);
        if (distance < minDistance) {
          tooClose = true;
          break;
        }
      }
      
      if (!tooClose) {
        filtered.add(point);
      }
    }
    
    return filtered;
  }

  List<Line> _connectCorners(List<Point> corners) {
    final List<Line> lines = [];
    
    for (int i = 0; i < corners.length; i++) {
      for (int j = i + 1; j < corners.length; j++) {
        final distance = _distance(corners[i], corners[j]);
        
        // Connect corners that are reasonably close
        if (distance < 200 && distance > 20) {
          lines.add(Line(corners[i], corners[j], distance));
        }
      }
    }
    
    return lines;
  }

  double _distance(Point p1, Point p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return (dx * dx + dy * dy).sqrt();
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
                    'Detecting corners...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
                  'Corner Detection Results',
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
              ],
            ),
          ),
        ),
        
        // Custom painter for overlays
        CustomPaint(
          painter: SimpleCornerPainter(
            corners: _corners,
            lines: _lines,
          ),
        ),
      ],
    );
  }
}

class SimpleCornerPainter extends CustomPainter {
  final List<Point> corners;
  final List<Line> lines;

  SimpleCornerPainter({
    required this.corners,
    required this.lines,
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
        6,
        paint..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(corner.x, corner.y),
        12,
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}

class Line {
  final Point start;
  final Point end;
  final double length;

  Line(this.start, this.end, this.length);
}
