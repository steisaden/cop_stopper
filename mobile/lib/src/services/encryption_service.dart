import 'dart:convert';
import 'dart:typed_data';

// A very basic AES implementation for demonstration.
// In a real application, use a well-vetted cryptographic library.
class EncryptionService {
  // This is a dummy key for demonstration purposes.
  // In a real application, this key must be securely generated and stored.
  static const String _aesKey = 'ThisIsAStrongAndSecureKeyForAES256Encryption!';

  // Simple XOR-based encryption for demonstration. NOT secure for production.
  Uint8List _xorEncrypt(Uint8List data, Uint8List key) {
    Uint8List encrypted = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ key[i % key.length];
    }
    return encrypted;
  }

  String encrypt(String plaintext) {
    final keyBytes = Uint8List.fromList(utf8.encode(_aesKey));
    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    final encryptedBytes = _xorEncrypt(plaintextBytes, keyBytes);
    return base64.encode(encryptedBytes);
  }

  String decrypt(String ciphertext) {
    final keyBytes = Uint8List.fromList(utf8.encode(_aesKey));
    final encryptedBytes = base64.decode(ciphertext);
    final decryptedBytes = _xorEncrypt(encryptedBytes, keyBytes);
    return utf8.decode(decryptedBytes);
  }
}