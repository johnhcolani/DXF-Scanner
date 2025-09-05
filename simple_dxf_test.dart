import 'dart:io';
import 'dart:math';
import 'lib/services/dxf_generator.dart';

void main() async {
  print('Simple DXF Test');
  print('===============');
  
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
    final String? filePath = await generator.generateDXF(testContours, 'simple_test');
    
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
        
        print('\n🎉 DXF file generated successfully!');
      }
    } else {
      print('✗ Failed to generate DXF');
    }
  } catch (e) {
    print('✗ Error: $e');
  }
}


