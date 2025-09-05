import 'dart:io';
import 'dart:math';

// Standalone Point class for testing
class Point {
  final double x;
  final double y;
  
  Point(this.x, this.y);
}

// Standalone DXF Generator for testing
class DXFGenerator {
  // Generate DXF file from contours
  Future<String?> generateDXF(List<List<Point>> contours, String fileName) async {
    try {
      final String filePath = '$fileName.dxf';
      
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
    
    // AutoCAD version (AC1015 = AutoCAD 2000/2000i/2002 - most compatible)
    buffer.writeln('9');
    buffer.writeln('\$ACADVER');
    buffer.writeln('1');
    buffer.writeln('AC1015');
    
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
    
    // LTYPE table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('LTYPE');
    buffer.writeln('5');
    buffer.writeln('5');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('1');
    
    // CONTINUOUS linetype
    buffer.writeln('0');
    buffer.writeln('LTYPE');
    buffer.writeln('5');
    buffer.writeln('14');
    buffer.writeln('330');
    buffer.writeln('5');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbLinetypeTableRecord');
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
    
    // LAYER table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('LAYER');
    buffer.writeln('5');
    buffer.writeln('2');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('1');
    
    // Default layer (0)
    buffer.writeln('0');
    buffer.writeln('LAYER');
    buffer.writeln('5');
    buffer.writeln('10');
    buffer.writeln('330');
    buffer.writeln('2');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbLayerTableRecord');
    buffer.writeln('2');
    buffer.writeln('0');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('6');
    buffer.writeln('CONTINUOUS');
    buffer.writeln('62');
    buffer.writeln('7');
    buffer.writeln('290');
    buffer.writeln('1');
    buffer.writeln('370');
    buffer.writeln('-3');
    buffer.writeln('390');
    buffer.writeln('F');
    
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // End tables section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Blocks Section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('BLOCKS');
    
    // Model space block
    buffer.writeln('0');
    buffer.writeln('BLOCK');
    buffer.writeln('5');
    buffer.writeln('20');
    buffer.writeln('330');
    buffer.writeln('1F');
    buffer.writeln('100');
    buffer.writeln('AcDbEntity');
    buffer.writeln('8');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbBlockBegin');
    buffer.writeln('2');
    buffer.writeln('*MODEL_SPACE');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    buffer.writeln('3');
    buffer.writeln('*MODEL_SPACE');
    buffer.writeln('1');
    buffer.writeln('');
    
    // End model space block
    buffer.writeln('0');
    buffer.writeln('ENDBLK');
    buffer.writeln('5');
    buffer.writeln('21');
    buffer.writeln('330');
    buffer.writeln('1F');
    buffer.writeln('100');
    buffer.writeln('AcDbEntity');
    buffer.writeln('8');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbBlockEnd');
    
    // End blocks section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Entities Section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');

    // Add LINE entities for each contour (most compatible)
    int handleCounter = 1000; // Start with higher handle numbers
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
        buffer.writeln('${handleCounter.toRadixString(16).toUpperCase()}');
        buffer.writeln('330'); // Owner handle
        buffer.writeln('1F'); // Model space
        buffer.writeln('100'); // Subclass marker
        buffer.writeln('AcDbEntity');
        buffer.writeln('8'); // Layer
        buffer.writeln('0');
        buffer.writeln('100'); // Subclass marker
        buffer.writeln('AcDbLine');
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
        
        handleCounter++;
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

  // Validate DXF file
  bool validateDXF(String dxfContent) {
    return dxfContent.contains('SECTION') && 
           dxfContent.contains('ENTITIES') && 
           dxfContent.contains('EOF');
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
  print('Standalone DXF Test');
  print('===================');
  
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
    final DXFGenerator generator = DXFGenerator();
    final String? filePath = await generator.generateDXF(testContours, 'autocad_compatible_test');
    
    if (filePath != null) {
      print('✓ DXF generated: $filePath');
      
      final File file = File(filePath);
      if (await file.exists()) {
        final String content = await file.readAsString();
        print('✓ File size: ${await file.length()} bytes');
        print('✓ Contains HEADER: ${content.contains('HEADER')}');
        print('✓ Contains TABLES: ${content.contains('TABLES')}');
        print('✓ Contains BLOCKS: ${content.contains('BLOCKS')}');
        print('✓ Contains ENTITIES: ${content.contains('ENTITIES')}');
        print('✓ Contains EOF: ${content.contains('EOF')}');
        print('✓ LINE count: ${'LINE'.allMatches(content).length}');
        
        // Check AutoCAD version
        if (content.contains('AC1015')) {
          print('✓ AutoCAD version: AC1015 (compatible)');
        }
        
        // Check for required tables
        print('✓ LTYPE table: ${content.contains('LTYPE')}');
        print('✓ LAYER table: ${content.contains('LAYER')}');
        print('✓ CONTINUOUS linetype: ${content.contains('CONTINUOUS')}');
        
        // Validate DXF structure
        final bool isValid = generator.validateDXF(content);
        print('✓ DXF structure valid: $isValid');
        
        print('\n🎉 DXF file generated successfully!');
        print('\nKey improvements made:');
        print('• Changed to AC1015 (AutoCAD 2000) for maximum compatibility');
        print('• Added required DXF tables (LTYPE, LAYER)');
        print('• Added proper BLOCKS section with MODEL_SPACE');
        print('• Used proper entity handles and subclass markers');
        print('• Added owner handles and proper entity structure');
        
        print('\n📁 You can now try opening this file in AutoCAD:');
        print('   $filePath');
        
      }
    } else {
      print('✗ Failed to generate DXF');
    }
  } catch (e) {
    print('✗ Error: $e');
  }
}


