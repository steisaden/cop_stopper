import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/settings_validation_service.dart';

/// Overlay widget for requesting permissions with clear explanations
class PermissionRequestOverlay extends StatefulWidget {
  final List<PermissionRequirement> permissions;
  final VoidCallback? onAllGranted;
  final VoidCallback? onDenied;
  final bool showSkipOption;

  const PermissionRequestOverlay({
    Key? key,
    required this.permissions,
    this.onAllGranted,
    this.onDenied,
    this.showSkipOption = true,
  }) : super(key: key);

  @override
  State<PermissionRequestOverlay> createState() => _PermissionRequestOverlayState();
}

class _PermissionRequestOverlayState extends State<PermissionRequestOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentPermissionIndex = 0;
  final Map<String, bool> _permissionResults = {};
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    if (widget.permissions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final currentPermission = widget.permissions[_currentPermissionIndex];
    
    return Material(
      color: Colors.black54,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(theme, currentPermission),
                        const SizedBox(height: 20),
                        _buildPermissionIcon(currentPermission),
                        const SizedBox(height: 16),
                        _buildPermissionExplanation(theme, currentPermission),
                        const SizedBox(height: 20),
                        _buildProgressIndicator(theme),
                        const SizedBox(height: 20),
                        _buildActionButtons(theme, currentPermission),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, PermissionRequirement permission) {
    return Column(
      children: [
        Text(
          'Permission Required',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentPermissionIndex + 1} of ${widget.permissions.length}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionIcon(PermissionRequirement permission) {
    IconData icon;
    Color color;
    
    switch (permission.permission) {
      case 'camera':
        icon = Icons.camera_alt;
        color = Colors.blue;
        break;
      case 'microphone':
      case 'microphone_always':
        icon = Icons.mic;
        color = Colors.green;
        break;
      case 'location':
        icon = Icons.location_on;
        color = Colors.orange;
        break;
      case 'storage':
        icon = Icons.storage;
        color = Colors.purple;
        break;
      case 'internet':
        icon = Icons.cloud;
        color = Colors.cyan;
        break;
      default:
        icon = Icons.security;
        color = Colors.grey;
    }
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40,
        color: color,
      ),
    );
  }

  Widget _buildPermissionExplanation(ThemeData theme, PermissionRequirement permission) {
    return Column(
      children: [
        Text(
          _getPermissionTitle(permission.permission),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          permission.reason,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        if (permission.required) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'Required for app functionality',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentPermissionIndex + 1) / widget.permissions.length,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              '${_currentPermissionIndex + 1}/${widget.permissions.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, PermissionRequirement permission) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isRequesting ? null : () => _requestCurrentPermission(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isRequesting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    permission.required ? 'Grant Permission' : 'Allow Access',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (!permission.required || widget.showSkipOption) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isRequesting ? null : () => _skipCurrentPermission(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                permission.required ? 'Skip for Now' : 'Not Now',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => _showPermissionDetails(permission),
          child: Text(
            'Why is this needed?',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _getPermissionTitle(String permission) {
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

  void _requestCurrentPermission() async {
    setState(() {
      _isRequesting = true;
    });

    // Simulate permission request (in real implementation, use permission_handler)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Provide haptic feedback
    HapticFeedback.lightImpact();
    
    final permission = widget.permissions[_currentPermissionIndex];
    _permissionResults[permission.permission] = true;
    
    setState(() {
      _isRequesting = false;
    });
    
    _moveToNextPermission();
  }

  void _skipCurrentPermission() {
    final permission = widget.permissions[_currentPermissionIndex];
    _permissionResults[permission.permission] = false;
    _moveToNextPermission();
  }

  void _moveToNextPermission() {
    if (_currentPermissionIndex < widget.permissions.length - 1) {
      setState(() {
        _currentPermissionIndex++;
      });
      
      // Animate to next permission
      _animationController.reset();
      _animationController.forward();
    } else {
      _completePermissionFlow();
    }
  }

  void _completePermissionFlow() {
    final allRequiredGranted = widget.permissions
        .where((p) => p.required)
        .every((p) => _permissionResults[p.permission] == true);
    
    if (allRequiredGranted) {
      widget.onAllGranted?.call();
    } else {
      widget.onDenied?.call();
    }
  }

  void _showPermissionDetails(PermissionRequirement permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getPermissionTitle(permission.permission)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(permission.reason),
            const SizedBox(height: 16),
            Text(
              'Privacy Information:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPrivacyInfo(permission.permission),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  String _getPrivacyInfo(String permission) {
    switch (permission) {
      case 'camera':
        return 'Video recordings are stored securely on your device with end-to-end encryption. They are never uploaded without your explicit consent.';
      case 'microphone':
      case 'microphone_always':
        return 'Audio recordings are processed locally and encrypted. Voice commands are processed on-device when possible.';
      case 'location':
        return 'Location data is used only to determine your jurisdiction for legal guidance. It is not shared with third parties.';
      case 'storage':
        return 'Storage access is used only to save your recordings securely. No other files are accessed.';
      case 'internet':
        return 'Internet access is used only for cloud backup (if enabled) and legal database updates. No tracking or analytics.';
      default:
        return 'This permission is used only for the stated functionality and follows strict privacy guidelines.';
    }
  }
}