import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'corner_detector_ffi.dart';

class GeometricDXFGenerator {
  static final GeometricDXFGenerator _instance = GeometricDXFGenerator._internal();
  factory GeometricDXFGenerator() => _instance;
  GeometricDXFGenerator._internal();

  // Generate DXF file from geometric primitives
  Future<String?> generateDXF(DartGeometricPrimitives primitives, String fileName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$fileName.dxf';
      
      final File file = File(filePath);
      final String dxfContent = _createGeometricDXFContent(primitives);
      
      await file.writeAsString(dxfContent);
      return filePath;
    } catch (e) {
      print('Error generating geometric DXF: $e');
      return null;
    }
  }

  // Create DXF content with proper geometric primitives
  String _createGeometricDXFContent(DartGeometricPrimitives primitives) {
    final StringBuffer buffer = StringBuffer();
    
    // Calculate bounds for proper scaling
    final bounds = _calculateBounds(primitives);
    final scale = _calculateScale(bounds);
    
    // DXF Header Section - Minimal but complete
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('HEADER');
    
    // AutoCAD version (AC1009 = AutoCAD R12 - most compatible)
    buffer.writeln('9');
    buffer.writeln('\$ACADVER');
    buffer.writeln('1');
    buffer.writeln('AC1009');
    
    // Drawing extents
    buffer.writeln('9');
    buffer.writeln('\$EXTMIN');
    buffer.writeln('10');
    buffer.writeln((bounds.minX * scale).toStringAsFixed(3));
    buffer.writeln('20');
    buffer.writeln((bounds.minY * scale).toStringAsFixed(3));
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$EXTMAX');
    buffer.writeln('10');
    buffer.writeln((bounds.maxX * scale).toStringAsFixed(3));
    buffer.writeln('20');
    buffer.writeln((bounds.maxY * scale).toStringAsFixed(3));
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    // End header section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Tables Section - Minimal
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('TABLES');
    
    // LTYPE table - Just CONTINUOUS
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('LTYPE');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('0');
    buffer.writeln('LTYPE');
    buffer.writeln('2');
    buffer.writeln('CONTINUOUS');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('3');
    buffer.writeln('Solid line');
    buffer.writeln('72');
    buffer.writeln('65');
    buffer.writeln('73');
    buffer.writeln('0');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // LAYER table - Just layer 0
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('LAYER');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('0');
    buffer.writeln('LAYER');
    buffer.writeln('2');
    buffer.writeln('0');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('6');
    buffer.writeln('CONTINUOUS');
    buffer.writeln('62');
    buffer.writeln('7');
    
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // End tables section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Entities Section - Geometric primitives
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');

    // Add LINE entities
    for (final line in primitives.lines) {
      _addLineEntity(buffer, line, scale);
    }
    
    // Add ARC entities
    for (final arc in primitives.arcs) {
      _addArcEntity(buffer, arc, scale);
    }
    
    // Add CIRCLE entities
    for (final circle in primitives.circles) {
      _addCircleEntity(buffer, circle, scale);
    }

    // End entities section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // End file
    buffer.writeln('0');
    buffer.writeln('EOF');

    return buffer.toString();
  }

  // Add LINE entity to DXF
  void _addLineEntity(StringBuffer buffer, DartLine line, double scale) {
    buffer.writeln('0');
    buffer.writeln('LINE');
    buffer.writeln('8'); // Layer
    buffer.writeln('0');
    buffer.writeln('10'); // Start X
    buffer.writeln((line.start.x * scale).toStringAsFixed(3));
    buffer.writeln('20'); // Start Y
    buffer.writeln((line.start.y * scale).toStringAsFixed(3));
    buffer.writeln('30'); // Start Z
    buffer.writeln('0.0');
    buffer.writeln('11'); // End X
    buffer.writeln((line.end.x * scale).toStringAsFixed(3));
    buffer.writeln('21'); // End Y
    buffer.writeln((line.end.y * scale).toStringAsFixed(3));
    buffer.writeln('31'); // End Z
    buffer.writeln('0.0');
  }

  // Add ARC entity to DXF
  void _addArcEntity(StringBuffer buffer, DartArc arc, double scale) {
    buffer.writeln('0');
    buffer.writeln('ARC');
    buffer.writeln('8'); // Layer
    buffer.writeln('0');
    buffer.writeln('10'); // Center X
    buffer.writeln((arc.center.x * scale).toStringAsFixed(3));
    buffer.writeln('20'); // Center Y
    buffer.writeln((arc.center.y * scale).toStringAsFixed(3));
    buffer.writeln('30'); // Center Z
    buffer.writeln('0.0');
    buffer.writeln('40'); // Radius
    buffer.writeln((arc.radius * scale).toStringAsFixed(3));
    buffer.writeln('50'); // Start angle (in degrees)
    buffer.writeln((arc.startAngle * 180.0 / pi).toStringAsFixed(3));
    buffer.writeln('51'); // End angle (in degrees)
    buffer.writeln((arc.endAngle * 180.0 / pi).toStringAsFixed(3));
  }

  // Add CIRCLE entity to DXF
  void _addCircleEntity(StringBuffer buffer, DartCircle circle, double scale) {
    buffer.writeln('0');
    buffer.writeln('CIRCLE');
    buffer.writeln('8'); // Layer
    buffer.writeln('0');
    buffer.writeln('10'); // Center X
    buffer.writeln((circle.center.x * scale).toStringAsFixed(3));
    buffer.writeln('20'); // Center Y
    buffer.writeln((circle.center.y * scale).toStringAsFixed(3));
    buffer.writeln('30'); // Center Z
    buffer.writeln('0.0');
    buffer.writeln('40'); // Radius
    buffer.writeln((circle.radius * scale).toStringAsFixed(3));
  }

  // Calculate bounds of all geometric primitives
  Bounds _calculateBounds(DartGeometricPrimitives primitives) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // Check lines
    for (final line in primitives.lines) {
      minX = min(minX, min(line.start.x, line.end.x));
      minY = min(minY, min(line.start.y, line.end.y));
      maxX = max(maxX, max(line.start.x, line.end.x));
      maxY = max(maxY, max(line.start.y, line.end.y));
    }

    // Check arcs
    for (final arc in primitives.arcs) {
      minX = min(minX, arc.center.x - arc.radius);
      minY = min(minY, arc.center.y - arc.radius);
      maxX = max(maxX, arc.center.x + arc.radius);
      maxY = max(maxY, arc.center.y + arc.radius);
    }

    // Check circles
    for (final circle in primitives.circles) {
      minX = min(minX, circle.center.x - circle.radius);
      minY = min(minY, circle.center.y - circle.radius);
      maxX = max(maxX, circle.center.x + circle.radius);
      maxY = max(maxY, circle.center.y + circle.radius);
    }

    return Bounds(minX, minY, maxX, maxY);
  }

  // Calculate appropriate scale factor
  double _calculateScale(Bounds bounds) {
    final width = bounds.maxX - bounds.minX;
    final height = bounds.maxY - bounds.minY;
    final maxDimension = max(width, height);
    
    // Scale to fit in a reasonable range (e.g., 100 units)
    if (maxDimension > 0) {
      return 100.0 / maxDimension;
    }
    return 1.0;
  }

  // Generate DXF from image data using corner detection
  Future<String?> generateDXFFromImage(Uint8List imageData, int width, int height, int channels, String fileName) async {
    try {
      // Use FFI to detect geometric primitives
      final cornerDetector = CornerDetectorFFI();
      final primitives = cornerDetector.processImage(imageData, width, height, channels);
      
      print('Detected primitives: ${primitives.lines.length} lines, ${primitives.arcs.length} arcs, ${primitives.circles.length} circles');
      
      // Generate DXF file
      return await generateDXF(primitives, fileName);
    } catch (e) {
      print('Error generating DXF from image: $e');
      return null;
    }
  }

  // Get DXF file as bytes for sharing
  Future<Uint8List?> getDXFBytes(String dxfFilePath) async {
    try {
      final File file = File(dxfFilePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading DXF file: $e');
      return null;
    }
  }

  // Validate DXF file
  bool validateDXF(String dxfContent) {
    return dxfContent.contains('SECTION') && 
           dxfContent.contains('ENTITIES') && 
           dxfContent.contains('EOF');
  }

  // Get file size in KB
  Future<double?> getDXFFileSize(String dxfFilePath) async {
    try {
      final File file = File(dxfFilePath);
      if (await file.exists()) {
        final int bytes = await file.length();
        return bytes / 1024.0; // Convert to KB
      }
      return null;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }
}

// Bounds class for calculating drawing extents
class Bounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  Bounds(this.minX, this.minY, this.maxX, this.maxY);
}


