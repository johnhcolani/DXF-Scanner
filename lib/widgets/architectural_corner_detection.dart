import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ArchitecturalCornerDetection extends StatefulWidget {
  final Uint8List imageBytes;

  const ArchitecturalCornerDetection({
    super.key,
    required this.imageBytes,
  });

  @override
  State<ArchitecturalCornerDetection> createState() => _ArchitecturalCornerDetectionState();
}

class _ArchitecturalCornerDetectionState extends State<ArchitecturalCornerDetection> {
  List<Point> _corners = [];
  List<Line> _lines = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _detectArchitecturalCorners();
  }

  Future<void> _detectArchitecturalCorners() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Decode image
      final img.Image? image = img.decodeImage(widget.imageBytes);
      if (image == null) return;

      // Resize for better performance
      final resizedImage = img.copyResize(image, width: 800, height: 600);
      
      // Convert to grayscale
      final grayImage = img.grayscale(resizedImage);
      
      // Apply edge detection
      final edgeImage = _detectEdges(grayImage);
      
      // Find corners using simple method
      final corners = _findCorners(edgeImage);
      
      // Connect corners to form lines
      final lines = _connectCorners(corners);

      setState(() {
        _corners = corners;
        _lines = lines;
        _isProcessing = false;
      });
    } catch (e) {
      print('Error in architectural corner detection: $e');
      setState(() {
        _isProcessing = false;
      });
    }
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
        
        final edgeValue = magnitude > 30 ? 255 : 0;
        edgeImage.setPixel(x, y, img.ColorRgb8(edgeValue, edgeValue, edgeValue));
      }
    }
    
    return edgeImage;
  }

  List<Point> _findCorners(img.Image edgeImage) {
    final List<Point> corners = [];
    
    // Very conservative corner detection - much larger step size
    for (int y = 20; y < edgeImage.height - 20; y += 15) {
      for (int x = 20; x < edgeImage.width - 20; x += 15) {
        if (_isCorner(edgeImage, x, y)) {
          corners.add(Point(x.toDouble(), y.toDouble()));
        }
      }
    }
    
    // Remove close corners with very large minimum distance
    return _removeClosePoints(corners, minDistance: 150);
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
    
    // Extremely strict corner detection - only perfect corners
    return edgeCount == 4;
  }

  List<Point> _removeClosePoints(List<Point> points, {double minDistance = 20}) {
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
        
        // Connect corners that are reasonably close and aligned
        if (distance < 300 && distance > 100) {
          final angle = _calculateAngle(corners[i], corners[j]);
          
          // Prefer horizontal, vertical, and 45-degree lines
          if (_isAligned(angle)) {
            lines.add(Line(corners[i], corners[j], distance));
          }
        }
      }
    }
    
    return lines;
  }

  double _calculateAngle(Point p1, Point p2) {
    return atan2(p2.y - p1.y, p2.x - p1.x) * 180 / 3.14159;
  }

  bool _isAligned(double angle) {
    final normalizedAngle = angle.abs() % 90;
    return normalizedAngle < 15 || normalizedAngle > 75;
  }

  double _distance(Point p1, Point p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return sqrt(dx * dx + dy * dy);
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
                    'Detecting architectural corners...',
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
                  'Architectural Analysis',
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
                if (_lines.isNotEmpty) ...[
                  Text(
                    'Avg Length: ${(_lines.map((l) => l.length).reduce((a, b) => a + b) / _lines.length).toStringAsFixed(0)}px',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Custom painter for overlays
        CustomPaint(
          painter: ArchitecturalCornerPainter(
            corners: _corners,
            lines: _lines,
          ),
        ),
      ],
    );
  }
}

class ArchitecturalCornerPainter extends CustomPainter {
  final List<Point> corners;
  final List<Line> lines;

  ArchitecturalCornerPainter({
    required this.corners,
    required this.lines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw corners as red circles
    for (final corner in corners) {
      paint.color = Colors.red;
      canvas.drawCircle(
        Offset(corner.x, corner.y),
        8,
        paint..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(corner.x, corner.y),
        16,
        paint..style = PaintingStyle.stroke,
      );
    }

    // Draw lines as blue lines
    for (final line in lines) {
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawLine(
        Offset(line.start.x, line.start.y),
        Offset(line.end.x, line.end.y),
        paint,
      );
      
      // Draw measurement text (only for longer lines to avoid clutter)
      if (line.length > 80) {
        final midpoint = Point(
          (line.start.x + line.end.x) / 2,
          (line.start.y + line.end.y) / 2,
        );
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${line.length.toStringAsFixed(0)}px',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        final textOffset = Offset(
          midpoint.x - textPainter.width / 2,
          midpoint.y - textPainter.height / 2,
        );
        
        // Draw background rectangle
        final backgroundRect = Rect.fromLTWH(
          textOffset.dx - 4,
          textOffset.dy - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        );
        
        canvas.drawRect(
          backgroundRect,
          Paint()
            ..color = Colors.white.withOpacity(0.9)
            ..style = PaintingStyle.fill,
        );
        
        textPainter.paint(canvas, textOffset);
      }
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
