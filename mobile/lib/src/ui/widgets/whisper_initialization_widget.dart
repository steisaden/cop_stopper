import 'package:flutter/material.dart';
import 'package:mobile/src/services/whisper_model_manager.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/service_locator.dart' if (dart.library.html) 'package:mobile/src/service_locator_web.dart';

class WhisperInitializationWidget extends StatefulWidget {
  final VoidCallback? onInitialized;
  final VoidCallback? onSkipped;
  
  const WhisperInitializationWidget({
    Key? key,
    this.onInitialized,
    this.onSkipped,
  }) : super(key: key);

  @override
  State<WhisperInitializationWidget> createState() => _WhisperInitializationWidgetState();
}

class _WhisperInitializationWidgetState extends State<WhisperInitializationWidget> {
  bool _isInitializing = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _status = 'Checking Whisper models...';
  String _recommendedModel = '';
  bool _hasModel = false;

  @override
  void initState() {
    super.initState();
    _checkWhisperStatus();
  }

  Future<void> _checkWhisperStatus() async {
    try {
      final downloadedModels = await WhisperModelManager.getDownloadedModels();
      final recommended = await WhisperModelManager.recommendModel();
      
      setState(() {
        _hasModel = downloadedModels.isNotEmpty;
        _recommendedModel = recommended;
        _status = _hasModel 
            ? 'Whisper model ready for offline transcription'
            : 'No Whisper model found. Download recommended for offline transcription.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking Whisper status: $e';
      });
    }
  }

  Future<void> _downloadRecommendedModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _status = 'Downloading recommended model...';
    });

    try {
      await WhisperModelManager.downloadModel(
        _recommendedModel,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
        onStatusUpdate: (status) {
          setState(() {
            _status = status;
          });
        },
      );

      setState(() {
        _isDownloading = false;
        _hasModel = true;
        _status = 'Model downloaded successfully!';
      });

      // Initialize transcription service
      await _initializeTranscriptionService();
      
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _status = 'Download failed: $e';
      });
    }
  }

  Future<void> _initializeTranscriptionService() async {
    setState(() {
      _isInitializing = true;
      _status = 'Initializing Whisper transcription...';
    });

    try {
      final transcriptionService = locator<TranscriptionServiceInterface>();
      await transcriptionService.initializeWhisper();
      
      setState(() {
        _isInitializing = false;
        _status = 'Whisper ready for offline transcription!';
      });

      // Notify parent that initialization is complete
      widget.onInitialized?.call();
      
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _status = 'Initialization failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.mic,
                size: 32,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Offline Transcription Setup',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (_isDownloading || _isInitializing) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                ],
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                if (_isDownloading) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 8),
                  Text(
                    '${(_downloadProgress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Benefits
          if (!_hasModel) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benefits of Offline Transcription:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBenefit('🔒 Complete privacy - no data sent to servers'),
                  _buildBenefit('⚡ Fast real-time processing'),
                  _buildBenefit('📱 Works without internet connection'),
                  _buildBenefit('🎯 Optimized for legal/police interactions'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
          
          // Action Buttons
          Row(
            children: [
              if (!_hasModel && !_isDownloading && !_isInitializing) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onSkipped,
                    child: const Text('Skip for Now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _downloadRecommendedModel,
                    icon: const Icon(Icons.download),
                    label: Text('Download ${_recommendedModel}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ] else if (_hasModel && !_isInitializing) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _initializeTranscriptionService,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Initialize Whisper'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ] else if (!_isDownloading && !_isInitializing) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onInitialized,
                    child: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Model info
          if (!_hasModel && _recommendedModel.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recommended: ${WhisperModelManager.getModelInfo(_recommendedModel).sizeString ?? ''} download',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}