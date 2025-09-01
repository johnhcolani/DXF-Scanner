import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager {
  static final FileManager _instance = FileManager._internal();
  factory FileManager() => _instance;
  FileManager._internal();

  // Get app documents directory
  Future<Directory?> getAppDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      print('Error getting app directory: $e');
      return null;
    }
  }

  // Save file to app directory
  Future<String?> saveFile(Uint8List bytes, String fileName) async {
    try {
      final Directory? appDir = await getAppDirectory();
      if (appDir == null) return null;

      final String filePath = '${appDir.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  // Read file from path
  Future<Uint8List?> readFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading file: $e');
      return null;
    }
  }

  // Delete file
  Future<bool> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }

  // Get file size in bytes
  Future<int?> getFileSize(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }

  // Get file size in human readable format
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Share file
  Future<bool> shareFile(String filePath, {String? subject, String? text}) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) return false;

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'DXF File',
        text: text ?? 'Generated DXF file from handwriting/sketch',
      );
      return true;
    } catch (e) {
      print('Error sharing file: $e');
      return false;
    }
  }

  // Share multiple files
  Future<bool> shareFiles(List<String> filePaths, {String? subject, String? text}) async {
    try {
      final List<XFile> files = [];
      for (String path in filePaths) {
        final File file = File(path);
        if (await file.exists()) {
          files.add(XFile(path));
        }
      }

      if (files.isEmpty) return false;

      await Share.shareXFiles(
        files,
        subject: subject ?? 'DXF Files',
        text: text ?? 'Generated DXF files from handwriting/sketch',
      );
      return true;
    } catch (e) {
      print('Error sharing files: $e');
      return false;
    }
  }

  // Request storage permissions
  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  // Check storage permission
  Future<bool> hasStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking storage permission: $e');
      return false;
    }
  }

  // List files in app directory
  Future<List<FileInfo>> listAppFiles() async {
    try {
      final Directory? appDir = await getAppDirectory();
      if (appDir == null) return [];

      final List<FileInfo> files = [];
      final List<FileSystemEntity> entities = await appDir.list().toList();

      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          final int size = await entity.length();
          final DateTime modified = await entity.lastModified();
          
          files.add(FileInfo(
            name: entity.path.split('/').last,
            path: entity.path,
            size: size,
            modified: modified,
          ));
        }
      }

      // Sort by modification date (newest first)
      files.sort((a, b) => b.modified.compareTo(a.modified));
      return files;
    } catch (e) {
      print('Error listing app files: $e');
      return [];
    }
  }

  // Clean up old files (keep only last N files)
  Future<void> cleanupOldFiles(int keepCount) async {
    try {
      final List<FileInfo> files = await listAppFiles();
      
      if (files.length <= keepCount) return;

      final List<FileInfo> filesToDelete = files.sublist(keepCount);
      
      for (FileInfo fileInfo in filesToDelete) {
        await deleteFile(fileInfo.path);
      }
    } catch (e) {
      print('Error cleaning up old files: $e');
    }
  }

  // Get available storage space
  Future<int?> getAvailableStorage() async {
    try {
      final Directory? appDir = await getAppDirectory();
      if (appDir == null) return null;

      // This is a simplified approach - in a real app you might want to use
      // platform-specific APIs to get actual storage information
      return 1024 * 1024 * 100; // Assume 100MB available
    } catch (e) {
      print('Error getting available storage: $e');
      return null;
    }
  }
}

// File information class
class FileInfo {
  final String name;
  final String path;
  final int size;
  final DateTime modified;

  FileInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() => 'FileInfo(name: $name, size: $formattedSize, modified: $modified)';
}

