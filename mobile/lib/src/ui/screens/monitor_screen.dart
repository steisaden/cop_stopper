import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/monitoring/monitoring_bloc.dart';
import '../../blocs/monitoring/monitoring_event.dart';
import '../../blocs/monitoring/monitoring_state.dart';
import '../../models/fact_check_result_model.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../widgets/transcription_display.dart';
import '../widgets/fact_check_panel.dart';
import '../components/shadcn_card.dart';
import '../components/figma_badge.dart';
import '../components/shadcn_button.dart';

/// Monitor screen for third-person listener functionality
class MonitorScreen extends StatelessWidget {
  const MonitorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MonitoringBloc(),
      child: const _MonitorScreenContent(),
    );
  }
}

class _MonitorScreenContent extends StatelessWidget {
  const _MonitorScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a), // Dark monitoring interface from Figma
      body: SafeArea(
        child: Column(
          children: [
            // Header - Figma design
            _buildHeader(context),

            // Status indicators
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const FigmaBadge.success(text: 'Listening'),
                  const SizedBox(width: AppSpacing.sm),
                  const FigmaBadge.info(text: 'Fact-Check Active'),
                  const Spacer(),
                  Text(
                    'Live Monitor',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildMonitoringContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringContent(BuildContext context) {
    return BlocBuilder<MonitoringBloc, MonitoringState>(
      builder: (context, state) {
        if (state is MonitoringActive) {
          return _buildActiveMonitoring(context, state);
        }
        // Default to active-style view even if initial, to always show transcription/fact-check panels.
        return _buildActiveMonitoring(context, state);
      },
    );
  }

  Widget _buildActiveMonitoring(BuildContext context, MonitoringState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Live transcription row
        ShadcnCard(
          backgroundColor: const Color(0xFF262626),
          borderColor: const Color(0xFF404040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic, size: 16, color: colorScheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Live Transcription',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ShadcnButton.secondary(
                      text: 'Copy All',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transcription copied')),
                        );
                      },
                      size: ShadcnButtonSize.sm,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ShadcnButton.primary(
                      text: 'Fact Check Text',
                      onPressed: () {
                        context.read<MonitoringBloc>().add(FactCheckRequested());
                      },
                      size: ShadcnButtonSize.sm,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 240,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: TranscriptionDisplay(
                    segments: const [],
                    autoScrollEnabled: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Fact check input row
        ShadcnCard(
          backgroundColor: colorScheme.surface,
          borderColor: colorScheme.outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fact_check, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Fact Check',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Paste text to fact check...',
                        filled: true,
                      ),
                      onChanged: (value) {
                        // Optionally store draft input in bloc/state
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ShadcnButton.primary(
                      text: 'Run Fact Check',
                      onPressed: () {
                        context.read<MonitoringBloc>().add(FactCheckRequested());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Fact check results row
        ShadcnCard(
          backgroundColor: colorScheme.surface,
          borderColor: colorScheme.outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.assignment, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Fact Check Results',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: FactCheckPanel(
                    factCheckResults: [],
                    legalAlerts: [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Starting monitoring session...',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF262626), // Dark header from Figma
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF404040), // Dark border from Figma
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Monitor',
            style: AppTextStyles.headlineLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs / 2),
          Text(
            'Real-time transcription and fact-checking',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: ShadcnButton.outline(
              text: 'Start Session',
              leadingIcon: const Icon(Icons.play_arrow, size: 16),
              onPressed: () {
                context.read<MonitoringBloc>().add(StartMonitoring());
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ShadcnButton.destructive(
              text: 'Stop Session',
              leadingIcon: const Icon(Icons.stop, size: 16),
              onPressed: () {
                context.read<MonitoringBloc>().add(StopMonitoring());
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFactCheckDetails(BuildContext context, FactCheckResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fact Check: ${result.statusText}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Claim:',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(result.claim),
              const SizedBox(height: AppSpacing.md),
              
              if (result.explanation != null) ...[
                Text(
                  'Explanation:',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(result.explanation!),
                const SizedBox(height: AppSpacing.md),
              ],
              
              Text(
                'Confidence: ${result.confidenceLevel} (${(result.confidence * 100).toStringAsFixed(1)}%)',
                style: AppTextStyles.bodySmall,
              ),
              
              if (result.sources.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Sources:',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                ...result.sources.map((source) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('• $source', style: AppTextStyles.bodySmall),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLegalAlertDetails(BuildContext context, LegalAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getAlertIcon(alert.type),
              color: _getSeverityColor(context, alert.severity),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text(alert.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _getSeverityColor(context, alert.severity).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getSeverityColor(context, alert.severity).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Severity: ${alert.severity.name.toUpperCase()}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getSeverityColor(context, alert.severity),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              Text(
                'Description:',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(alert.description),
              const SizedBox(height: AppSpacing.md),
              
              Text(
                'Suggested Response:',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(alert.suggestedResponse),
              ),
              
              if (alert.relevantLaws.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Relevant Laws:',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                ...alert.relevantLaws.map((law) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('• $law', style: AppTextStyles.bodySmall),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(BuildContext context, LegalAlertSeverity severity) {
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

  void _flagIncident(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flag Incident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe the incident you want to flag:'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Incident Description',
                hintText: 'Enter details about the incident',
              ),
              maxLines: 3,
              onSubmitted: (description) {
                if (description.isNotEmpty) {
                  context.read<MonitoringBloc>().add(FlagIncident(description));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incident flagged successfully')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // For demo purposes, flag a generic incident
              context.read<MonitoringBloc>().add(const FlagIncident('User flagged incident'));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incident flagged successfully')),
              );
            },
            child: const Text('Flag'),
          ),
        ],
      ),
    );
  }

  void _requestLegalHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Legal Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('What type of legal assistance do you need?'),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Legal Hotline'),
              subtitle: const Text('Connect to legal assistance hotline'),
              onTap: () {
                context.read<MonitoringBloc>().add(
                  const RequestLegalHelp('Legal hotline requested')
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connecting to legal hotline...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Legal Advice'),
              subtitle: const Text('Request written legal guidance'),
              onTap: () {
                context.read<MonitoringBloc>().add(
                  const RequestLegalHelp('Legal advice requested')
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Legal advice request submitted')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _contactEmergency(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: theme.colorScheme.error),
            const SizedBox(width: AppSpacing.xs),
            const Text('Emergency Contact'),
          ],
        ),
        content: const Text(
          'This will contact emergency services and share your location. '
          'Only use in genuine emergencies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ShadcnButton.destructive(
            text: 'Contact Emergency',
            onPressed: () {
              context.read<MonitoringBloc>().add(
                const ContactEmergency('Emergency assistance requested')
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Emergency services contacted'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _generateReport(BuildContext context) {
    context.read<MonitoringBloc>().add(const GenerateReport());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Report Generated'),
        content: const Text(
          'A comprehensive report of this monitoring session has been generated '
          'and saved securely. The report includes transcription, fact-checks, '
          'conversation analysis, and session events.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report exported successfully')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
