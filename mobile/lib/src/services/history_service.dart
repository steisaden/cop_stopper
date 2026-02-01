import 'dart:convert';
import 'package:mobile/src/models/recording_model.dart';
import 'package:mobile/src/services/storage_service.dart';

/// Service for managing recording history
class HistoryService {
  static const String _historyFileName = 'recording_history.json';
  final StorageService _storageService;

  HistoryService(this._storageService);

  /// Save a recording to history
  Future<void> saveRecordingToHistory(Recording recording) async {
    try {
      // Validate the recording before saving
      recording.validate();

      // Get existing history
      final List<Recording> history = await getRecordingHistory();

      // Add the new recording to the beginning of the list
      history.insert(0, recording);

      // Save updated history
      await _saveHistory(history);
    } catch (e) {
      throw Exception('Failed to save recording to history: $e');
    }
  }

  /// Get all recordings from history
  Future<List<Recording>> getRecordingHistory() async {
    try {
      final jsonString = await _storageService.readFromFile(_historyFileName);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Recording.fromJson(json)).toList();
    } catch (e) {
      print('Error reading recording history: $e');
      return [];
    }
  }

  /// Save the entire history list to storage
  Future<void> _saveHistory(List<Recording> history) async {
    try {
      final jsonString = json.encode(history.map((recording) => recording.toJson()).toList());
      await _storageService.writeToFile(_historyFileName, jsonString);
    } catch (e) {
      throw Exception('Failed to save history: $e');
    }
  }

  /// Delete a recording from history
  Future<void> deleteRecording(String recordingId) async {
    try {
      final List<Recording> history = await getRecordingHistory();
      history.removeWhere((recording) => recording.id == recordingId);
      await _saveHistory(history);
    } catch (e) {
      throw Exception('Failed to delete recording: $e');
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      await _storageService.deleteFile(_historyFileName);
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }
}