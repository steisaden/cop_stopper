import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mobile/src/services/settings_export_service.dart';

// Mock PathProviderPlatform for testing
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/mock/documents';
  }
}

void main() {
  group('SettingsExportService', () {
    late Directory tempDir;
    
    setUpAll(() async {
      // Set up mock path provider
      PathProviderPlatform.instance = MockPathProviderPlatform();
    });

    setUp(() async {
      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('settings_test');
    });

    tearDown(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('SettingsExportData', () {
      test('should serialize and deserialize correctly', () {
        final originalData = SettingsExportData(
          version: 1,
          exportDate: DateTime(2024, 1, 15, 10, 30),
          appVersion: '1.0.0',
          settings: {
            'recording': {
              'videoQuality': '1080p',
              'audioBitrate': 128.0,
            },
            'privacy': {
              'cloudBackup': false,
              'encryptionEnabled': true,
            },
          },
        );

        final json = originalData.toJson();
        final deserializedData = SettingsExportData.fromJson(json);

        expect(deserializedData.version, originalData.version);
        expect(deserializedData.exportDate, originalData.exportDate);
        expect(deserializedData.appVersion, originalData.appVersion);
        expect(deserializedData.settings, originalData.settings);
      });

      test('should handle complex nested settings', () {
        final complexSettings = {
          'recording': {
            'videoQuality': '4K',
            'audioBitrate': 256.0,
            'fileFormat': 'MP4',
            'advanced': {
              'codec': 'H.264',
              'frameRate': 30,
              'stabilization': true,
            },
          },
          'privacy': {
            'dataSharing': false,
            'cloudBackup': true,
            'autoDeleteDays': 30,
            'encryptionSettings': {
              'algorithm': 'AES-256',
              'keyRotation': true,
            },
          },
        };

        final exportData = SettingsExportData(
          version: 1,
          exportDate: DateTime.now(),
          appVersion: '1.0.0',
          settings: complexSettings,
        );

        final json = exportData.toJson();
        final deserializedData = SettingsExportData.fromJson(json);

        expect(deserializedData.settings, complexSettings);
        expect(deserializedData.settings['recording']['advanced']['codec'], 'H.264');
        expect(deserializedData.settings['privacy']['encryptionSettings']['algorithm'], 'AES-256');
      });
    });

    group('Settings validation', () {
      test('should validate complete settings structure', () {
        final validSettings = {
          'recording': {
            'videoQuality': '1080p',
            'audioBitrate': 128.0,
          },
          'privacy': {
            'cloudBackup': false,
            'encryptionEnabled': true,
          },
          'legal': {
            'consentRecording': false,
          },
          'accessibility': {
            'voiceCommands': false,
            'textSize': 1.0,
          },
        };

        final result = SettingsExportService._validateImportedSettings(validSettings);

        expect(result.isValid, isTrue);
        expect(result.warnings, isEmpty);
      });

      test('should warn about missing sections', () {
        final incompleteSettings = {
          'recording': {
            'videoQuality': '1080p',
          },
          // Missing privacy, legal, accessibility sections
        };

        final result = SettingsExportService._validateImportedSettings(incompleteSettings);

        expect(result.isValid, isTrue); // Still valid, but with warnings
        expect(result.warnings, isNotEmpty);
        expect(result.warnings.first, contains('Missing settings sections'));
      });

      test('should warn about missing recording settings', () {
        final settingsWithMissingRecording = {
          'recording': {
            // Missing videoQuality and audioBitrate
          },
          'privacy': {
            'cloudBackup': false,
          },
          'legal': {
            'consentRecording': false,
          },
          'accessibility': {
            'voiceCommands': false,
          },
        };

        final result = SettingsExportService._validateImportedSettings(settingsWithMissingRecording);

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(2));
        expect(result.warnings.any((w) => w.contains('Missing video quality setting')), isTrue);
        expect(result.warnings.any((w) => w.contains('Missing audio bitrate setting')), isTrue);
      });
    });

    group('Settings counting', () {
      test('should count simple settings correctly', () {
        final simpleSettings = {
          'recording': {
            'videoQuality': '1080p',
            'audioBitrate': 128.0,
            'fileFormat': 'MP4',
          },
          'privacy': {
            'cloudBackup': false,
            'encryptionEnabled': true,
          },
        };

        final count = SettingsExportService._countSettings(simpleSettings);

        expect(count, 7); // 2 top-level + 3 recording + 2 privacy
      });

      test('should count nested settings correctly', () {
        final nestedSettings = {
          'recording': {
            'videoQuality': '1080p',
            'advanced': {
              'codec': 'H.264',
              'frameRate': 30,
              'options': {
                'stabilization': true,
                'hdr': false,
              },
            },
          },
          'privacy': {
            'cloudBackup': false,
          },
        };

        final count = SettingsExportService._countSettings(nestedSettings);

        expect(count, 9); // 2 top-level + 2 recording + 3 advanced + 2 options + 1 privacy
      });
    });

    group('Backup operations', () {
      test('should create backup info correctly', () {
        final backupInfo = SettingsBackupInfo(
          filePath: '/path/to/backup.json',
          fileName: 'backup_2024-01-15.json',
          exportDate: DateTime(2024, 1, 15, 10, 30),
          appVersion: '1.0.0',
          fileSize: 1024,
          settingsCount: 15,
        );

        expect(backupInfo.filePath, '/path/to/backup.json');
        expect(backupInfo.fileName, 'backup_2024-01-15.json');
        expect(backupInfo.exportDate, DateTime(2024, 1, 15, 10, 30));
        expect(backupInfo.appVersion, '1.0.0');
        expect(backupInfo.fileSize, 1024);
        expect(backupInfo.settingsCount, 15);
      });
    });

    group('Result classes', () {
      test('should create export result correctly', () {
        const successResult = SettingsExportResult(
          success: true,
          filePath: '/path/to/export.json',
          fileSize: 2048,
        );

        expect(successResult.success, isTrue);
        expect(successResult.filePath, '/path/to/export.json');
        expect(successResult.fileSize, 2048);
        expect(successResult.error, isNull);

        const errorResult = SettingsExportResult(
          success: false,
          error: 'Export failed',
        );

        expect(errorResult.success, isFalse);
        expect(errorResult.error, 'Export failed');
        expect(errorResult.filePath, isNull);
        expect(errorResult.fileSize, isNull);
      });

      test('should create import result correctly', () {
        final settings = {
          'recording': {'videoQuality': '1080p'},
        };

        final successResult = SettingsImportResult(
          success: true,
          settings: settings,
          exportDate: DateTime(2024, 1, 15),
          appVersion: '1.0.0',
          warnings: ['Warning message'],
        );

        expect(successResult.success, isTrue);
        expect(successResult.settings, settings);
        expect(successResult.exportDate, DateTime(2024, 1, 15));
        expect(successResult.appVersion, '1.0.0');
        expect(successResult.warnings, ['Warning message']);
        expect(successResult.error, isNull);

        const errorResult = SettingsImportResult(
          success: false,
          error: 'Import failed',
        );

        expect(errorResult.success, isFalse);
        expect(errorResult.error, 'Import failed');
        expect(errorResult.settings, isNull);
      });

      test('should create backup result correctly', () {
        const successResult = SettingsBackupResult(
          success: true,
          backupPath: '/path/to/backup.json',
          backupSize: 1536,
        );

        expect(successResult.success, isTrue);
        expect(successResult.backupPath, '/path/to/backup.json');
        expect(successResult.backupSize, 1536);
        expect(successResult.error, isNull);

        const errorResult = SettingsBackupResult(
          success: false,
          error: 'Backup failed',
        );

        expect(errorResult.success, isFalse);
        expect(errorResult.error, 'Backup failed');
        expect(errorResult.backupPath, isNull);
        expect(errorResult.backupSize, isNull);
      });
    });

    group('Settings validation result', () {
      test('should create validation result correctly', () {
        const validResult = SettingsValidationResult(
          isValid: true,
          warnings: ['Warning 1', 'Warning 2'],
        );

        expect(validResult.isValid, isTrue);
        expect(validResult.warnings, ['Warning 1', 'Warning 2']);
        expect(validResult.error, isNull);

        const invalidResult = SettingsValidationResult(
          isValid: false,
          error: 'Validation error',
          warnings: ['Warning'],
        );

        expect(invalidResult.isValid, isFalse);
        expect(invalidResult.error, 'Validation error');
        expect(invalidResult.warnings, ['Warning']);
      });
    });

    group('JSON handling', () {
      test('should handle malformed JSON gracefully', () {
        expect(() {
          const malformedJson = '{"version": 1, "exportDate": "invalid-date"}';
          final jsonData = jsonDecode(malformedJson) as Map<String, dynamic>;
          SettingsExportData.fromJson(jsonData);
        }, throwsA(isA<FormatException>()));
      });

      test('should handle missing required fields', () {
        expect(() {
          const incompleteJson = '{"version": 1}'; // Missing required fields
          final jsonData = jsonDecode(incompleteJson) as Map<String, dynamic>;
          SettingsExportData.fromJson(jsonData);
        }, throwsA(isA<TypeError>()));
      });

      test('should handle null values appropriately', () {
        final jsonWithNulls = {
          'version': 1,
          'exportDate': DateTime.now().toIso8601String(),
          'appVersion': '1.0.0',
          'settings': {
            'recording': {
              'videoQuality': null,
              'audioBitrate': 128.0,
            },
          },
        };

        final exportData = SettingsExportData.fromJson(jsonWithNulls);
        expect(exportData.settings['recording']['videoQuality'], isNull);
        expect(exportData.settings['recording']['audioBitrate'], 128.0);
      });
    });

    group('Edge cases', () {
      test('should handle empty settings', () {
        final emptySettings = <String, dynamic>{};
        
        final result = SettingsExportService._validateImportedSettings(emptySettings);
        
        expect(result.isValid, isTrue);
        expect(result.warnings, isNotEmpty);
        expect(result.warnings.first, contains('Missing settings sections'));
      });

      test('should handle very large settings', () {
        final largeSettings = <String, dynamic>{};
        
        // Create a large settings structure
        for (int i = 0; i < 100; i++) {
          largeSettings['section_$i'] = <String, dynamic>{};
          for (int j = 0; j < 50; j++) {
            largeSettings['section_$i']['setting_$j'] = 'value_$j';
          }
        }

        final count = SettingsExportService._countSettings(largeSettings);
        expect(count, 5100); // 100 sections + 100*50 settings
      });

      test('should handle deeply nested settings', () {
        final deepSettings = <String, dynamic>{
          'level1': <String, dynamic>{
            'level2': <String, dynamic>{
              'level3': <String, dynamic>{
                'level4': <String, dynamic>{
                  'level5': 'deep_value',
                },
              },
            },
          },
        };

        final count = SettingsExportService._countSettings(deepSettings);
        expect(count, 5); // One setting at each level
      });
    });
  });
}