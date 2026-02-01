import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';

/// Abstract interface for recording services
abstract class RecordingService {
  bool get isRecording;
  
  /// Stream of raw audio data for real-time processing
  Stream<Uint8List>? get audioStream;
  
  Future<void> startAudioRecording();
  Future<String?> stopAudioRecording();
  Future<void> startVideoRecording();
  Future<String?> stopVideoRecording();
  Future<void> startAudioVideoRecording();
  Future<String?> stopAudioVideoRecording();
  
  /// Set camera controller from external source
  void setCameraController(CameraController? controller);
}