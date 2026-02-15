import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/service_locator.dart';
import 'package:mobile/src/services/offline_service.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/app_spacing.dart';
import 'package:mobile/src/ui/app_text_styles.dart';
import 'package:mobile/src/ui/components/shadcn_button.dart';
import 'package:mobile/src/ui/components/shadcn_card.dart';
import 'package:mobile/src/ui/widgets/offline_indicator.dart';

/// Test screen for Whisper on-device transcription
class WhisperTestScreen extends StatefulWidget {
  const WhisperTestScreen({Key? key}) : super(key: key);

  @override
  State<WhisperTestScreen> createState() => _WhisperTestScreenState();
}

class _WhisperTestScreenState extends State<WhisperTestScreen> {
  late TranscriptionServiceInterface _transcriptionService;
  late OfflineService _offlineService;
  String _statusMessage = 'Ready to test Whisper';
  bool _isTesting = false;
  final List<String> _transcriptions = [];

  @override
  void initState() {
    super.initState();
    _transcriptionService = locator<TranscriptionServiceInterface>();
    _offlineService = Provider.of<OfflineService>(context, listen: false);
  }

  Future<void> _testWhisperInitialization() async {
    setState(() {
      _isTesting = true;
      _statusMessage = 'Initializing Whisper model...';
    });

    try {
      await _transcriptionService.initializeWhisper();

      setState(() {
        _statusMessage = 'Whisper model initialized successfully!';
        _isTesting = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Whisper model initialized successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing Whisper: $e';
        _isTesting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing Whisper: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testWhisperTranscription() async {
    setState(() {
      _isTesting = true;
      _statusMessage = 'Generating test audio and transcribing...';
    });

    try {
      // First initialize if not already done
      if (!_transcriptionService.isWhisperReady) {
        await _transcriptionService.initializeWhisper();
      }

      // Generate test audio (simulated)
      final testAudio = _generateTestAudio();

      // Save to temporary file
      final tempFile = await _saveAudioToTempFile(testAudio);

      // Transcribe with Whisper
      final result = await _transcriptionService.transcribeAudio(tempFile.path);

      // Clean up
      await tempFile.delete();

      setState(() {
        if (result != null) {
          _transcriptions.add(result.transcriptionText);
          _statusMessage = 'Transcription successful!';
        } else {
          _statusMessage = 'Transcription returned no result';
        }
        _isTesting = false;
      });

      // Show success message
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio transcribed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error during transcription: $e';
        _isTesting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during transcription: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Generate test audio data (silent for this example)
  Float32List _generateTestAudio() {
    const sampleRate = 16000;
    const durationSeconds = 5;
    const sampleCount = sampleRate * durationSeconds;
    return Float32List(sampleCount); // All zeros = silence
  }

  Future<File> _saveAudioToTempFile(Float32List audioData) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/whisper_test_audio.wav');
    final wavBytes = _encodeWavPcm16(audioData);
    await tempFile.writeAsBytes(wavBytes);
    return tempFile;
  }

  Uint8List _encodeWavPcm16(Float32List samples, {int sampleRate = 16000}) {
    final pcmData = ByteData(samples.length * 2);
    for (int i = 0; i < samples.length; i++) {
      var s = samples[i];
      if (s > 1.0) s = 1.0;
      if (s < -1.0) s = -1.0;
      pcmData.setInt16(i * 2, (s * 32767).toInt(), Endian.little);
    }

    final int fileSize = 36 + pcmData.lengthInBytes;
    final header = ByteData(44);

    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // space
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // audio format (1 = PCM)
    header.setUint16(22, 1, Endian.little); // num channels (1 = mono)
    header.setUint32(24, sampleRate, Endian.little); // sample rate
    header.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    header.setUint16(32, 2, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample

    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, pcmData.lengthInBytes, Endian.little);

    final wavBytes = Uint8List(44 + pcmData.lengthInBytes);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());
    wavBytes.setRange(44, wavBytes.length, pcmData.buffer.asUint8List());

    return wavBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50 from Figma
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Whisper Test',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Test on-device Whisper transcription',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const OfflineIndicator(),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ShadcnCard(
                  backgroundColor: Colors.white,
                  borderColor: AppColors.outline,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _statusMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Consumer<OfflineService>(
                          builder: (context, offlineService, child) {
                            return Row(
                              children: [
                                Icon(
                                  offlineService.isOfflineMode
                                      ? Icons.cloud_off
                                      : Icons.cloud_done,
                                  size: 16,
                                  color: offlineService.isOfflineMode
                                      ? AppColors.error
                                      : AppColors.success,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  offlineService.isOfflineMode
                                      ? 'Offline Mode Active'
                                      : 'Online Mode',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: offlineService.isOfflineMode
                                        ? AppColors.error
                                        : AppColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShadcnButton.primary(
                      text: _isTesting
                          ? 'Testing...'
                          : 'Initialize Whisper Model',
                      onPressed: _isTesting ? null : _testWhisperInitialization,
                      isLoading: _isTesting,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ShadcnButton.secondary(
                      text: _isTesting ? 'Testing...' : 'Test Transcription',
                      onPressed: _isTesting ? null : _testWhisperTranscription,
                      isLoading: _isTesting,
                    ),
                  ],
                ),
              ),
              if (_transcriptions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'Transcriptions',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: _transcriptions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ShadcnCard(
                        backgroundColor: Colors.white,
                        borderColor: AppColors.outline,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            _transcriptions[index],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
