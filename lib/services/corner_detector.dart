import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

class CornerDetector {
  static final CornerDetector _instance = CornerDetector._internal();
  factory CornerDetector() => _instance;
  CornerDetector._internal();

  // Detect corners using Harris corner detection
  List<Corner> detectCorners(img.Image image, {
    double threshold = 0.01,
    int windowSize = 3,
    double k = 0.04,
  }) {
    final List<Corner> corners = [];
    
    try {
      // Convert to grayscale if needed
      img.Image grayImage = image;
      if (image.numChannels > 1) {
        grayImage = img.grayscale(image);
      }
      
      // Apply Gaussian blur for noise reduction
      grayImage = img.gaussianBlur(grayImage, radius: 1);
      
      // Calculate gradients
      final gradients = _calculateGradients(grayImage);
      
      // Calculate Harris response
      final harrisResponse = _calculateHarrisResponse(gradients, windowSize, k);
      
      // Find local maxima
      corners.addAll(_findLocalMaxima(harrisResponse, threshold));
      
      // Sort by response strength
      corners.sort((a, b) => b.response.compareTo(a.response));
      
      // Remove corners that are too close to each other
      return _removeCloseCorners(corners, minDistance: 20);
      
    } catch (e) {
      print('Error detecting corners: $e');
      return [];
    }
  }

  // Calculate image gradients using Sobel operators
  Map<String, List<List<double>>> _calculateGradients(img.Image image) {
    final int width = image.width;
    final int height = image.height;
    
    final List<List<double>> gx = List.generate(height, (i) => List.filled(width, 0.0));
    final List<List<double>> gy = List.generate(height, (i) => List.filled(width, 0.0));
    
    // Sobel X kernel
    final List<List<int>> sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1],
    ];
    
    // Sobel Y kernel
    final List<List<int>> sobelY = [
      [-1, -2, -1],
      [ 0,  0,  0],
      [ 1,  2,  1],
    ];
    
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double sumX = 0.0;
        double sumY = 0.0;
        
        for (int ky = 0; ky < 3; ky++) {
          for (int kx = 0; kx < 3; kx++) {
            final pixel = image.getPixel(x + kx - 1, y + ky - 1).r;
            sumX += pixel * sobelX[ky][kx];
            sumY += pixel * sobelY[ky][kx];
          }
        }
        
        gx[y][x] = sumX;
        gy[y][x] = sumY;
      }
    }
    
    return {'gx': gx, 'gy': gy};
  }

  // Calculate Harris corner response
  List<List<double>> _calculateHarrisResponse(
    Map<String, List<List<double>>> gradients,
    int windowSize,
    double k,
  ) {
    final gx = gradients['gx']!;
    final gy = gradients['gy']!;
    final int height = gx.length;
    final int width = gx[0].length;
    
    final List<List<double>> response = List.generate(
      height, 
      (i) => List.filled(width, 0.0),
    );
    
    final int halfWindow = windowSize ~/ 2;
    
    for (int y = halfWindow; y < height - halfWindow; y++) {
      for (int x = halfWindow; x < width - halfWindow; x++) {
        double Ixx = 0.0;
        double Iyy = 0.0;
        double Ixy = 0.0;
        
        // Calculate structure tensor in window
        for (int wy = -halfWindow; wy <= halfWindow; wy++) {
          for (int wx = -halfWindow; wx <= halfWindow; wx++) {
            final int px = x + wx;
            final int py = y + wy;
            
            final double gxVal = gx[py][px];
            final double gyVal = gy[py][px];
            
            Ixx += gxVal * gxVal;
            Iyy += gyVal * gyVal;
            Ixy += gxVal * gyVal;
          }
        }
        
        // Calculate Harris response
        final double det = Ixx * Iyy - Ixy * Ixy;
        final double trace = Ixx + Iyy;
        final double harrisResponse = det - k * (trace * trace);
        
        response[y][x] = harrisResponse;
      }
    }
    
    return response;
  }

  // Find local maxima in Harris response
  List<Corner> _findLocalMaxima(List<List<double>> response, double threshold) {
    final List<Corner> corners = [];
    final int height = response.length;
    final int width = response[0].length;
    
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final double current = response[y][x];
        
        if (current > threshold) {
          // Check if it's a local maximum
          bool isLocalMax = true;
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (dx == 0 && dy == 0) continue;
              if (response[y + dy][x + dx] >= current) {
                isLocalMax = false;
                break;
              }
            }
            if (!isLocalMax) break;
          }
          
          if (isLocalMax) {
            corners.add(Corner(x.toDouble(), y.toDouble(), current));
          }
        }
      }
    }
    
    return corners;
  }

  // Remove corners that are too close to each other
  List<Corner> _removeCloseCorners(List<Corner> corners, {double minDistance = 20}) {
    final List<Corner> filtered = [];
    
    for (final corner in corners) {
      bool tooClose = false;
      
      for (final existing in filtered) {
        final double distance = sqrt(
          pow(corner.x - existing.x, 2) + pow(corner.y - existing.y, 2),
        );
        
        if (distance < minDistance) {
          tooClose = true;
          break;
        }
      }
      
      if (!tooClose) {
        filtered.add(corner);
      }
    }
    
    return filtered;
  }

  // Connect corners to form lines
  List<Line> connectCorners(List<Corner> corners, {
    double maxDistance = 100,
    double angleThreshold = 15, // degrees
  }) {
    final List<Line> lines = [];
    
    for (int i = 0; i < corners.length; i++) {
      for (int j = i + 1; j < corners.length; j++) {
        final corner1 = corners[i];
        final corner2 = corners[j];
        
        final double distance = sqrt(
          pow(corner2.x - corner1.x, 2) + pow(corner2.y - corner1.y, 2),
        );
        
        if (distance <= maxDistance) {
          final double angle = atan2(
            corner2.y - corner1.y,
            corner2.x - corner1.x,
          ) * 180 / pi;
          
          // Check if angle is close to horizontal, vertical, or diagonal
          final double normalizedAngle = angle.abs() % 90;
          final bool isAligned = normalizedAngle < angleThreshold || 
                                normalizedAngle > (90 - angleThreshold);
          
          if (isAligned) {
            lines.add(Line(corner1, corner2, distance));
          }
        }
      }
    }
    
    return lines;
  }

  // Create a shape from lines by finding connected components
  List<Shape> createShapes(List<Line> lines) {
    final List<Shape> shapes = [];
    final Set<Line> usedLines = {};
    
    for (final line in lines) {
      if (usedLines.contains(line)) continue;
      
      final shape = _buildShapeFromLine(line, lines, usedLines);
      if (shape.lines.length >= 3) { // Minimum 3 lines for a valid shape
        shapes.add(shape);
      }
    }
    
    return shapes;
  }

  // Build a shape starting from a line
  Shape _buildShapeFromLine(Line startLine, List<Line> allLines, Set<Line> usedLines) {
    final List<Line> shapeLines = [startLine];
    usedLines.add(startLine);
    
    Corner currentCorner = startLine.end;
    bool foundConnection = true;
    
    while (foundConnection) {
      foundConnection = false;
      
      for (final line in allLines) {
        if (usedLines.contains(line)) continue;
        
        // Check if line connects to current corner
        if (_cornersMatch(line.start, currentCorner, tolerance: 5)) {
          shapeLines.add(line);
          usedLines.add(line);
          currentCorner = line.end;
          foundConnection = true;
          break;
        } else if (_cornersMatch(line.end, currentCorner, tolerance: 5)) {
          shapeLines.add(line);
          usedLines.add(line);
          currentCorner = line.start;
          foundConnection = true;
          break;
        }
      }
      
      // Check if we've completed the shape (back to start)
      if (_cornersMatch(currentCorner, startLine.start, tolerance: 5)) {
        break;
      }
    }
    
    return Shape(shapeLines);
  }

  // Check if two corners are close enough to be considered the same
  bool _cornersMatch(Corner c1, Corner c2, {double tolerance = 5}) {
    final double distance = sqrt(
      pow(c2.x - c1.x, 2) + pow(c2.y - c1.y, 2),
    );
    return distance <= tolerance;
  }

  // Calculate measurements for a shape
  ShapeMeasurement measureShape(Shape shape, {double scaleFactor = 1.0}) {
    final List<LineMeasurement> measurements = [];
    double totalPerimeter = 0.0;
    
    for (final line in shape.lines) {
      final double length = line.length * scaleFactor;
      final double angle = atan2(
        line.end.y - line.start.y,
        line.end.x - line.start.x,
      ) * 180 / pi;
      
      measurements.add(LineMeasurement(
        line: line,
        length: length,
        angle: angle,
        midpoint: Point(
          (line.start.x + line.end.x) / 2,
          (line.start.y + line.end.y) / 2,
        ),
      ));
      
      totalPerimeter += length;
    }
    
    return ShapeMeasurement(
      shape: shape,
      measurements: measurements,
      totalPerimeter: totalPerimeter,
    );
  }
}

// Data classes
class Corner {
  final double x;
  final double y;
  final double response;

  Corner(this.x, this.y, this.response);

  @override
  String toString() => 'Corner($x, $y, $response)';
}

class Line {
  final Corner start;
  final Corner end;
  final double length;

  Line(this.start, this.end, this.length);

  @override
  String toString() => 'Line($start -> $end, length: $length)';
}

class Shape {
  final List<Line> lines;

  Shape(this.lines);

  @override
  String toString() => 'Shape(${lines.length} lines)';
}

class LineMeasurement {
  final Line line;
  final double length;
  final double angle;
  final Point midpoint;

  LineMeasurement({
    required this.line,
    required this.length,
    required this.angle,
    required this.midpoint,
  });

  @override
  String toString() => 'LineMeasurement(length: ${length.toStringAsFixed(2)}, angle: ${angle.toStringAsFixed(1)}°)';
}

class ShapeMeasurement {
  final Shape shape;
  final List<LineMeasurement> measurements;
  final double totalPerimeter;

  ShapeMeasurement({
    required this.shape,
    required this.measurements,
    required this.totalPerimeter,
  });

  @override
  String toString() => 'ShapeMeasurement(${measurements.length} lines, perimeter: ${totalPerimeter.toStringAsFixed(2)})';
}

// Simple Point class
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  @override
  String toString() => 'Point($x, $y)';
}

