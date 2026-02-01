import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chatbot/chatbot_bloc.dart';
import '../../models/legal_advice_model.dart';
import '../ui/components/shadcn_card.dart';
import '../ui/components/shadcn_button.dart';
import '../ui/app_colors.dart';
import '../ui/app_text_styles.dart';
import '../ui/app_spacing.dart';

class LegalAdviceChatScreen extends StatefulWidget {
  const LegalAdviceChatScreen({Key? key}) : super(key: key);

  @override
  State<LegalAdviceChatScreen> createState() => _LegalAdviceChatScreenState();
}

class _LegalAdviceChatScreenState extends State<LegalAdviceChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    
    // Initialize the chatbot
    context.read<ChatbotBloc>().add(ChatbotInitialize());
    
    // Start a new session
    context.read<ChatbotBloc>().add(StartNewSessionRequested());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _sessionId == null) return;

    context.read<ChatbotBloc>().add(
      SendMessageRequested(
        sessionId: _sessionId!,
        message: message,
      ),
    );
    
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Guidance'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Chat header with confidence indicators
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outline),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: const Text(
                    'AI Legal Advisor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.shield,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
          
          // Chat messages area
          Expanded(
            child: BlocConsumer<ChatbotBloc, ChatbotState>(
              listener: (context, state) {
                if (state is ChatbotSessionStarted) {
                  _sessionId = state.sessionId;
                }
                
                if (state is ChatbotMessageReceived || state is ChatbotLegalAdviceReceived) {
                  // Scroll to bottom when new message arrives
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is ChatbotLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is ChatbotError) {
                  return Center(
                    child: Text('Error: ${state.errorMessage}'),
                  );
                }
                
                return _buildChatMessages();
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outline),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Ask about your rights...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (value) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sessionId != null ? _sendMessage : null,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ShadcnButton.outline(
                  text: 'Info',
                  onPressed: () {
                    _showLegalDisclaimer(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    // This would normally be a list of messages from the BLoC state
    // For now, we'll implement a basic chat interface
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Sample legal advice message
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppSpacing.md),
                  bottomLeft: Radius.circular(AppSpacing.md),
                  bottomRight: Radius.circular(AppSpacing.md),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legal Guidance',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'During a police encounter, you have the right to remain silent and the right to an attorney. You are not required to consent to searches without a warrant. Remember to stay calm, be respectful, and document the interaction if possible.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        'Confidence: High',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Sample user message
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.md),
                  bottomLeft: Radius.circular(AppSpacing.md),
                  bottomRight: Radius.circular(AppSpacing.md),
                ),
              ),
              child: Text(
                'What should I do if asked for ID?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gavel, color: Colors.orange),
            SizedBox(width: AppSpacing.sm),
            Text('Legal Disclaimer'),
          ],
        ),
        content: const Text(
          'The information provided by this AI legal advisor is for informational purposes only and does not constitute legal advice. Laws vary by jurisdiction, and you should consult with a qualified attorney for legal guidance specific to your situation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}