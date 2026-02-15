import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Manages Whisper model selection and information
class WhisperModelManager {
  // Use tiny.en for faster inference (~75MB)
  static const String _modelUrl =
      'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin';
  static const String _modelFileName = 'ggml-tiny.en.bin';
  static const String _envModelPathKey = 'WHISPER_MODEL_PATH';

  static Future<String> get _modelPath async {
    // Allow overriding model location via environment variable for pre-seeded installs.
    final envPath = Platform.environment[_envModelPathKey];
    if (envPath != null && envPath.isNotEmpty && await File(envPath).exists()) {
      return envPath;
    }

    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, _modelFileName);
  }

  static Future<bool> isModelDownloaded() async {
    final path = await _modelPath;
    return File(path).exists();
  }

  static Future<List<String>> getDownloadedModels() async {
    if (await isModelDownloaded()) {
      return ['tiny.en'];
    }
    return [];
  }

  static Future<String> recommendModel() async {
    return 'tiny.en';
  }

  static Future<void> downloadModel(
    String modelName, {
    Function(double)? onProgress,
    Function(String)? onStatusUpdate,
  }) async {
    if (await isModelDownloaded()) return;

    debugPrint('Downloading Whisper model...');
    onStatusUpdate?.call('Starting download...');

    try {
      final request = http.Request('GET', Uri.parse(_modelUrl));
      final response = await request.send();

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        final file = File(await _modelPath);
        final sink = file.openWrite();

        int bytesReceived = 0;
        int lastProgressUpdate = 0;

        await for (var chunk in response.stream) {
          sink.add(chunk);
          bytesReceived += chunk.length;

          if (contentLength > 0 && onProgress != null) {
            final progress = bytesReceived / contentLength;
            // Throttle updates to avoid state flooding
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - lastProgressUpdate > 100) {
              onProgress(progress);
              lastProgressUpdate = now;
            }
          }
        }

        await sink.close();
        debugPrint('Whisper model downloaded successfully');
        onStatusUpdate?.call('Download complete');
      } else {
        throw Exception(
            'Failed to download model: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Download error: $e');
      rethrow;
    }
  }

  static Future<void> deleteModel() async {
    final filePath = await _modelPath;
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      debugPrint('Whisper model deleted');
    }
  }

  static Future<Map<String, dynamic>> getModelInfo(String modelName) async {
    final filePath = await _modelPath;
    final file = File(filePath);
    int size = 0;
    if (await file.exists()) {
      size = await file.length();
    }

    return {
      'name': modelName,
      'size': size,
      'description': 'Whisper base.en model for on-device transcription',
      'isDownloaded': size > 0,
    };
  }

  static Future<String> getModelPath() async {
    return _modelPath;
  }
}

/// Model information stub
class ModelInfo {
  final String name;
  final int size;
  final String description;

  const ModelInfo({
    required this.name,
    required this.size,
    required this.description,
  });
}
