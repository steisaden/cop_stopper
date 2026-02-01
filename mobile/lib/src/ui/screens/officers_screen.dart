import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_spacing.dart';
import '../../collaborative_monitoring/interfaces/officer_records_service.dart';
import '../../collaborative_monitoring/models/officer_profile.dart';
import '../widgets/officer_profile_card.dart';
import '../widgets/api_status_banner.dart';
import '../components/shadcn_card.dart';
import '../components/figma_badge.dart';
import '../components/shadcn_button.dart';
import '../components/shadcn_input.dart';
import '../widgets/custom_toggle_switch.dart';
import 'api_test_screen.dart';
import 'officer_search_screen.dart';
import '../../service_locator.dart' if (dart.library.html) '../../service_locator_web.dart';
import '../../collaborative_monitoring/models/career_timeline.dart';
import '../../collaborative_monitoring/models/community_rating.dart';

/// Officer Records & Transparency screen for searching and viewing officer public records
class OfficersScreen extends StatefulWidget {
  const OfficersScreen({Key? key}) : super(key: key);

  @override
  State<OfficersScreen> createState() => _OfficersScreenState();
}

class _OfficersScreenState extends State<OfficersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<OfficerProfile> _searchResults = [];
  late final OfficerRecordsService _officerRecordsService;
  bool _useBackend = true;
  String? _apiErrorMessage;

  @override
  void initState() {
    super.initState();
    _officerRecordsService = locator<OfficerRecordsService>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _apiErrorMessage = null;
    });

    try {
      if (_useBackend) {
        // Search using the backend API
        List<String> officerIds;
        if (RegExp(r'^\d+$').hasMatch(query.trim())) {
           officerIds = await _officerRecordsService.searchOfficersByBadge(query.trim());
        } else {
           officerIds = await _officerRecordsService.searchOfficersByName(query.trim());
        }
        
        // Fetch full profiles
        final List<OfficerProfile> results = [];
        for (final id in officerIds) {
           try {
             final profile = await _officerRecordsService.getOfficer(id);
             results.add(profile);
           } catch (e) {
             print('Error fetching profile for $id: $e');
           }
        }
        
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchResults = results;
            _apiErrorMessage = results.isEmpty ? 'No officers found in backend database' : null;
          });
        }
      } else {
        // Mock fallback for demo if needed
        List<String> officerIds = ['LAPD-12345', 'NYPD-67890'];
        final List<OfficerProfile> results = [];
         for (final officerId in officerIds) {
          try {
            results.add(OfficerProfile(
                id: officerId, 
                name: 'EX-Officer (Mock)', 
                badgeNumber: officerId.split('-').last, 
                department: officerId.split('-').first, 
                complaintRecords: [], 
                disciplinaryActions: [], 
                commendations: [], 
                careerTimeline: const CareerTimeline(events: []),
                communityRating: CommunityRating(
                  officerId: officerId,
                  averageRating: 0,
                  totalRatings: 0,
                  ratingBreakdown: const {},
                  recentComments: const [],
                ),
                isUserGenerated: false,
                createdBy: null
            ));
          } catch (e) {
             // ignore
          }
         }
         if (mounted) {
          setState(() {
             _isSearching = false;
             _searchResults = results;
          });
         }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
          _apiErrorMessage = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Officer Records',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs / 2),
                            Text(
                              'Search public records and transparency data',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // API Toggle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _useBackend ? 'Backend API' : 'Mock',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          CustomToggleSwitch(
                            value: _useBackend,
                            onChanged: (value) {
                              setState(() {
                                _useBackend = value;
                                _searchResults = [];
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ShadcnInput(
                    controller: _searchController,
                    placeholder: 'Search by name or badge number...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    onChanged: _performSearch,
                  ),
                ],
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: ShadcnButton.outline(
                      text: 'Test APIs',
                      leadingIcon: const Icon(Icons.api, size: 16),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ApiTestScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ShadcnButton.primary(
                      text: 'Enhanced Search',
                      leadingIcon: const Icon(Icons.search, size: 16),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OfficerSearchScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    // Disclaimer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.figmaRadius),
                        border: Border.all(color: AppColors.warning, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Important Disclaimer',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Information provided is for transparency purposes only. ' +
                            'This data is compiled from public records and may not be complete.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _buildSearchResults()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      if (_apiErrorMessage != null) {
         return Center(child: Text(_apiErrorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
      }
      return _buildEmptyState();
    }

    return ListView(
      children: [
        Text(
          _useBackend ? 'Backend Results' : 'Mock Results',
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._searchResults.map((officer) => _buildOfficerCard(officer)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Search Officer Records',
            style: AppTextStyles.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter an officer\'s name or badge number to search',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(OfficerProfile officer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ShadcnCard(
        backgroundColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.outline,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      officer.name.isNotEmpty ? officer.name.substring(0, 1) : '?',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          officer.name,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Badge: ${officer.badgeNumber}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FigmaBadge.info(text: _useBackend ? 'Backend' : 'Mock'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
