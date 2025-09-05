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

  // Generate DXF file from contours - Ultra minimal for maximum compatibility
  Future<String?> generateDXF(List<List<Point>> contours, String fileName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$fileName.dxf';
      
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
    
    // DXF Header Section - Minimal but complete
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('HEADER');
    
    // AutoCAD version (AC1009 = AutoCAD R12 - most compatible)
    buffer.writeln('9');
    buffer.writeln('\$ACADVER');
    buffer.writeln('1');
    buffer.writeln('AC1009');
    
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
    
    buffer.writeln('9');
    buffer.writeln('\$AUPREC');
    buffer.writeln('70');
    buffer.writeln('0'); // 0 decimal places
    
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
    buffer.writeln('\$MENU');
    buffer.writeln('1');
    buffer.writeln('.');
    
    buffer.writeln('9');
    buffer.writeln('\$ELEVATION');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PELEVATION');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$THICKNESS');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$LIMCHECK');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$CHAMFERA');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$CHAMFERB');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$CHAMFERC');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$CHAMFERD');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$SKPOLY');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$TDCREATE');
    buffer.writeln('40');
    buffer.writeln('2459580.5');
    
    buffer.writeln('9');
    buffer.writeln('\$TDUCREATE');
    buffer.writeln('40');
    buffer.writeln('2459580.5');
    
    buffer.writeln('9');
    buffer.writeln('\$TDUPDATE');
    buffer.writeln('40');
    buffer.writeln('2459580.5');
    
    buffer.writeln('9');
    buffer.writeln('\$TDUUPDATE');
    buffer.writeln('40');
    buffer.writeln('2459580.5');
    
    buffer.writeln('9');
    buffer.writeln('\$TDINDWG');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$TDUSRTIMER');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$USRTIMER');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$ANGBASE');
    buffer.writeln('50');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$ANGDIR');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$PDMODE');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$PDSIZE');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PLINEWID');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$SPLFRAME');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$SPLINETYPE');
    buffer.writeln('70');
    buffer.writeln('6');
    
    buffer.writeln('9');
    buffer.writeln('\$SPLINESEGS');
    buffer.writeln('70');
    buffer.writeln('8');
    
    buffer.writeln('9');
    buffer.writeln('\$HANDSEED');
    buffer.writeln('5');
    buffer.writeln('FFFF');
    
    buffer.writeln('9');
    buffer.writeln('\$SURFTAB1');
    buffer.writeln('70');
    buffer.writeln('6');
    
    buffer.writeln('9');
    buffer.writeln('\$SURFTAB2');
    buffer.writeln('70');
    buffer.writeln('6');
    
    buffer.writeln('9');
    buffer.writeln('\$SURFTYPE');
    buffer.writeln('70');
    buffer.writeln('6');
    
    buffer.writeln('9');
    buffer.writeln('\$SURFU');
    buffer.writeln('70');
    buffer.writeln('6');
    
    buffer.writeln('9');
    buffer.writeln('\$SURFV');
    buffer.writeln('70');
    buffer.writeln('6');
    
    buffer.writeln('9');
    buffer.writeln('\$UCSBASE');
    buffer.writeln('2');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$UCSNAME');
    buffer.writeln('2');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$UCSORG');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$UCSXDIR');
    buffer.writeln('10');
    buffer.writeln('1.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$UCSYDIR');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('1.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PUCSBASE');
    buffer.writeln('2');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$PUCSNAME');
    buffer.writeln('2');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$PUCSORG');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PUCSXDIR');
    buffer.writeln('10');
    buffer.writeln('1.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PUCSYDIR');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('1.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERI1');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERI2');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERI3');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERI4');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERI5');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERR1');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERR2');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERR3');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERR4');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$USERR5');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$WORLDVIEW');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$SHADEDGE');
    buffer.writeln('70');
    buffer.writeln('3');
    
    buffer.writeln('9');
    buffer.writeln('\$SHADEDIF');
    buffer.writeln('70');
    buffer.writeln('70');
    
    buffer.writeln('9');
    buffer.writeln('\$TILEMODE');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$MAXACTVP');
    buffer.writeln('70');
    buffer.writeln('64');
    
    buffer.writeln('9');
    buffer.writeln('\$PINSBASE');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PLIMCHECK');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$PEXTMIN');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PEXTMAX');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    buffer.writeln('30');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PLIMMIN');
    buffer.writeln('10');
    buffer.writeln('0.0');
    buffer.writeln('20');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PLIMMAX');
    buffer.writeln('10');
    buffer.writeln('12.0');
    buffer.writeln('20');
    buffer.writeln('9.0');
    
    buffer.writeln('9');
    buffer.writeln('\$UNITMODE');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$VISRETAIN');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$PLINEGEN');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$PSLTSCALE');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$TREEDEPTH');
    buffer.writeln('70');
    buffer.writeln('3020');
    
    buffer.writeln('9');
    buffer.writeln('\$CMLSTYLE');
    buffer.writeln('2');
    buffer.writeln('STANDARD');
    
    buffer.writeln('9');
    buffer.writeln('\$CMLJUST');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$CMLSCALE');
    buffer.writeln('40');
    buffer.writeln('1.0');
    
    buffer.writeln('9');
    buffer.writeln('\$PROXYGRAPHICS');
    buffer.writeln('70');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$MEASUREMENT');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$CELWEIGHT');
    buffer.writeln('370');
    buffer.writeln('-1');
    
    buffer.writeln('9');
    buffer.writeln('\$ENDCAPS');
    buffer.writeln('280');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$JOINSTYLE');
    buffer.writeln('280');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$LWDISPLAY');
    buffer.writeln('290');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$INSUNITS');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$HYPERLINKBASE');
    buffer.writeln('1');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$STYLESHEET');
    buffer.writeln('1');
    buffer.writeln('');
    
    buffer.writeln('9');
    buffer.writeln('\$XEDIT');
    buffer.writeln('290');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$CEPSNTYPE');
    buffer.writeln('380');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$PSTYLEMODE');
    buffer.writeln('290');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$FINGERPRINTGUID');
    buffer.writeln('2');
    buffer.writeln('{00000000-0000-0000-0000-000000000000}');
    
    buffer.writeln('9');
    buffer.writeln('\$VERSIONGUID');
    buffer.writeln('2');
    buffer.writeln('{00000000-0000-0000-0000-000000000000}');
    
    buffer.writeln('9');
    buffer.writeln('\$EXTNAMES');
    buffer.writeln('290');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$PSVPSCALE');
    buffer.writeln('40');
    buffer.writeln('0.0');
    
    buffer.writeln('9');
    buffer.writeln('\$OLESTARTUP');
    buffer.writeln('290');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$SORTENTS');
    buffer.writeln('280');
    buffer.writeln('127');
    
    buffer.writeln('9');
    buffer.writeln('\$INDEXCTL');
    buffer.writeln('280');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$HIDETEXT');
    buffer.writeln('280');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$XCLIPFRAME');
    buffer.writeln('280');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$HALOGAP');
    buffer.writeln('280');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$OBSCOLOR');
    buffer.writeln('70');
    buffer.writeln('257');
    
    buffer.writeln('9');
    buffer.writeln('\$OBSLTYPE');
    buffer.writeln('280');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$INTERSECTIONDISPLAY');
    buffer.writeln('280');
    buffer.writeln('0');
    
    buffer.writeln('9');
    buffer.writeln('\$INTERSECTIONCOLOR');
    buffer.writeln('70');
    buffer.writeln('257');
    
    buffer.writeln('9');
    buffer.writeln('\$DIMASSOC');
    buffer.writeln('280');
    buffer.writeln('1');
    
    buffer.writeln('9');
    buffer.writeln('\$PROJECTNAME');
    buffer.writeln('1');
    buffer.writeln('');
    
    // End header section
    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    // Tables Section
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('TABLES');
    
    // VPORT table
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
    
    // VPORT entry
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
    buffer.writeln('290.0');
    buffer.writeln('22');
    buffer.writeln('148.5');
    buffer.writeln('13');
    buffer.writeln('0.0');
    buffer.writeln('23');
    buffer.writeln('0.0');
    buffer.writeln('14');
    buffer.writeln('10.0');
    buffer.writeln('24');
    buffer.writeln('10.0');
    buffer.writeln('15');
    buffer.writeln('0.0');
    buffer.writeln('25');
    buffer.writeln('0.0');
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
    buffer.writeln('297.0');
    buffer.writeln('41');
    buffer.writeln('1.9279835390946505');
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
    
    // STYLE table
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
    
    // STANDARD text style
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
    
    // VIEW table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('VIEW');
    buffer.writeln('5');
    buffer.writeln('6');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('0');
    
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // UCS table
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
    
    // APPID table
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
    
    // ACAD application ID
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
    
    // ACAD_LEADERSTYLE application ID
    buffer.writeln('0');
    buffer.writeln('APPID');
    buffer.writeln('5');
    buffer.writeln('13');
    buffer.writeln('330');
    buffer.writeln('9');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbRegAppTableRecord');
    buffer.writeln('2');
    buffer.writeln('ACAD_LEADERSTYLE');
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
    buffer.writeln('71');
    buffer.writeln('1');
    
    // STANDARD dimension style
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
    buffer.writeln('3');
    buffer.writeln('');
    buffer.writeln('4');
    buffer.writeln('');
    buffer.writeln('5');
    buffer.writeln('');
    buffer.writeln('6');
    buffer.writeln('');
    buffer.writeln('7');
    buffer.writeln('');
    buffer.writeln('40');
    buffer.writeln('1.0');
    buffer.writeln('41');
    buffer.writeln('2.5');
    buffer.writeln('42');
    buffer.writeln('0.625');
    buffer.writeln('43');
    buffer.writeln('3.75');
    buffer.writeln('44');
    buffer.writeln('1.25');
    buffer.writeln('45');
    buffer.writeln('0.0');
    buffer.writeln('46');
    buffer.writeln('0.0');
    buffer.writeln('47');
    buffer.writeln('0.0');
    buffer.writeln('48');
    buffer.writeln('0.0');
    buffer.writeln('140');
    buffer.writeln('2.5');
    buffer.writeln('141');
    buffer.writeln('2.5');
    buffer.writeln('142');
    buffer.writeln('0.0');
    buffer.writeln('143');
    buffer.writeln('0.03937007874016');
    buffer.writeln('144');
    buffer.writeln('1.0');
    buffer.writeln('145');
    buffer.writeln('0.0');
    buffer.writeln('146');
    buffer.writeln('1.0');
    buffer.writeln('147');
    buffer.writeln('0.625');
    buffer.writeln('71');
    buffer.writeln('0');
    buffer.writeln('72');
    buffer.writeln('0');
    buffer.writeln('73');
    buffer.writeln('0');
    buffer.writeln('74');
    buffer.writeln('0');
    buffer.writeln('75');
    buffer.writeln('0');
    buffer.writeln('76');
    buffer.writeln('0');
    buffer.writeln('77');
    buffer.writeln('1');
    buffer.writeln('78');
    buffer.writeln('8');
    buffer.writeln('170');
    buffer.writeln('0');
    buffer.writeln('171');
    buffer.writeln('3');
    buffer.writeln('172');
    buffer.writeln('1');
    buffer.writeln('173');
    buffer.writeln('0');
    buffer.writeln('174');
    buffer.writeln('0');
    buffer.writeln('175');
    buffer.writeln('0');
    buffer.writeln('176');
    buffer.writeln('0');
    buffer.writeln('177');
    buffer.writeln('0');
    buffer.writeln('178');
    buffer.writeln('0');
    buffer.writeln('270');
    buffer.writeln('2');
    buffer.writeln('271');
    buffer.writeln('2');
    buffer.writeln('272');
    buffer.writeln('2');
    buffer.writeln('273');
    buffer.writeln('2');
    buffer.writeln('274');
    buffer.writeln('3');
    buffer.writeln('340');
    buffer.writeln('11');
    buffer.writeln('275');
    buffer.writeln('0');
    buffer.writeln('280');
    buffer.writeln('0');
    buffer.writeln('281');
    buffer.writeln('0');
    buffer.writeln('282');
    buffer.writeln('0');
    buffer.writeln('283');
    buffer.writeln('0');
    buffer.writeln('284');
    buffer.writeln('8');
    buffer.writeln('285');
    buffer.writeln('0');
    buffer.writeln('286');
    buffer.writeln('0');
    buffer.writeln('287');
    buffer.writeln('3');
    buffer.writeln('288');
    buffer.writeln('0');
    buffer.writeln('289');
    buffer.writeln('0');
    buffer.writeln('290');
    buffer.writeln('0');
    buffer.writeln('291');
    buffer.writeln('0');
    buffer.writeln('292');
    buffer.writeln('0');
    buffer.writeln('293');
    buffer.writeln('0');
    buffer.writeln('294');
    buffer.writeln('0');
    buffer.writeln('295');
    buffer.writeln('0');
    buffer.writeln('296');
    buffer.writeln('0');
    buffer.writeln('297');
    buffer.writeln('0');
    buffer.writeln('298');
    buffer.writeln('0');
    buffer.writeln('299');
    buffer.writeln('0');
    buffer.writeln('300');
    buffer.writeln('');
    buffer.writeln('301');
    buffer.writeln('');
    buffer.writeln('302');
    buffer.writeln('');
    buffer.writeln('303');
    buffer.writeln('');
    buffer.writeln('304');
    buffer.writeln('');
    buffer.writeln('305');
    buffer.writeln('');
    buffer.writeln('306');
    buffer.writeln('');
    buffer.writeln('307');
    buffer.writeln('');
    buffer.writeln('371');
    buffer.writeln('-2');
    buffer.writeln('372');
    buffer.writeln('-2');
    buffer.writeln('373');
    buffer.writeln('1');
    buffer.writeln('374');
    buffer.writeln('1');
    buffer.writeln('375');
    buffer.writeln('0');
    
    buffer.writeln('0');
    buffer.writeln('ENDTAB');
    
    // BLOCK_RECORD table
    buffer.writeln('0');
    buffer.writeln('TABLE');
    buffer.writeln('2');
    buffer.writeln('BLOCK_RECORD');
    buffer.writeln('5');
    buffer.writeln('1');
    buffer.writeln('330');
    buffer.writeln('0');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTable');
    buffer.writeln('70');
    buffer.writeln('1');
    
    // Model space block record
    buffer.writeln('0');
    buffer.writeln('BLOCK_RECORD');
    buffer.writeln('5');
    buffer.writeln('1F');
    buffer.writeln('330');
    buffer.writeln('1');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbBlockTableRecord');
    buffer.writeln('2');
    buffer.writeln('*MODEL_SPACE');
    
    // Paper space block record
    buffer.writeln('0');
    buffer.writeln('BLOCK_RECORD');
    buffer.writeln('5');
    buffer.writeln('1B');
    buffer.writeln('330');
    buffer.writeln('1');
    buffer.writeln('100');
    buffer.writeln('AcDbSymbolTableRecord');
    buffer.writeln('100');
    buffer.writeln('AcDbBlockTableRecord');
    buffer.writeln('2');
    buffer.writeln('*PAPER_SPACE');
    
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
    
    // Paper space block
    buffer.writeln('0');
    buffer.writeln('BLOCK');
    buffer.writeln('5');
    buffer.writeln('1C');
    buffer.writeln('330');
    buffer.writeln('1B');
    buffer.writeln('100');
    buffer.writeln('AcDbEntity');
    buffer.writeln('67');
    buffer.writeln('1');
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
    
    // End paper space block
    buffer.writeln('0');
    buffer.writeln('ENDBLK');
    buffer.writeln('5');
    buffer.writeln('1D');
    buffer.writeln('330');
    buffer.writeln('1B');
    buffer.writeln('100');
    buffer.writeln('AcDbEntity');
    buffer.writeln('67');
    buffer.writeln('1');
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
