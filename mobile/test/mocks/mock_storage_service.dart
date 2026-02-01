import 'package:mobile/src/services/storage_service.dart';

class MockStorageService implements StorageService {
  bool isStorageLowResult = false;
  Function? compressOldRecordingsCallback;

  @override
  Future<int> getAvailableSpace() async {
    return 500 * 1024 * 1024; // Mock 500 MB available space
  }

  @override
  Future<bool> isStorageLow() async {
    return isStorageLowResult; // Mock storage not low
  }

  @override
  Future<void> compressOldRecordings() async {
    compressOldRecordingsCallback?.call();
  }
}