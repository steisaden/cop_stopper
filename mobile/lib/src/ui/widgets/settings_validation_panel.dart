import 'package:flutter/material.dart';
import '../../services/settings_validation_service.dart';
import '../../services/settings_export_service.dart' as export_service;
import 'settings_conflict_warning.dart';
import 'permission_request_overlay.dart';

/// Comprehensive settings validation panel with export/import functionality
class SettingsValidationPanel extends StatefulWidget {
  final Map<String, dynamic> currentSettings;
  final String jurisdiction;
  final Function(String setting, dynamic value)? onSettingChanged;
  final VoidCallback? onSettingsExported;
  final Function(Map<String, dynamic> settings)? onSettingsImported;

  const SettingsValidationPanel({
    Key? key,
    required this.currentSettings,
    required this.jurisdiction,
    this.onSettingChanged,
    this.onSettingsExported,
    this.onSettingsImported,
  }) : super(key: key);

  @override
  State<SettingsValidationPanel> createState() => _SettingsValidationPanelState();
}

class _SettingsValidationPanelState extends State<SettingsValidationPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  export_service.SettingsValidationResult? _validationResult;
  List<PermissionRequirement> _requiredPermissions = [];
  bool _isValidating = false;
  bool _showPermissionOverlay = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _validateSettings();
    _updateRequiredPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SettingsValidationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSettings != widget.currentSettings ||
        oldWidget.jurisdiction != widget.jurisdiction) {
      _validateSettings();
      _updateRequiredPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(theme),
              if (_validationResult != null && 
                  (_validationResult!.hasConflicts || _validationResult!.hasWarnings))
                SettingsConflictWarning(
                  validationResult: _validationResult!,
                  onApplySuggestion: _applySuggestion,
                ),
              _buildTabBar(theme),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildValidationTab(),
                    _buildPermissionsTab(),
                    _buildBackupTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showPermissionOverlay)
          PermissionRequestOverlay(
            permissions: _requiredPermissions,
            onAllGranted: () {
              setState(() {
                _showPermissionOverlay = false;
              });
            },
            onDenied: () {
              setState(() {
                _showPermissionOverlay = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings Validation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ensure your settings are optimized and compliant',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (_isValidating)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: _validateSettings,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh validation',
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(
          icon: Icon(Icons.check_circle),
          text: 'Validation',
        ),
        Tab(
          icon: Icon(Icons.security),
          text: 'Permissions',
        ),
        Tab(
          icon: Icon(Icons.backup),
          text: 'Backup',
        ),
      ],
    );
  }

  Widget _buildValidationTab() {
    if (_validationResult == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildValidationSummary(theme),
          const SizedBox(height: 16),
          if (_validationResult!.hasSuggestions) ...[
            _buildSuggestionsSection(theme),
            const SizedBox(height: 16),
          ],
          _buildValidationActions(theme),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Permissions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your current settings, the following permissions are needed:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ..._requiredPermissions.map((permission) => 
            _buildPermissionItem(theme, permission),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _requiredPermissions.isNotEmpty ? _requestPermissions : null,
              child: const Text('Request All Permissions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTab() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings Backup & Restore',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Export your settings for backup or sharing, or import previously saved settings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildBackupActions(theme),
          const SizedBox(height: 24),
          _buildRecentBackups(theme),
        ],
      ),
    );
  }

  Widget _buildValidationSummary(ThemeData theme) {
    final result = _validationResult!;
    final isValid = result.isValid;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid 
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.warning,
            color: isValid ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValid ? 'Settings Valid' : 'Issues Found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isValid ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isValid 
                      ? 'Your settings are optimized and compliant'
                      : '${result.conflicts.length} conflicts, ${result.warnings.length} warnings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._validationResult!.suggestions.map((suggestion) => 
          Container(
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
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _validateSettings,
            child: const Text('Re-validate'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _validationResult!.isValid ? null : _autoFixIssues,
            child: const Text('Auto-fix Issues'),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionItem(ThemeData theme, PermissionRequirement permission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getPermissionIcon(permission.permission),
            color: permission.required 
                ? theme.colorScheme.error 
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatPermissionName(permission.permission),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  permission.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (permission.required)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Required',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackupActions(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportSettings,
                icon: const Icon(Icons.upload),
                label: const Text('Export Settings'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _importSettings,
                icon: const Icon(Icons.download),
                label: const Text('Import Settings'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _createBackup,
            icon: const Icon(Icons.backup),
            label: const Text('Create Backup'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentBackups(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Backups',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<SettingsBackupInfo>>(
          future: SettingsExportService.getAvailableBackups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No backups found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              );
            }
            
            return Column(
              children: snapshot.data!.take(3).map((backup) => 
                _buildBackupItem(theme, backup),
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackupItem(ThemeData theme, SettingsBackupInfo backup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.backup,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.fileName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${backup.settingsCount} settings • ${_formatFileSize(backup.fileSize)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _restoreFromBackup(backup),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  // Helper methods

  void _validateSettings() async {
    setState(() {
      _isValidating = true;
    });

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate validation

    final result = SettingsValidationService.validateAllSettings(
      allSettings: widget.currentSettings,
      jurisdiction: widget.jurisdiction,
    );

    setState(() {
      _validationResult = result;
      _isValidating = false;
    });
  }

  void _updateRequiredPermissions() {
    final recording = widget.currentSettings['recording'] as Map<String, dynamic>? ?? {};
    final privacy = widget.currentSettings['privacy'] as Map<String, dynamic>? ?? {};
    final accessibility = widget.currentSettings['accessibility'] as Map<String, dynamic>? ?? {};

    _requiredPermissions = SettingsValidationService.getRequiredPermissions(
      videoQuality: recording['videoQuality'] as String? ?? '1080p',
      cloudBackup: privacy['cloudBackup'] as bool? ?? false,
      voiceCommands: accessibility['voiceCommands'] as bool? ?? false,
      jurisdiction: widget.jurisdiction,
    );
  }

  void _applySuggestion(String setting, dynamic value) {
    widget.onSettingChanged?.call(setting, value);
  }

  void _autoFixIssues() {
    if (_validationResult == null) return;

    for (final conflict in _validationResult!.conflicts) {
      widget.onSettingChanged?.call(conflict.affectedSetting, conflict.suggestedValue);
    }

    _validateSettings();
  }

  void _requestPermissions() {
    setState(() {
      _showPermissionOverlay = true;
    });
  }

  void _exportSettings() async {
    final result = await SettingsExportService.exportSettings(
      settings: widget.currentSettings,
    );

    if (result.success) {
      widget.onSettingsExported?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings exported successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${result.error}')),
        );
      }
    }
  }

  void _importSettings() async {
    final result = await SettingsExportService.importSettings();

    if (result.success && result.settings != null) {
      widget.onSettingsImported?.call(result.settings!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings imported successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${result.error}')),
        );
      }
    }
  }

  void _createBackup() async {
    final result = await SettingsExportService.createBackup(
      settings: widget.currentSettings,
    );

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
      setState(() {}); // Refresh backup list
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: ${result.error}')),
        );
      }
    }
  }

  void _restoreFromBackup(SettingsBackupInfo backup) async {
    final result = await SettingsExportService.restoreFromBackup(backup.filePath);

    if (result.success && result.settings != null) {
      widget.onSettingsImported?.call(result.settings!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings restored from backup')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: ${result.error}')),
        );
      }
    }
  }

  IconData _getPermissionIcon(String permission) {
    switch (permission) {
      case 'camera':
        return Icons.camera_alt;
      case 'microphone':
      case 'microphone_always':
        return Icons.mic;
      case 'location':
        return Icons.location_on;
      case 'storage':
        return Icons.storage;
      case 'internet':
        return Icons.cloud;
      default:
        return Icons.security;
    }
  }

  String _formatPermissionName(String permission) {
    switch (permission) {
      case 'camera':
        return 'Camera Access';
      case 'microphone':
        return 'Microphone Access';
      case 'microphone_always':
        return 'Always-On Microphone';
      case 'location':
        return 'Location Access';
      case 'storage':
        return 'Storage Access';
      case 'internet':
        return 'Internet Access';
      default:
        return 'Permission Access';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}