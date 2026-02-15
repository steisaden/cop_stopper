class ApiKeys {
  // IMPORTANT: Replace with your actual OpenAI API key
  // Get your key from: https://platform.openai.com/api-keys
  // For production, use environment variables or secure storage
      'YOUR_OPENAI_API_KEY_HERE';

  static String get openAI {
    if (_openAIKey.isEmpty || _openAIKey == 'YOUR_OPENAI_API_KEY_HERE') {
      throw Exception('OpenAI API key not configured. '
          'Please add your API key in lib/src/config/api_keys.dart');
    }
    return _openAIKey;
  }

  static bool get hasOpenAIKey {
    return _openAIKey.isNotEmpty && _openAIKey != 'YOUR_OPENAI_API_KEY_HERE';
  }
}
