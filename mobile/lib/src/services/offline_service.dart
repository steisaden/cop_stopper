import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/models/note_model.dart';

/// Service for managing offline capabilities
class OfflineService {
  static const String _isOfflineModeKey = 'is_offline_mode';
  static const String _cachedTranscriptsKey = 'cached_transcripts';
  static const String _cachedNotesKey = 'cached_notes';
  static const String _cachedJurisdictionKey = 'cached_jurisdiction';
  static const String _cachedLegalGuidanceKey = 'cached_legal_guidance';
  static const String _cachedRecordingsKey = 'cached_recordings';

  final SharedPreferences _prefs;

  OfflineService(this._prefs);

  /// Check if the app is currently in offline mode
  bool get isOfflineMode => _prefs.getBool(_isOfflineModeKey) ?? false;

  /// Set offline mode
  Future<void> setOfflineMode(bool isOffline) async {
    await _prefs.setBool(_isOfflineModeKey, isOffline);
  }

  /// Cache transcription segments for offline access
  Future<void> cacheTranscripts(List<TranscriptionSegment> segments) async {
    final List<Map<String, dynamic>> jsonList = segments.map((segment) => segment.toJson()).toList();
    await _prefs.setString(_cachedTranscriptsKey, jsonEncode(jsonList));
  }

  /// Get cached transcription segments
  List<TranscriptionSegment> getCachedTranscripts() {
    final jsonString = _prefs.getString(_cachedTranscriptsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => TranscriptionSegment.fromJson(json)).toList();
  }

  /// Cache notes for offline access
  Future<void> cacheNotes(List<Note> notes) async {
    final List<Map<String, dynamic>> jsonList = notes.map((note) => note.toJson()).toList();
    await _prefs.setString(_cachedNotesKey, jsonEncode(jsonList));
  }

  /// Get cached notes
  List<Note> getCachedNotes() {
    final jsonString = _prefs.getString(_cachedNotesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Note.fromJson(json)).toList();
  }

  /// Cache jurisdiction data for offline access
  Future<void> cacheJurisdictionData(String jurisdiction) async {
    await _prefs.setString(_cachedJurisdictionKey, jurisdiction);
  }

  /// Get cached jurisdiction data
  String? getCachedJurisdictionData() {
    return _prefs.getString(_cachedJurisdictionKey);
  }

  /// Cache legal guidance for offline access
  Future<void> cacheLegalGuidance(String legalGuidance) async {
    await _prefs.setString(_cachedLegalGuidanceKey, legalGuidance);
  }

  /// Get cached legal guidance
  String? getCachedLegalGuidance() {
    return _prefs.getString(_cachedLegalGuidanceKey);
  }

  /// Cache recordings metadata for offline access
  Future<void> cacheRecordingsMetadata(String recordings) async {
    await _prefs.setString(_cachedRecordingsKey, recordings);
  }

  /// Get cached recordings metadata
  String? getCachedRecordingsMetadata() {
    return _prefs.getString(_cachedRecordingsKey);
  }

  /// Store a recording file locally for offline access
  /// This creates a copy of the recording in the app's document directory
  Future<String?> storeRecordingOffline(String originalFilePath) async {
    try {
      final originalFile = File(originalFilePath);
      if (!await originalFile.exists()) {
        return null;
      }

      // Get app's document directory
      final appDir = await getApplicationDocumentsDirectory();
      final offlineDir = Directory('${appDir.path}/offline_recordings');
      await offlineDir.create(recursive: true);

      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = originalFilePath.split('.').last;
      final newFileName = 'offline_recording_$timestamp.$fileExtension';
      final newFilePath = '${offlineDir.path}/$newFileName';

      // Copy the file to the offline directory
      final copiedFile = await originalFile.copy(newFilePath);
      return copiedFile.path;
    } catch (e) {
      print('Error storing recording offline: $e');
      return null;
    }
  }

  /// Get list of offline recordings
  Future<List<String>> getOfflineRecordings() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final offlineDir = Directory('${appDir.path}/offline_recordings');
      
      if (!await offlineDir.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = offlineDir.listSync();
      return files
          .whereType<File>()
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting offline recordings: $e');
      return [];
    }
  }

  /// Delete an offline recording
  Future<bool> deleteOfflineRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting offline recording: $e');
      return false;
    }
  }

  /// Clear all cached offline data
  Future<void> clearCachedData() async {
    await _prefs.remove(_cachedTranscriptsKey);
    await _prefs.remove(_cachedNotesKey);
    await _prefs.remove(_cachedJurisdictionKey);
    await _prefs.remove(_cachedLegalGuidanceKey);
    await _prefs.remove(_cachedRecordingsKey);
  }
}