import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../components/shadcn_card.dart';
import '../components/shadcn_button.dart';

/// Documents screen for secure document storage with encryption
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<SecureDocument> _documents = [];
  bool _isUploading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50 from Figma
      body: SafeArea(
        child: Column(
          children: [
            // Header - Figma design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: const Color(0xFF2E7D32), // Green from Figma
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Secure Documents',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    'Store important documents with military-grade encryption',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8), // Light green background
                      borderRadius: BorderRadius.circular(AppSpacing.figmaRadius),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.security,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'AES-256 encryption • Biometric access • Local storage only',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Document list or empty state
            Expanded(
              child: _documents.isEmpty
                  ? _buildEmptyState()
                  : _buildDocumentList(),
            ),
            
            // Upload button - Figma design
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ShadcnButton.primary(
                text: _isUploading ? 'Encrypting Document...' : 'Upload Secure Document',
                leadingIcon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate, size: 16),
                width: double.infinity,
                onPressed: _isUploading ? null : _showUploadOptions,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_special,
              size: 80,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Documents Yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Upload important documents like ID, driver\'s license, insurance, or registration for quick access during police interactions.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSecurityFeatures(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecurityFeatures() {
    final features = [
      {'icon': Icons.enhanced_encryption, 'text': 'AES-256 Encryption'},
      {'icon': Icons.fingerprint, 'text': 'Biometric Access'},
      {'icon': Icons.phone_android, 'text': 'Local Storage Only'},
      {'icon': Icons.auto_delete, 'text': 'Auto-Delete Option'},
    ];
    
    return Column(
      children: [
        Text(
          'Security Features',
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: features.map((feature) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  feature['icon'] as IconData,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  feature['text'] as String,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }
  
  Widget _buildDocumentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final document = _documents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ShadcnCard(
            backgroundColor: Colors.white,
            borderColor: const Color(0xFFE5E7EB),
            onTap: () => _viewDocument(document),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getDocumentColor(document.type),
                        radius: 20,
                        child: Icon(
                          _getDocumentIcon(document.type),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          document.name,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Quick access badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1), // Use accent color with opacity
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          document.type.split(' ').first.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        size: 12,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: AppSpacing.xs / 2),
                      Text(
                        '${document.type} • ${document.encryptionMethod}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  if (document.expirationDate != null) ...[
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      'Expires: ${_formatDate(document.expirationDate!)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _isExpiringSoon(document.expirationDate!)
                            ? const Color(0xFFEF6C00)
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                  // Quick action buttons for common actions
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ShadcnButton.outline(
                          text: 'Quick View',
                          size: ShadcnButtonSize.sm,
                          onPressed: () => _viewDocument(document),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: ShadcnButton.primary(
                          text: 'Quick Share',
                          size: ShadcnButtonSize.sm,
                          onPressed: () => _shareDocument(document),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'Upload Secure Document',
              style: AppTextStyles.titleLarge,
            ),
            AppSpacing.verticalSpaceMD,
            
            // Security reminder
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Documents are encrypted with AES-256 and stored locally only. Biometric authentication required for access.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            AppSpacing.verticalSpaceMD,
            
            // Upload options
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture document with camera'),
              onTap: () {
                Navigator.pop(context);
                _uploadDocument('camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select existing photo'),
              onTap: () {
                Navigator.pop(context);
                _uploadDocument('gallery');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Choose File'),
              subtitle: const Text('PDF or image file'),
              onTap: () {
                Navigator.pop(context);
                _uploadDocument('file');
              },
            ),
            
            AppSpacing.verticalSpaceMD,
          ],
        ),
      ),
    );
  }
  
  void _uploadDocument(String source) async {
    setState(() {
      _isUploading = true;
    });
    
    try {
      // Show biometric authentication first
      final isAuthenticated = await _authenticateUser();
      if (!isAuthenticated) {
        setState(() {
          _isUploading = false;
        });
        return;
      }
      
      // Show document type selection
      final documentType = await _showDocumentTypeDialog();
      if (documentType == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }
      
      // Show document name input
      final documentName = await _showDocumentNameDialog(documentType);
      if (documentName == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }
      
      // Simulate file selection and processing
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Show encryption progress
      await _showEncryptionProgress();
      
      // Add document to list
      final newDocument = SecureDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: documentName,
        type: documentType,
        uploadDate: DateTime.now(),
        expirationDate: _getDefaultExpirationDate(documentType),
        isEncrypted: true,
        fileSize: '2.4 MB',
        encryptionMethod: 'AES-256-GCM',
      );
      
      setState(() {
        _documents.add(newDocument);
        _isUploading = false;
      });
      
      // Close encryption dialog
      Navigator.pop(context);
      
      // Show success message with security details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Document Secured Successfully'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '✓ AES-256 encrypted  ✓ Local storage only  ✓ Biometric protected',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade100,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      HapticFeedback.lightImpact();
      
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Upload failed: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  Future<bool> _authenticateUser() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.blue),
            SizedBox(width: 8),
            Text('Biometric Authentication'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please authenticate to upload sensitive documents'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 48,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Touch sensor or use Face ID',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Simulate biometric authentication
              await Future.delayed(const Duration(seconds: 1));
              Navigator.pop(context, true);
            },
            child: const Text('Authenticate'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  Future<String?> _showDocumentTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Driver\'s License',
            'State ID Card',
            'Insurance Card',
            'Vehicle Registration',
            'Passport',
            'Other Document',
          ].map((type) => ListTile(
            leading: Icon(_getDocumentIcon(type)),
            title: Text(type),
            onTap: () => Navigator.pop(context, type),
          )).toList(),
        ),
      ),
    );
  }
  
  Future<String?> _showDocumentNameDialog(String type) async {
    final controller = TextEditingController(text: type);
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter a name for your $type:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., Driver License - John Doe',
              ),
              autofocus: true,
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
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showEncryptionProgress() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Encrypting Document...'),
            const SizedBox(height: 8),
            Text(
              'Using AES-256-GCM encryption',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
    
    // Simulate encryption time
    await Future.delayed(const Duration(seconds: 2));
  }
  
  void _handleDocumentAction(String action, SecureDocument document) {
    switch (action) {
      case 'view':
        _viewDocument(document);
        break;
      case 'share':
        _shareDocument(document);
        break;
      case 'delete':
        _deleteDocument(document);
        break;
    }
  }
  
  void _viewDocument(SecureDocument document) async {
    // Require biometric authentication to view
    final isAuthenticated = await _authenticateUser();
    if (!isAuthenticated) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getDocumentIcon(document.type)),
            const SizedBox(width: 8),
            Expanded(child: Text(document.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDocumentDetail('Type', document.type),
            _buildDocumentDetail('Uploaded', _formatDate(document.uploadDate)),
            if (document.expirationDate != null)
              _buildDocumentDetail('Expires', _formatDate(document.expirationDate!)),
            _buildDocumentDetail('Size', document.fileSize),
            _buildDocumentDetail('Encryption', document.encryptionMethod),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Document Preview',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      '(Decrypted view would appear here)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareDocument(document);
            },
            child: const Text('Quick Share'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDocumentDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  void _shareDocument(SecureDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.blue),
            SizedBox(width: 8),
            Text('Quick Share'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share ${document.name} during police interaction?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code, size: 48, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    'QR Code for Quick Access',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Officer can scan to view document',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
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
                SnackBar(
                  content: Text('${document.name} ready for sharing'),
                  backgroundColor: Colors.blue.shade600,
                ),
              );
            },
            child: const Text('Generate QR Code'),
          ),
        ],
      ),
    );
  }
  
  void _deleteDocument(SecureDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Secure Delete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permanently delete \"${document.name}\"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will securely overwrite the encrypted file. This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
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
              setState(() {
                _documents.remove(document);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Document securely deleted'),
                    ],
                  ),
                  backgroundColor: Colors.orange.shade600,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Secure Delete'),
          ),
        ],
      ),
    );
  }
  
  Color _getDocumentColor(String type) {
    switch (type.toLowerCase()) {
      case 'driver\'s license':
        return Colors.blue.shade600;
      case 'state id card':
        return Colors.green.shade600;
      case 'insurance card':
        return Colors.orange.shade600;
      case 'vehicle registration':
        return Colors.purple.shade600;
      case 'passport':
        return Colors.indigo.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
  
  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'driver\'s license':
        return Icons.drive_eta;
      case 'state id card':
        return Icons.badge;
      case 'insurance card':
        return Icons.security;
      case 'vehicle registration':
        return Icons.directions_car;
      case 'passport':
        return Icons.flight;
      default:
        return Icons.description;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  bool _isExpiringSoon(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;
    return difference <= 30 && difference >= 0;
  }
  
  DateTime? _getDefaultExpirationDate(String type) {
    switch (type.toLowerCase()) {
      case 'driver\'s license':
        return DateTime.now().add(const Duration(days: 1825)); // 5 years
      case 'state id card':
        return DateTime.now().add(const Duration(days: 3650)); // 10 years
      case 'insurance card':
        return DateTime.now().add(const Duration(days: 365)); // 1 year
      case 'vehicle registration':
        return DateTime.now().add(const Duration(days: 365)); // 1 year
      case 'passport':
        return DateTime.now().add(const Duration(days: 3650)); // 10 years
      default:
        return null;
    }
  }
}

class SecureDocument {
  final String id;
  final String name;
  final String type;
  final DateTime uploadDate;
  final DateTime? expirationDate;
  final bool isEncrypted;
  final String fileSize;
  final String encryptionMethod;
  
  SecureDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.uploadDate,
    this.expirationDate,
    this.isEncrypted = true,
    required this.fileSize,
    required this.encryptionMethod,
  });
}