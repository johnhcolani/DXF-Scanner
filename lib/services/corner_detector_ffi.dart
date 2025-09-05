import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// C struct definitions
class Point2D extends Struct {
  @Double()
  external double x;
  
  @Double()
  external double y;
}

class Line extends Struct {
  external Point2D start;
  external Point2D end;
}

class Arc extends Struct {
  external Point2D center;
  @Double()
  external double radius;
  @Double()
  external double startAngle;
  @Double()
  external double endAngle;
}

class Circle extends Struct {
  external Point2D center;
  @Double()
  external double radius;
}

class GeometricPrimitives extends Struct {
  // Note: In a real implementation, you'd need to handle vectors differently
  // This is a simplified version for demonstration
}

// Dart wrapper classes
class DartPoint2D {
  final double x;
  final double y;
  
  DartPoint2D(this.x, this.y);
  
  @override
  String toString() => 'Point2D($x, $y)';
}

class DartLine {
  final DartPoint2D start;
  final DartPoint2D end;
  
  DartLine(this.start, this.end);
  
  @override
  String toString() => 'Line($start -> $end)';
}

class DartArc {
  final DartPoint2D center;
  final double radius;
  final double startAngle;
  final double endAngle;
  
  DartArc(this.center, this.radius, this.startAngle, this.endAngle);
  
  @override
  String toString() => 'Arc(center: $center, radius: $radius, angles: $startAngle-$endAngle)';
}

class DartCircle {
  final DartPoint2D center;
  final double radius;
  
  DartCircle(this.center, this.radius);
  
  @override
  String toString() => 'Circle(center: $center, radius: $radius)';
}

class DartGeometricPrimitives {
  final List<DartLine> lines;
  final List<DartArc> arcs;
  final List<DartCircle> circles;
  
  DartGeometricPrimitives(this.lines, this.arcs, this.circles);
  
  @override
  String toString() => 'GeometricPrimitives(lines: ${lines.length}, arcs: ${arcs.length}, circles: ${circles.length})';
}

// FFI function signatures
typedef CreateCornerDetectorNative = Pointer<Void> Function();
typedef CreateCornerDetectorDart = Pointer<Void> Function();

typedef ProcessImageFFINative = Pointer<Void> Function(
  Pointer<Void> detector,
  Pointer<Uint8> imageData,
  Int32 width,
  Int32 height,
  Int32 channels
);
typedef ProcessImageFFIDart = Pointer<Void> Function(
  Pointer<Void> detector,
  Pointer<Uint8> imageData,
  int width,
  int height,
  int channels
);

typedef GetLineCountNative = Int32 Function(Pointer<Void> primitives);
typedef GetLineCountDart = int Function(Pointer<Void> primitives);

typedef GetLineNative = Line Function(Pointer<Void> primitives, Int32 index);
typedef GetLineDart = Line Function(Pointer<Void> primitives, int index);

typedef GetArcCountNative = Int32 Function(Pointer<Void> primitives);
typedef GetArcCountDart = int Function(Pointer<Void> primitives);

typedef GetArcNative = Arc Function(Pointer<Void> primitives, Int32 index);
typedef GetArcDart = Arc Function(Pointer<Void> primitives, int index);

typedef GetCircleCountNative = Int32 Function(Pointer<Void> primitives);
typedef GetCircleCountDart = int Function(Pointer<Void> primitives);

typedef GetCircleNative = Circle Function(Pointer<Void> primitives, Int32 index);
typedef GetCircleDart = Circle Function(Pointer<Void> primitives, int index);

typedef DestroyGeometricPrimitivesNative = Void Function(Pointer<Void> primitives);
typedef DestroyGeometricPrimitivesDart = void Function(Pointer<Void> primitives);

typedef DestroyCornerDetectorNative = Void Function(Pointer<Void> detector);
typedef DestroyCornerDetectorDart = void Function(Pointer<Void> detector);

class CornerDetectorFFI {
  late DynamicLibrary _lib;
  late CreateCornerDetectorDart _createCornerDetector;
  late ProcessImageFFIDart _processImageFFI;
  late GetLineCountDart _getLineCount;
  late GetLineDart _getLine;
  late GetArcCountDart _getArcCount;
  late GetArcDart _getArc;
  late GetCircleCountDart _getCircleCount;
  late GetCircleDart _getCircle;
  late DestroyGeometricPrimitivesDart _destroyGeometricPrimitives;
  late DestroyCornerDetectorDart _destroyCornerDetector;
  
  CornerDetectorFFI() {
    _loadLibrary();
    _setupFunctions();
  }
  
  void _loadLibrary() {
    if (Platform.isWindows) {
      _lib = DynamicLibrary.open('corner_detector.dll');
    } else if (Platform.isMacOS) {
      _lib = DynamicLibrary.open('libcorner_detector.dylib');
    } else if (Platform.isLinux) {
      _lib = DynamicLibrary.open('libcorner_detector.so');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }
  
  void _setupFunctions() {
    _createCornerDetector = _lib
        .lookup<NativeFunction<CreateCornerDetectorNative>>('createCornerDetector')
        .asFunction();
    
    _processImageFFI = _lib
        .lookup<NativeFunction<ProcessImageFFINative>>('processImageFFI')
        .asFunction();
    
    _getLineCount = _lib
        .lookup<NativeFunction<GetLineCountNative>>('getLineCount')
        .asFunction();
    
    _getLine = _lib
        .lookup<NativeFunction<GetLineNative>>('getLine')
        .asFunction();
    
    _getArcCount = _lib
        .lookup<NativeFunction<GetArcCountNative>>('getArcCount')
        .asFunction();
    
    _getArc = _lib
        .lookup<NativeFunction<GetArcNative>>('getArc')
        .asFunction();
    
    _getCircleCount = _lib
        .lookup<NativeFunction<GetCircleCountNative>>('getCircleCount')
        .asFunction();
    
    _getCircle = _lib
        .lookup<NativeFunction<GetCircleNative>>('getCircle')
        .asFunction();
    
    _destroyGeometricPrimitives = _lib
        .lookup<NativeFunction<DestroyGeometricPrimitivesNative>>('destroyGeometricPrimitives')
        .asFunction();
    
    _destroyCornerDetector = _lib
        .lookup<NativeFunction<DestroyCornerDetectorNative>>('destroyCornerDetector')
        .asFunction();
  }
  
  DartGeometricPrimitives processImage(Uint8List imageData, int width, int height, int channels) {
    // Create detector
    final detector = _createCornerDetector();
    
    try {
      // Allocate memory for image data
      final imageDataPtr = malloc.allocate<Uint8>(imageData.length);
      imageDataPtr.asTypedList(imageData.length).setAll(0, imageData);
      
      try {
        // Process image
        final primitivesPtr = _processImageFFI(detector, imageDataPtr, width, height, channels);
        
        try {
          // Extract results
          final lines = <DartLine>[];
          final arcs = <DartArc>[];
          final circles = <DartCircle>[];
          
          // Get lines
          final lineCount = _getLineCount(primitivesPtr);
          for (int i = 0; i < lineCount; i++) {
            final line = _getLine(primitivesPtr, i);
            lines.add(DartLine(
              DartPoint2D(line.start.x, line.start.y),
              DartPoint2D(line.end.x, line.end.y)
            ));
          }
          
          // Get arcs
          final arcCount = _getArcCount(primitivesPtr);
          for (int i = 0; i < arcCount; i++) {
            final arc = _getArc(primitivesPtr, i);
            arcs.add(DartArc(
              DartPoint2D(arc.center.x, arc.center.y),
              arc.radius,
              arc.startAngle,
              arc.endAngle
            ));
          }
          
          // Get circles
          final circleCount = _getCircleCount(primitivesPtr);
          for (int i = 0; i < circleCount; i++) {
            final circle = _getCircle(primitivesPtr, i);
            circles.add(DartCircle(
              DartPoint2D(circle.center.x, circle.center.y),
              circle.radius
            ));
          }
          
          return DartGeometricPrimitives(lines, arcs, circles);
        } finally {
          _destroyGeometricPrimitives(primitivesPtr);
        }
      } finally {
        malloc.free(imageDataPtr);
      }
    } finally {
      _destroyCornerDetector(detector);
    }
  }
}


