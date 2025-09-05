import 'dart:io';
import 'dart:math';

// Standalone Point class for testing
class Point {
  final double x;
  final double y;
  
  Point(this.x, this.y);
}

// Minimal DXF Generator for testing
class MinimalDXFGenerator {
  // Generate DXF file from contours - Ultra minimal for maximum compatibility
  Future<String?> generateDXF(List<List<Point>> contours, String fileName) async {
    try {
      final String filePath = '$fileName.dxf';
      
      final File file = File(filePath);
      final String dxfContent = _createMinimalDXFContent(contours);
      
      await file.writeAsString(dxfContent);
      return filePath;
    } catch (e) {
      print('Error generating DXF: $e');
      return null;
    }
  }

  // Create minimal DXF content - Only essential elements
  String _createMinimalDXFContent(List<List<Point>> contours) {
    final StringBuffer buffer = StringBuffer();
    
    // Calculate bounds for proper scaling
    final bounds = _calculateBounds(contours);
    final scale = _calculateScale(bounds);
    
    // DXF Header Section - Absolute minimum
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

    // Entities Section - Simple LINE entities only
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');

    // Add LINE entities for each contour
    for (int i = 0; i < contours.length; i++) {
      final List<Point> contour = contours[i];
      if (contour.length < 2) continue;

      // Create individual LINE entities for each segment
      for (int j = 0; j < contour.length; j++) {
        final Point startPoint = contour[j];
        final Point endPoint = contour[(j + 1) % contour.length]; // Connect last point to first
        
        buffer.writeln('0');
        buffer.writeln('LINE');
        buffer.writeln('8'); // Layer
        buffer.writeln('0');
        buffer.writeln('10'); // Start X
        buffer.writeln((startPoint.x * scale).toStringAsFixed(3));
        buffer.writeln('20'); // Start Y
        buffer.writeln((startPoint.y * scale).toStringAsFixed(3));
        buffer.writeln('30'); // Start Z
        buffer.writeln('0.0');
        buffer.writeln('11'); // End X
        buffer.writeln((endPoint.x * scale).toStringAsFixed(3));
        buffer.writeln('21'); // End Y
        buffer.writeln((endPoint.y * scale).toStringAsFixed(3));
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
}

// Bounds class for calculating drawing extents
class Bounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  Bounds(this.minX, this.minY, this.maxX, this.maxY);
}

void main() async {
  print('Minimal DXF Test');
  print('================');
  
  // Create simple test contour
  final List<List<Point>> testContours = [
    [
      Point(0, 0),
      Point(100, 0),
      Point(100, 50),
      Point(0, 50),
    ],
  ];
  
  try {
    final MinimalDXFGenerator generator = MinimalDXFGenerator();
    final String? filePath = await generator.generateDXF(testContours, 'minimal_autocad_test');
    
    if (filePath != null) {
      print('✓ DXF generated: $filePath');
      
      final File file = File(filePath);
      if (await file.exists()) {
        final String content = await file.readAsString();
        print('✓ File size: ${await file.length()} bytes');
        print('✓ Contains HEADER: ${content.contains('HEADER')}');
        print('✓ Contains TABLES: ${content.contains('TABLES')}');
        print('✓ Contains ENTITIES: ${content.contains('ENTITIES')}');
        print('✓ Contains EOF: ${content.contains('EOF')}');
        print('✓ LINE count: ${'LINE'.allMatches(content).length}');
        
        // Check AutoCAD version
        if (content.contains('AC1009')) {
          print('✓ AutoCAD version: AC1009 (R12 - most compatible)');
        }
        
        // Check for required tables
        print('✓ LTYPE table: ${content.contains('LTYPE')}');
        print('✓ LAYER table: ${content.contains('LAYER')}');
        print('✓ CONTINUOUS linetype: ${content.contains('CONTINUOUS')}');
        
        print('\n🎉 Minimal DXF file generated successfully!');
        print('\nKey features:');
        print('• AC1009 (AutoCAD R12) - maximum compatibility');
        print('• Minimal header with only essential variables');
        print('• Simple LTYPE and LAYER tables');
        print('• Basic LINE entities without handles');
        print('• No complex blocks or advanced features');
        
        print('\n📁 Try opening this file in AutoCAD:');
        print('   $filePath');
        
        print('\nThis should be much more stable and less likely to crash AutoCAD!');
        
      }
    } else {
      print('✗ Failed to generate DXF');
    }
  } catch (e) {
    print('✗ Error: $e');
  }
}


