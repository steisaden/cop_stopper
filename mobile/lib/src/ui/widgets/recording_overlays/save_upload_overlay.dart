import 'package:flutter/material.dart';
import 'package:mobile/src/ui/app_colors.dart';

/// Save/Upload overlay for video recording.
/// Allows naming and uploading to cloud services.
class SaveUploadOverlay extends StatefulWidget {
  final Duration duration;
  final Function(String name, String? destination) onSave;
  final VoidCallback onCancel;

  const SaveUploadOverlay({
    super.key,
    required this.duration,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<SaveUploadOverlay> createState() => _SaveUploadOverlayState();
}

class _SaveUploadOverlayState extends State<SaveUploadOverlay> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedDestination;
  bool _isSaving = false;

  // Cloud service connection status (would come from settings)
  final Map<String, bool> _connectedServices = {
    'local': true,
    'google_drive': false,
    'youtube': false,
    'dropbox': false,
  };

  @override
  void initState() {
    super.initState();
    // Default name with date
    final now = DateTime.now();
    _nameController.text = 'Recording_${now.month}-${now.day}-${now.year}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:'
        '${twoDigits(d.inSeconds.remainder(60))}';
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    await widget.onSave(_nameController.text.trim(), _selectedDestination);
    if (!mounted) return;
    setState(() => _isSaving = false);
  }

  void _connectService(String service) {
    // TODO: Implement OAuth flow for each service
    debugPrint('Connect to $service');

    // For now, show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.glassCardBorder),
        ),
        title: Text(
          'Connect ${_getServiceName(service)}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'OAuth integration coming soon. You can configure connected accounts in Settings.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getServiceName(String key) {
    switch (key) {
      case 'local':
        return 'Local Storage';
      case 'google_drive':
        return 'Google Drive';
      case 'youtube':
        return 'YouTube';
      case 'dropbox':
        return 'Dropbox';
      default:
        return key;
    }
  }

  IconData _getServiceIcon(String key) {
    switch (key) {
      case 'local':
        return Icons.phone_android;
      case 'google_drive':
        return Icons.add_to_drive;
      case 'youtube':
        return Icons.play_circle_fill;
      case 'dropbox':
        return Icons.cloud;
      default:
        return Icons.cloud_upload;
    }
  }

  Color _getServiceColor(String key) {
    switch (key) {
      case 'local':
        return AppColors.glassPrimary;
      case 'google_drive':
        return const Color(0xFF4285F4);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'dropbox':
        return const Color(0xFF0061FF);
      default:
        return AppColors.glassPrimary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration info
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glassPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.glassPrimary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam,
                    color: AppColors.glassPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(widget.duration),
                    style: TextStyle(
                      color: AppColors.glassPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Name input
          Text(
            'VIDEO NAME',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.glassCardBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.glassCardBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.glassPrimary,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 24),

          // Upload destinations
          Text(
            'UPLOAD TO',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          ...['local', 'google_drive', 'youtube', 'dropbox'].map(
            (service) => _buildServiceOption(service),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: AppColors.glassCardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.glassSuccess,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Recording',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption(String service) {
    final isConnected = _connectedServices[service] ?? false;
    final isSelected = _selectedDestination == service;
    final color = _getServiceColor(service);

    return GestureDetector(
      onTap: () {
        if (isConnected) {
          setState(() => _selectedDestination = service);
        } else {
          _connectService(service);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? color : AppColors.glassCardBorder.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getServiceIcon(service),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getServiceName(service),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isConnected ? 'Connected' : 'Tap to connect',
                    style: TextStyle(
                      color: isConnected
                          ? AppColors.glassSuccess
                          : Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else if (!isConnected)
              Icon(
                Icons.add_circle_outline,
                color: Colors.white.withOpacity(0.3),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
