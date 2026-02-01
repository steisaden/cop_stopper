import 'package:flutter/material.dart';
import '../../models/fact_check_result_model.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Widget for displaying fact-checking results and legal alerts
class FactCheckPanel extends StatefulWidget {
  final List<FactCheckResult> factCheckResults;
  final List<LegalAlert> legalAlerts;
  final Function(FactCheckResult)? onFactCheckTap;
  final Function(LegalAlert)? onLegalAlertTap;

  const FactCheckPanel({
    Key? key,
    required this.factCheckResults,
    required this.legalAlerts,
    this.onFactCheckTap,
    this.onLegalAlertTap,
  }) : super(key: key);

  @override
  State<FactCheckPanel> createState() => _FactCheckPanelState();
}

class _FactCheckPanelState extends State<FactCheckPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(FactCheckStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case FactCheckStatus.verified:
        return colorScheme.primary;
      case FactCheckStatus.disputed:
        return colorScheme.secondary;
      case FactCheckStatus.false_claim:
        return colorScheme.error;
      case FactCheckStatus.unverifiable:
        return colorScheme.onSurfaceVariant;
      case FactCheckStatus.unknown:
        return colorScheme.onSurfaceVariant.withOpacity(0.5);
    }
  }

  Color _getSeverityColor(LegalAlertSeverity severity) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (severity) {
      case LegalAlertSeverity.low:
        return colorScheme.primary;
      case LegalAlertSeverity.medium:
        return colorScheme.secondary;
      case LegalAlertSeverity.high:
        return colorScheme.error;
      case LegalAlertSeverity.critical:
        return colorScheme.error;
    }
  }

  IconData _getAlertIcon(LegalAlertType type) {
    switch (type) {
      case LegalAlertType.rightsViolation:
        return Icons.warning;
      case LegalAlertType.proceduralError:
        return Icons.error;
      case LegalAlertType.illegalSearch:
        return Icons.search_off;
      case LegalAlertType.mirandaRights:
        return Icons.record_voice_over;
      case LegalAlertType.excessiveForce:
        return Icons.report_problem;
      case LegalAlertType.other:
        return Icons.info;
    }
  }

  Widget _buildFactCheckCard(FactCheckResult result) {
    final statusColor = _getStatusColor(result.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => widget.onFactCheckTap?.call(result),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(result.status),
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.statusText,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(result.confidence * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Claim text
              Text(
                result.claim,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              if (result.explanation != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  result.explanation!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              
              if (result.sources.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sources: ${result.sources.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalAlertCard(LegalAlert alert) {
    final severityColor = _getSeverityColor(alert.severity);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => widget.onLegalAlertTap?.call(alert),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: severityColor.withOpacity(0.3),
              width: alert.severity == LegalAlertSeverity.critical ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alert header
                Row(
                  children: [
                    Icon(
                      _getAlertIcon(alert.type),
                      color: severityColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        alert.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: severityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: Text(
                        alert.severity.name.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: severityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // Description
                Text(
                  alert.description,
                  style: AppTextStyles.bodySmall,
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Suggested response
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suggested Response:',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        alert.suggestedResponse,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                if (alert.relevantLaws.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Relevant Laws: ${alert.relevantLaws.join(', ')}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(FactCheckStatus status) {
    switch (status) {
      case FactCheckStatus.verified:
        return Icons.check_circle;
      case FactCheckStatus.disputed:
        return Icons.warning;
      case FactCheckStatus.false_claim:
        return Icons.cancel;
      case FactCheckStatus.unverifiable:
        return Icons.help_outline;
      case FactCheckStatus.unknown:
        return Icons.question_mark;
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFactCheckTab() {
    if (widget.factCheckResults.isEmpty) {
      return _buildEmptyState(
        'No fact-check results yet.\nClaims will appear here as they are analyzed.',
        Icons.fact_check,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: widget.factCheckResults.length,
      itemBuilder: (context, index) {
        return _buildFactCheckCard(widget.factCheckResults[index]);
      },
    );
  }

  Widget _buildLegalAlertsTab() {
    if (widget.legalAlerts.isEmpty) {
      return _buildEmptyState(
        'No legal alerts.\nRights violations and procedural issues will appear here.',
        Icons.gavel,
      );
    }

    // Sort alerts by severity (critical first)
    final sortedAlerts = List<LegalAlert>.from(widget.legalAlerts)
      ..sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: sortedAlerts.length,
      itemBuilder: (context, index) {
        return _buildLegalAlertCard(sortedAlerts[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final criticalAlerts = widget.legalAlerts
        .where((alert) => alert.severity == LegalAlertSeverity.critical)
        .length;
    
    final attentionResults = widget.factCheckResults
        .where((result) => result.requiresAttention)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.md),
                topRight: Radius.circular(AppSpacing.md),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fact_check),
                      const SizedBox(width: 4),
                      const Text('Fact Check'),
                      if (attentionResults > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            attentionResults.toString(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: colorScheme.onError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gavel),
                      const SizedBox(width: 4),
                      const Text('Legal'),
                      if (criticalAlerts > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            criticalAlerts.toString(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: colorScheme.onError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFactCheckTab(),
                _buildLegalAlertsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
