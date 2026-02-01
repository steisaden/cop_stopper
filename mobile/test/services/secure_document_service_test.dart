
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/encryption_service.dart';
import 'package:mobile/src/services/secure_document_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Add this line

  // Define MethodChannel for flutter_secure_storage
  const MethodChannel secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  // Define MethodChannel for local_auth
  const MethodChannel localAuthChannel = MethodChannel('plugins.flutter.io/local_auth');

  group('EncryptionService', () {
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
    });

    test('encrypts and decrypts text correctly', () {
      const plaintext = 'This is a secret message.';
      final encryptedText = encryptionService.encrypt(plaintext);
      final decryptedText = encryptionService.decrypt(encryptedText);
      expect(decryptedText, plaintext);
    });

    test('encrypts different text to different ciphertexts', () {
      const plaintext1 = 'Message one';
      const plaintext2 = 'Message two';
      final encryptedText1 = encryptionService.encrypt(plaintext1);
      final encryptedText2 = encryptionService.encrypt(plaintext2);
      expect(encryptedText1, isNot(equals(encryptedText2)));
    });
  });

  group('SecureDocumentService', () {
    late SecureDocumentService secureDocumentService;
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();

      // Register mocks with GetIt
      GetIt.I.registerSingleton<EncryptionService>(encryptionService);

      secureDocumentService = SecureDocumentService();

      // Generate a valid encrypted value for mocking read operations
      final validEncryptedValue = encryptionService.encrypt('testValue');

      // Mock platform channels
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(secureStorageChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'write':
            return null;
          case 'read':
            return validEncryptedValue; // Return a valid encrypted value
          case 'delete':
            return null;
          case 'deleteAll':
            return null;
          default:
            return null;
        }
      });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(localAuthChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'authenticate':
            return true; // Default to successful authentication
          case 'canCheckBiometrics':
            return true; // Default to biometrics available
          case 'getAvailableBiometrics':
            return ['fingerprint']; // Return available biometric types
          default:
            return null;
        }
      });
    });

    tearDown(() {
      GetIt.I.reset(); // Reset GetIt after each test
      // Reset mock method call handlers
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(secureStorageChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(localAuthChannel, null);
    });

    test('writes and reads secure data correctly', () async {
      const key = 'testKey';
      const value = 'testValue';

      await secureDocumentService.writeSecureData(key, value);
      final readValue = await secureDocumentService.readSecureData(key);

      expect(readValue, value);
    });

    test('deletes secure data correctly', () async {
      const key = 'testKey';
      await secureDocumentService.deleteSecureData(key);
    });

    test('deletes all secure data correctly', () async {
      await secureDocumentService.deleteAllSecureData();
    });

    test('authenticates with biometrics successfully', () async {
      final authenticated = await secureDocumentService.authenticateWithBiometrics();
      expect(authenticated, true);
    });

    test('biometric authentication fails when not available', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(localAuthChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'canCheckBiometrics':
            return false; // Simulate biometrics not available
          case 'getAvailableBiometrics':
            return []; // No biometrics available
          default:
            return null;
        }
      });

      final authenticated = await secureDocumentService.authenticateWithBiometrics();
      expect(authenticated, false);
    });

    test('biometric authentication fails on authentication error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(localAuthChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'authenticate':
            throw PlatformException(code: 'AUTH_FAILED', message: 'Authentication failed');
          case 'canCheckBiometrics':
            return true;
          case 'getAvailableBiometrics':
            return ['fingerprint'];
          default:
            return null;
        }
      });

      final authenticated = await secureDocumentService.authenticateWithBiometrics();
      expect(authenticated, false);
    });
  });
}