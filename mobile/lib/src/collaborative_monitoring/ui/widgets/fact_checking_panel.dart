import 'package:flutter/material.dart';
import 'package:mobile/src/collaborative_monitoring/models/fact_check_entry.dart';
import 'package:mobile/src/collaborative_monitoring/services/collaborative_session_manager.dart';
import 'package:mobile/src/collaborative_monitoring/services/real_time_collaboration_service.dart';

class FactCheckingPanel extends StatefulWidget {
  final CollaborativeSessionManager sessionManager;

  const FactCheckingPanel({
    Key? key,
    required this.sessionManager,
  }) : super(key: key);

  @override
  State<FactCheckingPanel> createState() => _FactCheckingPanelState();
}

class _FactCheckingPanelState extends State<FactCheckingPanel> {
  final _claimController = TextEditingController();
  final _verificationController = TextEditingController();
  final _sourcesController = TextEditingController();
  ConfidenceLevel _selectedConfidence = ConfidenceLevel.medium;
  List<AggregatedFactCheck> _factChecks = [];

  @override
  void initState() {
    super.initState();
    _listenToFactChecks();
  }

  void _listenToFactChecks() {
    widget.sessionManager.onFactChecksUpdated.listen((factChecks) {
      if (mounted) {
        setState(() {
          _factChecks = factChecks;
        });
      }
    });
  }

  @override
  void dispose() {
    _claimController.dispose();
    _verificationController.dispose();
    _sourcesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fact Check Submission Form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: _buildSubmissionForm(),
        ),
        
        // Existing Fact Checks
        Expanded(
          child: _buildFactChecksList(),
        ),
      ],
    );
  }

  Widget _buildSubmissionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submit Fact Check',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 12),
        
        // Claim Input
        TextField(
          controller: _claimController,
          decoration: const InputDecoration(
            labelText: 'Claim to verify',
            hintText: 'e.g., "Officer needs warrant to search"',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        
        // Verification Input
        TextField(
          controller: _verificationController,
          decoration: const InputDecoration(
            labelText: 'Verification',
            hintText: 'True/False with explanation',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        
        // Sources Input
        TextField(
          controller: _sourcesController,
          decoration: const InputDecoration(
            labelText: 'Sources (comma-separated)',
            hintText: 'constitution.gov, aclu.org',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        
        // Confidence Level
        Row(
          children: [
            const Text('Confidence: '),
            Expanded(
              child: DropdownButton<ConfidenceLevel>(
                value: _selectedConfidence,
                isExpanded: true,
                items: ConfidenceLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(_getConfidenceLevelText(level)),
                  );
                }).toList(),
                onChanged: (level) {
                  if (level != null) {
                    setState(() {
                      _selectedConfidence = level;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canSubmit() ? _submitFactCheck : null,
            child: const Text('Submit Fact Check'),
          ),
        ),
      ],
    );
  }

  Widget _buildFactChecksList() {
    if (_factChecks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No fact checks yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit the first fact check to help the broadcaster',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _factChecks.length,
      itemBuilder: (context, index) {
        final factCheck = _factChecks[index];
        return _buildFactCheckCard(factCheck);
      },
    );
  }

  Widget _buildFactCheckCard(AggregatedFactCheck factCheck) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Claim
            Text(
              factCheck.claim,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            
            // Consensus
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getConsensusColor(factCheck.consensus),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                factCheck.consensus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Confidence Score
            Row(
              children: [
                Text(
                  'Confidence: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                _buildConfidenceBar(factCheck.confidenceScore),
                const SizedBox(width: 8),
                Text(
                  '${(factCheck.confidenceScore * 100).round()}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Contributors
            Text(
              '${factCheck.entries.length} contributor(s)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            
            // Sources (expandable)
            if (factCheck.sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                title: Text(
                  'Sources (${factCheck.sources.length})',
                  style: const TextStyle(fontSize: 12),
                ),
                children: factCheck.sources.map((source) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.link, size: 16),
                    title: Text(
                      source,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => _openSource(source),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: confidence,
          child: Container(
            decoration: BoxDecoration(
              color: _getConfidenceColor(confidence),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Color _getConsensusColor(String consensus) {
    final lowerConsensus = consensus.toLowerCase();
    if (lowerConsensus.contains('true') || lowerConsensus.contains('correct')) {
      return Colors.green;
    } else if (lowerConsensus.contains('false') || lowerConsensus.contains('incorrect')) {
      return Colors.red;
    } else if (lowerConsensus.contains('partial') || lowerConsensus.contains('mixed')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLevelText(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return 'Low (30%)';
      case ConfidenceLevel.medium:
        return 'Medium (60%)';
      case ConfidenceLevel.high:
        return 'High (90%)';
      case ConfidenceLevel.verified:
        return 'Verified (100%)';
    }
  }

  bool _canSubmit() {
    return _claimController.text.trim().isNotEmpty &&
           _verificationController.text.trim().isNotEmpty;
  }

  void _submitFactCheck() async {
    try {
      final sources = _sourcesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await widget.sessionManager.submitFactCheck(
        claim: _claimController.text.trim(),
        verification: _verificationController.text.trim(),
        sources: sources,
        confidence: _selectedConfidence,
      );

      // Clear form
      _claimController.clear();
      _verificationController.clear();
      _sourcesController.clear();
      setState(() {
        _selectedConfidence = ConfidenceLevel.medium;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fact check submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit fact check: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openSource(String source) {
    // In a real implementation, this would open the source URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening source: $source')),
    );
  }
}