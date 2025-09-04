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

  // Extract contours from binary image using edge detection
  List<List<Point>> extractContours(img.Image image) {
    final List<List<Point>> contours = [];

    try {
      // Apply edge detection (Canny-like algorithm)
      final edgeImage = _detectEdges(image);
      
      // Find contours using a simple edge following algorithm
      final foundContours = _findContours(edgeImage);
      
      // Filter and simplify contours
      for (final contour in foundContours) {
        if (contour.length >= 3) { // Minimum 3 points for a valid contour
          contours.add(contour);
        }
      }
      
      // If no contours found, create a simple border contour
      if (contours.isEmpty) {
        contours.add(_createBorderContour(image));
      }
      
    } catch (e) {
      print('Error extracting contours: $e');
      // Fallback to simple border contour
      contours.add(_createBorderContour(image));
    }

    return contours;
  }

  // Create a simple border contour as fallback
  List<Point> _createBorderContour(img.Image image) {
    final int width = image.width;
    final int height = image.height;
    
    return [
      Point(0, 0),
      Point(width.toDouble(), 0),
      Point(width.toDouble(), height.toDouble()),
      Point(0, height.toDouble()),
    ];
  }

  // Simple edge detection
  img.Image _detectEdges(img.Image image) {
    // Convert to grayscale if not already
    img.Image grayImage = image;
    if (image.numChannels > 1) {
      grayImage = img.grayscale(image);
    }
    
    // Apply Sobel edge detection
    final sobelX = img.convolution(grayImage, [
      -1, 0, 1,
      -2, 0, 2,
      -1, 0, 1
    ]);
    
    final sobelY = img.convolution(grayImage, [
      -1, -2, -1,
       0,  0,  0,
       1,  2,  1
    ]);
    
    // Combine X and Y gradients
    final edgeImage = img.Image(width: grayImage.width, height: grayImage.height);
    
    for (int y = 0; y < grayImage.height; y++) {
      for (int x = 0; x < grayImage.width; x++) {
        final pixelX = sobelX.getPixel(x, y);
        final pixelY = sobelY.getPixel(x, y);
        
        final gx = pixelX.r;
        final gy = pixelY.r;
        
        final magnitude = sqrt(gx * gx + gy * gy).round();
        final edgeValue = magnitude > 50 ? 255 : 0; // Threshold
        
        edgeImage.setPixel(x, y, img.ColorRgb8(edgeValue, edgeValue, edgeValue));
      }
    }
    
    return edgeImage;
  }

  // Find contours using edge following
  List<List<Point>> _findContours(img.Image edgeImage) {
    final List<List<Point>> contours = [];
    final List<List<bool>> visited = List.generate(
      edgeImage.height,
      (i) => List.generate(edgeImage.width, (j) => false),
    );
    
    for (int y = 0; y < edgeImage.height; y++) {
      for (int x = 0; x < edgeImage.width; x++) {
        if (!visited[y][x] && _isEdgePixel(edgeImage, x, y)) {
          final contour = _traceContour(edgeImage, visited, x, y);
          if (contour.length >= 3) {
            contours.add(contour);
          }
        }
      }
    }
    
    return contours;
  }

  // Check if pixel is an edge pixel
  bool _isEdgePixel(img.Image image, int x, int y) {
    if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
      return false;
    }
    final pixel = image.getPixel(x, y);
    return pixel.r > 128; // White pixels are edges
  }

  // Trace a contour starting from an edge pixel
  List<Point> _traceContour(img.Image image, List<List<bool>> visited, int startX, int startY) {
    final List<Point> contour = [];
    final List<Point> stack = [Point(startX.toDouble(), startY.toDouble())];
    
    // 8-connected neighbors
    final List<Point> neighbors = [
      Point(-1, -1), Point(0, -1), Point(1, -1),
      Point(-1,  0),               Point(1,  0),
      Point(-1,  1), Point(0,  1), Point(1,  1),
    ];
    
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      final x = current.x.round();
      final y = current.y.round();
      
      if (x < 0 || x >= image.width || y < 0 || y >= image.height || visited[y][x]) {
        continue;
      }
      
      if (!_isEdgePixel(image, x, y)) {
        continue;
      }
      
      visited[y][x] = true;
      contour.add(current);
      
      // Add neighbors to stack
      for (final neighbor in neighbors) {
        final nx = x + neighbor.x.round();
        final ny = y + neighbor.y.round();
        if (nx >= 0 && nx < image.width && ny >= 0 && ny < image.height && !visited[ny][nx]) {
          stack.add(Point(nx.toDouble(), ny.toDouble()));
        }
      }
    }
    
    return contour;
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
