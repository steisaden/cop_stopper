import 'package:flutter/material.dart';
import '../../models/monitoring_session_model.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Widget for managing monitoring session actions and displaying session info
class SessionManagementPanel extends StatelessWidget {
  final MonitoringSession? currentSession;
  final SessionSummary? sessionSummary;
  final VoidCallback? onFlagIncident;
  final VoidCallback? onRequestLegalHelp;
  final VoidCallback? onContactEmergency;
  final VoidCallback? onGenerateReport;
  final VoidCallback? onEndSession;

  const SessionManagementPanel({
    Key? key,
    this.currentSession,
    this.sessionSummary,
    this.onFlagIncident,
    this.onRequestLegalHelp,
    this.onContactEmergency,
    this.onGenerateReport,
    this.onEndSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.md),
          if (currentSession != null) ...[
            _buildSessionInfo(context),
            const SizedBox(height: AppSpacing.md),
            _buildCriticalIssues(context),
            const SizedBox(height: AppSpacing.md),
          ],
          _buildActionButtons(context),
          if (sessionSummary != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildSessionSummary(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.manage_accounts,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Session Management',
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (currentSession != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(currentSession!.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(currentSession!.status).withOpacity(0.3),
              ),
            ),
            child: Text(
              currentSession!.status.name.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: _getStatusColor(currentSession!.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    if (currentSession == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Info',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildInfoRow('Duration', currentSession!.duration.toString().split('.').first),
          _buildInfoRow('Segments', currentSession!.transcriptionSegments.length.toString()),
          _buildInfoRow('Fact Checks', currentSession!.factCheckResults.length.toString()),
          _buildInfoRow('Legal Alerts', currentSession!.legalAlerts.length.toString()),
          if (currentSession!.location != null)
            _buildInfoRow('Location', currentSession!.location!),
          if (currentSession!.jurisdiction != null)
            _buildInfoRow('Jurisdiction', currentSession!.jurisdiction!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalIssues(BuildContext context) {
    if (currentSession == null || !currentSession!.hasCriticalIssues) {
      return const SizedBox.shrink();
    }

    final issues = currentSession!.criticalIssues;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Critical Issues',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ...issues.take(3).map((issue) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '• $issue',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          )),
          if (issues.length > 3)
            Text(
              '... and ${issues.length - 3} more',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.error,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Emergency actions row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.flag,
                label: 'Flag Incident',
                color: AppColors.warning,
                onPressed: onFlagIncident,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.gavel,
                label: 'Legal Help',
                color: AppColors.primary,
                onPressed: onRequestLegalHelp,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Emergency contact button
        _buildActionButton(
          context,
          icon: Icons.emergency,
          label: 'Emergency Contact',
          color: AppColors.error,
          onPressed: onContactEmergency,
          isFullWidth: true,
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Session management buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.description,
                label: 'Generate Report',
                color: Colors.green,
                onPressed: onGenerateReport,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.stop,
                label: 'End Session',
                color: Colors.grey,
                onPressed: onEndSession,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
    bool isFullWidth = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isFullWidth ? AppSpacing.md : AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildSessionSummary(BuildContext context) {
    if (sessionSummary == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Summary',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Statistics grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.xs,
            children: [
              _buildSummaryItem('Duration', sessionSummary!.formattedDuration),
              _buildSummaryItem('Words', sessionSummary!.totalWords.toString()),
              _buildSummaryItem('Speakers', sessionSummary!.uniqueSpeakers.toString()),
              _buildSummaryItem('Confidence', sessionSummary!.confidencePercentage),
              _buildSummaryItem('Verified', sessionSummary!.verifiedClaims.toString()),
              _buildSummaryItem('Disputed', sessionSummary!.disputedClaims.toString()),
              _buildSummaryItem('False Claims', sessionSummary!.falseClaims.toString()),
              _buildSummaryItem('Critical Alerts', sessionSummary!.criticalAlerts.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return AppColors.success;
      case SessionStatus.paused:
        return AppColors.warning;
      case SessionStatus.completed:
        return Colors.blue;
      case SessionStatus.error:
        return AppColors.error;
      case SessionStatus.cancelled:
        return Colors.grey;
    }
  }
}