import 'dart:io';
import 'dart:typed_data';
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
    
    // DXF Header
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('HEADER');
    buffer.writeln('9');
    buffer.writeln(DXFConstants.ACADVER);
    buffer.writeln('1');
    buffer.writeln('AC1021');
    buffer.writeln('9');
    buffer.writeln(DXFConstants.DWGCODEPAGE);
    buffer.writeln('3');
    buffer.writeln('ANSI_1252');
    buffer.writeln('9');
    buffer.writeln(DXFConstants.INSBASE);
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    buffer.writeln('9');
    buffer.writeln(DXFConstants.EXTMIN);
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('9');
    buffer.writeln(DXFConstants.EXTMAX);
    buffer.writeln('10');
    buffer.writeln('1000.0');
    buffer.writeln('20');
    buffer.writeln('1000.0');
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Tables section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('TABLES');
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
    buffer.writeln('62');
    buffer.writeln('7');
    buffer.writeln('6');
    buffer.writeln('CONTINUOUS');
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Entities section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');

    // Add polylines for each contour
    for (int i = 0; i < contours.length; i++) {
      final List<Point> contour = contours[i];
      if (contour.length < 2) continue;

      // Create polyline
      buffer.writeln('0');
      buffer.writeln('POLYLINE');
      buffer.writeln('8');
      buffer.writeln('0');
      buffer.writeln('66');
      buffer.writeln('1');
      buffer.writeln('70');
      buffer.writeln('1'); // Closed polyline

      // Add vertices
      for (int j = 0; j < contour.length; j++) {
        final Point point = contour[j];
        buffer.writeln('0');
        buffer.writeln('VERTEX');
        buffer.writeln('8');
        buffer.writeln('0');
        buffer.writeln('10');
        buffer.writeln(point.x.toStringAsFixed(3));
        buffer.writeln('20');
        buffer.writeln(point.y.toStringAsFixed(3));
        buffer.writeln('30');
        buffer.writeln('0.0');
      }

      // End polyline
      buffer.writeln('0');
      buffer.writeln('SEQEND');
    }

    // End entities section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // End file
    buffer.writeln('0');
    buffer.writeln('EOF');

    return buffer.toString();
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

// DXF constants
class DXFConstants {
  static const String ACADVER = '\$ACADVER';
  static const String DWGCODEPAGE = '\$DWGCODEPAGE';
  static const String INSBASE = '\$INSBASE';
  static const String EXTMIN = '\$EXTMIN';
  static const String EXTMAX = '\$EXTMAX';
}
