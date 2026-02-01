import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/services/settings_service.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../theme_manager.dart';
import '../widgets/recording_settings_card.dart';
import '../widgets/privacy_settings_card.dart';
import '../widgets/legal_settings_card.dart';
import '../widgets/accessibility_settings_card.dart';
import '../widgets/theme_switcher.dart';
import '../widgets/custom_toggle_switch.dart';
import '../widgets/accessibility_support.dart';
import '../components/shadcn_card.dart';
import '../components/figma_badge.dart';
import '../components/shadcn_button.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _settingsService = Provider.of<SettingsService>(context, listen: false);
  }

  // Recording settings state - initialized from SettingsService
  String get _videoQuality => _settingsService.videoQuality;
  double get _audioBitrate => _settingsService.audioBitrate;
  String get _fileFormat => _settingsService.fileFormat;
  bool get _autoSave => _settingsService.autoSave;

  // Privacy settings state - initialized from SettingsService
  bool get _dataSharing => _settingsService.dataSharing;
  bool get _cloudBackup => _settingsService.cloudBackup;
  bool get _analyticsSharing => _settingsService.analyticsSharing;
  int get _autoDeleteDays => _settingsService.autoDeleteDays;
  bool get _encryptionEnabled => _settingsService.encryptionEnabled;

  // Legal settings state - initialized from SettingsService
  String get _jurisdiction => _settingsService.jurisdiction;
  bool get _consentRecording => _settingsService.consentRecording;
  bool get _notificationsEnabled => _settingsService.notificationsEnabled;
  bool get _rightsReminders => _settingsService.rightsReminders;
  bool get _legalHotlineAccess => _settingsService.legalHotlineAccess;

  // Accessibility settings state - initialized from SettingsService
  bool get _voiceCommands => _settingsService.voiceCommands;
  double get _textSize => _settingsService.textSize;
  bool get _highContrast => _settingsService.highContrast;
  bool get _reducedMotion => _settingsService.reducedMotion;
  bool get _screenReaderSupport => _settingsService.screenReaderSupport;
  bool get _hapticFeedback => _settingsService.hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background slate-50 from Figma
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Figma design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white, // White header from Figma
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE5E7EB), // Light border from Figma
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    'Configure your app preferences and security settings',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Settings sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Account Section - Figma design
                  _buildSettingsSection(
                    theme,
                    'Account',
                    [
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.person,
                        title: 'Profile',
                        subtitle: 'John Doe • john.doe@email.com',
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () {
                          // TODO: Navigate to profile
                        },
                      ),
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.security,
                        title: 'Change Password',
                        subtitle: 'Last changed 30 days ago',
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () {
                          // TODO: Navigate to change password
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Recording Section - Figma design
                  _buildSettingsSection(
                    theme,
                    'Recording',
                    [
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.videocam,
                        title: 'Video Quality',
                        subtitle: 'Higher quality uses more storage',
                        trailing: DropdownButton<String>(
                          value: _videoQuality,
                          underline: const SizedBox(),
                          style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurface),
                          dropdownColor: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.figmaRadius),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: ['720p', '1080p', '4K'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _settingsService.videoQuality = value;
                              });
                            }
                          },
                        ),
                      ),
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.smartphone,
                        title: 'Auto-start Recording',
                        subtitle: 'Start recording with voice command or shortcut',
                        trailing: Switch(
                          value: _autoSave,
                          onChanged: (value) {
                            setState(() {
                              _settingsService.autoSave = value;
                            });
                          },
                        ),
                      ),
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.notifications,
                        title: 'Recording Notifications',
                        subtitle: 'Show alerts during active recording',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _settingsService.notificationsEnabled = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Emergency Contacts Section - Figma design
                  _buildSettingsSection(
                    theme,
                    'Emergency Contacts',
                    [
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.group,
                        title: 'Trusted Contacts',
                        subtitle: '2 contacts configured',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FigmaBadge.success(text: 'Active'),
                            const SizedBox(width: AppSpacing.xs),
                            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        onTap: () {
                          // TODO: Navigate to contacts
                        },
                      ),
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.notifications_active,
                        title: 'Auto-alert Contacts',
                        subtitle: 'Notify contacts when recording starts',
                        trailing: Switch(
                          value: _settingsService.autoAlertContacts,
                          onChanged: (value) {
                            setState(() {
                              _settingsService.autoAlertContacts = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Storage & Sync Section - Figma design
                  _buildSettingsSection(
                    theme,
                    'Storage & Sync',
                    [
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.cloud,
                        title: 'Cloud Storage',
                        subtitle: '2.1 GB used of 5 GB',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FigmaBadge.info(text: 'Pro Plan'),
                            const SizedBox(width: AppSpacing.xs),
                            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        onTap: () {
                          // TODO: Navigate to cloud storage
                        },
                      ),
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.wifi,
                        title: 'Sync on Wi-Fi Only',
                        subtitle: 'Save cellular data usage',
                        trailing: CustomToggleSwitch(
                          value: _cloudBackup,
                          onChanged: (value) {
                            setState(() {
                              _settingsService.cloudBackup = value;
                            });
                          },
                        ),
                      ),
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.storage,
                        title: 'Local Storage',
                        subtitle: 'Manage device storage usage',
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () {
                          // TODO: Navigate to local storage
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Legal & Privacy Section - Figma design
                  _buildSettingsSection(
                    theme,
                    'Legal & Privacy',
                    [
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () {
                          // TODO: Navigate to privacy policy
                        },
                      ),
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.description,
                        title: 'Terms of Service',
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () {
                          // TODO: Navigate to terms
                        },
                      ),
                      _buildSettingItem(
                        theme: theme,
                        icon: Icons.gavel,
                        title: 'Recording Laws',
                        subtitle: 'Know your local recording rights',
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () {
                          // TODO: Navigate to recording laws
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // App Info Section - Figma design
                  ShadcnCard(
                    backgroundColor: theme.colorScheme.surface,
                    borderColor: theme.colorScheme.outline,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Text(
                            'Cop Stopper',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs / 2),
                          Text(
                            'Version 1.0.0',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Secure personal safety documentation',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Sign Out Button - Figma design
                  ShadcnButton.outline(
                    text: 'Sign Out',
                    width: double.infinity,
                    onPressed: () {
                      _showSignOutDialog(context);
                    },
                  ),

                  // Bottom padding for safe scrolling
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme, String title, List<Widget> items) {
    return ShadcnCard(
      backgroundColor: theme.colorScheme.surface,
      borderColor: theme.colorScheme.outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Container(
                decoration: BoxDecoration(
                  border: isLast ? null : Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                child: item,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: AppTextStyles.titleMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out? You will need to sign in again to access your account.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadcnButton.destructive(
            text: 'Sign Out',
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement sign out
            },
          ),
        ],
      ),
    );
  }
}
