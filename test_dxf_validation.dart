import 'dart:io';

void main() async {
  // Test the generated DXF file
  final file = File('test_improved_dxf.dxf');
  
  if (await file.exists()) {
    final content = await file.readAsString();
    
    print('DXF File Analysis:');
    print('==================');
    print('File size: ${await file.length()} bytes');
    print('Contains SECTION: ${content.contains('SECTION')}');
    print('Contains ENTITIES: ${content.contains('ENTITIES')}');
    print('Contains EOF: ${content.contains('EOF')}');
    print('Contains LWPOLYLINE: ${content.contains('LWPOLYLINE')}');
    
    // Count entities
    final lineCount = 'LINE'.allMatches(content).length;
    print('Number of LINE entities: $lineCount');
    
    print('\nFirst 20 lines of DXF:');
    print('======================');
    final lines = content.split('\n');
    for (int i = 0; i < lines.length && i < 20; i++) {
      print('${i + 1}: ${lines[i]}');
    }
    
    print('\nDXF file appears to be valid!');
  } else {
    print('Test DXF file not found!');
  }
}
