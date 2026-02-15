import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

/// Service for exporting and importing settings configurations
class SettingsExportService {
  static const String _settingsFileName = 'cop_stopper_settings.json';
  static const int _currentVersion = 1;

  /// Export current settings to a JSON file
  static Future<SettingsExportResult> exportSettings({
    required Map<String, dynamic> settings,
    String? customFileName,
  }) async {
    try {
      final exportData = SettingsExportData(
        version: _currentVersion,
        exportDate: DateTime.now(),
        appVersion: '1.0.0', // This should come from package info
        settings: settings,
      );

      final jsonString = jsonEncode(exportData.toJson());
      final fileName = customFileName ?? _settingsFileName;

      if (kIsWeb) {
        // For web, use share functionality
        return await _exportForWeb(jsonString, fileName);
      } else {
        // For mobile, save to documents and optionally share
        return await _exportForMobile(jsonString, fileName);
      }
    } catch (e) {
      return SettingsExportResult(
        success: false,
        error: 'Failed to export settings: ${e.toString()}',
      );
    }
  }

  /// Import settings from a JSON file
  static Future<SettingsImportResult> importSettings() async {
    try {
      String? jsonString;

      if (kIsWeb) {
        jsonString = await _importForWeb();
      } else {
        jsonString = await _importForMobile();
      }

      if (jsonString == null) {
        return const SettingsImportResult(
          success: false,
          error: 'No file selected or file could not be read',
        );
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final importData = SettingsExportData.fromJson(jsonData);

      // Validate version compatibility
      if (importData.version > _currentVersion) {
        return const SettingsImportResult(
          success: false,
          error: 'Settings file is from a newer version of the app. Please update the app to import these settings.',
        );
      }

      // Validate settings structure
      final validationResult = _validateImportedSettings(importData.settings);
      if (!validationResult.isValid) {
        return SettingsImportResult(
          success: false,
          error: validationResult.error,
          warnings: validationResult.warnings,
        );
      }

      return SettingsImportResult(
        success: true,
        settings: importData.settings,
        exportDate: importData.exportDate,
        appVersion: importData.appVersion,
        warnings: validationResult.warnings,
      );
    } catch (e) {
      return SettingsImportResult(
        success: false,
        error: 'Failed to import settings: ${e.toString()}',
      );
    }
  }

  /// Create a backup of current settings
  static Future<SettingsBackupResult> createBackup({
    required Map<String, dynamic> settings,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/settings_backups');
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFile = File('${backupDir.path}/backup_$timestamp.json');

      final exportData = SettingsExportData(
        version: _currentVersion,
        exportDate: DateTime.now(),
        appVersion: '1.0.0',
        settings: settings,
      );

      await backupFile.writeAsString(jsonEncode(exportData.toJson()));

      // Clean up old backups (keep only last 10)
      await _cleanupOldBackups(backupDir);

      return SettingsBackupResult(
        success: true,
        backupPath: backupFile.path,
        backupSize: await backupFile.length(),
      );
    } catch (e) {
      return SettingsBackupResult(
        success: false,
        error: 'Failed to create backup: ${e.toString()}',
      );
    }
  }

  /// Get list of available backups
  static Future<List<SettingsBackupInfo>> getAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/settings_backups');
      
      if (!await backupDir.exists()) {
        return [];
      }

      final backupFiles = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      final backups = <SettingsBackupInfo>[];
      
      for (final file in backupFiles) {
        try {
          final content = await file.readAsString();
          final jsonData = jsonDecode(content) as Map<String, dynamic>;
          final exportData = SettingsExportData.fromJson(jsonData);
          
          final stat = await file.stat();
          
          backups.add(SettingsBackupInfo(
            filePath: file.path,
            fileName: file.path.split('/').last,
            exportDate: exportData.exportDate,
            appVersion: exportData.appVersion,
            fileSize: stat.size,
            settingsCount: _countSettings(exportData.settings),
          ));
        } catch (e) {
          debugPrint('Failed to read backup file ${file.path}: $e');
        }
      }

      // Sort by date, newest first
      backups.sort((a, b) => b.exportDate.compareTo(a.exportDate));
      
      return backups;
    } catch (e) {
      debugPrint('Failed to get available backups: $e');
      return [];
    }
  }

  /// Restore settings from a backup file
  static Future<SettingsImportResult> restoreFromBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        return const SettingsImportResult(
          success: false,
          error: 'Backup file not found',
        );
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final importData = SettingsExportData.fromJson(jsonData);

      final validationResult = _validateImportedSettings(importData.settings);
      if (!validationResult.isValid) {
        return SettingsImportResult(
          success: false,
          error: validationResult.error,
          warnings: validationResult.warnings,
        );
      }

      return SettingsImportResult(
        success: true,
        settings: importData.settings,
        exportDate: importData.exportDate,
        appVersion: importData.appVersion,
        warnings: validationResult.warnings,
      );
    } catch (e) {
      return SettingsImportResult(
        success: false,
        error: 'Failed to restore from backup: ${e.toString()}',
      );
    }
  }

  // Private helper methods

  static Future<SettingsExportResult> _exportForWeb(String jsonString, String fileName) async {
    try {
      // For web, we'll use the share functionality
      final result = await Share.shareXFiles(
        [XFile.fromData(
          utf8.encode(jsonString),
          name: fileName,
          mimeType: 'application/json',
        )],
        subject: 'Cop Stopper Settings Export',
      );

      return SettingsExportResult(
        success: result.status == ShareResultStatus.success,
        filePath: fileName,
        fileSize: utf8.encode(jsonString).length,
      );
    } catch (e) {
      return SettingsExportResult(
        success: false,
        error: 'Failed to export for web: ${e.toString()}',
      );
    }
  }

  static Future<SettingsExportResult> _exportForMobile(String jsonString, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // Optionally share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Cop Stopper Settings Export',
      );

      return SettingsExportResult(
        success: true,
        filePath: file.path,
        fileSize: await file.length(),
      );
    } catch (e) {
      return SettingsExportResult(
        success: false,
        error: 'Failed to export for mobile: ${e.toString()}',
      );
    }
  }

  static Future<String?> _importForWeb() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          return utf8.decode(file.bytes!);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to import for web: $e');
      return null;
    }
  }

  static Future<String?> _importForMobile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          final file = File(filePath);
          return await file.readAsString();
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to import for mobile: $e');
      return null;
    }
  }

  static SettingsValidationResult _validateImportedSettings(Map<String, dynamic> settings) {
    final warnings = <String>[];
    
    // Define expected settings structure
    final expectedSections = ['recording', 'privacy', 'legal', 'accessibility'];
    final missingSections = <String>[];
    
    for (final section in expectedSections) {
      if (!settings.containsKey(section)) {
        missingSections.add(section);
      }
    }
    
    if (missingSections.isNotEmpty) {
      warnings.add('Missing settings sections: ${missingSections.join(', ')}');
    }
    
    // Validate specific settings
    if (settings.containsKey('recording')) {
      final recording = settings['recording'] as Map<String, dynamic>?;
      if (recording != null) {
        if (!recording.containsKey('videoQuality')) {
          warnings.add('Missing video quality setting');
        }
        if (!recording.containsKey('audioBitrate')) {
          warnings.add('Missing audio bitrate setting');
        }
      }
    }
    
    return SettingsValidationResult(
      isValid: true, // We allow import even with warnings
      warnings: warnings,
    );
  }

  static Future<void> _cleanupOldBackups(Directory backupDir) async {
    try {
      final backupFiles = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      if (backupFiles.length > 10) {
        // Sort by modification date, oldest first
        backupFiles.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
        
        // Delete oldest files, keeping only the 10 most recent
        for (int i = 0; i < backupFiles.length - 10; i++) {
          await backupFiles[i].delete();
        }
      }
    } catch (e) {
      debugPrint('Failed to cleanup old backups: $e');
    }
  }

  static int _countSettings(Map<String, dynamic> settings) {
    int count = 0;
    
    void countRecursive(dynamic value) {
      if (value is Map<String, dynamic>) {
        count += value.length;
        for (final v in value.values) {
          countRecursive(v);
        }
      }
    }
    
    countRecursive(settings);
    return count;
  }
}

/// Data structure for exported settings
class SettingsExportData {
  final int version;
  final DateTime exportDate;
  final String appVersion;
  final Map<String, dynamic> settings;

  const SettingsExportData({
    required this.version,
    required this.exportDate,
    required this.appVersion,
    required this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportDate': exportDate.toIso8601String(),
      'appVersion': appVersion,
      'settings': settings,
    };
  }

  factory SettingsExportData.fromJson(Map<String, dynamic> json) {
    return SettingsExportData(
      version: json['version'] as int,
      exportDate: DateTime.parse(json['exportDate'] as String),
      appVersion: json['appVersion'] as String,
      settings: json['settings'] as Map<String, dynamic>,
    );
  }
}

/// Result of settings export operation
class SettingsExportResult {
  final bool success;
  final String? filePath;
  final int? fileSize;
  final String? error;

  const SettingsExportResult({
    required this.success,
    this.filePath,
    this.fileSize,
    this.error,
  });
}

/// Result of settings import operation
class SettingsImportResult {
  final bool success;
  final Map<String, dynamic>? settings;
  final DateTime? exportDate;
  final String? appVersion;
  final List<String> warnings;
  final String? error;

  const SettingsImportResult({
    required this.success,
    this.settings,
    this.exportDate,
    this.appVersion,
    this.warnings = const [],
    this.error,
  });
}

/// Result of settings backup operation
class SettingsBackupResult {
  final bool success;
  final String? backupPath;
  final int? backupSize;
  final String? error;

  const SettingsBackupResult({
    required this.success,
    this.backupPath,
    this.backupSize,
    this.error,
  });
}

/// Information about a settings backup
class SettingsBackupInfo {
  final String filePath;
  final String fileName;
  final DateTime exportDate;
  final String appVersion;
  final int fileSize;
  final int settingsCount;

  const SettingsBackupInfo({
    required this.filePath,
    required this.fileName,
    required this.exportDate,
    required this.appVersion,
    required this.fileSize,
    required this.settingsCount,
  });
}

/// Result of settings validation
class SettingsValidationResult {
  final bool isValid;
  final List<String> warnings;
  final String? error;

  const SettingsValidationResult({
    required this.isValid,
    this.warnings = const [],
    this.error,
  });
}