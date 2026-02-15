import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile/src/services/encryption_service.dart';

class SecureDocumentService {
  final FlutterSecureStorage _secureStorage;
  final EncryptionService _encryptionService;
  final LocalAuthentication _localAuth;

  SecureDocumentService()
      : _secureStorage = const FlutterSecureStorage(),
        _encryptionService = GetIt.I<EncryptionService>(),
        _localAuth = LocalAuthentication();

  Future<void> writeSecureData(String key, String value) async {
    final encryptedValue = await _encryptionService.encrypt(value);
    await _secureStorage.write(key: key, value: encryptedValue);
  }

  Future<String?> readSecureData(String key) async {
    final encryptedValue = await _secureStorage.read(key: key);
    if (encryptedValue == null) {
      return null;
    }
    return await _encryptionService.decrypt(encryptedValue);
  }

  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAllSecureData() async {
    await _secureStorage.deleteAll();
  }

  Future<bool> authenticateWithBiometrics() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return false;
    }

    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your secure documents',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      // Error during biometric authentication - handled silently in production
      return false;
    }
    return authenticated;
  }
}
