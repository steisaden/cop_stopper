import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/models/document_model.dart';

void main() {
  group('Document', () {
    test('fromJson creates a valid Document object', () {
      final json = {
        'id': 'doc123',
        'title': 'My Important Document',
        'filePath': '/path/to/document.pdf',
        'uploadDate': '2025-08-16T12:00:00.000Z',
        'expirationDate': '2026-08-16T12:00:00.000Z',
        'description': 'A description of the document.',
      };
      final document = Document.fromJson(json);

      expect(document.id, 'doc123');
      expect(document.title, 'My Important Document');
      expect(document.filePath, '/path/to/document.pdf');
      expect(document.uploadDate, DateTime.parse('2025-08-16T12:00:00.000Z'));
      expect(document.expirationDate, DateTime.parse('2026-08-16T12:00:00.000Z'));
      expect(document.description, 'A description of the document.');
    });

    test('toJson converts Document object to JSON', () {
      final document = Document(
        id: 'doc123',
        title: 'My Important Document',
        filePath: '/path/to/document.pdf',
        uploadDate: DateTime.parse('2025-08-16T12:00:00.000Z'),
        expirationDate: DateTime.parse('2026-08-16T12:00:00.000Z'),
        description: 'A description of the document.',
      );
      final json = document.toJson();

      expect(json['id'], 'doc123');
      expect(json['title'], 'My Important Document');
      expect(json['filePath'], '/path/to/document.pdf');
      expect(json['uploadDate'], '2025-08-16T12:00:00.000Z');
      expect(json['expirationDate'], '2026-08-16T12:00:00.000Z');
      expect(json['description'], 'A description of the document.');
    });

    test('validate throws ArgumentError for empty title', () {
      final document = Document(
        id: 'doc123',
        title: '',
        filePath: '/path/to/document.pdf',
        uploadDate: DateTime.now(),
      );
      expect(() => document.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate throws ArgumentError for empty filePath', () {
      final document = Document(
        id: 'doc123',
        title: 'My Document',
        filePath: '',
        uploadDate: DateTime.now(),
      );
      expect(() => document.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate does not throw for valid Document', () {
      final document = Document(
        id: 'doc123',
        title: 'My Document',
        filePath: '/path/to/document.pdf',
        uploadDate: DateTime.now(),
      );
      expect(() => document.validate(), returnsNormally);
    });
  });
}