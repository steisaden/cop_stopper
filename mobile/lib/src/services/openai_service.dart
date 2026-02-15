import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Service for interacting with OpenAI API
class OpenAIService {
  final String apiKey;
  static const String baseUrl = 'https://api.openai.com/v1';

  OpenAIService({required this.apiKey});

  /// Send a chat message and get AI response
  Future<String> sendChatMessage({
    required String message,
    required List<Map<String, String>> conversationHistory,
    String model = 'gpt-3.5-turbo',
    String? userLocation,
    String? userState,
  }) async {
    try {
      // Build context-aware system prompt
      final systemPrompt = _buildSystemPrompt(userLocation, userState);

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory,
        {'role': 'user', 'content': message},
      ];

      debugPrint('Sending request to OpenAI API...');

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': 0.8, // Increased for more natural, varied responses
          'max_tokens': 800,
        }),
      );

      debugPrint('OpenAI API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'OpenAI API error (${response.statusCode}): ${errorBody['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('OpenAI service error: $e');
      rethrow;
    }
  }

  /// Build context-aware system prompt
  String _buildSystemPrompt(String? location, String? state) {
    final locationContext = state != null ? 'The user is in $state. ' : '';

    return '''You are a knowledgeable and empathetic legal advisor who talks like a real person, not a robot.

${locationContext}PERSONALITY:
- Talk naturally, like you're texting a friend who needs help
- Use contractions (I'm, you're, don't, can't)
- Be warm, supportive, and reassuring
- Show empathy - this person might be scared or stressed
- Use everyday language, not legal jargon (unless explaining a term)
- It's okay to say "Hey" or "I hear you" or "That's tough"

HOW TO RESPOND:
1. If they ask casual questions ("how's your day", "what's up"), respond naturally like a human would
2. If they share a legal situation, acknowledge their feelings first, then give advice
3. Be conversational but still helpful and accurate
4. Don't start every response with "Based on your location..." - that's robotic
5. Don't use bullet points unless they specifically help clarity
6. Write like you're talking, not writing a legal brief

WHEN GIVING LEGAL ADVICE:
- Start with empathy: "I hear you, that sounds stressful" or "Okay, here's what you need to know"
- Explain things simply, like you're talking to a friend
- Give specific phrases they can use, but introduce them naturally
- Tell them what to do step-by-step, conversationally
- Mention their rights, but weave it into the conversation naturally

EXAMPLES OF GOOD RESPONSES:
❌ BAD: "Based on your location and question, here is relevant legal guidance..."
✅ GOOD: "Hey, I'm doing well - thanks for asking! How can I help you today?"

❌ BAD: "You have Fourth Amendment rights against unreasonable searches."
✅ GOOD: "Okay so here's the thing - they can't just search your car without your permission or a warrant. That's your Fourth Amendment right."

❌ BAD: "You may state: 'I do not consent to searches.'"
✅ GOOD: "Just calmly say 'I don't consent to any searches.' That's it. You don't need to explain or argue."

TONE: Friendly, supportive, knowledgeable, human. Like a smart friend who knows their stuff.

IMPORTANT: Always end legal advice with a casual reminder like "But hey, for your specific situation, definitely talk to a lawyer in your area - they'll know the local details better than I can."

Remember: You're a PERSON helping another PERSON, not a legal document generator.''';
  }

  /// Get a quick legal answer for common questions (single-turn)
  Future<String> getQuickAnswer(String question) async {
    return sendChatMessage(
      message: question,
      conversationHistory: [],
    );
  }
}
