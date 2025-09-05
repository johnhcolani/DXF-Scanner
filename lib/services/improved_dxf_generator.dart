import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import '../models/image_data.dart';
import 'image_processor.dart';

class ImprovedDXFGenerator {
  static final ImprovedDXFGenerator _instance = ImprovedDXFGenerator._internal();
  factory ImprovedDXFGenerator() => _instance;
  ImprovedDXFGenerator._internal();

  // Generate high-quality DXF file from contours
  Future<String?> generateDXF(List<List<Point>> contours, String fileName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$fileName.dxf';
      
      final File file = File(filePath);
      final String dxfContent = _createHighQualityDXFContent(contours);
      
      await file.writeAsString(dxfContent);
      return filePath;
    } catch (e) {
      print('Error generating DXF: $e');
      return null;
    }
  }

  // Create high-quality DXF content with proper structure
  String _createHighQualityDXFContent(List<List<Point>> contours) {
    final StringBuffer buffer = StringBuffer();
    
    // Calculate bounds and scaling
    final bounds = _calculateBounds(contours);
    final scale = _calculateOptimalScale(bounds);
    final offset = _calculateOffset(bounds);
    
    // DXF Header Section - Clean and minimal
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('HEADER');
    
    // Essential header variables only
    buffer.writeln('9');
    buffer.writeln('\$ACADVER');
    buffer.writeln('1');
    buffer.writeln('AC1015'); // AutoCAD 2000 format
    
    buffer.writeln('9');
    buffer.writeln('\$INSBASE');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$EXTMIN');
    buffer.writeln('10');
    buffer.writeln('${bounds.minX * scale + offset.x}');
    buffer.writeln('20');
    buffer.writeln('${bounds.minY * scale + offset.y}');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$EXTMAX');
    buffer.writeln('10');
    buffer.writeln('${bounds.maxX * scale + offset.x}');
    buffer.writeln('20');
    buffer.writeln('${bounds.maxY * scale + offset.y}');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$LIMMIN');
    buffer.writeln('10');
    buffer.writeln('${bounds.minX * scale + offset.x}');
    buffer.writeln('20');
    buffer.writeln('${bounds.minY * scale + offset.y}');
    
    buffer.writeln('9');
    buffer.writeln('\$LIMMAX');
    buffer.writeln('10');
    buffer.writeln('${bounds.maxX * scale + offset.x}');
    buffer.writeln('20');
    buffer.writeln('${bounds.maxY * scale + offset.y}');
    
    buffer.writeln('9');
    buffer.writeln('\$ORTHOMODE');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$REGENMODE');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$FILLMODE');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$QTEXTMODE');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$MIRRTEXT');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DRAGMODE');
    buffer.writeln('70');
    buffer.writeln('2');
    
    buffer.writeln('9');
    buffer.writeln('\$LTSCALE');
    buffer.writeln('40');
    buffer.writeln('1.0');
    
    buffer.writeln('9');
    buffer.writeln('\$OSMODE');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$ATTMODE');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$TEXTSIZE');
    buffer.writeln('40');
    buffer.writeln('2.5');
    
    buffer.writeln('9');
    buffer.writeln('\$TRACEWID');
    buffer.writeln('40');
    buffer.writeln('0.05');
    
    buffer.writeln('9');
    buffer.writeln('\$TEXTSTYLE');
    buffer.writeln('7');
    buffer.writeln('STANDARD');
    
    buffer.writeln('9');
    buffer.writeln('\$CLAYER');
    buffer.writeln('8');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$CELTYPE');
    buffer.writeln('6');
    buffer.writeln('BYLAYER');
    
    buffer.writeln('9');
    buffer.writeln('\$CECOLOR');
    buffer.writeln('62');
    buffer.writeln('256'); // BYLAYER
    
    buffer.writeln('9');
    buffer.writeln('\$CELTSCALE');
    buffer.writeln('40');
    buffer.writeln('1.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DISPSILH');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSCALE');
    buffer.writeln('40');
    buffer.writeln('1.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMASZ');
    buffer.writeln('40');
    buffer.writeln('2.5');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMEXO');
    buffer.writeln('40');
    buffer.writeln('0.625');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMDLI');
    buffer.writeln('40');
    buffer.writeln('3.75');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMRND');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMDLE');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMEXE');
    buffer.writeln('40');
    buffer.writeln('1.25');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTP');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTM');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTXT');
    buffer.writeln('40');
    buffer.writeln('2.5');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMCEN');
    buffer.writeln('40');
    buffer.writeln('2.5');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTSZ');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTOL');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLIM');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTIH');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTOH');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSE1');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSE2');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTAD');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMZIN');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMBLK');
    buffer.writeln('1');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMASO');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSHO');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMPOST');
    buffer.writeln('1');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMAPOST');
    buffer.writeln('1');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMALT');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMALTD');
    buffer.writeln('70');
    buffer.writeln('2');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMALTF');
    buffer.writeln('40');
    buffer.writeln('25.4');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLFAC');
    buffer.writeln('40');
    buffer.writeln('1.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTOFL');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTVP');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTIX');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSOXD');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSAH');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMBLK1');
    buffer.writeln('1');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMBLK2');
    buffer.writeln('1');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSTYLE');
    buffer.writeln('2');
    buffer.writeln('STANDARD');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMCLRD');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMCLRE');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMCLRT');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTFAC');
    buffer.writeln('40');
    buffer.writeln('1.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMGAP');
    buffer.writeln('40');
    buffer.writeln('0.625');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMJUST');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSD1');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMSD2');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTOLJ');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTZIN');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMALTZ');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMALTTZ');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMUPT');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMDEC');
    buffer.writeln('70');
    buffer.writeln('4');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTDEC');
    buffer.writeln('70');
    buffer.writeln('4');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMALTU');
    buffer.writeln('70');
    buffer.writeln('2');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMALTTD');
    buffer.writeln('70');
    buffer.writeln('2');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTXSTY');
    buffer.writeln('7');
    buffer.writeln('STANDARD');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMAUNIT');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMADEC');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMALTRND');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMAZIN');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMDSEP');
    buffer.writeln('70');
    buffer.writeln('46');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMATFIT');
    buffer.writeln('70');
    buffer.writeln('3');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMFRAC');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLDRBLK');
    buffer.writeln('1');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLUNIT');
    buffer.writeln('70');
    buffer.writeln('2');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLWD');
    buffer.writeln('70');
    buffer.writeln('-2');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLWE');
    buffer.writeln('70');
    buffer.writeln('-2');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTMOVE');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMFXL');
    buffer.writeln('40');
    buffer.writeln('1.0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMFXLON');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMJOGANG');
    buffer.writeln('40');
    buffer.writeln('1.5707963267948966');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTFILL');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTFILLCLR');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMARCSYM');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLTYPE');
    buffer.writeln('6');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLTEX1');
    buffer.writeln('6');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMLTEX2');
    buffer.writeln('6');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMTXTDIRECTION');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$LUNITS');
    buffer.writeln('70');
    buffer.writeln('2');
    
    buffer.writeln('9');
    buffer.writeln('\$LUPREC');
    buffer.writeln('70');
    buffer.writeln('4');
    
    buffer.writeln('9');
    buffer.writeln('\$SKETCHINC');
    buffer.writeln('40');
    buffer.writeln('0.1');
    
    buffer.writeln('9');
    buffer.writeln('\$FILLETRAD');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$AUNITS');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$AUPREC');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$INSUNITS');
    buffer.writeln('70');
    buffer.writeln('0');
    
    // End header section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    
    // Tables section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('TABLES');
    
    // Viewport table
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
    buffer.writeln('${(bounds.minX + bounds.maxX) * scale / 2 + offset.x}');
    buffer.writeln('22');
    buffer.writeln('${(bounds.minY + bounds.maxY) * scale / 2 + offset.y}');
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
    buffer.writeln('${max(bounds.maxX - bounds.minX, bounds.maxY - bounds.minY) * scale * 1.2}');
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
    
    // Linetype table
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
    buffer.writeln('BYBLOCK');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('3');
    buffer.writeln('');
    buffer.writeln('72');
    buffer.writeln('65');
    buffer.writeln('73');
    buffer.writeln('0');
    buffer.writeln('40');
    buffer.writeln('0.0');
    buffer.writeln('0');
    buffer.writeln('LTYPE');
    buffer.writeln('5');
    buffer.writeln('15');
    buffer.writeln('330');
    buffer.writeln('5');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbLinetypeTableRecord');
    buffer.writeln('2');
    buffer.writeln('BYLAYER');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('3');
    buffer.writeln('');
    buffer.writeln('72');
    buffer.writeln('65');
    buffer.writeln('73');
    buffer.writeln('0');
    buffer.writeln('40');
    buffer.writeln('0.0');
    buffer.writeln('0');
    buffer.writeln('LTYPE');
    buffer.writeln('5');
    buffer.writeln('16');
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
    
    // Layer table
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
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // Style table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('STYLE');
    buffer.writeln('5');
    buffer.writeln('3');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('1');
    buffer.writeln('0');
    buffer.writeln('STYLE');
    buffer.writeln('5');
    buffer.writeln('11');
    buffer.writeln('330');
    buffer.writeln('3');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbTextStyleTableRecord');
    buffer.writeln('2');
    buffer.writeln('STANDARD');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('40');
    buffer.writeln('0.0');
    buffer.writeln('41');
    buffer.writeln('1.0');
    buffer.writeln('50');
    buffer.writeln('0.0');
    buffer.writeln('71');
    buffer.writeln('0');
    buffer.writeln('42');
    buffer.writeln('2.5');
    buffer.writeln('3');
    buffer.writeln('txt');
    buffer.writeln('4');
    buffer.writeln('');
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // View table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('UCS');
    buffer.writeln('5');
    buffer.writeln('7');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // AppID table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('APPID');
    buffer.writeln('5');
    buffer.writeln('9');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('2');
    buffer.writeln('0');
    buffer.writeln('APPID');
    buffer.writeln('5');
    buffer.writeln('12');
    buffer.writeln('330');
    buffer.writeln('9');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbRegAppTableRecord');
    buffer.writeln('2');
    buffer.writeln('ACAD');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // DIMSTYLE table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('DIMSTYLE');
    buffer.writeln('5');
    buffer.writeln('A');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('1');
    buffer.writeln('0');
    buffer.writeln('DIMSTYLE');
    buffer.writeln('105');
    buffer.writeln('27');
    buffer.writeln('330');
    buffer.writeln('A');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbDimStyleTableRecord');
    buffer.writeln('2');
    buffer.writeln('STANDARD');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // End tables section
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
    buffer.writeln('BLOCK');
    buffer.writeln('5');
    buffer.writeln('1F');
    buffer.writeln('330');
    buffer.writeln('1B');
    buffer.writeln('100');
    buffer.writeln('AcDbEntity');
    buffer.writeln('8');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbBlockBegin');
    buffer.writeln('2');
    buffer.writeln('*PAPER_SPACE');
    buffer.writeln('70');
    buffer.writeln('0');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    buffer.writeln('3');
    buffer.writeln('*PAPER_SPACE');
    buffer.writeln('1');
    buffer.writeln('');
    buffer.writeln('0');
    buffer.writeln('ENDBLK');
    buffer.writeln('5');
    buffer.writeln('1B');
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

    // Add LWPOLYLINE entities for each contour (much better than individual lines)
    int handleCounter = 1000;
    for (int i = 0; i < contours.length; i++) {
      final List<Point> contour = contours[i];
      if (contour.length < 2) continue;

      // Create LWPOLYLINE entity
      buffer.writeln('0');
      buffer.writeln('LWPOLYLINE');
      buffer.writeln('5');
      buffer.writeln('${handleCounter++}');
      buffer.writeln('330');
      buffer.writeln('1F');
      buffer.writeln('100');
      buffer.writeln('AcDbEntity');
      buffer.writeln('8');
      buffer.writeln('0');
      buffer.writeln('100');
      buffer.writeln('AcDbPolyline');
      buffer.writeln('90');
      buffer.writeln('${contour.length}');
      buffer.writeln('70');
      buffer.writeln('1'); // Closed polyline
      
      // Add vertices
      for (final point in contour) {
        final x = point.x * scale + offset.x;
        final y = point.y * scale + offset.y;
        buffer.writeln('10');
        buffer.writeln('$x');
        buffer.writeln('20');
        buffer.writeln('$y');
      }
    }

    // End entities section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    
    // End of file
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

  // Calculate optimal scale for DXF
  double _calculateOptimalScale(Bounds bounds) {
    final width = bounds.maxX - bounds.minX;
    final height = bounds.maxY - bounds.minY;
    final maxDimension = max(width, height);
    
    // Scale to fit in a reasonable DXF coordinate space (1000 units)
    if (maxDimension == 0) return 1.0;
    return 1000.0 / maxDimension;
  }

  // Calculate offset to center the drawing
  Point _calculateOffset(Bounds bounds) {
    final width = bounds.maxX - bounds.minX;
    final height = bounds.maxY - bounds.minY;
    
    // Center the drawing at origin
    return Point(-bounds.minX, -bounds.minY);
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

      // Simplify contours with better parameters
      final simplifiedContours = contours.map((contour) {
        return processor.simplifyContour(contour, 0.5); // Less aggressive simplification
      }).toList();

      // Generate DXF file
      final fileName = 'improved_dxf_${imageData.id}';
      return await generateDXF(simplifiedContours, fileName);
    } catch (e) {
      print('Error generating DXF from image: $e');
      return null;
    }
  }
}

// Bounds class for calculating extents
class Bounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  Bounds(this.minX, this.minY, this.maxX, this.maxY);
}

