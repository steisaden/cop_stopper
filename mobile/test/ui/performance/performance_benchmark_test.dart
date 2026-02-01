import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/optimized_widgets.dart';
import 'package:mobile/src/ui/widgets/error_card.dart';
import 'package:mobile/src/ui/widgets/storage_warning_banner.dart';
import 'package:mobile/src/ui/widgets/camera_preview_card.dart';
import 'package:mobile/src/ui/screens/navigation_wrapper.dart';

void main() {
  group('Performance Benchmark Tests', () {
    testWidgets('widget build performance benchmark', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ErrorCard(
                  title: 'Test Error',
                  message: 'Performance test error message',
                  severity: ErrorSeverity.error,
                ),
                StorageWarningBanner(
                  usagePercentage: 75.0,
                  availableSpace: '2.5 GB',
                ),
                CameraPreviewCard(
                  isRecording: false,
                  onCameraSwitch: () {},
                  onFlashToggle: () {},
                  onFocusTap: (details) {},
                ),
              ],
            ),
          ),
        ),
      );

      stopwatch.stop();
      final buildTime = stopwatch.elapsedMilliseconds;

      // Should build complex UI in less than 100ms
      expect(buildTime, lessThan(100));
      print('Widget build time: ${buildTime}ms');
    });

    testWidgets('scroll performance benchmark', (tester) async {
      final scrollController = OptimizedScrollController();
      final items = List.generate(1000, (index) => 'Item $index');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedWidgets.lazyListView(
              itemCount: items.length,
              controller: scrollController,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  subtitle: Text('Subtitle for ${items[index]}'),
                );
              },
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Perform rapid scrolling
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -1000),
        1000,
      );
      await tester.pumpAndSettle();

      stopwatch.stop();
      final scrollTime = stopwatch.elapsedMilliseconds;

      // Should handle rapid scrolling smoothly
      expect(scrollTime, lessThan(500));
      print('Scroll performance time: ${scrollTime}ms');

      scrollController.dispose();
    });

    testWidgets('memory usage benchmark', (tester) async {
      MemoryMonitor.reset();

      // Create multiple widgets to test memory usage
      for (int i = 0; i < 100; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: List.generate(10, (index) {
                  MemoryMonitor.trackWidget(ErrorCard);
                  return ErrorCard(
                    title: 'Error $index',
                    message: 'Message $index',
                  );
                }),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      final memoryUsage = MemoryMonitor.getMemoryUsage();
      
      // Should track memory usage properly
      expect(memoryUsage.totalWidgets, greaterThan(0));
      expect(memoryUsage.mostUsedWidgetType, equals(ErrorCard));
      
      print('Total widgets created: ${memoryUsage.totalWidgets}');
      print('Most used widget: ${memoryUsage.mostUsedWidgetType}');
    });

    testWidgets('animation performance benchmark', (tester) async {
      bool isExpanded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: OptimizedWidgets.optimizedAnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isExpanded ? 300 : 100,
                  height: isExpanded ? 300 : 100,
                  color: isExpanded ? Colors.blue : Colors.red,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: const Center(
                      child: Text('Tap me'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Trigger multiple animations
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Tap me'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      final animationTime = stopwatch.elapsedMilliseconds;
      
      // Should handle multiple animations efficiently
      expect(animationTime, lessThan(5000)); // 10 animations * 300ms + overhead
      print('Animation performance time: ${animationTime}ms');
    });

    testWidgets('rebuild optimization benchmark', (tester) async {
      int buildCount = 0;
      String testValue = 'initial';

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    RebuildOptimizer(
                      dependencies: [testValue],
                      child: Builder(
                        builder: (context) {
                          buildCount++;
                          return Text('Build count: $buildCount, Value: $testValue');
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          testValue = 'updated';
                        });
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      final initialBuildCount = buildCount;

      // Trigger multiple state changes with same value
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Update'));
        await tester.pump();
      }

      // Should only rebuild when dependencies actually change
      expect(buildCount, equals(initialBuildCount + 1));
      print('Rebuild optimization: ${buildCount} builds for 5 state changes');
    });

    testWidgets('performance monitoring benchmark', (tester) async {
      PerformanceMetrics? lastMetrics;

      await tester.pumpWidget(
        MaterialApp(
          home: PerformanceMonitor(
            enabled: true,
            onMetricsUpdate: (metrics) {
              lastMetrics = metrics;
            },
            child: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );

      // Let it run for a bit to collect metrics
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60fps
      }

      if (lastMetrics != null) {
        expect(lastMetrics!.averageFps, greaterThan(30.0));
        expect(lastMetrics!.isPerformanceAcceptable, isTrue);
        print('Average FPS: ${lastMetrics!.averageFps.toStringAsFixed(2)}');
        print('Performance good: ${lastMetrics!.isPerformanceGood}');
      }
    });

    testWidgets('navigation performance benchmark', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Rapidly switch between tabs
      final tabs = ['Record', 'Monitor', 'Documents', 'History', 'Settings'];
      
      for (int cycle = 0; cycle < 5; cycle++) {
        for (final tab in tabs) {
          final tabFinder = find.text(tab);
          if (tabFinder.evaluate().isNotEmpty) {
            await tester.tap(tabFinder);
            await tester.pump();
          }
        }
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      final navigationTime = stopwatch.elapsedMilliseconds;
      
      // Should handle rapid navigation efficiently
      expect(navigationTime, lessThan(2000));
      print('Navigation performance time: ${navigationTime}ms');
    });

    testWidgets('cleanup performance benchmark', (tester) async {
      // Create many widgets and register cleanup callbacks
      for (int i = 0; i < 100; i++) {
        SessionCleanup.registerCleanup(() {
          // Simulate cleanup work
        });
      }

      final stopwatch = Stopwatch()..start();
      SessionCleanup.performCleanup();
      stopwatch.stop();

      final cleanupTime = stopwatch.elapsedMilliseconds;
      
      // Should perform cleanup quickly
      expect(cleanupTime, lessThan(100));
      print('Cleanup performance time: ${cleanupTime}ms');
    });

    testWidgets('image caching performance benchmark', (tester) async {
      const imageUrl = 'https://via.placeholder.com/150';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: List.generate(10, (index) {
                return OptimizedWidgets.cachedImage(
                  imageUrl: imageUrl,
                  width: 150,
                  height: 150,
                );
              }),
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      // Clear cache and reload
      SessionCleanup.clearImageCache();
      await tester.pump();
      
      stopwatch.stop();
      final cacheTime = stopwatch.elapsedMilliseconds;
      
      // Should handle cache operations efficiently
      expect(cacheTime, lessThan(50));
      print('Image cache performance time: ${cacheTime}ms');
    });

    testWidgets('overall app performance benchmark', (tester) async {
      final stopwatch = Stopwatch()..start();

      // Simulate complete app usage
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Navigate through all screens
      final screens = ['Record', 'Monitor', 'Documents', 'History', 'Settings'];
      for (final screen in screens) {
        final screenFinder = find.text(screen);
        if (screenFinder.evaluate().isNotEmpty) {
          await tester.tap(screenFinder);
          await tester.pumpAndSettle();
        }
      }

      // Simulate user interactions
      final recordButton = find.byIcon(Icons.fiber_manual_record);
      if (recordButton.evaluate().isNotEmpty) {
        await tester.tap(recordButton);
        await tester.pumpAndSettle();
      }

      stopwatch.stop();
      final totalTime = stopwatch.elapsedMilliseconds;

      // Should complete full app interaction in reasonable time
      expect(totalTime, lessThan(3000));
      print('Overall app performance time: ${totalTime}ms');
    });
  });
}