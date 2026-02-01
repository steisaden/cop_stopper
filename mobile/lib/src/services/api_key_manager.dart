import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Secure API key management with encryption and rotation
class ApiKeyManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      // accessibility: IOSAccessibility.first_unlock_this_device, // Commented out - not available
    ),
  );

  final String serviceName;
  final Duration keyRotationInterval;

  ApiKeyManager({
    required this.serviceName,
    this.keyRotationInterval = const Duration(days: 30),
  });

  /// Store an API key securely
  Future<void> storeApiKey(String apiKey) async {
    final keyData = {
      'key': apiKey,
      'created_at': DateTime.now().toIso8601String(),
      'service': serviceName,
    };

    await _storage.write(
      key: _getKeyName(),
      value: jsonEncode(keyData),
    );
  }

  /// Retrieve the current API key
  Future<String?> getApiKey() async {
    try {
      final keyDataJson = await _storage.read(key: _getKeyName());
      if (keyDataJson == null) return null;

      final keyData = jsonDecode(keyDataJson) as Map<String, dynamic>;
      final createdAt = DateTime.parse(keyData['created_at'] as String);
      
      // Check if key needs rotation
      if (DateTime.now().difference(createdAt) > keyRotationInterval) {
        await _rotateApiKey();
        return await getApiKey(); // Recursive call to get new key
      }

      return keyData['key'] as String;
    } catch (e) {
      print('Error retrieving API key: $e');
      return null;
    }
  }

  /// Rotate the API key (placeholder - would integrate with actual key rotation service)
  Future<void> _rotateApiKey() async {
    // In production, this would call the API provider's key rotation endpoint
    print('API key rotation needed for $serviceName');
    // For now, just update the timestamp to prevent constant rotation attempts
    final currentKey = await _getCurrentKeyData();
    if (currentKey != null) {
      currentKey['rotation_attempted'] = DateTime.now().toIso8601String();
      await _storage.write(
        key: _getKeyName(),
        value: jsonEncode(currentKey),
      );
    }
  }

  /// Get current key data without validation
  Future<Map<String, dynamic>?> _getCurrentKeyData() async {
    try {
      final keyDataJson = await _storage.read(key: _getKeyName());
      if (keyDataJson == null) return null;
      return jsonDecode(keyDataJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Delete the stored API key
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _getKeyName());
  }

  /// Check if an API key is stored
  Future<bool> hasApiKey() async {
    return await _storage.containsKey(key: _getKeyName());
  }

  /// Validate API key format (basic validation)
  bool validateKeyFormat(String apiKey) {
    // Basic validation - adjust based on specific API requirements
    return apiKey.isNotEmpty && 
           apiKey.length >= 16 && 
           !apiKey.contains(' ');
  }

  /// Generate a hash of the API key for logging (never log the actual key)
  String hashApiKey(String apiKey) {
    final bytes = utf8.encode(apiKey);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 8); // First 8 characters of hash
  }

  String _getKeyName() => 'api_key_$serviceName';

  /// Get key metadata without exposing the actual key
  Future<Map<String, dynamic>?> getKeyMetadata() async {
    final keyData = await _getCurrentKeyData();
    if (keyData == null) return null;

    return {
      'service': keyData['service'],
      'created_at': keyData['created_at'],
      'has_key': true,
      'key_hash': hashApiKey(keyData['key'] as String),
    };
  }
}

/// Factory for creating API key managers for different services
class ApiKeyManagerFactory {
  static final Map<String, ApiKeyManager> _managers = {};

  static ApiKeyManager getManager(String serviceName) {
    return _managers.putIfAbsent(
      serviceName,
      () => ApiKeyManager(serviceName: serviceName),
    );
  }

  /// Initialize API keys for all supported services
  static Future<void> initializeAllKeys(Map<String, String> apiKeys) async {
    for (final entry in apiKeys.entries) {
      final manager = getManager(entry.key);
      await manager.storeApiKey(entry.value);
    }
  }

  /// Check status of all API keys
  static Future<Map<String, Map<String, dynamic>?>> getAllKeyStatus() async {
    final status = <String, Map<String, dynamic>?>{};
    
    for (final entry in _managers.entries) {
      status[entry.key] = await entry.value.getKeyMetadata();
    }
    
    return status;
  }
}