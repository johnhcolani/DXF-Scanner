import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import '../models/image_data.dart';
import 'image_processor.dart';

class DXFGenerator {
  static final DXFGenerator _instance = DXFGenerator._internal();
  factory DXFGenerator() => _instance;
  DXFGenerator._internal();

  // Generate DXF file from contours
  Future<String?> generateDXF(List<List<Point>> contours, String fileName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$fileName.dxf';
      
      final File file = File(filePath);
      final String dxfContent = _createDXFContent(contours);
      
      await file.writeAsString(dxfContent);
      return filePath;
    } catch (e) {
      print('Error generating DXF: $e');
      return null;
    }
  }

  // Create DXF content from contours
  String _createDXFContent(List<List<Point>> contours) {
    final StringBuffer buffer = StringBuffer();
    
    // Calculate bounds for proper scaling
    final bounds = _calculateBounds(contours);
    final scale = _calculateScale(bounds);
    
    // DXF Header Section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('HEADER');
    
    // AutoCAD version (AC1021 = AutoCAD 2007/2008)
    buffer.writeln('9');
    buffer.writeln('\$ACADVER');
    buffer.writeln('1');
    buffer.writeln('AC1021');
    
    // Drawing code page
    buffer.writeln('9');
    buffer.writeln('\$DWGCODEPAGE');
    buffer.writeln('3');
    buffer.writeln('ANSI_1252');
    
    // Insertion base point
    buffer.writeln('9');
    buffer.writeln('\$INSBASE');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    // Drawing extents
    buffer.writeln('9');
    buffer.writeln('\$EXTMIN');
    buffer.writeln('10');
    buffer.writeln((bounds.minX * scale).toStringAsFixed(6));
    buffer.writeln('20');
    buffer.writeln((bounds.minY * scale).toStringAsFixed(6));
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$EXTMAX');
    buffer.writeln('10');
    buffer.writeln((bounds.maxX * scale).toStringAsFixed(6));
    buffer.writeln('20');
    buffer.writeln((bounds.maxY * scale).toStringAsFixed(6));
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    // Current layer
    buffer.writeln('9');
    buffer.writeln('\$CLAYER');
    buffer.writeln('8');
    buffer.writeln('0');
    
    // Units
    buffer.writeln('9');
    buffer.writeln('\$INSUNITS');
    buffer.writeln('70');
    buffer.writeln('0'); // Unitless
    
    // End header section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Tables Section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('TABLES');
    
    // Layer table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('LAYER');
    buffer.writeln('70');
    buffer.writeln('1'); // Number of layers
    
    // Default layer (0)
    buffer.writeln('0');
    buffer.writeln('LAYER');
    buffer.writeln('2');
    buffer.writeln('0');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('62');
    buffer.writeln('7'); // White color
    buffer.writeln('6');
    buffer.writeln('CONTINUOUS');
    
    // End layer table
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // End tables section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Entities Section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');

    // Add LINE entities for each contour (most compatible)
    int handleCounter = 100;
    for (int i = 0; i < contours.length; i++) {
      final List<Point> contour = contours[i];
      if (contour.length < 2) continue;

      // Create individual LINE entities for each segment
      for (int j = 0; j < contour.length; j++) {
        final Point startPoint = contour[j];
        final Point endPoint = contour[(j + 1) % contour.length]; // Connect last point to first
        
        buffer.writeln('0');
        buffer.writeln('LINE');
        buffer.writeln('5'); // Handle
        buffer.writeln('${handleCounter++}');
        buffer.writeln('8'); // Layer
        buffer.writeln('0');
        buffer.writeln('10'); // Start X
        buffer.writeln((startPoint.x * scale).toStringAsFixed(6));
        buffer.writeln('20'); // Start Y
        buffer.writeln((startPoint.y * scale).toStringAsFixed(6));
        buffer.writeln('30'); // Start Z
        buffer.writeln('0.0');
        buffer.writeln('11'); // End X
        buffer.writeln((endPoint.x * scale).toStringAsFixed(6));
        buffer.writeln('21'); // End Y
        buffer.writeln((endPoint.y * scale).toStringAsFixed(6));
        buffer.writeln('31'); // End Z
        buffer.writeln('0.0');
      }
    }

    // End entities section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // End file
    buffer.writeln('0');
    buffer.writeln('EOF');

    return buffer.toString();
  }

  // Calculate bounds of all contours
  Bounds _calculateBounds(List<List<Point>> contours) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final contour in contours) {
      for (final point in contour) {
        minX = min(minX, point.x);
        minY = min(minY, point.y);
        maxX = max(maxX, point.x);
        maxY = max(maxY, point.y);
      }
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

  // Generate DXF from image data
  Future<String?> generateDXFFromImage(ImageData imageData) async {
    try {
      if (imageData.imageBytes == null) return null;

      // Process image to get contours
      final ImageProcessor processor = ImageProcessor();
      final processedImage = await processor.processImage(imageData.imageBytes!);
      
      if (processedImage == null) return null;

      // Extract contours
      final contours = processor.extractContours(processedImage);
      
      if (contours.isEmpty) return null;

      // Simplify contours
      final simplifiedContours = contours.map((contour) {
        return processor.simplifyContour(contour, 2.0);
      }).toList();

      // Generate DXF file
      final fileName = 'dxf_${imageData.id}';
      return await generateDXF(simplifiedContours, fileName);
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
