import 'dart:typed_data';
import 'dart:ui' as ui;

class ImageData {
  final String id;
  final String? filePath;
  Uint8List? imageBytes; // Made mutable for cropping
  final ui.Image? image;
  final DateTime createdAt;
  final ProcessingStatus status;
  final String? dxfFilePath;
  final String? errorMessage;

  ImageData({
    required this.id,
    this.filePath,
    this.imageBytes,
    this.image,
    required this.createdAt,
    this.status = ProcessingStatus.pending,
    this.dxfFilePath,
    this.errorMessage,
  });

  ImageData copyWith({
    String? id,
    String? filePath,
    Uint8List? imageBytes,
    ui.Image? image,
    DateTime? createdAt,
    ProcessingStatus? status,
    String? dxfFilePath,
    String? errorMessage,
  }) {
    return ImageData(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      imageBytes: imageBytes ?? this.imageBytes,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      dxfFilePath: dxfFilePath ?? this.dxfFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum ProcessingStatus {
  pending,
  processing,
  completed,
  failed,
}

enum PaperOrientation {
  portrait,
  landscape,
}

