import 'package:flutter/material.dart';
import 'package:mobile/src/models/legal_guidance_model.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../components/shadcn_card.dart';
import '../components/figma_badge.dart';
import '../components/shadcn_button.dart';

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

  // Mock data for legal guidance items
  final List<LegalGuidanceItem> _mockLegalGuidanceItems = [
    LegalGuidanceItem(
      id: '1',
      title: 'Your Right to Remain Silent',
      content: 'You have the right to remain silent during any police interaction. ' +
          'Anything you say can be used against you in court. You can invoke this ' +
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
      content: 'You have the right to an attorney during police questioning. ' +
          'If you cannot afford one, a public defender will be appointed to you. ' +
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
      content: 'Police generally need a warrant to search your person, vehicle, or property. ' +
          'You have the right to refuse consent for searches. Clearly state "I do not consent " +
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

            // Emergency legal help button
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ShadcnButton.primary(
                text: 'Emergency Legal Help',
                leadingIcon: const Icon(Icons.local_police, size: 16),
                onPressed: () {
                  // TODO: Implement emergency legal help functionality
                },
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
          Icon(
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
}