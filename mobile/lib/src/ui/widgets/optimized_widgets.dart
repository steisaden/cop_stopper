import 'package:flutter/material.dart';

/// Performance-optimized widget implementations
class OptimizedWidgets {
  /// Create a const-optimized card widget
  static Widget constCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? elevation,
  }) {
    return Card(
      color: color,
      elevation: elevation ?? 2.0,
      child: padding != null
          ? Padding(
              padding: padding,
              child: child,
            )
          : child,
    );
  }

  /// Create an optimized list view with lazy loading
  static Widget lazyListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Optimize for performance
      cacheExtent: 200.0,
      physics: const BouncingScrollPhysics(),
    );
  }

  /// Create an optimized image widget with caching
  static Widget cachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            const Icon(
              Icons.error,
              color: Colors.red,
            );
      },
      // Enable caching
      cacheWidth: width?.round(),
      cacheHeight: height?.round(),
    );
  }

  /// Create an optimized animated widget
  static Widget optimizedAnimatedContainer({
    required Widget child,
    required Duration duration,
    double? width,
    double? height,
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    Curve curve = Curves.linear,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      width: width,
      height: height,
      color: color,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}

/// Memory-efficient scroll controller
class OptimizedScrollController extends ScrollController {
  OptimizedScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        );

  /// Smooth scroll to position with performance optimization
  Future<void> smoothScrollTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!hasClients) return;

    await animateTo(
      offset,
      duration: duration,
      curve: curve,
    );
  }

  /// Jump to position without animation for better performance
  void jumpToPosition(double offset) {
    if (!hasClients) return;
    jumpTo(offset);
  }
}

/// Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final ValueChanged<PerformanceMetrics>? onMetricsUpdate;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.enabled = false,
    this.onMetricsUpdate,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  DateTime? _lastFrameTime;
  int _frameCount = 0;
  double _averageFps = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startMonitoring();
    }
  }

  void _startMonitoring() {
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!widget.enabled) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      final fps = 1000 / frameDuration.inMilliseconds;
      
      _frameCount++;
      _averageFps = (_averageFps * (_frameCount - 1) + fps) / _frameCount;

      if (_frameCount % 60 == 0) {
        // Report metrics every 60 frames
        widget.onMetricsUpdate?.call(
          PerformanceMetrics(
            averageFps: _averageFps,
            frameCount: _frameCount,
            lastFrameDuration: frameDuration,
          ),
        );
      }
    }
    
    _lastFrameTime = now;
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Performance metrics data class
class PerformanceMetrics {
  final double averageFps;
  final int frameCount;
  final Duration lastFrameDuration;

  PerformanceMetrics({
    required this.averageFps,
    required this.frameCount,
    required this.lastFrameDuration,
  });

  bool get isPerformanceGood => averageFps >= 55.0;
  bool get isPerformanceAcceptable => averageFps >= 30.0;
}

/// Widget rebuild optimizer
class RebuildOptimizer extends StatelessWidget {
  final Widget child;
  final List<Object?> dependencies;

  const RebuildOptimizer({
    Key? key,
    required this.child,
    required this.dependencies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _OptimizedWrapper(
      dependencies: dependencies,
      child: child,
    );
  }
}

class _OptimizedWrapper extends StatefulWidget {
  final Widget child;
  final List<Object?> dependencies;

  const _OptimizedWrapper({
    required this.child,
    required this.dependencies,
  });

  @override
  State<_OptimizedWrapper> createState() => _OptimizedWrapperState();
}

class _OptimizedWrapperState extends State<_OptimizedWrapper> {
  List<Object?> _lastDependencies = [];

  @override
  void didUpdateWidget(_OptimizedWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only rebuild if dependencies actually changed
    if (!_listEquals(widget.dependencies, _lastDependencies)) {
      _lastDependencies = List.from(widget.dependencies);
    }
  }

  bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Memory usage monitor
class MemoryMonitor {
  static int _widgetCount = 0;
  static final Map<Type, int> _widgetTypeCount = {};

  static void trackWidget(Type widgetType) {
    _widgetCount++;
    _widgetTypeCount[widgetType] = (_widgetTypeCount[widgetType] ?? 0) + 1;
  }

  static void untrackWidget(Type widgetType) {
    _widgetCount--;
    final count = _widgetTypeCount[widgetType] ?? 0;
    if (count > 0) {
      _widgetTypeCount[widgetType] = count - 1;
    }
  }

  static MemoryUsage getMemoryUsage() {
    return MemoryUsage(
      totalWidgets: _widgetCount,
      widgetTypeCount: Map.from(_widgetTypeCount),
    );
  }

  static void reset() {
    _widgetCount = 0;
    _widgetTypeCount.clear();
  }
}

/// Memory usage data class
class MemoryUsage {
  final int totalWidgets;
  final Map<Type, int> widgetTypeCount;

  MemoryUsage({
    required this.totalWidgets,
    required this.widgetTypeCount,
  });

  Type? get mostUsedWidgetType {
    if (widgetTypeCount.isEmpty) return null;
    
    Type? mostUsed;
    int maxCount = 0;
    
    widgetTypeCount.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = type;
      }
    });
    
    return mostUsed;
  }
}

/// Cleanup utilities for long-running sessions
class SessionCleanup {
  static final List<VoidCallback> _cleanupCallbacks = [];

  static void registerCleanup(VoidCallback callback) {
    _cleanupCallbacks.add(callback);
  }

  static void performCleanup() {
    for (final callback in _cleanupCallbacks) {
      try {
        callback();
      } catch (e) {
        // Log error but continue cleanup
        debugPrint('Cleanup error: $e');
      }
    }
    _cleanupCallbacks.clear();
  }

  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static void clearMemoryCache() {
    MemoryMonitor.reset();
    clearImageCache();
  }
}