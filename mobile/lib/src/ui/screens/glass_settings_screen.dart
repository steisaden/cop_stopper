import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/components/glass_surface.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';

/// Settings screen with dark glassmorphism design
/// Based on Stitch app-settings.html
class GlassSettingsScreen extends StatefulWidget {
  const GlassSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GlassSettingsScreen> createState() => _GlassSettingsScreenState();
}

class _GlassSettingsScreenState extends State<GlassSettingsScreen> {
  bool _stealthMode = false;
  bool _whisperEnabled = true;
  bool _biometricLock = true;
  double _modelSize = 0.6; // 0-1 scale

  // Cloud upload connections
  bool _googleDriveConnected = false;
  bool _youtubeConnected = false;
  bool _dropboxConnected = false;

  // Legal AI location
  String _userAddress = '';
  String _detectedState = '';
  String _detectedCity = '';
  String _detectedCounty = '';

  String get _modelSizeLabel {
    if (_modelSize < 0.25) return 'Tiny';
    if (_modelSize < 0.5) return 'Small';
    if (_modelSize < 0.75) return 'Medium';
    return 'Large';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.glassBackground,
      child: Stack(
        children: [
          // Background gradient blobs
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.glassPrimary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -50,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.glassAI.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile card
                        _buildProfileCard(),

                        const SizedBox(height: 32),

                        // Recording section
                        _buildSectionHeader('Recording'),
                        const SizedBox(height: 12),
                        _buildRecordingSettings(),

                        const SizedBox(height: 32),

                        // Whisper AI section
                        _buildWhisperSection(),

                        const SizedBox(height: 32),

                        // Emergency Contacts section (NEW)
                        _buildSectionHeader('Emergency Contacts'),
                        const SizedBox(height: 12),
                        _buildEmergencyContactsSettings(),

                        const SizedBox(height: 32),

                        // Upload To section (NEW)
                        _buildSectionHeader('Upload To'),
                        const SizedBox(height: 12),
                        _buildUploadSettings(),

                        const SizedBox(height: 32),

                        // Legal AI Settings section (NEW)
                        _buildSectionHeader('Legal AI Settings'),
                        const SizedBox(height: 12),
                        _buildLegalAISettings(),

                        const SizedBox(height: 32),

                        // Privacy section
                        _buildSectionHeader('Privacy & Security'),
                        const SizedBox(height: 12),
                        _buildPrivacySettings(),

                        const SizedBox(height: 32),

                        // Legal section
                        _buildSectionHeader('Legal & Support'),
                        const SizedBox(height: 12),
                        _buildLegalSettings(),

                        const SizedBox(height: 24),

                        // Version
                        Center(
                          child: Text(
                            'Cop Stopper v3.0 • Build 942',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    // Design ref: #1a1a1a bg, gray-800 border, rounded-2xl (16px)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassCardBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glassPrimary.withOpacity(0.2),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1), width: 2),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.glassPrimary,
                  size: 28,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.glassSuccess,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.glassBackground, width: 3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alex Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Premium Member',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.glassCardBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.glassCardBorder),
              ),
              child: Text(
                'Edit',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    // Design ref: gray-400, uppercase, 12px
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.glassTextMuted, // gray-400
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRecordingSettings() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.hd,
            iconColor: AppColors.glassPrimary,
            title: 'Video Quality',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '1080p',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: Colors.white.withOpacity(0.3), size: 20),
              ],
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.visibility_off,
            iconColor: AppColors.glassRecording,
            title: 'Stealth Mode',
            subtitle: 'Dim screen while recording',
            trailing: _buildToggle(
                _stealthMode, (v) => setState(() => _stealthMode = v)),
          ),
        ],
      ),
    );
  }

  Widget _buildWhisperSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassAI.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassSurface(
        variant: GlassVariant.base,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.graphic_eq, color: AppColors.glassAI, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Whisper AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.glassAI.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.glassAI.withOpacity(0.3)),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(
                          color: AppColors.glassAI.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildToggle(
                    _whisperEnabled, (v) => setState(() => _whisperEnabled = v),
                    accent: AppColors.glassAI),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              'On-device transcription powered by OpenAI.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),

            const SizedBox(height: 16),

            // Language
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Language',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GlassSurface(
                  variant: GlassVariant.floating,
                  borderRadius: BorderRadius.circular(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'English (US)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more,
                          color: Colors.white.withOpacity(0.5), size: 16),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Model size slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Model Size',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _modelSizeLabel,
                  style: TextStyle(
                    color: AppColors.glassAI,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.glassAI,
                inactiveTrackColor: Colors.white.withOpacity(0.1),
                thumbColor: Colors.white,
                overlayColor: AppColors.glassAI.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _modelSize,
                onChanged: (v) => setState(() => _modelSize = v),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Tiny', 'Small', 'Medium', 'Large']
                  .map((label) => Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Download button
            GlassSurface(
              variant: GlassVariant.floating,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download,
                      color: AppColors.glassAI.withOpacity(0.8), size: 20),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        'Download Model',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Requires 1.5 GB',
                        style: TextStyle(
                          color: AppColors.glassAI.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.fingerprint,
            iconColor: AppColors.glassSuccess,
            title: 'Biometric Lock',
            trailing: _buildToggle(
                _biometricLock, (v) => setState(() => _biometricLock = v),
                accent: AppColors.glassSuccess),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.storage,
            iconColor: AppColors.glassWarning,
            title: 'Storage Location',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Local Only',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: Colors.white.withOpacity(0.3), size: 20),
              ],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSettings() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.gavel,
            iconColor: Colors.white.withOpacity(0.7),
            title: 'Legal Rights Guide',
            trailing: Icon(Icons.open_in_new,
                color: Colors.white.withOpacity(0.3), size: 18),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.help_outline,
            iconColor: Colors.white.withOpacity(0.7),
            title: 'Help Center',
            trailing: Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.3), size: 20),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged,
      {Color? accent}) {
    final color = accent ?? AppColors.glassPrimary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: value ? color : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsSettings() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_add,
            iconColor: AppColors.glassRecording,
            title: 'Add Emergency Contact',
            subtitle: 'People to alert during recording',
            trailing: Icon(Icons.add_circle_outline,
                color: AppColors.glassRecording, size: 24),
            onTap: () => _showAddContactDialog(),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.people,
            iconColor: AppColors.glassPrimary,
            title: 'Manage Contacts',
            subtitle: 'View and edit saved contacts',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.glassPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '3 contacts',
                    style: TextStyle(
                      color: AppColors.glassPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: Colors.white.withOpacity(0.3), size: 20),
              ],
            ),
            onTap: () => _showManageContactsSheet(),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.glassCardBorder),
        ),
        title: const Text('Add Contact', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Contact Name',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.glassCardBorder),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.glassCardBorder),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact added')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.glassSuccess,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showManageContactsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: AppColors.glassCardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Emergency Contacts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildContactItem(
                      'Mom', '(555) 123-4567', ContactType.family),
                  _buildContactItem(
                      'Attorney', '(555) 987-6543', ContactType.legal),
                  _buildContactItem(
                      'Partner', '(555) 456-7890', ContactType.personal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String name, String phone, ContactType type) {
    final color = type == ContactType.legal
        ? AppColors.glassAI
        : type == ContactType.family
            ? AppColors.glassSuccess
            : AppColors.glassPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassCardBorder.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              name[0],
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
                Text(phone,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type.name,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSettings() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildCloudServiceTile(
            icon: Icons.add_to_drive,
            color: const Color(0xFF4285F4),
            title: 'Google Drive',
            isConnected: _googleDriveConnected,
            onConnect: () =>
                setState(() => _googleDriveConnected = !_googleDriveConnected),
          ),
          _buildDivider(),
          _buildCloudServiceTile(
            icon: Icons.play_circle_fill,
            color: const Color(0xFFFF0000),
            title: 'YouTube',
            subtitle: 'Unlisted uploads only',
            isConnected: _youtubeConnected,
            onConnect: () =>
                setState(() => _youtubeConnected = !_youtubeConnected),
          ),
          _buildDivider(),
          _buildCloudServiceTile(
            icon: Icons.cloud,
            color: const Color(0xFF0061FF),
            title: 'Dropbox',
            isConnected: _dropboxConnected,
            onConnect: () =>
                setState(() => _dropboxConnected = !_dropboxConnected),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudServiceTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required bool isConnected,
    required VoidCallback onConnect,
  }) {
    return _buildSettingsTile(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      trailing: GestureDetector(
        onTap: onConnect,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isConnected
                ? AppColors.glassSuccess.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isConnected
                  ? AppColors.glassSuccess
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          child: Text(
            isConnected ? 'Connected' : 'Connect',
            style: TextStyle(
              color: isConnected
                  ? AppColors.glassSuccess
                  : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onTap: onConnect,
    );
  }

  Widget _buildLegalAISettings() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.location_on,
            iconColor: AppColors.glassSuccess,
            title: 'Auto-Detect Location',
            subtitle: _detectedCity.isEmpty
                ? 'Detecting your jurisdiction...'
                : '$_detectedCity, $_detectedState',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_detectedCity.isEmpty)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.glassSuccess,
                    ),
                  )
                else
                  Icon(Icons.check_circle,
                      color: AppColors.glassSuccess, size: 20),
                const SizedBox(width: 8),
                Icon(Icons.refresh,
                    color: Colors.white.withOpacity(0.5), size: 20),
              ],
            ),
            onTap: () => _detectLocation(),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.edit_location_alt,
            iconColor: AppColors.glassPrimary,
            title: 'Manual Address',
            subtitle: _userAddress.isEmpty
                ? 'Set your address manually'
                : _userAddress,
            trailing: Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.3), size: 20),
            onTap: () => _showAddressDialog(),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.gavel,
            iconColor: AppColors.glassAI,
            title: 'State Laws Database',
            subtitle: _detectedState.isEmpty
                ? 'Select your state'
                : '$_detectedState laws loaded',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.glassAI.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _detectedState.isEmpty ? 'N/A' : _detectedState,
                    style: TextStyle(
                      color: AppColors.glassAI,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: Colors.white.withOpacity(0.3), size: 20),
              ],
            ),
            onTap: () => _showStateSelector(),
          ),
        ],
      ),
    );
  }

  void _detectLocation() async {
    // Simulate location detection
    setState(() {
      _detectedCity = '';
      _detectedState = '';
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _detectedCity = 'Austin';
        _detectedState = 'TX';
        _detectedCounty = 'Travis';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location detected: Austin, TX (Travis County)'),
          backgroundColor: AppColors.glassSuccess,
        ),
      );
    }
  }

  void _showAddressDialog() {
    final controller = TextEditingController(text: _userAddress);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.glassCardBorder),
        ),
        title:
            const Text('Enter Address', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Street, City, State, ZIP',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.glassCardBorder),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _userAddress = controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.glassPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStateSelector() {
    final states = [
      'AL',
      'AK',
      'AZ',
      'AR',
      'CA',
      'CO',
      'CT',
      'DE',
      'FL',
      'GA',
      'HI',
      'ID',
      'IL',
      'IN',
      'IA',
      'KS',
      'KY',
      'LA',
      'ME',
      'MD',
      'MA',
      'MI',
      'MN',
      'MS',
      'MO',
      'MT',
      'NE',
      'NV',
      'NH',
      'NJ',
      'NM',
      'NY',
      'NC',
      'ND',
      'OH',
      'OK',
      'OR',
      'PA',
      'RI',
      'SC',
      'SD',
      'TN',
      'TX',
      'UT',
      'VT',
      'VA',
      'WA',
      'WV',
      'WI',
      'WY'
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: AppColors.glassCardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Your State',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: states.length,
                itemBuilder: (context, index) {
                  final state = states[index];
                  final isSelected = state == _detectedState;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _detectedState = state);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.glassAI.withOpacity(0.3)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.glassAI
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          state,
                          style: TextStyle(
                            color:
                                isSelected ? AppColors.glassAI : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
