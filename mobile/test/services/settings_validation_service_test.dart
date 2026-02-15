import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/settings_validation_service.dart';

void main() {
  group('SettingsValidationService', () {
    group('validateRecordingSettings', () {
      test('should pass validation for valid settings', () {
        final result = SettingsValidationService.validateRecordingSettings(
          jurisdiction: 'New York',
          videoQuality: '1080p',
          audioBitrate: 128.0,
          fileFormat: 'MP4',
          consentRecording: false,
        );

        expect(result.isValid, isTrue);
        expect(result.conflicts, isEmpty);
        expect(result.warnings, isEmpty);
      });

      test('should detect two-party consent state conflict', () {
        final result = SettingsValidationService.validateRecordingSettings(
          jurisdiction: 'California',
          videoQuality: '1080p',
          audioBitrate: 128.0,
          fileFormat: 'MP4',
          consentRecording: false,
        );

        expect(result.isValid, isFalse);
        expect(result.conflicts, hasLength(1));
        expect(result.conflicts.first.type, ConflictType.legalRequirement);
        expect(result.conflicts.first.affectedSetting, 'consentRecording');
        expect(result.conflicts.first.suggestedValue, isTrue);
      });

      test('should warn about 4K with high audio bitrate', () {
        final result = SettingsValidationService.validateRecordingSettings(
          jurisdiction: 'New York',
          videoQuality: '4K',
          audioBitrate: 320.0,
          fileFormat: 'MP4',
          consentRecording: false,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.performance);
        expect(result.warnings.first.affectedSetting, 'videoQuality');
      });

      test('should warn about AVI format with 4K', () {
        final result = SettingsValidationService.validateRecordingSettings(
          jurisdiction: 'New York',
          videoQuality: '4K',
          audioBitrate: 128.0,
          fileFormat: 'AVI',
          consentRecording: false,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.compatibility);
        expect(result.warnings.first.affectedSetting, 'fileFormat');
      });

      test('should validate all two-party consent states', () {
        final twoPartyStates = ['California', 'Florida', 'Pennsylvania', 'Illinois', 'Michigan'];
        
        for (final state in twoPartyStates) {
          final result = SettingsValidationService.validateRecordingSettings(
            jurisdiction: state,
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            consentRecording: false,
          );

          expect(result.isValid, isFalse, reason: 'Should fail for $state');
          expect(result.conflicts.first.type, ConflictType.legalRequirement);
        }
      });
    });

    group('validatePrivacySettings', () {
      test('should pass validation for valid privacy settings', () {
        final result = SettingsValidationService.validatePrivacySettings(
          dataSharing: false,
          cloudBackup: false,
          analyticsSharing: false,
          autoDeleteDays: 30,
          encryptionEnabled: true,
        );

        expect(result.isValid, isTrue);
        expect(result.conflicts, isEmpty);
        expect(result.warnings, isEmpty);
      });

      test('should detect cloud backup without encryption conflict', () {
        final result = SettingsValidationService.validatePrivacySettings(
          dataSharing: false,
          cloudBackup: true,
          analyticsSharing: false,
          autoDeleteDays: 30,
          encryptionEnabled: false,
        );

        expect(result.isValid, isFalse);
        expect(result.conflicts, hasLength(1));
        expect(result.conflicts.first.type, ConflictType.security);
        expect(result.conflicts.first.affectedSetting, 'encryptionEnabled');
        expect(result.conflicts.first.suggestedValue, isTrue);
      });

      test('should warn about inconsistent data sharing settings', () {
        final result = SettingsValidationService.validatePrivacySettings(
          dataSharing: false,
          cloudBackup: false,
          analyticsSharing: true,
          autoDeleteDays: 30,
          encryptionEnabled: true,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.consistency);
        expect(result.warnings.first.affectedSetting, 'analyticsSharing');
      });

      test('should warn about short auto-delete with cloud backup', () {
        final result = SettingsValidationService.validatePrivacySettings(
          dataSharing: false,
          cloudBackup: true,
          analyticsSharing: false,
          autoDeleteDays: 7,
          encryptionEnabled: true,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.dataLoss);
        expect(result.warnings.first.affectedSetting, 'autoDeleteDays');
      });
    });

    group('validateAccessibilitySettings', () {
      test('should pass validation for valid accessibility settings', () {
        final result = SettingsValidationService.validateAccessibilitySettings(
          voiceCommands: false,
          textSize: 1.0,
          highContrast: false,
          reducedMotion: false,
          screenReaderSupport: false,
          hapticFeedback: true,
        );

        expect(result.isValid, isTrue);
        expect(result.conflicts, isEmpty);
        expect(result.warnings, isEmpty);
      });

      test('should warn about very large text size', () {
        final result = SettingsValidationService.validateAccessibilitySettings(
          voiceCommands: false,
          textSize: 2.0,
          highContrast: false,
          reducedMotion: false,
          screenReaderSupport: false,
          hapticFeedback: true,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.usability);
        expect(result.warnings.first.affectedSetting, 'textSize');
      });

      test('should warn about voice commands with screen reader', () {
        final result = SettingsValidationService.validateAccessibilitySettings(
          voiceCommands: true,
          textSize: 1.0,
          highContrast: false,
          reducedMotion: false,
          screenReaderSupport: true,
          hapticFeedback: true,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.compatibility);
        expect(result.warnings.first.affectedSetting, 'voiceCommands');
      });

      test('should warn about haptic feedback with reduced motion', () {
        final result = SettingsValidationService.validateAccessibilitySettings(
          voiceCommands: false,
          textSize: 1.0,
          highContrast: false,
          reducedMotion: true,
          screenReaderSupport: false,
          hapticFeedback: true,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.consistency);
        expect(result.warnings.first.affectedSetting, 'hapticFeedback');
      });
    });

    group('getRequiredPermissions', () {
      test('should always require camera and microphone', () {
        final permissions = SettingsValidationService.getRequiredPermissions(
          videoQuality: '720p',
          cloudBackup: false,
          voiceCommands: false,
          jurisdiction: 'New York',
        );

        expect(permissions.length, greaterThanOrEqualTo(2));
        expect(permissions.any((p) => p.permission == 'camera'), isTrue);
        expect(permissions.any((p) => p.permission == 'microphone'), isTrue);
        expect(permissions.where((p) => p.permission == 'camera').first.required, isTrue);
        expect(permissions.where((p) => p.permission == 'microphone').first.required, isTrue);
      });

      test('should require location for auto-detect jurisdiction', () {
        final permissions = SettingsValidationService.getRequiredPermissions(
          videoQuality: '720p',
          cloudBackup: false,
          voiceCommands: false,
          jurisdiction: 'Auto-detect',
        );

        expect(permissions.any((p) => p.permission == 'location'), isTrue);
        expect(permissions.where((p) => p.permission == 'location').first.required, isFalse);
      });

      test('should require storage for 4K recording', () {
        final permissions = SettingsValidationService.getRequiredPermissions(
          videoQuality: '4K',
          cloudBackup: false,
          voiceCommands: false,
          jurisdiction: 'New York',
        );

        expect(permissions.any((p) => p.permission == 'storage'), isTrue);
        expect(permissions.where((p) => p.permission == 'storage').first.required, isTrue);
      });

      test('should require internet for cloud backup', () {
        final permissions = SettingsValidationService.getRequiredPermissions(
          videoQuality: '720p',
          cloudBackup: true,
          voiceCommands: false,
          jurisdiction: 'New York',
        );

        expect(permissions.any((p) => p.permission == 'internet'), isTrue);
        expect(permissions.where((p) => p.permission == 'internet').first.required, isFalse);
      });

      test('should require always-on microphone for voice commands', () {
        final permissions = SettingsValidationService.getRequiredPermissions(
          videoQuality: '720p',
          cloudBackup: false,
          voiceCommands: true,
          jurisdiction: 'New York',
        );

        expect(permissions.any((p) => p.permission == 'microphone_always'), isTrue);
        expect(permissions.where((p) => p.permission == 'microphone_always').first.required, isFalse);
      });
    });

    group('validateAllSettings', () {
      test('should validate complete settings configuration', () {
        final settings = {
          'recording': {
            'videoQuality': '1080p',
            'audioBitrate': 128.0,
            'fileFormat': 'MP4',
          },
          'privacy': {
            'dataSharing': false,
            'cloudBackup': false,
            'analyticsSharing': false,
            'autoDeleteDays': 30,
            'encryptionEnabled': true,
          },
          'legal': {
            'consentRecording': false,
          },
          'accessibility': {
            'voiceCommands': false,
            'textSize': 1.0,
            'highContrast': false,
            'reducedMotion': false,
            'screenReaderSupport': false,
            'hapticFeedback': true,
          },
        };

        final result = SettingsValidationService.validateAllSettings(
          allSettings: settings,
          jurisdiction: 'New York',
        );

        expect(result.isValid, isTrue);
        expect(result.conflicts, isEmpty);
      });

      test('should detect cross-section conflicts', () {
        final settings = {
          'recording': {
            'videoQuality': '4K',
            'audioBitrate': 128.0,
            'fileFormat': 'MP4',
          },
          'privacy': {
            'dataSharing': false,
            'cloudBackup': true,
            'analyticsSharing': false,
            'autoDeleteDays': 30,
            'encryptionEnabled': true,
          },
          'legal': {
            'consentRecording': false,
          },
          'accessibility': {
            'voiceCommands': true,
            'textSize': 1.0,
            'highContrast': false,
            'reducedMotion': false,
            'screenReaderSupport': false,
            'hapticFeedback': true,
          },
        };

        final result = SettingsValidationService.validateAllSettings(
          allSettings: settings,
          jurisdiction: 'New York',
        );

        expect(result.warnings.any((w) => 
          w.message.contains('4K recordings with cloud backup')), isTrue);
        expect(result.warnings.any((w) => 
          w.message.contains('Voice commands are enabled but consent recording is disabled')), isTrue);
      });
    });

    group('validateDeviceCapabilities', () {
      test('should pass validation for compatible settings', () {
        final settings = {
          'recording': {
            'videoQuality': '1080p',
            'audioBitrate': 128.0,
          },
        };

        final capabilities = DeviceCapabilities.defaultCapabilities();

        final result = SettingsValidationService.validateDeviceCapabilities(
          settings: settings,
          capabilities: capabilities,
        );

        expect(result.isValid, isTrue);
        expect(result.conflicts, isEmpty);
      });

      test('should detect 4K incompatibility', () {
        final settings = {
          'recording': {
            'videoQuality': '4K',
            'audioBitrate': 128.0,
          },
        };

        const capabilities = DeviceCapabilities(
          supports4K: false,
          hasHighQualityMicrophone: true,
          ramGB: 6.0,
          availableStorageGB: 10.0,
          supportsBackgroundRecording: true,
          hasHapticFeedback: true,
        );

        final result = SettingsValidationService.validateDeviceCapabilities(
          settings: settings,
          capabilities: capabilities,
        );

        expect(result.isValid, isFalse);
        expect(result.conflicts, hasLength(1));
        expect(result.conflicts.first.type, ConflictType.compatibility);
        expect(result.conflicts.first.affectedSetting, 'videoQuality');
        expect(result.conflicts.first.suggestedValue, '1080p');
      });

      test('should warn about low storage', () {
        final settings = {
          'recording': {
            'videoQuality': '1080p',
            'audioBitrate': 128.0,
          },
        };

        const capabilities = DeviceCapabilities(
          supports4K: true,
          hasHighQualityMicrophone: true,
          ramGB: 6.0,
          availableStorageGB: 1.0, // Low storage
          supportsBackgroundRecording: true,
          hasHapticFeedback: true,
        );

        final result = SettingsValidationService.validateDeviceCapabilities(
          settings: settings,
          capabilities: capabilities,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.performance);
        expect(result.warnings.first.severity, WarningSeverity.high);
      });

      test('should warn about 4K with low RAM', () {
        final settings = {
          'recording': {
            'videoQuality': '4K',
            'audioBitrate': 128.0,
          },
        };

        const capabilities = DeviceCapabilities(
          supports4K: true,
          hasHighQualityMicrophone: true,
          ramGB: 2.0, // Low RAM
          availableStorageGB: 10.0,
          supportsBackgroundRecording: true,
          hasHapticFeedback: true,
        );

        final result = SettingsValidationService.validateDeviceCapabilities(
          settings: settings,
          capabilities: capabilities,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.performance);
        expect(result.warnings.first.affectedSetting, 'videoQuality');
      });

      test('should warn about high bitrate with low-quality microphone', () {
        final settings = {
          'recording': {
            'videoQuality': '1080p',
            'audioBitrate': 320.0,
          },
        };

        const capabilities = DeviceCapabilities(
          supports4K: true,
          hasHighQualityMicrophone: false,
          ramGB: 6.0,
          availableStorageGB: 10.0,
          supportsBackgroundRecording: true,
          hasHapticFeedback: true,
        );

        final result = SettingsValidationService.validateDeviceCapabilities(
          settings: settings,
          capabilities: capabilities,
        );

        expect(result.isValid, isTrue);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.type, WarningType.compatibility);
        expect(result.warnings.first.affectedSetting, 'audioBitrate');
      });
    });

    group('SettingsValidationResult', () {
      test('should correctly identify highest severity', () {
        const result = SettingsValidationResult(
          isValid: false,
          warnings: [
            SettingsWarning(
              type: WarningType.performance,
              message: 'Test warning',
              affectedSetting: 'test',
              severity: WarningSeverity.low,
            ),
          ],
          conflicts: [
            SettingsConflict(
              type: ConflictType.legalRequirement,
              message: 'Test conflict',
              affectedSetting: 'test',
              suggestedValue: true,
              severity: ConflictSeverity.high,
            ),
          ],
          suggestions: ['Test suggestion'],
        );

        expect(result.highestSeverity, ConflictSeverity.high);
        expect(result.hasWarnings, isTrue);
        expect(result.hasConflicts, isTrue);
        expect(result.hasSuggestions, isTrue);
      });

      test('should handle medium severity correctly', () {
        const result = SettingsValidationResult(
          isValid: false,
          warnings: [
            SettingsWarning(
              type: WarningType.performance,
              message: 'Test warning',
              affectedSetting: 'test',
              severity: WarningSeverity.high,
            ),
          ],
          conflicts: [
            SettingsConflict(
              type: ConflictType.security,
              message: 'Test conflict',
              affectedSetting: 'test',
              suggestedValue: true,
              severity: ConflictSeverity.medium,
            ),
          ],
          suggestions: [],
        );

        expect(result.highestSeverity, ConflictSeverity.medium);
      });

      test('should default to low severity', () {
        const result = SettingsValidationResult(
          isValid: true,
          warnings: [
            SettingsWarning(
              type: WarningType.performance,
              message: 'Test warning',
              affectedSetting: 'test',
              severity: WarningSeverity.low,
            ),
          ],
          conflicts: [],
          suggestions: [],
        );

        expect(result.highestSeverity, ConflictSeverity.low);
      });
    });

    group('DeviceCapabilities', () {
      test('should create default capabilities', () {
        final capabilities = DeviceCapabilities.defaultCapabilities();

        expect(capabilities.supports4K, isTrue);
        expect(capabilities.hasHighQualityMicrophone, isTrue);
        expect(capabilities.ramGB, 6.0);
        expect(capabilities.availableStorageGB, 10.0);
        expect(capabilities.supportsBackgroundRecording, isTrue);
        expect(capabilities.hasHapticFeedback, isTrue);
      });

      test('should create capabilities from device info', () {
        final capabilities = DeviceCapabilities.fromDeviceInfo(
          supports4K: false,
          hasHighQualityMicrophone: false,
          ramGB: 3.0,
          availableStorageGB: 5.0,
          supportsBackgroundRecording: false,
          hasHapticFeedback: false,
        );

        expect(capabilities.supports4K, isFalse);
        expect(capabilities.hasHighQualityMicrophone, isFalse);
        expect(capabilities.ramGB, 3.0);
        expect(capabilities.availableStorageGB, 5.0);
        expect(capabilities.supportsBackgroundRecording, isFalse);
        expect(capabilities.hasHapticFeedback, isFalse);
      });
    });
  });
}