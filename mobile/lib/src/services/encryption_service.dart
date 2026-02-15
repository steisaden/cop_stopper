import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Industry-standard AES-256-GCM encryption service for sensitive documents.
///
/// Security features:
/// - AES-256-GCM (authenticated encryption with associated data)
/// - PBKDF2 key derivation with 100,000 iterations
/// - Unique IV per encryption operation
/// - Encryption key stored in platform Keychain/Keystore
class EncryptionService {
  static const String _masterKeyStorageKey = 'encryption_master_key';
  static const String _saltStorageKey = 'encryption_salt';
  static const int _pbkdf2Iterations = 100000;
  static const int _keyLengthBits = 256;
  static const int _ivLengthBytes = 12; // GCM recommended IV size

  final FlutterSecureStorage _secureStorage;
  final AesGcm _aesGcm;

  SecretKey? _cachedKey;

  EncryptionService()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        ),
        _aesGcm = AesGcm.with256bits();

  /// Initialize the encryption service and ensure master key exists.
  Future<void> initialize() async {
    await _getOrCreateMasterKey();
  }

  /// Encrypts string data and returns base64-encoded ciphertext with IV prepended.
  Future<String> encrypt(String plaintext) async {
    final plaintextBytes = utf8.encode(plaintext);
    final encryptedBytes =
        await encryptBytes(Uint8List.fromList(plaintextBytes));
    return base64.encode(encryptedBytes);
  }

  /// Decrypts base64-encoded ciphertext and returns the original string.
  Future<String> decrypt(String ciphertext) async {
    final encryptedBytes = base64.decode(ciphertext);
    final decryptedBytes =
        await decryptBytes(Uint8List.fromList(encryptedBytes));
    return utf8.decode(decryptedBytes);
  }

  /// Encrypts raw bytes and returns encrypted bytes with IV prepended.
  /// Format: [IV (12 bytes)][Ciphertext][Auth Tag (16 bytes)]
  Future<Uint8List> encryptBytes(Uint8List plaintext) async {
    final secretKey = await _getOrCreateMasterKey();

    // Generate a unique IV for each encryption
    final nonce = _aesGcm.newNonce();

    // Encrypt with AES-256-GCM
    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonce,
    );

    // Combine IV + ciphertext + MAC into single byte array
    final result = Uint8List(
      nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length,
    );

    int offset = 0;
    result.setRange(offset, offset + nonce.length, nonce);
    offset += nonce.length;
    result.setRange(
        offset, offset + secretBox.cipherText.length, secretBox.cipherText);
    offset += secretBox.cipherText.length;
    result.setRange(
        offset, offset + secretBox.mac.bytes.length, secretBox.mac.bytes);

    return result;
  }

  /// Decrypts raw bytes (with IV prepended) and returns the original bytes.
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    final secretKey = await _getOrCreateMasterKey();

    // Extract IV, ciphertext, and MAC
    final nonce = encryptedData.sublist(0, _ivLengthBytes);
    final cipherTextWithMac = encryptedData.sublist(_ivLengthBytes);
    final cipherText =
        cipherTextWithMac.sublist(0, cipherTextWithMac.length - 16);
    final mac = Mac(cipherTextWithMac.sublist(cipherTextWithMac.length - 16));

    // Decrypt with AES-256-GCM
    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: mac,
    );

    final decrypted = await _aesGcm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return Uint8List.fromList(decrypted);
  }

  /// Securely deletes the master key (for emergency wipe).
  Future<void> destroyMasterKey() async {
    _cachedKey = null;
    await _secureStorage.delete(key: _masterKeyStorageKey);
    await _secureStorage.delete(key: _saltStorageKey);
  }

  /// Gets or creates the master encryption key using PBKDF2.
  Future<SecretKey> _getOrCreateMasterKey() async {
    if (_cachedKey != null) {
      return _cachedKey!;
    }

    // Try to retrieve existing key material from secure storage
    String? storedKeyBase64 =
        await _secureStorage.read(key: _masterKeyStorageKey);

    if (storedKeyBase64 != null) {
      // Key exists - reconstruct it
      final keyBytes = base64.decode(storedKeyBase64);
      _cachedKey = SecretKey(keyBytes);
      return _cachedKey!;
    }

    // No existing key - generate new one
    // Generate cryptographically secure random salt
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: _keyLengthBits,
    );

    // Generate random salt
    final saltGenerator = AesGcm.with256bits();
    final salt = saltGenerator.newNonce(); // 12 bytes of random

    // Generate random password (device-specific entropy)
    final passwordBytes = Uint8List(32);
    for (int i = 0; i < passwordBytes.length; i++) {
      passwordBytes[i] = DateTime.now().microsecondsSinceEpoch % 256;
      await Future.delayed(
          const Duration(microseconds: 1)); // Add timing entropy
    }

    // Derive the master key using PBKDF2
    final derivedKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(passwordBytes),
      nonce: salt,
    );

    // Extract the key bytes and store securely
    final keyBytes = await derivedKey.extractBytes();
    await _secureStorage.write(
      key: _masterKeyStorageKey,
      value: base64.encode(keyBytes),
    );
    await _secureStorage.write(
      key: _saltStorageKey,
      value: base64.encode(salt),
    );

    _cachedKey = SecretKey(keyBytes);
    return _cachedKey!;
  }

  /// Validates that a piece of encrypted data can be decrypted.
  /// Returns true if decryption succeeds, false if data is corrupted or tampered.
  Future<bool> validateEncryptedData(Uint8List encryptedData) async {
    try {
      await decryptBytes(encryptedData);
      return true;
    } catch (e) {
      return false;
    }
  }
}
