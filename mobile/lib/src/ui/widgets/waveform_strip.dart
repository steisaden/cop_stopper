import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_colors.dart';

/// A minimal audio waveform visualization strip.
///
/// Displays amplitude data as vertical bars with smooth animation.
///
/// Example:
/// ```dart
/// WaveformStrip(
///   amplitudes: [0.2, 0.5, 0.8, 0.3, ...],
///   color: AppColors.glassPrimary,
///   height: 40,
/// )
/// ```
class WaveformStrip extends StatelessWidget {
  /// List of amplitude values (0.0 to 1.0)
  final List<double> amplitudes;

  /// Color of the waveform bars
  final Color? color;

  /// Height of the waveform
  final double height;

  /// Width of each bar
  final double barWidth;

  /// Spacing between bars
  final double barSpacing;

  /// Number of bars to display
  final int barCount;

  /// Minimum bar height as percentage
  final double minBarHeight;

  const WaveformStrip({
    super.key,
    required this.amplitudes,
    this.color,
    this.height = 40,
    this.barWidth = 2,
    this.barSpacing = 2,
    this.barCount = 40,
    this.minBarHeight = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.glassPrimary;

    // Sample or interpolate amplitudes to match bar count
    final sampledAmplitudes = _sampleAmplitudes();

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (index) {
          final amplitude = index < sampledAmplitudes.length
              ? sampledAmplitudes[index].clamp(minBarHeight, 1.0)
              : minBarHeight;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: barSpacing / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: barWidth,
              height: height * amplitude,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.3 + (amplitude * 0.7)),
                borderRadius: BorderRadius.circular(barWidth / 2),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<double> _sampleAmplitudes() {
    if (amplitudes.isEmpty) {
      return List.filled(barCount, minBarHeight);
    }

    if (amplitudes.length == barCount) {
      return amplitudes;
    }

    // Simple sampling/interpolation
    final result = <double>[];
    final step = amplitudes.length / barCount;

    for (int i = 0; i < barCount; i++) {
      final index = (i * step).floor().clamp(0, amplitudes.length - 1);
      result.add(amplitudes[index]);
    }

    return result;
  }
}

/// An animated waveform that simulates live audio input
class LiveWaveform extends StatefulWidget {
  /// Color of the waveform
  final Color? color;

  /// Height of the waveform
  final double height;

  /// Whether the waveform is actively animating
  final bool isActive;

  /// Number of bars
  final int barCount;

  const LiveWaveform({
    super.key,
    this.color,
    this.height = 40,
    this.isActive = true,
    this.barCount = 40,
  });

  @override
  State<LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends State<LiveWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _amplitudes;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _amplitudes = List.generate(widget.barCount, (_) => 0.1);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    if (widget.isActive) {
      _controller.repeat();
      _controller.addListener(_updateAmplitudes);
    }
  }

  @override
  void didUpdateWidget(LiveWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
        _controller.addListener(_updateAmplitudes);
      } else {
        _controller.stop();
        _controller.removeListener(_updateAmplitudes);
        setState(() {
          _amplitudes = List.generate(widget.barCount, (_) => 0.1);
        });
      }
    }
  }

  void _updateAmplitudes() {
    if (!mounted) return;

    setState(() {
      for (int i = 0; i < _amplitudes.length; i++) {
        // Create wave-like pattern with some randomness
        final phase = (i / widget.barCount) * math.pi * 2;
        final wave = math.sin(phase + _controller.value * math.pi * 4) * 0.3;
        final randomComponent = (_random.nextDouble() - 0.5) * 0.3;
        _amplitudes[i] = (0.3 + wave + randomComponent).clamp(0.1, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WaveformStrip(
      amplitudes: _amplitudes,
      color: widget.color,
      height: widget.height,
      barCount: widget.barCount,
    );
  }
}
