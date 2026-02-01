import 'package:flutter/material.dart';
import '../../services/settings_validation_service.dart';

/// Widget for displaying settings validation conflicts and warnings
class SettingsConflictWarning extends StatefulWidget {
  final SettingsValidationResult validationResult;
  final Function(String setting, dynamic value)? onApplySuggestion;
  final VoidCallback? onDismiss;

  const SettingsConflictWarning({
    Key? key,
    required this.validationResult,
    this.onApplySuggestion,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<SettingsConflictWarning> createState() => _SettingsConflictWarningState();
}

class _SettingsConflictWarningState extends State<SettingsConflictWarning>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.validationResult.hasConflicts && !widget.validationResult.hasWarnings) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final severity = widget.validationResult.highestSeverity;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getSeverityColor(severity, theme).withOpacity(0.1),
                border: Border.all(
                  color: _getSeverityColor(severity, theme),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildHeader(theme, severity),
                  if (_isExpanded) ...[
                    const Divider(height: 1),
                    _buildContent(theme),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, ConflictSeverity severity) {
    final color = _getSeverityColor(severity, theme);
    final icon = _getSeverityIcon(severity);
    final title = _getSeverityTitle(severity);
    
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getHeaderSubtitle(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            if (widget.onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onDismiss,
                icon: const Icon(Icons.close),
                iconSize: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.validationResult.hasConflicts) ...[
            _buildConflictsSection(theme),
            if (widget.validationResult.hasWarnings) const SizedBox(height: 16),
          ],
          if (widget.validationResult.hasWarnings) ...[
            _buildWarningsSection(theme),
          ],
          if (widget.validationResult.hasSuggestions) ...[
            const SizedBox(height: 16),
            _buildSuggestionsSection(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildConflictsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error,
              color: theme.colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Conflicts',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.validationResult.conflicts.map((conflict) => 
          _buildConflictItem(theme, conflict),
        ),
      ],
    );
  }

  Widget _buildWarningsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Warnings',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.validationResult.warnings.map((warning) => 
          _buildWarningItem(theme, warning),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: theme.colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Suggestions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.validationResult.suggestions.map((suggestion) => 
          _buildSuggestionItem(theme, suggestion),
        ),
      ],
    );
  }

  Widget _buildConflictItem(ThemeData theme, SettingsConflict conflict) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conflict.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Affected: ${_formatSettingName(conflict.affectedSetting)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onApplySuggestion != null 
                    ? () => widget.onApplySuggestion!(
                        conflict.affectedSetting,
                        conflict.suggestedValue,
                      )
                    : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Fix',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(ThemeData theme, SettingsWarning warning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            warning.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Affects: ${_formatSettingName(warning.affectedSetting)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(ThemeData theme, String suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suggestion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(ConflictSeverity severity, ThemeData theme) {
    switch (severity) {
      case ConflictSeverity.high:
        return theme.colorScheme.error;
      case ConflictSeverity.medium:
        return Colors.orange;
      case ConflictSeverity.low:
        return theme.colorScheme.primary;
    }
  }

  IconData _getSeverityIcon(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.high:
        return Icons.error;
      case ConflictSeverity.medium:
        return Icons.warning;
      case ConflictSeverity.low:
        return Icons.info;
    }
  }

  String _getSeverityTitle(ConflictSeverity severity) {
    if (widget.validationResult.hasConflicts) {
      return 'Settings Issues Found';
    } else if (widget.validationResult.hasWarnings) {
      return 'Settings Warnings';
    } else {
      return 'Settings Suggestions';
    }
  }

  String _getHeaderSubtitle() {
    final conflictCount = widget.validationResult.conflicts.length;
    final warningCount = widget.validationResult.warnings.length;
    
    if (conflictCount > 0 && warningCount > 0) {
      return '$conflictCount conflicts, $warningCount warnings';
    } else if (conflictCount > 0) {
      return '$conflictCount ${conflictCount == 1 ? 'conflict' : 'conflicts'}';
    } else if (warningCount > 0) {
      return '$warningCount ${warningCount == 1 ? 'warning' : 'warnings'}';
    }
    return 'Tap to view details';
  }

  String _formatSettingName(String settingName) {
    // Convert camelCase to readable format
    return settingName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ')
        .trim();
  }
}