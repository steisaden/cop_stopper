import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';

/// Abstract interface for recording services
abstract class RecordingService {
  bool get isRecording;
  String? get currentRecordingId;

  /// Stream of raw audio data for real-time processing
  Stream<Uint8List>? get audioStream;

  Future<void> startAudioRecording({String? recordingId});
  Future<String?> stopAudioRecording();
  Future<void> startVideoRecording();
  Future<String?> stopVideoRecording();
  Future<void> startAudioVideoRecording({String? recordingId});
  Future<String?> stopAudioVideoRecording();

  /// Set camera controller from external source
  void setCameraController(CameraController? controller);
}
