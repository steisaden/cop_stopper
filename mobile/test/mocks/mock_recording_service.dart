import 'dart:typed_data';
import 'package:mobile/src/services/recording_service_interface.dart';

class MockRecordingService implements RecordingService {
  bool _isRecordingAudio = false;
  bool _isRecordingVideo = false;
  String? _currentRecordingId;

  @override
  bool get isRecording => _isRecordingAudio || _isRecordingVideo;

  @override
  String? get currentRecordingId => _currentRecordingId;

  @override
  Stream<Uint8List>? get audioStream => null;

  @override
  void setCameraController(dynamic controller) {}

  @override
  Future<void> startAudioRecording({String? recordingId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isRecordingAudio = true;
    _currentRecordingId =
        recordingId ?? 'mock_id_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String?> stopAudioRecording() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isRecordingAudio = false;
    _currentRecordingId = null;
    return 'mock_audio.m4a';
  }

  @override
  Future<void> startVideoRecording() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isRecordingVideo = true;
  }

  @override
  Future<String?> stopVideoRecording() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isRecordingVideo = false;
    return 'mock_video.mp4';
  }

  @override
  Future<void> startAudioVideoRecording({String? recordingId}) async {
    await startAudioRecording(recordingId: recordingId);
    await startVideoRecording();
  }

  @override
  Future<String?> stopAudioVideoRecording() async {
    await stopAudioRecording();
    final videoPath = await stopVideoRecording();
    return videoPath;
  }
}
