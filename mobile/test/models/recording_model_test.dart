import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/models/recording_model.dart';

void main() {
  group('Recording', () {
    test('fromJson creates a valid Recording object', () {
      final json = {
        'id': 'rec123',
        'filePath': '/path/to/recording.m4a',
        'timestamp': '2025-08-16T10:00:00.000Z',
        'durationSeconds': 120,
        'transcriptionId': 'trans456',
        'fileType': 'audio',
      };
      final recording = Recording.fromJson(json);

      expect(recording.id, 'rec123');
      expect(recording.filePath, '/path/to/recording.m4a');
      expect(recording.timestamp, DateTime.parse('2025-08-16T10:00:00.000Z'));
      expect(recording.durationSeconds, 120);
      expect(recording.transcriptionId, 'trans456');
      expect(recording.fileType, RecordingFileType.audio);
    });

    test('toJson converts Recording object to JSON', () {
      final recording = Recording(
        id: 'rec123',
        filePath: '/path/to/recording.m4a',
        timestamp: DateTime.parse('2025-08-16T10:00:00.000Z'),
        durationSeconds: 120,
        transcriptionId: 'trans456',
        fileType: RecordingFileType.audio,
      );
      final json = recording.toJson();

      expect(json['id'], 'rec123');
      expect(json['filePath'], '/path/to/recording.m4a');
      expect(json['timestamp'], '2025-08-16T10:00:00.000Z');
      expect(json['durationSeconds'], 120);
      expect(json['transcriptionId'], 'trans456');
      expect(json['fileType'], 'audio');
    });

    test('validate throws ArgumentError for empty filePath', () {
      final recording = Recording(
        id: 'rec123',
        filePath: '',
        timestamp: DateTime.now(),
        durationSeconds: 120,
        fileType: RecordingFileType.audio,
      );
      expect(() => recording.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate throws ArgumentError for non-positive durationSeconds', () {
      final recording = Recording(
        id: 'rec123',
        filePath: '/path/to/recording.m4a',
        timestamp: DateTime.now(),
        durationSeconds: 0,
        fileType: RecordingFileType.audio,
      );
      expect(() => recording.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate does not throw for valid Recording', () {
      final recording = Recording(
        id: 'rec123',
        filePath: '/path/to/recording.m4a',
        timestamp: DateTime.now(),
        durationSeconds: 120,
        fileType: RecordingFileType.audio,
      );
      expect(() => recording.validate(), returnsNormally);
    });
  });
}