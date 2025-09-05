import 'dart:io';
import 'dart:typed_data';
import 'lib/services/geometric_dxf_generator.dart';
import 'lib/services/corner_detector_ffi.dart';

void main() async {
  print('Geometric DXF Test');
  print('=================');
  
  try {
    // Create test geometric primitives
    final primitives = DartGeometricPrimitives(
      // Lines
      [
        DartLine(DartPoint2D(0, 0), DartPoint2D(100, 0)),
        DartLine(DartPoint2D(100, 0), DartPoint2D(100, 50)),
        DartLine(DartPoint2D(100, 50), DartPoint2D(0, 50)),
        DartLine(DartPoint2D(0, 50), DartPoint2D(0, 0)),
      ],
      // Arcs
      [
        DartArc(DartPoint2D(50, 25), 20, 0, 3.14159), // Half circle
      ],
      // Circles
      [
        DartCircle(DartPoint2D(150, 25), 15),
      ],
    );
    
    print('Test primitives created:');
    print('- ${primitives.lines.length} lines');
    print('- ${primitives.arcs.length} arcs');
    print('- ${primitives.circles.length} circles');
    
    // Generate DXF file
    final generator = GeometricDXFGenerator();
    final String? filePath = await generator.generateDXF(primitives, 'geometric_test');
    
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
        
        // Count entities
        final lineCount = 'LINE'.allMatches(content).length;
        final arcCount = 'ARC'.allMatches(content).length;
        final circleCount = 'CIRCLE'.allMatches(content).length;
        
        print('✓ LINE entities: $lineCount');
        print('✓ ARC entities: $arcCount');
        print('✓ CIRCLE entities: $circleCount');
        
        // Check AutoCAD version
        if (content.contains('AC1009')) {
          print('✓ AutoCAD version: AC1009 (R12 - most compatible)');
        }
        
        // Validate DXF structure
        final bool isValid = generator.validateDXF(content);
        print('✓ DXF structure valid: $isValid');
        
        print('\n🎉 Geometric DXF file generated successfully!');
        print('\nKey features:');
        print('• Proper geometric primitives (LINE, ARC, CIRCLE)');
        print('• AC1009 (AutoCAD R12) format for maximum compatibility');
        print('• Minimal but complete DXF structure');
        print('• No complex handles or advanced features');
        
        print('\n📁 Try opening this file in AutoCAD:');
        print('   $filePath');
        
        print('\nThis should be much more stable and provide better geometric accuracy!');
        
      }
    } else {
      print('✗ Failed to generate DXF');
    }
  } catch (e) {
    print('✗ Error: $e');
    print('\nNote: This test requires the C++ library to be built first.');
    print('Run build_native.bat (Windows) or build_native.sh (Linux/Mac) to build the library.');
  }
}


