
/// Settings validation service for legal compliance and conflict detection
class SettingsValidationService {
  /// Validates recording settings against local law requirements
  static SettingsValidationResult validateRecordingSettings({
    required String jurisdiction,
    required String videoQuality,
    required double audioBitrate,
    required String fileFormat,
    required bool consentRecording,
  }) {
    final List<SettingsWarning> warnings = [];
    final List<SettingsConflict> conflicts = [];
    final List<String> suggestions = [];

    // Validate consent recording for two-party consent states
    final twoPartyStates = ['California', 'Florida', 'Pennsylvania', 'Illinois', 'Michigan'];
    if (twoPartyStates.contains(jurisdiction) && !consentRecording) {
      conflicts.add(SettingsConflict(
        type: ConflictType.legalRequirement,
        message: 'Consent recording is required in $jurisdiction (two-party consent state)',
        affectedSetting: 'consentRecording',
        suggestedValue: true,
        severity: ConflictSeverity.high,
      ));
      suggestions.add('Enable consent recording to comply with $jurisdiction law');
    }

    // Validate video quality vs storage implications
    if (videoQuality == '4K' && audioBitrate > 256.0) {
      warnings.add(SettingsWarning(
        type: WarningType.performance,
        message: '4K video with high audio bitrate will create very large files',
        affectedSetting: 'videoQuality',
        severity: WarningSeverity.medium,
      ));
      suggestions.add('Consider reducing audio bitrate to 256 kbps or lower for 4K recording');
    }

    // Validate file format compatibility
    if (fileFormat == 'AVI' && videoQuality == '4K') {
      warnings.add(SettingsWarning(
        type: WarningType.compatibility,
        message: 'AVI format may have compatibility issues with 4K recording',
        affectedSetting: 'fileFormat',
        severity: WarningSeverity.low,
      ));
      suggestions.add('Consider using MP4 format for better 4K compatibility');
    }

    return SettingsValidationResult(
      isValid: conflicts.isEmpty,
      warnings: warnings,
      conflicts: conflicts,
      suggestions: suggestions,
    );
  }

  /// Validates privacy settings for consistency
  static SettingsValidationResult validatePrivacySettings({
    required bool dataSharing,
    required bool cloudBackup,
    required bool analyticsSharing,
    required int autoDeleteDays,
    required bool encryptionEnabled,
  }) {
    final List<SettingsWarning> warnings = [];
    final List<SettingsConflict> conflicts = [];
    final List<String> suggestions = [];

    // Validate encryption requirement for cloud backup
    if (cloudBackup && !encryptionEnabled) {
      conflicts.add(SettingsConflict(
        type: ConflictType.security,
        message: 'Cloud backup requires encryption to be enabled for security',
        affectedSetting: 'encryptionEnabled',
        suggestedValue: true,
        severity: ConflictSeverity.high,
      ));
      suggestions.add('Enable encryption to use cloud backup securely');
    }

    // Validate data sharing consistency
    if (!dataSharing && analyticsSharing) {
      warnings.add(SettingsWarning(
        type: WarningType.consistency,
        message: 'Analytics sharing is enabled but general data sharing is disabled',
        affectedSetting: 'analyticsSharing',
        severity: WarningSeverity.low,
      ));
      suggestions.add('Consider enabling data sharing or disabling analytics sharing for consistency');
    }

    // Validate auto-delete with cloud backup
    if (cloudBackup && autoDeleteDays > 0 && autoDeleteDays < 30) {
      warnings.add(SettingsWarning(
        type: WarningType.dataLoss,
        message: 'Short auto-delete timer may delete files before cloud backup completes',
        affectedSetting: 'autoDeleteDays',
        severity: WarningSeverity.medium,
      ));
      suggestions.add('Consider setting auto-delete to 30 days or more when using cloud backup');
    }

    return SettingsValidationResult(
      isValid: conflicts.isEmpty,
      warnings: warnings,
      conflicts: conflicts,
      suggestions: suggestions,
    );
  }

  /// Validates accessibility settings for usability
  static SettingsValidationResult validateAccessibilitySettings({
    required bool voiceCommands,
    required double textSize,
    required bool highContrast,
    required bool reducedMotion,
    required bool screenReaderSupport,
    required bool hapticFeedback,
  }) {
    final List<SettingsWarning> warnings = [];
    final List<SettingsConflict> conflicts = [];
    final List<String> suggestions = [];

    // Validate text size extremes
    if (textSize > 1.8) {
      warnings.add(SettingsWarning(
        type: WarningType.usability,
        message: 'Very large text size may cause layout issues on small screens',
        affectedSetting: 'textSize',
        severity: WarningSeverity.low,
      ));
      suggestions.add('Test the app thoroughly with this text size setting');
    }

    // Validate voice commands with screen reader
    if (voiceCommands && screenReaderSupport) {
      warnings.add(SettingsWarning(
        type: WarningType.compatibility,
        message: 'Voice commands may interfere with screen reader functionality',
        affectedSetting: 'voiceCommands',
        severity: WarningSeverity.medium,
      ));
      suggestions.add('Test voice commands with your screen reader to ensure compatibility');
    }

    // Validate reduced motion with haptic feedback
    if (reducedMotion && hapticFeedback) {
      warnings.add(SettingsWarning(
        type: WarningType.consistency,
        message: 'Haptic feedback may be distracting when reduced motion is enabled',
        affectedSetting: 'hapticFeedback',
        severity: WarningSeverity.low,
      ));
      suggestions.add('Consider disabling haptic feedback when using reduced motion');
    }

    return SettingsValidationResult(
      isValid: conflicts.isEmpty,
      warnings: warnings,
      conflicts: conflicts,
      suggestions: suggestions,
    );
  }

  /// Gets required permissions for current settings
  static List<PermissionRequirement> getRequiredPermissions({
    required String videoQuality,
    required bool cloudBackup,
    required bool voiceCommands,
    required String jurisdiction,
  }) {
    final List<PermissionRequirement> permissions = [];

    // Camera permission always required
    permissions.add(PermissionRequirement(
      permission: 'camera',
      reason: 'Required to record video during police interactions',
      required: true,
    ));

    // Microphone permission always required
    permissions.add(PermissionRequirement(
      permission: 'microphone',
      reason: 'Required to record audio during police interactions',
      required: true,
    ));

    // Location permission for jurisdiction detection
    if (jurisdiction == 'Auto-detect') {
      permissions.add(PermissionRequirement(
        permission: 'location',
        reason: 'Required to automatically detect your jurisdiction for legal guidance',
        required: false,
      ));
    }

    // Storage permission for high-quality recording
    if (videoQuality == '4K') {
      permissions.add(PermissionRequirement(
        permission: 'storage',
        reason: 'Required for 4K video recording which creates large files',
        required: true,
      ));
    }

    // Network permission for cloud backup
    if (cloudBackup) {
      permissions.add(PermissionRequirement(
        permission: 'internet',
        reason: 'Required to backup recordings to secure cloud storage',
        required: false,
      ));
    }

    // Microphone permission for voice commands
    if (voiceCommands) {
      permissions.add(PermissionRequirement(
        permission: 'microphone_always',
        reason: 'Required for voice commands to work when app is in background',
        required: false,
      ));
    }

    return permissions;
  }

  /// Validates all settings together for comprehensive conflict detection
  static SettingsValidationResult validateAllSettings({
    required Map<String, dynamic> allSettings,
    required String jurisdiction,
  }) {
    final List<SettingsWarning> warnings = [];
    final List<SettingsConflict> conflicts = [];
    final List<String> suggestions = [];

    // Extract settings from different sections
    final recording = allSettings['recording'] as Map<String, dynamic>? ?? {};
    final privacy = allSettings['privacy'] as Map<String, dynamic>? ?? {};
    final legal = allSettings['legal'] as Map<String, dynamic>? ?? {};
    final accessibility = allSettings['accessibility'] as Map<String, dynamic>? ?? {};

    // Validate recording settings
    final recordingResult = validateRecordingSettings(
      jurisdiction: jurisdiction,
      videoQuality: recording['videoQuality'] as String? ?? '1080p',
      audioBitrate: (recording['audioBitrate'] as num?)?.toDouble() ?? 128.0,
      fileFormat: recording['fileFormat'] as String? ?? 'MP4',
      consentRecording: legal['consentRecording'] as bool? ?? false,
    );
    warnings.addAll(recordingResult.warnings);
    conflicts.addAll(recordingResult.conflicts);
    suggestions.addAll(recordingResult.suggestions);

    // Validate privacy settings
    final privacyResult = validatePrivacySettings(
      dataSharing: privacy['dataSharing'] as bool? ?? false,
      cloudBackup: privacy['cloudBackup'] as bool? ?? false,
      analyticsSharing: privacy['analyticsSharing'] as bool? ?? false,
      autoDeleteDays: privacy['autoDeleteDays'] as int? ?? 0,
      encryptionEnabled: privacy['encryptionEnabled'] as bool? ?? true,
    );
    warnings.addAll(privacyResult.warnings);
    conflicts.addAll(privacyResult.conflicts);
    suggestions.addAll(privacyResult.suggestions);

    // Validate accessibility settings
    final accessibilityResult = validateAccessibilitySettings(
      voiceCommands: accessibility['voiceCommands'] as bool? ?? false,
      textSize: (accessibility['textSize'] as num?)?.toDouble() ?? 1.0,
      highContrast: accessibility['highContrast'] as bool? ?? false,
      reducedMotion: accessibility['reducedMotion'] as bool? ?? false,
      screenReaderSupport: accessibility['screenReaderSupport'] as bool? ?? false,
      hapticFeedback: accessibility['hapticFeedback'] as bool? ?? true,
    );
    warnings.addAll(accessibilityResult.warnings);
    conflicts.addAll(accessibilityResult.conflicts);
    suggestions.addAll(accessibilityResult.suggestions);

    // Cross-section validation
    _validateCrossSectionSettings(
      recording: recording,
      privacy: privacy,
      legal: legal,
      accessibility: accessibility,
      warnings: warnings,
      conflicts: conflicts,
      suggestions: suggestions,
    );

    return SettingsValidationResult(
      isValid: conflicts.isEmpty,
      warnings: warnings,
      conflicts: conflicts,
      suggestions: suggestions,
    );
  }

  /// Validates settings against device capabilities
  static SettingsValidationResult validateDeviceCapabilities({
    required Map<String, dynamic> settings,
    required DeviceCapabilities capabilities,
  }) {
    final List<SettingsWarning> warnings = [];
    final List<SettingsConflict> conflicts = [];
    final List<String> suggestions = [];

    final recording = settings['recording'] as Map<String, dynamic>? ?? {};
    final videoQuality = recording['videoQuality'] as String? ?? '1080p';
    final audioBitrate = (recording['audioBitrate'] as num?)?.toDouble() ?? 128.0;

    // Check video quality support
    if (videoQuality == '4K' && !capabilities.supports4K) {
      conflicts.add(SettingsConflict(
        type: ConflictType.compatibility,
        message: 'Your device does not support 4K video recording',
        affectedSetting: 'videoQuality',
        suggestedValue: '1080p',
        severity: ConflictSeverity.high,
      ));
      suggestions.add('Use 1080p video quality for optimal performance on your device');
    }

    // Check storage capacity
    if (capabilities.availableStorageGB < 2.0) {
      warnings.add(SettingsWarning(
        type: WarningType.performance,
        message: 'Low storage space may limit recording duration',
        affectedSetting: 'videoQuality',
        severity: WarningSeverity.high,
      ));
      suggestions.add('Free up storage space or reduce video quality to extend recording time');
    }

    // Check RAM for high-quality recording
    if (videoQuality == '4K' && capabilities.ramGB < 4.0) {
      warnings.add(SettingsWarning(
        type: WarningType.performance,
        message: '4K recording may cause performance issues on devices with limited RAM',
        affectedSetting: 'videoQuality',
        severity: WarningSeverity.medium,
      ));
      suggestions.add('Consider using 1080p recording for better performance');
    }

    // Check microphone quality for high bitrate audio
    if (audioBitrate > 256.0 && !capabilities.hasHighQualityMicrophone) {
      warnings.add(SettingsWarning(
        type: WarningType.compatibility,
        message: 'High audio bitrate may not provide better quality on this device',
        affectedSetting: 'audioBitrate',
        severity: WarningSeverity.low,
      ));
      suggestions.add('Consider using 256 kbps or lower audio bitrate');
    }

    return SettingsValidationResult(
      isValid: conflicts.isEmpty,
      warnings: warnings,
      conflicts: conflicts,
      suggestions: suggestions,
    );
  }

  /// Private method for cross-section validation
  static void _validateCrossSectionSettings({
    required Map<String, dynamic> recording,
    required Map<String, dynamic> privacy,
    required Map<String, dynamic> legal,
    required Map<String, dynamic> accessibility,
    required List<SettingsWarning> warnings,
    required List<SettingsConflict> conflicts,
    required List<String> suggestions,
  }) {
    final videoQuality = recording['videoQuality'] as String? ?? '1080p';
    final cloudBackup = privacy['cloudBackup'] as bool? ?? false;
    final voiceCommands = accessibility['voiceCommands'] as bool? ?? false;
    final consentRecording = legal['consentRecording'] as bool? ?? false;

    // High quality recording with cloud backup warning
    if (videoQuality == '4K' && cloudBackup) {
      warnings.add(SettingsWarning(
        type: WarningType.performance,
        message: '4K recordings with cloud backup will use significant bandwidth and storage',
        affectedSetting: 'cloudBackup',
        severity: WarningSeverity.medium,
      ));
      suggestions.add('Consider disabling cloud backup for 4K recordings or use Wi-Fi only');
    }

    // Voice commands with consent recording
    if (voiceCommands && !consentRecording) {
      warnings.add(SettingsWarning(
        type: WarningType.consistency,
        message: 'Voice commands are enabled but consent recording is disabled',
        affectedSetting: 'consentRecording',
        severity: WarningSeverity.low,
      ));
      suggestions.add('Enable consent recording to ensure voice commands are legally compliant');
    }
  }
}

/// Result of settings validation
class SettingsValidationResult {
  final bool isValid;
  final List<SettingsWarning> warnings;
  final List<SettingsConflict> conflicts;
  final List<String> suggestions;

  const SettingsValidationResult({
    required this.isValid,
    required this.warnings,
    required this.conflicts,
    required this.suggestions,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasConflicts => conflicts.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;

  /// Gets the highest severity level
  ConflictSeverity get highestSeverity {
    if (conflicts.any((c) => c.severity == ConflictSeverity.high)) {
      return ConflictSeverity.high;
    }
    if (conflicts.any((c) => c.severity == ConflictSeverity.medium) ||
        warnings.any((w) => w.severity == WarningSeverity.high)) {
      return ConflictSeverity.medium;
    }
    return ConflictSeverity.low;
  }
}

/// Settings warning for non-critical issues
class SettingsWarning {
  final WarningType type;
  final String message;
  final String affectedSetting;
  final WarningSeverity severity;

  const SettingsWarning({
    required this.type,
    required this.message,
    required this.affectedSetting,
    required this.severity,
  });
}

/// Settings conflict for critical issues
class SettingsConflict {
  final ConflictType type;
  final String message;
  final String affectedSetting;
  final dynamic suggestedValue;
  final ConflictSeverity severity;

  const SettingsConflict({
    required this.type,
    required this.message,
    required this.affectedSetting,
    required this.suggestedValue,
    required this.severity,
  });
}

/// Permission requirement information
class PermissionRequirement {
  final String permission;
  final String reason;
  final bool required;

  const PermissionRequirement({
    required this.permission,
    required this.reason,
    required this.required,
  });
}

/// Types of warnings
enum WarningType {
  performance,
  compatibility,
  consistency,
  usability,
  dataLoss,
}

/// Types of conflicts
enum ConflictType {
  legalRequirement,
  security,
  compatibility,
  performance,
}

/// Warning severity levels
enum WarningSeverity {
  low,
  medium,
  high,
}

/// Conflict severity levels
enum ConflictSeverity {
  low,
  medium,
  high,
}

/// Device capabilities for settings validation
class DeviceCapabilities {
  final bool supports4K;
  final bool hasHighQualityMicrophone;
  final double ramGB;
  final double availableStorageGB;
  final bool supportsBackgroundRecording;
  final bool hasHapticFeedback;

  const DeviceCapabilities({
    required this.supports4K,
    required this.hasHighQualityMicrophone,
    required this.ramGB,
    required this.availableStorageGB,
    required this.supportsBackgroundRecording,
    required this.hasHapticFeedback,
  });

  /// Create device capabilities from device info
  factory DeviceCapabilities.fromDeviceInfo({
    required bool supports4K,
    required bool hasHighQualityMicrophone,
    required double ramGB,
    required double availableStorageGB,
    required bool supportsBackgroundRecording,
    required bool hasHapticFeedback,
  }) {
    return DeviceCapabilities(
      supports4K: supports4K,
      hasHighQualityMicrophone: hasHighQualityMicrophone,
      ramGB: ramGB,
      availableStorageGB: availableStorageGB,
      supportsBackgroundRecording: supportsBackgroundRecording,
      hasHapticFeedback: hasHapticFeedback,
    );
  }

  /// Default capabilities for testing
  factory DeviceCapabilities.defaultCapabilities() {
    return const DeviceCapabilities(
      supports4K: true,
      hasHighQualityMicrophone: true,
      ramGB: 6.0,
      availableStorageGB: 10.0,
      supportsBackgroundRecording: true,
      hasHapticFeedback: true,
    );
  }
}