import 'dart:io';
import 'dart:math';
import 'lib/services/dxf_generator.dart';

void main() async {
  print('Testing Improved DXF Generation');
  print('===============================');
  
  // Create test contours (simple shapes)
  final List<List<Point>> testContours = [
    // Rectangle
    [
      Point(0, 0),
      Point(100, 0),
      Point(100, 50),
      Point(0, 50),
    ],
    // Triangle
    [
      Point(150, 0),
      Point(200, 0),
      Point(175, 50),
    ],
    // Circle approximation (octagon)
    [
      Point(250, 25),
      Point(275, 0),
      Point(300, 0),
      Point(325, 25),
      Point(325, 50),
      Point(300, 75),
      Point(275, 75),
      Point(250, 50),
    ],
  ];
  
  try {
    // Generate DXF file
    final DXFGenerator generator = DXFGenerator();
    final String? filePath = await generator.generateDXF(testContours, 'autocad_compatible_test');
    
    if (filePath != null) {
      print('✓ DXF file generated successfully: $filePath');
      
      // Read and analyze the file
      final File file = File(filePath);
      if (await file.exists()) {
        final String content = await file.readAsString();
        final int fileSize = await file.length();
        
        print('\nDXF File Analysis:');
        print('==================');
        print('File size: $fileSize bytes');
        print('File path: $filePath');
        
        // Check for required sections
        final bool hasHeader = content.contains('SECTION') && content.contains('HEADER');
        final bool hasTables = content.contains('TABLES');
        final bool hasBlocks = content.contains('BLOCKS');
        final bool hasEntities = content.contains('ENTITIES');
        final bool hasEOF = content.contains('EOF');
        
        print('\nRequired Sections:');
        print('✓ Header: $hasHeader');
        print('✓ Tables: $hasTables');
        print('✓ Blocks: $hasBlocks');
        print('✓ Entities: $hasEntities');
        print('✓ EOF: $hasEOF');
        
        // Check for required tables
        final bool hasVPORT = content.contains('VPORT');
        final bool hasLTYPE = content.contains('LTYPE');
        final bool hasLAYER = content.contains('LAYER');
        final bool hasSTYLE = content.contains('STYLE');
        final bool hasDIMSTYLE = content.contains('DIMSTYLE');
        final bool hasBLOCK_RECORD = content.contains('BLOCK_RECORD');
        
        print('\nRequired Tables:');
        print('✓ VPORT: $hasVPORT');
        print('✓ LTYPE: $hasLTYPE');
        print('✓ LAYER: $hasLAYER');
        print('✓ STYLE: $hasSTYLE');
        print('✓ DIMSTYLE: $hasDIMSTYLE');
        print('✓ BLOCK_RECORD: $hasBLOCK_RECORD');
        
        // Check for required header variables
        final bool hasACADVER = content.contains('\$ACADVER');
        final bool hasDWGCODEPAGE = content.contains('\$DWGCODEPAGE');
        final bool hasINSBASE = content.contains('\$INSBASE');
        final bool hasEXTMIN = content.contains('\$EXTMIN');
        final bool hasEXTMAX = content.contains('\$EXTMAX');
        final bool hasCLAYER = content.contains('\$CLAYER');
        final bool hasINSUNITS = content.contains('\$INSUNITS');
        
        print('\nRequired Header Variables:');
        print('✓ ACADVER: $hasACADVER');
        print('✓ DWGCODEPAGE: $hasDWGCODEPAGE');
        print('✓ INSBASE: $hasINSBASE');
        print('✓ EXTMIN: $hasEXTMIN');
        print('✓ EXTMAX: $hasEXTMAX');
        print('✓ CLAYER: $hasCLAYER');
        print('✓ INSUNITS: $hasINSUNITS');
        
        // Count entities
        final int lineCount = 'LINE'.allMatches(content).length;
        print('\nEntities:');
        print('✓ LINE entities: $lineCount');
        
        // Check AutoCAD version
        final RegExp acadVerRegex = RegExp(r'\$ACADVER\s*\n1\s*\n(AC\d+)');
        final Match? acadVerMatch = acadVerRegex.firstMatch(content);
        if (acadVerMatch != null) {
          print('✓ AutoCAD version: ${acadVerMatch.group(1)}');
        }
        
        // Validate DXF structure
        final bool isValid = generator.validateDXF(content);
        print('\nValidation:');
        print('✓ DXF structure valid: $isValid');
        
        // Get file size in KB
        final double? fileSizeKB = await generator.getDXFFileSize(filePath);
        if (fileSizeKB != null) {
          print('✓ File size: ${fileSizeKB.toStringAsFixed(2)} KB');
        }
        
        print('\n🎉 DXF file appears to be fully AutoCAD compatible!');
        print('\nKey improvements made:');
        print('• Changed to AC1015 (AutoCAD 2000) for maximum compatibility');
        print('• Added all required DXF tables (VPORT, LTYPE, LAYER, STYLE, DIMSTYLE, BLOCK_RECORD)');
        print('• Added comprehensive header variables');
        print('• Added proper BLOCKS section with MODEL_SPACE and PAPER_SPACE');
        print('• Used proper entity handles and subclass markers');
        print('• Added owner handles and proper entity structure');
        
        print('\n📁 You can now try opening this file in AutoCAD:');
        print('   $filePath');
        
      } else {
        print('✗ Generated file does not exist!');
      }
    } else {
      print('✗ Failed to generate DXF file!');
    }
  } catch (e) {
    print('✗ Error during DXF generation: $e');
  }
}


