import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

class ImageProcessor {
  static final ImageProcessor _instance = ImageProcessor._internal();
  factory ImageProcessor() => _instance;
  ImageProcessor._internal();

  // Process image from bytes to processed image
  Future<img.Image?> processImage(Uint8List imageBytes) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Resize if too large (for performance)
      if (image.width > 1024 || image.height > 1024) {
        image = img.copyResize(image, width: 1024, height: 1024);
      }

      // Convert to grayscale
      image = img.grayscale(image);

      // Apply noise reduction (Gaussian blur)
      image = img.gaussianBlur(image, radius: 1);

      // Enhance contrast
      image = img.contrast(image, contrast: 150);

      return image;
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }

  // Extract contours from binary image (simplified version)
  List<List<Point>> extractContours(img.Image image) {
    final List<List<Point>> contours = [];

    // For now, return a simple contour based on image dimensions
    // This is a placeholder that will be enhanced later
    final int width = image.width;
    final int height = image.height;

    // Create a simple rectangular contour
    final List<Point> contour = [
      Point(0, 0),
      Point(width.toDouble(), 0),
      Point(width.toDouble(), height.toDouble()),
      Point(0, height.toDouble()),
    ];

    contours.add(contour);
    return contours;
  }

  // Simplify contour using Douglas-Peucker algorithm
  List<Point> simplifyContour(List<Point> contour, double epsilon) {
    if (contour.length <= 2) return contour;

    double maxDistance = 0;
    int maxIndex = 0;
    final Point start = contour.first;
    final Point end = contour.last;

    for (int i = 1; i < contour.length - 1; i++) {
      final double distance = _pointToLineDistance(contour[i], start, end);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    if (maxDistance > epsilon) {
      final List<Point> result1 = simplifyContour(
        contour.sublist(0, maxIndex + 1),
        epsilon,
      );
      final List<Point> result2 = simplifyContour(
        contour.sublist(maxIndex),
        epsilon,
      );
      return [...result1.sublist(0, result1.length - 1), ...result2];
    } else {
      return [start, end];
    }
  }

  // Calculate distance from point to line
  double _pointToLineDistance(Point point, Point lineStart, Point lineEnd) {
    final double A = point.x - lineStart.x;
    final double B = point.y - lineStart.y;
    final double C = lineEnd.x - lineStart.x;
    final double D = lineEnd.y - lineStart.y;

    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;

    if (lenSq == 0) return _distance(point, lineStart);

    final double param = dot / lenSq;
    double xx, yy;

    if (param < 0) {
      xx = lineStart.x;
      yy = lineStart.y;
    } else if (param > 1) {
      xx = lineEnd.x;
      yy = lineEnd.y;
    } else {
      xx = lineStart.x + param * C;
      yy = lineStart.y + param * D;
    }

    return _distance(point, Point(xx, yy));
  }

  // Calculate distance between two points
  double _distance(Point p1, Point p2) {
    final double dx = p1.x - p2.x;
    final double dy = p1.y - p2.y;
    return sqrt(dx * dx + dy * dy);
  }
}

// Simple Point class
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  @override
  String toString() => 'Point($x, $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
