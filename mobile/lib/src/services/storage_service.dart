import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const int _minStorageThresholdBytes = 100 * 1024 * 1024; // 100 MB

  Future<int> getAvailableSpace() async {
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      // For Android, get free space from the data directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final stat = await appDir.stat();
      // This is a simplified approach, actual free space might be different
      // A more accurate way would be to use platform channels or external packages
      // that provide exact free space for the internal storage.
      // For now, we'll return a dummy value or rely on a more robust package if needed.
      debugPrint('Android available space check not fully implemented');
      return 500 * 1024 * 1024; // Dummy 500 MB for Android
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      // For iOS, get free space from the file system
      final FileSystemEntity appDir = await getApplicationDocumentsDirectory();
      final stat = await appDir.stat();
      // This is also a simplified approach for iOS
      debugPrint('iOS available space check not fully implemented');
      return 500 * 1024 * 1024; // Dummy 500 MB for iOS
    } else {
      // For other platforms, return a dummy value
      return 500 * 1024 * 1024; // Dummy 500 MB
    }
  }

  Future<bool> isStorageLow() async {
    final int availableSpace = await getAvailableSpace();
    return availableSpace < _minStorageThresholdBytes;
  }

  // Placeholder for future compression logic
  Future<void> compressOldRecordings() async {
    debugPrint('Compressing old recordings (not yet implemented)');
    // TODO: Implement actual compression logic
  }

  /// Read content from a file
  Future<String?> readFromFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading from file $fileName: $e');
      return null;
    }
  }

  /// Write content to a file
  Future<void> writeToFile(String fileName, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
    } catch (e) {
      debugPrint('Error writing to file $fileName: $e');
    }
  }

  /// Delete a file
  Future<void> deleteFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file $fileName: $e');
    }
  }

  /// Append content to a file
  Future<void> appendToFile(String fileName, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content, mode: FileMode.append);
    } catch (e) {
      debugPrint('Error appending to file $fileName: $e');
    }
  }
}