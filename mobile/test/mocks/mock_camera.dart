import 'package:camera/camera.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/widgets.dart';

// Mock CameraDescription
class MockCameraDescription extends Mock implements CameraDescription {}

// Mock CameraController
class MockCameraController extends Mock implements CameraController {
  @override
  Future<void> initialize() => super.noSuchMethod(
        Invocation.method(#initialize, []), 
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  Future<XFile> takePicture() => super.noSuchMethod(
        Invocation.method(#takePicture, []), 
        returnValue: Future.value(XFile('mock_picture.jpg')),
        returnValueForMissingStub: Future.value(XFile('mock_picture.jpg')),
      );

  @override
  Future<XFile> stopVideoRecording() => super.noSuchMethod(
        Invocation.method(#stopVideoRecording, []), 
        returnValue: Future.value(XFile('mock_video.mp4')),
        returnValueForMissingStub: Future.value(XFile('mock_video.mp4')),
      );

  @override
  Future<void> startVideoRecording() => super.noSuchMethod(
        Invocation.method(#startVideoRecording, []), 
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  Future<void> dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []), 
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  CameraControllerValue get value => super.noSuchMethod(
        Invocation.getter(#value),
        returnValue: CameraControllerValue(
          isInitialized: true,
          errorDescription: null,
          isRecordingVideo: false,
          isRecordingPaused: false,
          isTakingPicture: false,
          isStreamingImages: false,
          flashMode: FlashMode.auto,
          exposureMode: ExposureMode.auto,
          focusMode: FocusMode.auto,
          deviceOrientation: DeviceOrientation.portraitUp,
          lockedCaptureOrientation: null,
          isPreviewPaused: false,
          minZoomLevel: 1.0,
          maxZoomLevel: 1.0,
          exposureOffset: 0.0,
          supportedHardwareLevel: HardwareLevel.full,
          sensorOrientation: 0,
        ),
        returnValueForMissingStub: CameraControllerValue(
          isInitialized: true,
          errorDescription: null,
          isRecordingVideo: false,
          isRecordingPaused: false,
          isTakingPicture: false,
          isStreamingImages: false,
          flashMode: FlashMode.auto,
          exposureMode: ExposureMode.auto,
          focusMode: FocusMode.auto,
          deviceOrientation: DeviceOrientation.portraitUp,
          lockedCaptureOrientation: null,
          isPreviewPaused: false,
          minZoomLevel: 1.0,
          maxZoomLevel: 1.0,
          exposureOffset: 0.0,
          supportedHardwareLevel: HardwareLevel.full,
          sensorOrientation: 0,
        ),
      );
}

// Mock availableCameras function
Future<List<CameraDescription>> mockAvailableCameras() async {
  return [MockCameraDescription()];
}
