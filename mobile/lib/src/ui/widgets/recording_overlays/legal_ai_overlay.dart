import 'package:flutter/material.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/services/openai_service.dart';
import 'package:mobile/src/config/api_keys.dart';

/// Legal AI overlay for video recording.
/// Allows users to ask legal questions during recording.
class LegalAIOverlay extends StatefulWidget {
  const LegalAIOverlay({super.key});

  @override
  State<LegalAIOverlay> createState() => _LegalAIOverlayState();
}

class _LegalAIOverlayState extends State<LegalAIOverlay> {
  final TextEditingController _questionController = TextEditingController();
  final List<_LegalQuestion> _questions = [];
  bool _isLoading = false;
  OpenAIService? _openAIService;
  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeOpenAI();
  }

  void _initializeOpenAI() {
    try {
      if (ApiKeys.hasOpenAIKey) {
        _openAIService = OpenAIService(apiKey: ApiKeys.openAI);
      }
    } catch (e) {
      debugPrint('OpenAI initialization failed: $e');
    }
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _questions.add(_LegalQuestion(
        question: question,
        response: null,
        isLoading: true,
      ));
      _isLoading = true;
    });
    _questionController.clear();

    try {
      // Get real AI response from OpenAI service
      final response = await _getAIResponse(question);

      if (mounted) {
        setState(() {
          _questions.last = _LegalQuestion(
            question: question,
            response: response,
            isLoading: false,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      if (mounted) {
        setState(() {
          _questions.last = _LegalQuestion(
            question: question,
            response:
                'Sorry, I couldn\'t get a response right now. Please try again or check your internet connection.',
            isLoading: false,
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getAIResponse(String question) async {
    if (_openAIService == null) {
      return 'AI service is not available. Please check your API key configuration.';
    }

    try {
      // Add user message to conversation history
      _conversationHistory.add({'role': 'user', 'content': question});

      // Get response from OpenAI
      final response = await _openAIService!.sendChatMessage(
        message: question,
        conversationHistory: _conversationHistory,
      );

      // Add AI response to conversation history
      _conversationHistory.add({'role': 'assistant', 'content': response});

      return response;
    } catch (e) {
      debugPrint('OpenAI API error: $e');
      rethrow;
    }
  }

  void _showResponseModal(_LegalQuestion question) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.glassCardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.gavel, color: AppColors.glassAI),
                  const SizedBox(width: 12),
                  const Text(
                    'Legal Response',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.glassCardBorder, height: 1),

            // Question
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.glassPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.glassPrimary.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.help_outline,
                      size: 18, color: AppColors.glassPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.question,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Response
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  question.response ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            // Quick phrases
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.glassCardBorder.withOpacity(0.5),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUGGESTED PHRASES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPhraseChip('Am I free to go?'),
                      _buildPhraseChip('I do not consent'),
                      _buildPhraseChip('I want a lawyer'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseChip(String phrase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassSuccess.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassSuccess.withOpacity(0.5),
        ),
      ),
      child: Text(
        phrase,
        style: TextStyle(
          color: AppColors.glassSuccess,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input area
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ask a legal question...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _askQuestion(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isLoading ? null : _askQuestion,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.glassAI,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ),

        const Divider(color: AppColors.glassCardBorder, height: 1),

        // Questions list
        Expanded(
          child: _questions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) =>
                      _buildQuestionTile(_questions[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gavel,
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Ask a legal question',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Get natural, conversational guidance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(_LegalQuestion question) {
    return GestureDetector(
      onTap:
          question.response != null ? () => _showResponseModal(question) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: question.response != null
                ? AppColors.glassAI.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (question.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              color: AppColors.glassAI,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Thinking...',
                            style: TextStyle(
                              color: AppColors.glassAI,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (question.response != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassAI,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Read',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegalQuestion {
  final String question;
  final String? response;
  final bool isLoading;

  _LegalQuestion({
    required this.question,
    required this.response,
    required this.isLoading,
  });
}
