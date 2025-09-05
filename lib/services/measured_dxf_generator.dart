import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import '../models/image_data.dart';
import 'corner_detector.dart';

class MeasuredDXFGenerator {
  static final MeasuredDXFGenerator _instance = MeasuredDXFGenerator._internal();
  factory MeasuredDXFGenerator() => _instance;
  MeasuredDXFGenerator._internal();

  // Generate DXF with proper measurements from corner detection
  Future<String?> generateMeasuredDXF(List<ShapeMeasurement> measurements, String fileName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$fileName.dxf';
      
      final File file = File(filePath);
      final String dxfContent = _createMeasuredDXFContent(measurements);
      
      await file.writeAsString(dxfContent);
      return filePath;
    } catch (e) {
      print('Error generating measured DXF: $e');
      return null;
    }
  }

  String _createMeasuredDXFContent(List<ShapeMeasurement> measurements) {
    final StringBuffer buffer = StringBuffer();
    
    // Calculate bounds
    final bounds = _calculateBounds(measurements);
    final scale = _calculateScale(bounds);
    final offset = _calculateOffset(bounds);
    
    // DXF Header
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('HEADER');
    buffer.writeln('9');
    buffer.writeln('\$ACADVER');
    buffer.writeln('1');
    buffer.writeln('AC1015');
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
    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    
    // Tables
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
    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    
    // Blocks
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
    
    // Entities
    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');

    int handleCounter = 1000;
    
    // Add measured lines and dimensions
    for (final measurement in measurements) {
      for (final lineMeasurement in measurement.measurements) {
        final line = lineMeasurement.line;
        
        // Draw the line
        buffer.writeln('0');
        buffer.writeln('LINE');
        buffer.writeln('5');
        buffer.writeln('${handleCounter++}');
        buffer.writeln('330');
        buffer.writeln('1F');
        buffer.writeln('100');
        buffer.writeln('AcDbEntity');
        buffer.writeln('8');
        buffer.writeln('0');
        buffer.writeln('100');
        buffer.writeln('AcDbLine');
        buffer.writeln('10');
        buffer.writeln('${line.start.x * scale + offset.x}');
        buffer.writeln('20');
        buffer.writeln('${line.start.y * scale + offset.y}');
        buffer.writeln('30');
        buffer.writeln('0.0');
        buffer.writeln('11');
        buffer.writeln('${line.end.x * scale + offset.x}');
        buffer.writeln('21');
        buffer.writeln('${line.end.y * scale + offset.y}');
        buffer.writeln('31');
        buffer.writeln('0.0');
        
        // Add dimension text
        buffer.writeln('0');
        buffer.writeln('TEXT');
        buffer.writeln('5');
        buffer.writeln('${handleCounter++}');
        buffer.writeln('330');
        buffer.writeln('1F');
        buffer.writeln('100');
        buffer.writeln('AcDbEntity');
        buffer.writeln('8');
        buffer.writeln('0');
        buffer.writeln('100');
        buffer.writeln('AcDbText');
        buffer.writeln('10');
        buffer.writeln('${lineMeasurement.midpoint.x * scale + offset.x}');
        buffer.writeln('20');
        buffer.writeln('${lineMeasurement.midpoint.y * scale + offset.y}');
        buffer.writeln('30');
        buffer.writeln('0.0');
        buffer.writeln('40');
        buffer.writeln('10.0');
        buffer.writeln('1');
        buffer.writeln('${lineMeasurement.length.toStringAsFixed(1)}');
        buffer.writeln('50');
        buffer.writeln('${lineMeasurement.angle}');
      }
    }

    buffer.writeln('0');
    buffer.writeln('ENDSEC');
    buffer.writeln('0');
    buffer.writeln('EOF');

    return buffer.toString();
  }

  Bounds _calculateBounds(List<ShapeMeasurement> measurements) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final measurement in measurements) {
      for (final lineMeasurement in measurement.measurements) {
        final line = lineMeasurement.line;
        minX = min(minX, min(line.start.x, line.end.x));
        minY = min(minY, min(line.start.y, line.end.y));
        maxX = max(maxX, max(line.start.x, line.end.x));
        maxY = max(maxY, max(line.start.y, line.end.y));
      }
    }

    return Bounds(minX, minY, maxX, maxY);
  }

  double _calculateScale(Bounds bounds) {
    final width = bounds.maxX - bounds.minX;
    final height = bounds.maxY - bounds.minY;
    final maxDimension = max(width, height);
    
    if (maxDimension == 0) return 1.0;
    return 1000.0 / maxDimension;
  }

  Point _calculateOffset(Bounds bounds) {
    return Point(-bounds.minX, -bounds.minY);
  }
}

class Bounds {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  Bounds(this.minX, this.minY, this.maxX, this.maxY);
}

