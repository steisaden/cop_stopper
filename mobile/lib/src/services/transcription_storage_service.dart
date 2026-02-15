import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';

/// Service for persisting and loading transcription segments
class TranscriptionStorageService {
  static const String _transcriptionDirName = 'transcriptions';

  /// Get the transcriptions directory
  Future<Directory> _getTranscriptionsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final transcriptionsDir =
        Directory('${appDocDir.path}/$_transcriptionDirName');

    if (!await transcriptionsDir.exists()) {
      await transcriptionsDir.create(recursive: true);
    }

    return transcriptionsDir;
  }

  /// Get the file path for a recording's transcription
  Future<String> getTranscriptionFilePath(String recordingId) async {
    final dir = await _getTranscriptionsDirectory();
    return '${dir.path}/transcription_$recordingId.json';
  }

  /// Save transcription segments for a recording
  Future<void> saveTranscription(
    String recordingId,
    List<TranscriptionSegment> segments,
  ) async {
    try {
      if (segments.isEmpty) {
        debugPrint('No segments to save for recording $recordingId');
        return;
      }

      final filePath = await getTranscriptionFilePath(recordingId);
      final file = File(filePath);

      // Convert segments to JSON
      final jsonList = segments.map((segment) => segment.toJson()).toList();
      final jsonString = jsonEncode({
        'recordingId': recordingId,
        'segmentCount': segments.length,
        'savedAt': DateTime.now().toIso8601String(),
        'segments': jsonList,
      });

      // Write to file
      await file.writeAsString(jsonString);

      debugPrint(
          '✅ Saved ${segments.length} transcription segments for recording $recordingId');
    } catch (e) {
      debugPrint('❌ Error saving transcription: $e');
      rethrow;
    }
  }

  /// Load transcription segments for a recording
  Future<List<TranscriptionSegment>> loadTranscription(
      String recordingId) async {
    try {
      final filePath = await getTranscriptionFilePath(recordingId);
      final file = File(filePath);

      if (!await file.exists()) {
        debugPrint('No transcription file found for recording $recordingId');
        return [];
      }

      // Read and parse JSON
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final segmentsList = jsonData['segments'] as List<dynamic>;
      final segments = segmentsList
          .map((json) =>
              TranscriptionSegment.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
          '✅ Loaded ${segments.length} transcription segments for recording $recordingId');
      return segments;
    } catch (e) {
      debugPrint('❌ Error loading transcription: $e');
      return [];
    }
  }

  /// Check if a recording has a transcription
  Future<bool> hasTranscription(String recordingId) async {
    try {
      final filePath = await getTranscriptionFilePath(recordingId);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking transcription existence: $e');
      return false;
    }
  }

  /// Delete transcription for a recording
  Future<void> deleteTranscription(String recordingId) async {
    try {
      final filePath = await getTranscriptionFilePath(recordingId);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Deleted transcription for recording $recordingId');
      }
    } catch (e) {
      debugPrint('❌ Error deleting transcription: $e');
      rethrow;
    }
  }

  /// Get transcription metadata without loading all segments
  Future<Map<String, dynamic>?> getTranscriptionMetadata(
      String recordingId) async {
    try {
      final filePath = await getTranscriptionFilePath(recordingId);
      final file = File(filePath);

      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return {
        'recordingId': jsonData['recordingId'],
        'segmentCount': jsonData['segmentCount'],
        'savedAt': jsonData['savedAt'],
      };
    } catch (e) {
      debugPrint('Error getting transcription metadata: $e');
      return null;
    }
  }

  /// Get full text from transcription (without loading full segments)
  Future<String> getFullText(String recordingId) async {
    try {
      final segments = await loadTranscription(recordingId);
      if (segments.isEmpty) return '';

      return segments.map((s) => s.text).join(' ');
    } catch (e) {
      debugPrint('Error getting full text: $e');
      return '';
    }
  }

  /// Clear all transcriptions
  Future<void> clearAllTranscriptions() async {
    try {
      final dir = await _getTranscriptionsDirectory();

      if (await dir.exists()) {
        await dir.delete(recursive: true);
        debugPrint('✅ Cleared all transcriptions');
      }
    } catch (e) {
      debugPrint('❌ Error clearing transcriptions: $e');
      rethrow;
    }
  }
}
