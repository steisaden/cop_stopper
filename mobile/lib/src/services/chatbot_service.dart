import '../models/legal_advice_model.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';

/// Service for handling AI-powered legal guidance
/// Communicates with backend for legal advice and manages chatbot state
class ChatbotService {
  final ApiService _apiService;
  final String _baseUrl;

  ChatbotService({required ApiService apiService, required String baseUrl})
      : _apiService = apiService,
        _baseUrl = baseUrl;

  /// Sends a query to the AI legal advisor and returns legal guidance
  Future<ApiResponse<LegalAdvice>> getLegalAdvice(String query, String jurisdiction) async {
    try {
      final response = await _apiService.post('/api/legal/advice', {
        'query': query,
        'jurisdiction': jurisdiction,
      });

      if (response['success'] == true) {
        final legalAdvice = LegalAdvice.fromJson(response['data']);
        return ApiResponse.success(legalAdvice);
      } else {
        return ApiResponse.error('Failed to get legal advice: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      return ApiResponse.error('Error getting legal advice: $e');
    }
  }

  /// Starts a new conversation session with the AI legal advisor
  Future<ApiResponse<String>> startNewSession() async {
    try {
      final response = await _apiService.post('/api/legal/session', {});

      if (response['success'] == true) {
        final sessionId = response['sessionId'] as String;
        return ApiResponse.success(sessionId);
      } else {
        return ApiResponse.error('Failed to start new session: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      return ApiResponse.error('Error starting new session: $e');
    }
  }

  /// Sends a message to the chatbot and returns the response
  Future<ApiResponse<LegalAdvice>> sendMessage(String sessionId, String message) async {
    try {
      final response = await _apiService.post('/api/legal/chat', {
        'sessionId': sessionId,
        'message': message,
      });

      if (response['success'] == true) {
        final legalAdvice = LegalAdvice.fromJson(response['data']);
        return ApiResponse.success(legalAdvice);
      } else {
        return ApiResponse.error('Failed to get response: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      return ApiResponse.error('Error sending message: $e');
    }
  }

  /// Get conversation history for a session
  Future<ApiResponse<List<LegalAdvice>>> getConversationHistory(String sessionId) async {
    try {
      final response = await _apiService.get('/api/legal/history/$sessionId');

      if (response['success'] == true) {
        final data = response['data'] as List;
        final history = data.map((item) => LegalAdvice.fromJson(item as Map<String, dynamic>)).toList();
        return ApiResponse.success(history);
      } else {
        return ApiResponse.error('Failed to get conversation history: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      return ApiResponse.error('Error getting conversation history: $e');
    }
  }

  /// Rate the quality of legal advice provided
  Future<ApiResponse<bool>> rateAdvice(String adviceId, int rating, String? feedback) async {
    try {
      final response = await _apiService.post('/api/legal/rate', {
        'adviceId': adviceId,
        'rating': rating,
        'feedback': feedback,
      });

      if (response['success'] == true) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error('Failed to submit rating: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      return ApiResponse.error('Error rating advice: $e');
    }
  }
}