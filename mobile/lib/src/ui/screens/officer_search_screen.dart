import 'package:flutter/material.dart';
import '../../models/officer_record_model.dart';
import '../../services/police_conduct_database_service.dart';
import '../../service_locator.dart' if (dart.library.html) '../../service_locator_web.dart';
import '../widgets/officer_profile_card.dart';
import './add_officer_screen.dart';
import './add_encounter_screen.dart';

/// Screen for searching and displaying officer information from multiple databases
class OfficerSearchScreen extends StatefulWidget {
  const OfficerSearchScreen({Key? key}) : super(key: key);

  @override
  State<OfficerSearchScreen> createState() => _OfficerSearchScreenState();
}

class _OfficerSearchScreenState extends State<OfficerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final PoliceConductDatabaseService _databaseService = locator<PoliceConductDatabaseService>();
  
  List<OfficerRecord> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchType = 'name'; // 'name' or 'badge'

  @override
  void dispose() {
    _searchController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search term')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final results = await _databaseService.searchOfficers(
        query: _searchController.text.trim(),
        department: _departmentController.text.trim().isEmpty 
            ? null 
            : _departmentController.text.trim(),
        limit: 50,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      if (results.isEmpty) {
        setState(() {
          _errorMessage = 'No officers found matching your search criteria.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Search failed: ${e.toString()}';
      });
    }
  }

  Future<void> _searchByBadge(String badgeNumber, String department) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final officer = await _databaseService.getOfficerByBadge(
        badgeNumber: badgeNumber,
        department: department,
      );

      setState(() {
        _searchResults = officer != null ? [officer] : [];
        _isLoading = false;
      });

      if (officer == null) {
        setState(() {
          _errorMessage = 'No officer found with badge number $badgeNumber in $department.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Search failed: ${e.toString()}';
      });
    }
  }

  void _showOfficerDetails(OfficerRecord officer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOfficerDetailsSheet(officer),
    );
  }

  Widget _buildOfficerDetailsSheet(OfficerRecord officer) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OfficerProfileCard(
                        officer: officer,
                        showRiskScore: true,
                        showDetailedInfo: true,
                      ),
                      const SizedBox(height: 16),
                      _buildComplaintsSection(officer),
                      const SizedBox(height: 16),
                      _buildCommendationsSection(officer),
                      const SizedBox(height: 16),
                      _buildDataSourcesSection(officer),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEncounterScreen(officerId: officer.id),
                            ),
                          );
                        },
                        child: const Text('Add Encounter'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplaintsSection(OfficerRecord officer) {
    if (officer.complaints.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complaints',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('No complaint records found.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaints (${officer.complaints.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...officer.complaints.map((complaint) => _buildComplaintTile(complaint)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintTile(ComplaintRecord complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  complaint.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: complaint.status.toLowerCase().contains('sustained')
                      ? Colors.red[200]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  complaint.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: complaint.status.toLowerCase().contains('sustained')
                        ? Colors.red[800]
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          if (complaint.date != null) ...[
            const SizedBox(height: 4),
            Text(
              'Date: ${_formatDate(complaint.date!)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
          if (complaint.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              complaint.description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (complaint.outcome.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Outcome: ${complaint.outcome}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommendationsSection(OfficerRecord officer) {
    if (officer.commendations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('No commendation records found.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commendations (${officer.commendations.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...officer.commendations.map((commendation) => _buildCommendationTile(commendation)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommendationTile(CommendationRecord commendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            commendation.type,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (commendation.date != null) ...[
            const SizedBox(height: 4),
            Text(
              'Date: ${_formatDate(commendation.date!)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
          if (commendation.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              commendation.description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataSourcesSection(OfficerRecord officer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Sources',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Source: ${officer.dataSource}'),
            Text('Reliability: ${(officer.reliability * 100).toInt()}%'),
            Text('Last Updated: ${_formatDate(officer.lastUpdated)}'),
            const SizedBox(height: 8),
            Text(
              'This information is compiled from publicly available records and may not be complete or current. Always verify information through official channels.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Search'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'name',
                            label: Text('Name'),
                            icon: Icon(Icons.person),
                          ),
                          ButtonSegment(
                            value: 'badge',
                            label: Text('Badge'),
                            icon: Icon(Icons.badge),
                          ),
                        ],
                        selected: {_searchType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _searchType = selection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: _searchType == 'name' ? 'Officer Name' : 'Badge Number',
                    hintText: _searchType == 'name' 
                        ? 'Enter officer\'s name' 
                        : 'Enter badge number',
                    prefixIcon: Icon(_searchType == 'name' ? Icons.person : Icons.badge),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department (Optional)',
                    hintText: 'e.g., LAPD, NYPD',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _performSearch,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isLoading ? 'Searching...' : 'Search'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching multiple databases...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Search for officers by name or badge number',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data is sourced from multiple public records databases',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddOfficerScreen(),
                  ),
                );
              },
              child: const Text('Create New Officer Profile'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final officer = _searchResults[index];
        return OfficerProfileCard(
          officer: officer,
          onTap: () => _showOfficerDetails(officer),
          showRiskScore: true,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}