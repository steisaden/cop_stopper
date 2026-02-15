import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/components/glass_surface.dart';

/// Document vault screen with dark glassmorphism design
/// Based on Stitch document-vault.html
class GlassDocumentsScreen extends StatefulWidget {
  const GlassDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<GlassDocumentsScreen> createState() => _GlassDocumentsScreenState();
}

class _GlassDocumentsScreenState extends State<GlassDocumentsScreen> {
  String _selectedCategory = 'All';

  final List<Document> _documents = [
    Document(
      title: 'Traffic Stop Video',
      type: DocumentType.video,
      date: 'Today',
      size: '128 MB',
      isEncrypted: true,
    ),
    Document(
      title: 'Audio Recording',
      type: DocumentType.audio,
      date: 'Today',
      size: '24 MB',
      isEncrypted: true,
    ),
    Document(
      title: 'Officer Badge Photo',
      type: DocumentType.photo,
      date: 'Yesterday',
      size: '4 MB',
      isEncrypted: false,
    ),
    Document(
      title: 'Incident Report',
      type: DocumentType.document,
      date: 'Jan 28',
      size: '2 MB',
      isEncrypted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.glassBackground,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encrypted vault status
                    _buildVaultStatus(),

                    const SizedBox(height: 20),

                    // Category filters
                    _buildCategoryFilters(),

                    const SizedBox(height: 20),

                    // Document list
                    ..._filteredDocuments.map((doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDocumentCard(doc),
                        )),

                    const SizedBox(height: 24),

                    // Upload button
                    _buildUploadButton(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Document> get _filteredDocuments {
    if (_selectedCategory == 'All') return _documents;
    return _documents.where((d) {
      switch (_selectedCategory) {
        case 'Videos':
          return d.type == DocumentType.video;
        case 'Photos':
          return d.type == DocumentType.photo;
        case 'Audio':
          return d.type == DocumentType.audio;
        case 'Docs':
          return d.type == DocumentType.document;
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceFrosted,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.folder_special,
                  color: AppColors.glassPrimary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Document Vault',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.sort, color: Colors.white.withOpacity(0.7)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaultStatus() {
    return GlassSurface(
      variant: GlassVariant.base,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.glassSuccess.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.lock,
              color: AppColors.glassSuccess,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Vault Encrypted',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.glassSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'AES-256 encryption active',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatPill('4 Files', Icons.insert_drive_file),
                    const SizedBox(width: 8),
                    _buildStatPill('158 MB', Icons.storage),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All', 'Videos', 'Photos', 'Audio', 'Docs'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = cat);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.glassPrimary.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.glassPrimary.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.glassPrimary
                        : Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentCard(Document doc) {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      onTap: () {},
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDocTypeColor(doc.type).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDocTypeIcon(doc.type),
              color: _getDocTypeColor(doc.type),
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doc.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (doc.isEncrypted)
                      Icon(
                        Icons.lock,
                        size: 14,
                        color: AppColors.glassSuccess.withOpacity(0.7),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      doc.date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      doc.size,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  IconData _getDocTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.video:
        return Icons.videocam;
      case DocumentType.audio:
        return Icons.mic;
      case DocumentType.photo:
        return Icons.photo;
      case DocumentType.document:
        return Icons.description;
    }
  }

  Color _getDocTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.video:
        return AppColors.glassRecording;
      case DocumentType.audio:
        return AppColors.glassPrimary;
      case DocumentType.photo:
        return AppColors.glassSuccess;
      case DocumentType.document:
        return AppColors.glassWarning;
    }
  }

  Widget _buildUploadButton() {
    return GlassSurface(
      variant: GlassVariant.floating,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      onTap: () => HapticFeedback.mediumImpact(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload, color: AppColors.glassPrimary, size: 24),
          const SizedBox(width: 12),
          Text(
            'Upload Document',
            style: TextStyle(
              color: AppColors.glassPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum DocumentType { video, audio, photo, document }

class Document {
  final String title;
  final DocumentType type;
  final String date;
  final String size;
  final bool isEncrypted;

  Document({
    required this.title,
    required this.type,
    required this.date,
    required this.size,
    required this.isEncrypted,
  });
}
