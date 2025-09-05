import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import '../models/image_data.dart';

class SimpleDXFGenerator {
  static final SimpleDXFGenerator _instance = SimpleDXFGenerator._internal();
  factory SimpleDXFGenerator() => _instance;
  SimpleDXFGenerator._internal();

  // Generate simple, stable DXF file
  Future<String?> generateSimpleDXF(String fileName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$fileName.dxf';
      
      final File file = File(filePath);
      final String dxfContent = _createSimpleDXFContent();
      
      await file.writeAsString(dxfContent);
      return filePath;
    } catch (e) {
      print('Error generating simple DXF: $e');
      return null;
    }
  }

  String _createSimpleDXFContent() {
    final StringBuffer buffer = StringBuffer();
    
    // Minimal DXF header
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('HEADER');
    buffer.writeln('9');
    buffer.writeln('\$ACADVER');
    buffer.writeln('1');
    buffer.writeln('AC1015');
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
    buffer.writeln('VPORT');
    buffer.writeln('5');
    buffer.writeln('8');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('1');
    buffer.writeln('0');
    buffer.writeln('VPORT');
    buffer.writeln('5');
    buffer.writeln('2E');
    buffer.writeln('330');
    buffer.writeln('8');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbViewportTableRecord');
    buffer.writeln('2');
    buffer.writeln('*ACTIVE');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('11');
    buffer.writeln('1.0');
    buffer.writeln('21');
    buffer.writeln('1.0');
    buffer.writeln('12');
    buffer.writeln('0.0');
    buffer.writeln('22');
    buffer.writeln('0.0');
    buffer.writeln('13');
    buffer.writeln('0.0');
    buffer.writeln('23');
    buffer.writeln('0.0');
    buffer.writeln('14');
    buffer.writeln('10.0');
    buffer.writeln('24');
    buffer.writeln('10.0');
    buffer.writeln('15');
    buffer.writeln('10.0');
    buffer.writeln('25');
    buffer.writeln('10.0');
    buffer.writeln('16');
    buffer.writeln('0.0');
    buffer.writeln('26');
    buffer.writeln('0.0');
    buffer.writeln('36');
    buffer.writeln('1.0');
    buffer.writeln('17');
    buffer.writeln('0.0');
    buffer.writeln('27');
    buffer.writeln('0.0');
    buffer.writeln('37');
    buffer.writeln('0.0');
    buffer.writeln('40');
    buffer.writeln('100.0');
    buffer.writeln('41');
    buffer.writeln('1.0');
    buffer.writeln('42');
    buffer.writeln('50.0');
    buffer.writeln('43');
    buffer.writeln('0.0');
    buffer.writeln('44');
    buffer.writeln('0.0');
    buffer.writeln('50');
    buffer.writeln('0.0');
    buffer.writeln('51');
    buffer.writeln('0.0');
    buffer.writeln('71');
    buffer.writeln('0');
    buffer.writeln('72');
    buffer.writeln('100');
    buffer.writeln('73');
    buffer.writeln('1');
    buffer.writeln('74');
    buffer.writeln('3');
    buffer.writeln('75');
    buffer.writeln('0');
    buffer.writeln('76');
    buffer.writeln('0');
    buffer.writeln('77');
    buffer.writeln('0');
    buffer.writeln('78');
    buffer.writeln('0');
    buffer.writeln('281');
    buffer.writeln('0');
    buffer.writeln('65');
    buffer.writeln('1');
    buffer.writeln('110');
    buffer.writeln('0.0');
    buffer.writeln('120');
    buffer.writeln('0.0');
    buffer.writeln('130');
    buffer.writeln('0.0');
    buffer.writeln('111');
    buffer.writeln('1.0');
    buffer.writeln('121');
    buffer.writeln('0.0');
    buffer.writeln('131');
    buffer.writeln('0.0');
    buffer.writeln('112');
    buffer.writeln('0.0');
    buffer.writeln('122');
    buffer.writeln('1.0');
    buffer.writeln('132');
    buffer.writeln('0.0');
    buffer.writeln('79');
    buffer.writeln('0');
    buffer.writeln('146');
    buffer.writeln('0.0');
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    
    // Blocks section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('BLOCKS');
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
    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    
    // Entities section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');
    
    // Add a simple rectangle as example
    buffer.writeln('0');
    buffer.writeln('LWPOLYLINE');
    buffer.writeln('5');
    buffer.writeln('100');
    buffer.writeln('330');
    buffer.writeln('1F');
    buffer.writeln('100');
    buffer.writeln('AcDbEntity');
    buffer.writeln('8');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbPolyline');
    buffer.writeln('90');
    buffer.writeln('4');
    buffer.writeln('70');
    buffer.writeln('1');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('10');
    buffer.writeln('100.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('10');
    buffer.writeln('100.0');
    buffer.writeln('20');
    buffer.writeln('100.0');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('100.0');
    
    // Add some text
    buffer.writeln('0');
    buffer.writeln('TEXT');
    buffer.writeln('5');
    buffer.writeln('101');
    buffer.writeln('330');
    buffer.writeln('1F');
    buffer.writeln('100');
    buffer.writeln('AcDbEntity');
    buffer.writeln('8');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbText');
    buffer.writeln('10');
    buffer.writeln('50.0');
    buffer.writeln('20');
    buffer.writeln('50.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    buffer.writeln('40');
    buffer.writeln('10.0');
    buffer.writeln('1');
    buffer.writeln('Field Sketch - DXF Scanner');
    
    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    buffer.writeln('0');
    buffer.writeln('EOF');

    return buffer.toString();
  }
}
