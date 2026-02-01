import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app settings and preferences
class SettingsService {
  static const String _videoQualityKey = 'video_quality';
  static const String _audioBitrateKey = 'audio_bitrate';
  static const String _fileFormatKey = 'file_format';
  static const String _autoSaveKey = 'auto_save';
  static const String _dataSharingKey = 'data_sharing';
  static const String _cloudBackupKey = 'cloud_backup';
  static const String _analyticsSharingKey = 'analytics_sharing';
  static const String _autoDeleteDaysKey = 'auto_delete_days';
  static const String _encryptionEnabledKey = 'encryption_enabled';
  static const String _jurisdictionKey = 'jurisdiction';
  static const String _consentRecordingKey = 'consent_recording';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _rightsRemindersKey = 'rights_reminders';
  static const String _legalHotlineAccessKey = 'legal_hotline_access';
  static const String _voiceCommandsKey = 'voice_commands';
  static const String _textSizeKey = 'text_size';
  static const String _highContrastKey = 'high_contrast';
  static const String _reducedMotionKey = 'reduced_motion';
  static const String _screenReaderSupportKey = 'screen_reader_support';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _autoAlertContactsKey = 'auto_alert_contacts';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Emergency settings
  bool get autoAlertContacts => _prefs.getBool(_autoAlertContactsKey) ?? false;
  set autoAlertContacts(bool value) => _prefs.setBool(_autoAlertContactsKey, value);

  // Recording settings
  String get videoQuality => _prefs.getString(_videoQualityKey) ?? '1080p';
  set videoQuality(String value) => _prefs.setString(_videoQualityKey, value);

  double get audioBitrate => _prefs.getDouble(_audioBitrateKey) ?? 128.0;
  set audioBitrate(double value) => _prefs.setDouble(_audioBitrateKey, value);

  String get fileFormat => _prefs.getString(_fileFormatKey) ?? 'MP4';
  set fileFormat(String value) => _prefs.setString(_fileFormatKey, value);

  bool get autoSave => _prefs.getBool(_autoSaveKey) ?? true;
  set autoSave(bool value) => _prefs.setBool(_autoSaveKey, value);

  // Privacy settings
  bool get dataSharing => _prefs.getBool(_dataSharingKey) ?? false;
  set dataSharing(bool value) => _prefs.setBool(_dataSharingKey, value);

  bool get cloudBackup => _prefs.getBool(_cloudBackupKey) ?? true;
  set cloudBackup(bool value) => _prefs.setBool(_cloudBackupKey, value);

  bool get analyticsSharing => _prefs.getBool(_analyticsSharingKey) ?? false;
  set analyticsSharing(bool value) => _prefs.setBool(_analyticsSharingKey, value);

  int get autoDeleteDays => _prefs.getInt(_autoDeleteDaysKey) ?? 90;
  set autoDeleteDays(int value) => _prefs.setInt(_autoDeleteDaysKey, value);

  bool get encryptionEnabled => _prefs.getBool(_encryptionEnabledKey) ?? true;
  set encryptionEnabled(bool value) => _prefs.setBool(_encryptionEnabledKey, value);

  // Legal settings
  String get jurisdiction => _prefs.getString(_jurisdictionKey) ?? 'Auto-detect';
  set jurisdiction(String value) => _prefs.setString(_jurisdictionKey, value);

  bool get consentRecording => _prefs.getBool(_consentRecordingKey) ?? true;
  set consentRecording(bool value) => _prefs.setBool(_consentRecordingKey, value);

  bool get notificationsEnabled => _prefs.getBool(_notificationsEnabledKey) ?? true;
  set notificationsEnabled(bool value) => _prefs.setBool(_notificationsEnabledKey, value);

  bool get rightsReminders => _prefs.getBool(_rightsRemindersKey) ?? true;
  set rightsReminders(bool value) => _prefs.setBool(_rightsRemindersKey, value);

  bool get legalHotlineAccess => _prefs.getBool(_legalHotlineAccessKey) ?? true;
  set legalHotlineAccess(bool value) => _prefs.setBool(_legalHotlineAccessKey, value);

  // Accessibility settings
  bool get voiceCommands => _prefs.getBool(_voiceCommandsKey) ?? false;
  set voiceCommands(bool value) => _prefs.setBool(_voiceCommandsKey, value);

  double get textSize => _prefs.getDouble(_textSizeKey) ?? 1.0;
  set textSize(double value) => _prefs.setDouble(_textSizeKey, value);

  bool get highContrast => _prefs.getBool(_highContrastKey) ?? false;
  set highContrast(bool value) => _prefs.setBool(_highContrastKey, value);

  bool get reducedMotion => _prefs.getBool(_reducedMotionKey) ?? false;
  set reducedMotion(bool value) => _prefs.setBool(_reducedMotionKey, value);

  bool get screenReaderSupport => _prefs.getBool(_screenReaderSupportKey) ?? true;
  set screenReaderSupport(bool value) => _prefs.setBool(_screenReaderSupportKey, value);

  bool get hapticFeedback => _prefs.getBool(_hapticFeedbackKey) ?? true;
  set hapticFeedback(bool value) => _prefs.setBool(_hapticFeedbackKey, value);

  /// Load all settings from persistent storage
  Future<void> loadSettings() async {
    // Settings are loaded automatically via SharedPreferences
    // This method exists for consistency with other services
  }

  /// Save all current settings to persistent storage
  Future<void> saveSettings() async {
    // Settings are saved individually when updated
    // This method exists for consistency with other services
  }
}