import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/models/transcription_result_model.dart';

void main() {
  group('TranscriptionResult', () {
    test('fromJson creates a valid TranscriptionResult object', () {
      final json = {
        'id': 'trans123',
        'recordingId': 'rec456',
        'transcriptionText': 'This is a test transcription.',
        'timestamp': '2025-08-16T10:05:00.000Z',
        'confidence': 0.95,
      };
      final transcriptionResult = TranscriptionResult.fromJson(json);

      expect(transcriptionResult.id, 'trans123');
      expect(transcriptionResult.recordingId, 'rec456');
      expect(transcriptionResult.transcriptionText, 'This is a test transcription.');
      expect(transcriptionResult.timestamp, DateTime.parse('2025-08-16T10:05:00.000Z'));
      expect(transcriptionResult.confidence, 0.95);
    });

    test('toJson converts TranscriptionResult object to JSON', () {
      final transcriptionResult = TranscriptionResult(
        id: 'trans123',
        recordingId: 'rec456',
        transcriptionText: 'This is a test transcription.',
        timestamp: DateTime.parse('2025-08-16T10:05:00.000Z'),
        confidence: 0.95,
      );
      final json = transcriptionResult.toJson();

      expect(json['id'], 'trans123');
      expect(json['recordingId'], 'rec456');
      expect(json['transcriptionText'], 'This is a test transcription.');
      expect(json['timestamp'], '2025-08-16T10:05:00.000Z');
      expect(json['confidence'], 0.95);
    });

    test('validate throws ArgumentError for empty transcriptionText', () {
      final transcriptionResult = TranscriptionResult(
        id: 'trans123',
        recordingId: 'rec456',
        transcriptionText: '',
        timestamp: DateTime.now(),
        confidence: 0.95,
      );
      expect(() => transcriptionResult.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate throws ArgumentError for invalid confidence (less than 0)', () {
      final transcriptionResult = TranscriptionResult(
        id: 'trans123',
        recordingId: 'rec456',
        transcriptionText: 'Test',
        timestamp: DateTime.now(),
        confidence: -0.1,
      );
      expect(() => transcriptionResult.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate throws ArgumentError for invalid confidence (greater than 1)', () {
      final transcriptionResult = TranscriptionResult(
        id: 'trans123',
        recordingId: 'rec456',
        transcriptionText: 'Test',
        timestamp: DateTime.now(),
        confidence: 1.1,
      );
      expect(() => transcriptionResult.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate does not throw for valid TranscriptionResult', () {
      final transcriptionResult = TranscriptionResult(
        id: 'trans123',
        recordingId: 'rec456',
        transcriptionText: 'Test',
        timestamp: DateTime.now(),
        confidence: 0.95,
      );
      expect(() => transcriptionResult.validate(), returnsNormally);
    });
  });
}