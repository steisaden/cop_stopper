
import 'package:mobile/src/services/recording_service_interface.dart';

class MockRecordingService implements RecordingService {
  bool _isRecordingAudio = false;
  bool _isRecordingVideo = false;

  @override
  bool get isRecording => _isRecordingAudio || _isRecordingVideo;

  @override
  Future<void> startAudioRecording() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isRecordingAudio = true;
  }

  @override
  Future<String?> stopAudioRecording() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isRecordingAudio = false;
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
  Future<void> startAudioVideoRecording() async {
    await startAudioRecording();
    await startVideoRecording();
  }

  @override
  Future<String?> stopAudioVideoRecording() async {
    await stopAudioRecording();
    final videoPath = await stopVideoRecording();
    return videoPath;
  }
}
