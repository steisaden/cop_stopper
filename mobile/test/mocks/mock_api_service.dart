
import 'package:mobile/src/services/api_service.dart';

class MockApiService implements ApiService {
  @override
  Future<dynamic> get(String url) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));
    // Return a mock response
    return {'data': 'Mock data for $url'};
  }

  @override
  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));
    // Return a mock response
    return {'message': 'Mock success for $url'};
  }
}
