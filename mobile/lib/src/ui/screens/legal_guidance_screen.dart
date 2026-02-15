import 'package:flutter/material.dart';
import 'package:mobile/src/models/legal_guidance_model.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../components/shadcn_card.dart';
import '../components/figma_badge.dart';
import '../components/shadcn_button.dart';
import '../../services/openai_service.dart';
import '../../config/api_keys.dart';
import '../../services/location_service.dart';
import '../../services/gps_location_service.dart';

/// Legal Guidance Screen with organized information
class LegalGuidanceScreen extends StatefulWidget {
  const LegalGuidanceScreen({Key? key}) : super(key: key);

  @override
  State<LegalGuidanceScreen> createState() => _LegalGuidanceScreenState();
}

class _LegalGuidanceScreenState extends State<LegalGuidanceScreen> {
  List<LegalGuidanceItem> _legalGuidanceItems = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  
  // AI Chatbot state
  OpenAIService? _openAIService;
  final List<Map<String, String>> _chatHistory = [];
  LocationService? _locationService;
  String? _userState;

  // Mock data for legal guidance items
  final List<LegalGuidanceItem> _mockLegalGuidanceItems = [
    LegalGuidanceItem(
      id: '1',
      title: 'Your Right to Remain Silent',
      content: 'You have the right to remain silent during any police interaction. ' 'Anything you say can be used against you in court. You can invoke this ' +
          'right at any time by clearly stating, "I wish to remain silent."',
      jurisdiction: 'US Federal',
      tags: ['rights', 'silence', 'arrest'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      relevanceScore: 0.95,
      scenario: 'arrest',
      citations: ['Miranda v. Arizona', 'Fifth Amendment'],
    ),
    LegalGuidanceItem(
      id: '2',
      title: 'Right to Legal Representation',
      content: 'You have the right to an attorney during police questioning. ' 'If you cannot afford one, a public defender will be appointed to you. ' +
          'Request an attorney immediately and do not answer questions until one is present.',
      jurisdiction: 'US Federal',
      tags: ['rights', 'representation', 'arrest'],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      relevanceScore: 0.92,
      scenario: 'arrest',
      citations: ['Gideon v. Wainwright', 'Sixth Amendment'],
    ),
    LegalGuidanceItem(
      id: '3',
      title: 'Consent for Searches',
      content: 'Police generally need a warrant to search your person, vehicle, or property. ' 'You have the right to refuse consent for searches. Clearly state "I do not consent " +
          'to any search." If they proceed anyway, do not physically resist but make it clear ' +
          'that you do not consent.',
      jurisdiction: 'US Federal',
      tags: ['searches', 'consent', 'warrants'],
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      relevanceScore: 0.88,
      scenario: 'traffic_stop',
      citations: ['Fourth Amendment', 'Terry v. Ohio'],
    ),
  ];

  final List<String> _categories = ['All', 'Rights', 'Searches', 'Arrest', 'Traffic Stops'];

  @override
  void initState() {
    super.initState();
    _loadLegalGuidance();
    _initializeOpenAI();
  }
  
  void _initializeOpenAI() {
    try {
      if (ApiKeys.hasOpenAIKey) {
        _openAIService = OpenAIService(apiKey: ApiKeys.openAI);
      }
      _locationService = GPSLocationService();
      _getUserLocation();
    } catch (e) {
      debugPrint('OpenAI initialization failed: $e');
    }
  }
  
  Future<void> _getUserLocation() async {
    try {
      final locationResult = await _locationService?.getCurrentLocation();
      if (locationResult != null && mounted) {
        // For now, we'll use a simple state detection based on coordinates
        // In production, you'd use reverse geocoding or jurisdiction service
        final jurisdiction = await _locationService?.getCurrentJurisdiction();
        if (jurisdiction != null) {
          setState(() {
            _userState = jurisdiction.state;
          });
          debugPrint('User state detected: $_userState');
        }
      }
    } catch (e) {
      debugPrint('Failed to get user location: $e');
    }
  }

  void _loadLegalGuidance() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading data with small delay
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      setState(() {
        _legalGuidanceItems = _mockLegalGuidanceItems;
        _isLoading = false;
      });
    });
  }

  List<LegalGuidanceItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return _legalGuidanceItems;
    }
    
    return _legalGuidanceItems
        .where((item) => item.tags
            .any((tag) => tag.toLowerCase().contains(_selectedCategory.toLowerCase())))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50 from Figma
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Figma design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legal Guidance',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    'Know your rights and legal protections',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            // Category filter tabs
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.figmaRadius),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.outline,
                          ),
                        ),
                        child: Text(
                          category,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.mutedForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Content section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredItems.isEmpty
                      ? _buildEmptyState()
                      : _buildLegalGuidanceList(),
            ),

            // AI Chat and Emergency buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: ShadcnButton(
                      text: 'Ask AI',
                      leadingIcon: const Icon(Icons.chat, size: 16),
                      onPressed: _openAIService != null
                          ? () => _showAIChatDialog()
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ShadcnButton.primary(
                      text: 'Emergency',
                      leadingIcon: const Icon(Icons.local_police, size: 16),
                      onPressed: () {
                        // TODO: Implement emergency legal help
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.gavel,
            size: 80,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Legal Guidance Available',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No legal guidance matches the selected category',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalGuidanceList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.builder(
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ShadcnCard(
              backgroundColor: Colors.white,
              borderColor: AppColors.outline,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FigmaBadge.info(
                          text: item.jurisdiction,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.content,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: item.tags.map((tag) {
                        return FigmaBadge(
                          text: tag,
                        );
                      }).toList(),
                    ),
                    if (item.citations.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Citations: ${item.citations.join(', ')}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// Show AI chat dialog
  void _showAIChatDialog() {
    final messageController = TextEditingController();
    bool isLoading = false;
    final localChatHistory = List<Map<String, String>>.from(_chatHistory);
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.chat, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                const Text('Legal AI Assistant'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // Chat history
                  Expanded(
                    child: localChatHistory.isEmpty
                        ? Center(
                            child: Text(
                              'Ask me anything about your legal rights!',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: localChatHistory.length,
                            itemBuilder: (context, index) {
                              final message = localChatHistory[index];
                              final isUser = message['role'] == 'user';
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? AppColors.primary
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      message['content'] ?? '',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isUser
                                            ? Colors.white
                                            : AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: CircularProgressIndicator(),
                    ),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Input field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your question...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                          ),
                          maxLines: null,
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: AppColors.primary,
                        onPressed: isLoading
                            ? null
                            : () async {
                                final message = messageController.text.trim();
                                if (message.isEmpty) return;
                                
                                messageController.clear();
                                
                                setDialogState(() {
                                  localChatHistory.add({
                                    'role': 'user',
                                    'content': message,
                                  });
                                  isLoading = true;
                                });
                                
                                try {
                                  final response = await _openAIService!.sendChatMessage(
                                    message: message,
                                    conversationHistory: localChatHistory
                                        .where((m) => m['role'] != 'user' || m['content'] != message)
                                        .toList(),
                                    userState: _userState, // Pass user's state for location-specific advice
                                  );
                                  
                                  setDialogState(() {
                                    localChatHistory.add({
                                      'role': 'assistant',
                                      'content': response,
                                    });
                                    isLoading = false;
                                  });
                                  
                                  // Update main chat history
                                  setState(() {
                                    _chatHistory.clear();
                                    _chatHistory.addAll(localChatHistory);
                                  });
                                } catch (e) {
                                  setDialogState(() {
                                    localChatHistory.add({
                                      'role': 'assistant',
                                      'content': 'Sorry, I encountered an error: ${e.toString()}',
                                    });
                                    isLoading = false;
                                  });
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}