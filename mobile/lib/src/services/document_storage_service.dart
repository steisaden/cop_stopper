import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'encryption_service.dart';

/// Model class for secure document metadata.
class SecureDocumentMetadata {
  final String id;
  final String name;
  final String type;
  final String encryptedFilePath;
  final DateTime uploadDate;
  final DateTime? expirationDate;
  final int fileSizeBytes;
  final String mimeType;
  final String checksum;

  SecureDocumentMetadata({
    required this.id,
    required this.name,
    required this.type,
    required this.encryptedFilePath,
    required this.uploadDate,
    this.expirationDate,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'encryptedFilePath': encryptedFilePath,
        'uploadDate': uploadDate.toIso8601String(),
        'expirationDate': expirationDate?.toIso8601String(),
        'fileSizeBytes': fileSizeBytes,
        'mimeType': mimeType,
        'checksum': checksum,
      };

  factory SecureDocumentMetadata.fromJson(Map<String, dynamic> json) {
    return SecureDocumentMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      encryptedFilePath: json['encryptedFilePath'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      fileSizeBytes: json['fileSizeBytes'] as int,
      mimeType: json['mimeType'] as String,
      checksum: json['checksum'] as String,
    );
  }

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024)
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Service for secure document storage with AES-256-GCM encryption.
///
/// Security features:
/// - All documents encrypted at rest with AES-256-GCM
/// - Metadata stored in Keychain/Keystore
/// - Secure deletion with file overwrite
/// - Biometric authentication enforced at UI level
class DocumentStorageService {
  static const String _metadataStorageKey = 'secure_documents_metadata';
  static const String _documentsFolder = 'secure_documents';

  final EncryptionService _encryptionService;
  final FlutterSecureStorage _secureStorage;

  List<SecureDocumentMetadata>? _cachedMetadata;

  DocumentStorageService({
    required EncryptionService encryptionService,
  })  : _encryptionService = encryptionService,
        _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device),
        );

  /// Initialize the service and ensure storage directory exists.
  Future<void> initialize() async {
    await _encryptionService.initialize();
    await _getSecureDocumentsDirectory();
  }

  /// Get the secure documents directory path.
  Future<Directory> _getSecureDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final secureDir = Directory(path.join(appDir.path, _documentsFolder));
    if (!await secureDir.exists()) {
      await secureDir.create(recursive: true);
    }
    return secureDir;
  }

  /// Store a document securely with encryption.
  /// Returns the metadata of the stored document.
  Future<SecureDocumentMetadata> storeDocument({
    required String name,
    required String type,
    required Uint8List fileData,
    required String mimeType,
    DateTime? expirationDate,
  }) async {
    // Generate unique ID
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Calculate checksum before encryption
    final checksum = _calculateChecksum(fileData);

    // Encrypt the file data
    final encryptedData = await _encryptionService.encryptBytes(fileData);

    // Get storage path
    final secureDir = await _getSecureDocumentsDirectory();
    final encryptedFilePath = path.join(secureDir.path, '$id.enc');

    // Write encrypted file
    final encryptedFile = File(encryptedFilePath);
    await encryptedFile.writeAsBytes(encryptedData);

    // Create metadata
    final metadata = SecureDocumentMetadata(
      id: id,
      name: name,
      type: type,
      encryptedFilePath: encryptedFilePath,
      uploadDate: DateTime.now(),
      expirationDate: expirationDate,
      fileSizeBytes: fileData.length,
      mimeType: mimeType,
      checksum: checksum,
    );

    // Save metadata
    await _addMetadata(metadata);

    return metadata;
  }

  /// Retrieve and decrypt a document by ID.
  Future<Uint8List?> retrieveDocument(String documentId) async {
    final metadata = await getDocumentMetadata(documentId);
    if (metadata == null) return null;

    final encryptedFile = File(metadata.encryptedFilePath);
    if (!await encryptedFile.exists()) return null;

    final encryptedData = await encryptedFile.readAsBytes();
    final decryptedData = await _encryptionService.decryptBytes(encryptedData);

    // Verify checksum
    final calculatedChecksum = _calculateChecksum(decryptedData);
    if (calculatedChecksum != metadata.checksum) {
      throw Exception(
          'Document integrity check failed - data may be corrupted');
    }

    return decryptedData;
  }

  /// Delete a document securely with file overwrite.
  Future<void> deleteDocument(String documentId) async {
    final metadata = await getDocumentMetadata(documentId);
    if (metadata == null) return;

    final encryptedFile = File(metadata.encryptedFilePath);
    if (await encryptedFile.exists()) {
      // Secure deletion: overwrite with random data before deleting
      final fileSize = await encryptedFile.length();
      final randomData = Uint8List(fileSize);
      for (int i = 0; i < fileSize; i++) {
        randomData[i] = DateTime.now().microsecondsSinceEpoch % 256;
      }
      await encryptedFile.writeAsBytes(randomData);
      await encryptedFile.delete();
    }

    // Remove metadata
    await _removeMetadata(documentId);
  }

  /// Get all document metadata.
  Future<List<SecureDocumentMetadata>> getAllDocuments() async {
    if (_cachedMetadata != null) return _cachedMetadata!;

    final metadataJson = await _secureStorage.read(key: _metadataStorageKey);
    if (metadataJson == null) {
      _cachedMetadata = [];
      return _cachedMetadata!;
    }

    final List<dynamic> metadataList = jsonDecode(metadataJson);
    _cachedMetadata = metadataList
        .map((json) =>
            SecureDocumentMetadata.fromJson(json as Map<String, dynamic>))
        .toList();

    return _cachedMetadata!;
  }

  /// Get a specific document's metadata by ID.
  Future<SecureDocumentMetadata?> getDocumentMetadata(String documentId) async {
    final allDocs = await getAllDocuments();
    try {
      return allDocs.firstWhere((doc) => doc.id == documentId);
    } catch (e) {
      return null;
    }
  }

  /// Add metadata to storage.
  Future<void> _addMetadata(SecureDocumentMetadata metadata) async {
    final allDocs = await getAllDocuments();
    allDocs.add(metadata);
    await _saveAllMetadata(allDocs);
  }

  /// Remove metadata from storage.
  Future<void> _removeMetadata(String documentId) async {
    final allDocs = await getAllDocuments();
    allDocs.removeWhere((doc) => doc.id == documentId);
    await _saveAllMetadata(allDocs);
  }

  /// Save all metadata to secure storage.
  Future<void> _saveAllMetadata(List<SecureDocumentMetadata> metadata) async {
    _cachedMetadata = metadata;
    final metadataJson = jsonEncode(metadata.map((m) => m.toJson()).toList());
    await _secureStorage.write(key: _metadataStorageKey, value: metadataJson);
  }

  /// Calculate a simple checksum for integrity verification.
  String _calculateChecksum(Uint8List data) {
    int sum = 0;
    for (final byte in data) {
      sum = (sum + byte) & 0xFFFFFFFF;
    }
    return sum.toRadixString(16).padLeft(8, '0');
  }

  /// Delete all documents and metadata (emergency wipe).
  Future<void> deleteAllDocuments() async {
    final allDocs = await getAllDocuments();
    for (final doc in allDocs) {
      await deleteDocument(doc.id);
    }
    await _encryptionService.destroyMasterKey();
  }

  /// Check if any documents exist.
  Future<bool> hasDocuments() async {
    final docs = await getAllDocuments();
    return docs.isNotEmpty;
  }

  /// Get documents that are expiring within the given number of days.
  Future<List<SecureDocumentMetadata>> getExpiringDocuments(
      int withinDays) async {
    final docs = await getAllDocuments();
    final now = DateTime.now();
    final threshold = now.add(Duration(days: withinDays));

    return docs.where((doc) {
      if (doc.expirationDate == null) return false;
      return doc.expirationDate!.isBefore(threshold) &&
          doc.expirationDate!.isAfter(now);
    }).toList();
  }
}
