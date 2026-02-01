import 'package:record/record.dart';
import 'package:mockito/mockito.dart';

class MockRecord extends Mock implements Record {
  @override
  Future<bool> hasPermission() => super.noSuchMethod(
        Invocation.method(#hasPermission, []), 
        returnValue: Future.value(true),
        returnValueForMissingStub: Future.value(true),
      );

  @override
  Future<void> start({
    String? path,
    AudioEncoder? encoder,
    int? bitRate,
    int? samplingRate,
    int? numChannels,
    String? device,
    bool? autoGain,
    bool? echoCancellation,
    bool? noiseSuppression,
  }) =>
      super.noSuchMethod(
        Invocation.method(#start, [], {
          #path: path,
          #encoder: encoder,
          #bitRate: bitRate,
          #samplingRate: samplingRate,
          #numChannels: numChannels,
          #device: device,
          #autoGain: autoGain,
          #echoCancellation: echoCancellation,
          #noiseSuppression: noiseSuppression,
        }),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  Future<String?> stop() => super.noSuchMethod(
        Invocation.method(#stop, []), 
        returnValue: Future.value('mock_audio_path.m4a'),
        returnValueForMissingStub: Future.value('mock_audio_path.m4a'),
      );
}
