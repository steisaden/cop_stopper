import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Manages Whisper model selection and information
class WhisperModelManager {
  // Use tiny.en by default for faster downloads and smaller footprint
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
      return ['base.en'];
    }
    return [];
  }
  
  static Future<void> downloadModel(String modelName) async {
    if (await isModelDownloaded()) return;
    
    debugPrint('Downloading Whisper model...');
    final response = await http.get(Uri.parse(_modelUrl));
    
    if (response.statusCode == 200) {
      final file = File(await _modelPath);
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('Whisper model downloaded successfully');
    } else {
      throw Exception('Failed to download model: ${response.statusCode}');
    }
  }
  
  static Future<void> deleteModel(String modelName) async {
    final filePath = await _modelPath;
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
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
