import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/ui/app_colors.dart';

/// Officer search screen with dark glassmorphism design
/// Based on Stitch officer-search.html
class GlassOfficerSearchScreen extends StatefulWidget {
  const GlassOfficerSearchScreen({Key? key}) : super(key: key);

  @override
  State<GlassOfficerSearchScreen> createState() =>
      _GlassOfficerSearchScreenState();
}

class _GlassOfficerSearchScreenState extends State<GlassOfficerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;

  final List<OfficerResult> _results = [
    OfficerResult(
      badgeNumber: '4521',
      name: 'Officer J. Smith',
      department: 'Metro Police Department',
      district: 'District 5',
      complaintsCount: 3,
      yearsOfService: 8,
    ),
    OfficerResult(
      badgeNumber: '4522',
      name: 'Officer M. Johnson',
      department: 'Metro Police Department',
      district: 'District 5',
      complaintsCount: 0,
      yearsOfService: 12,
    ),
  ];

  void _performSearch() {
    HapticFeedback.lightImpact();
    setState(() => _hasSearched = true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.glassBackground,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _hasSearched ? _buildResults() : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassBackground, // #0a0a0a
        border: Border(
          bottom: BorderSide(color: AppColors.glassCardBorder), // gray-800
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Officer Lookup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.info_outline, color: Colors.white.withOpacity(0.5)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      // Design ref: #1a1a1a bg, gray-800 border, rounded-full input
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.glassCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter badge number or name...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            GestureDetector(
              onTap: _performSearch,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.glassPrimary, // blue-500
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.badge_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Search for Officers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a badge number or officer name\nto look up their public record',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_results.length} RESULTS FOUND',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ..._results.map((officer) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOfficerCard(officer),
              )),

          const SizedBox(height: 24),

          // Disclaimer (design ref styling)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassCardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassCardBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.glassTextMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Information is sourced from public records. Data may not be current.',
                    style: TextStyle(
                      color: AppColors.glassTextMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(OfficerResult officer) {
    // Design ref: #1a1a1a bg, gray-800 border, rounded-2xl (16px)
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Badge icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.glassPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '#',
                      style: TextStyle(
                        color: AppColors.glassPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Badge ${officer.badgeNumber}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (officer.complaintsCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.glassWarning.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${officer.complaintsCount} complaints',
                                style: TextStyle(
                                  color: AppColors.glassWarning,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.glassSuccess.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'No complaints',
                                style: TextStyle(
                                  color: AppColors.glassSuccess,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        officer.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.06),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildOfficerStat(Icons.business, officer.department),
                const SizedBox(width: 16),
                _buildOfficerStat(Icons.location_on, officer.district),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.4)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class OfficerResult {
  final String badgeNumber;
  final String name;
  final String department;
  final String district;
  final int complaintsCount;
  final int yearsOfService;

  OfficerResult({
    required this.badgeNumber,
    required this.name,
    required this.department,
    required this.district,
    required this.complaintsCount,
    required this.yearsOfService,
  });
}
