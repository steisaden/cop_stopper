import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
      print('📁 Reading history file: $_historyFileName');
      final jsonString = await _storageService.readFromFile(_historyFileName);

      if (jsonString == null || jsonString.isEmpty) {
        print('📁 History file is empty or doesn\'t exist');
        return [];
      }

      print('📁 History file content length: ${jsonString.length} characters');
      final List<dynamic> jsonList = json.decode(jsonString);
      print('📁 Decoded ${jsonList.length} recordings from history');

      // Get current app docs dir for path correction
      final appDocDir = await getApplicationDocumentsDirectory();
      final currentDocsPath = appDocDir.path;

      return jsonList.map((json) {
        final recording = Recording.fromJson(json);

        // Fix path if needed (iOS sandbox container ID changes on reinstall/rebuild)
        if (Platform.isIOS) {
          return _fixRecordingPath(recording, currentDocsPath);
        }

        return recording;
      }).toList();
    } catch (e) {
      print('❌ Error reading recording history: $e');
      return [];
    }
  }

  /// Fix recording path if it points to an old container
  Recording _fixRecordingPath(Recording recording, String currentDocsPath) {
    // If file exists at current path, no fix needed
    final file = File(recording.filePath);
    if (file.existsSync()) {
      return recording;
    }

    // Try to construct new path
    // Assumption: files are stored in documents/recordings/ or similar
    if (recording.filePath.contains('/Documents/')) {
      final parts = recording.filePath.split('/Documents/');
      if (parts.length > 1) {
        final relativePath = parts.last;
        final newPath = '$currentDocsPath/$relativePath';

        final newFile = File(newPath);
        if (newFile.existsSync()) {
          print('🔧 Fixed path for ${recording.id}:');
          print('  Old: ${recording.filePath}');
          print('  New: $newPath');

          return Recording(
            id: recording.id,
            filePath: newPath,
            timestamp: recording.timestamp,
            durationSeconds: recording.durationSeconds,
            fileType: recording.fileType,
            transcriptionId: recording.transcriptionId,
            transcriptionFilePath: recording.transcriptionFilePath,
            transcriptionSegmentCount: recording.transcriptionSegmentCount,
            hasTranscription: recording.hasTranscription,
            isFlagged: recording.isFlagged,
          );
        }
      }
    }

    return recording;
  }

  /// Save the entire history list to storage
  Future<void> _saveHistory(List<Recording> history) async {
    try {
      final jsonString =
          json.encode(history.map((recording) => recording.toJson()).toList());
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
