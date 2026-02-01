import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/real_police_api_service.dart';
import '../../models/officer_record_model.dart';
import '../widgets/officer_profile_card.dart';

/// Screen for testing real police APIs
class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final RealPoliceApiService _apiService = RealPoliceApiService();
  
  Map<String, dynamic>? _testResults;
  List<OfficerRecord>? _searchResults;
  bool _isRunningTests = false;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _runApiTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults = null;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.runApiTests();
      setState(() {
        _testResults = results;
        _isRunningTests = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Test failed: $e';
        _isRunningTests = false;
      });
    }
  }

  Future<void> _searchUKOfficers() async {
    setState(() {
      _isSearching = true;
      _searchResults = null;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.searchUKPoliceOfficers();
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: $e';
        _isSearching = false;
      });
    }
  }

  Future<void> _searchSpecificForce(String forceId) async {
    setState(() {
      _isSearching = true;
      _searchResults = null;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.searchUKPoliceOfficers(forceId: forceId);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: $e';
        _isSearching = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Police API Tests'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestSection(),
            const SizedBox(height: 24),
            _buildSearchSection(),
            const SizedBox(height: 24),
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Connectivity Tests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test connections to real police databases and APIs',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunningTests ? null : _runApiTests,
                icon: _isRunningTests
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isRunningTests ? 'Running Tests...' : 'Run API Tests'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_testResults != null) ...[
              const SizedBox(height: 16),
              _buildTestResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, size: 20),
              const SizedBox(width: 8),
              Text(
                'Test Results',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _copyToClipboard(_testResults.toString()),
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy results',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._testResults!.entries.map((entry) => _buildTestResultItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildTestResultItem(String apiName, dynamic result) {
    final isSuccess = result['status'] == 'success';
    final icon = isSuccess ? Icons.check_circle : Icons.error;
    final color = isSuccess ? Colors.green : Colors.red;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatApiName(apiName),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (result['message'] != null)
                  Text(
                    result['message'].toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (result['count'] != null)
                  Text(
                    'Found ${result['count']} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatApiName(String apiName) {
    switch (apiName) {
      case 'uk_police_forces':
        return 'UK Police API - Forces';
      case 'uk_police_officers':
        return 'UK Police API - Officers';
      case 'openoversight':
        return 'OpenOversight';
      case 'chicago_data':
        return 'Chicago Data Portal';
      case 'washington_post':
        return 'Washington Post Data';
      case 'fatal_encounters':
        return 'Fatal Encounters';
      default:
        return apiName.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildSearchSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Officer Search',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search real police officer data from UK Police API',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _searchUKOfficers,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearching ? 'Searching...' : 'Search All Forces'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : () => _searchSpecificForce('metropolitan'),
                    icon: const Icon(Icons.location_city),
                    label: const Text('Search Met Police'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : () => _searchSpecificForce('west-midlands'),
                    icon: const Icon(Icons.business),
                    label: const Text('West Midlands'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : () => _searchSpecificForce('greater-manchester'),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Manchester'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.blue[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Ready to Test',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Run API tests to check connectivity, then search for real officer data.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Results',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No officers found. This may be normal if the selected force has no senior officers listed in the public API.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${_searchResults!.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Real officer data from UK Police API',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ..._searchResults!.map((officer) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OfficerProfileCard(
            officer: officer,
            showRiskScore: false, // UK data doesn't have complaint info
            onTap: () => _showOfficerDetails(officer),
          ),
        )),
      ],
    );
  }

  void _showOfficerDetails(OfficerRecord officer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(officer.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Department: ${officer.department}'),
            Text('Rank: ${officer.rank}'),
            Text('Data Source: ${officer.dataSource}'),
            Text('Reliability: ${(officer.reliability * 100).toInt()}%'),
            const SizedBox(height: 8),
            const Text(
              'Note: UK Police API only provides senior officer information. Complaint and commendation data is not available through public APIs.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              _copyToClipboard('''
Officer: ${officer.name}
Department: ${officer.department}
Rank: ${officer.rank}
Data Source: ${officer.dataSource}
Reliability: ${(officer.reliability * 100).toInt()}%
''');
              Navigator.of(context).pop();
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}