import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';

/// A scaffold wrapper with the dark mesh background from the Stitch design.
///
/// Provides common glass screen structure with:
/// - Dark mesh gradient background
/// - Safe area handling
/// - Support for glass app bar and bottom nav
///
/// Example:
/// ```dart
/// GlassScaffold(
///   appBar: GlassAppBar(title: 'Dashboard'),
///   body: YourContent(),
///   bottomNavigationBar: GlassBottomNav(...),
/// )
/// ```
class GlassScaffold extends StatelessWidget {
  /// The primary content of the scaffold
  final Widget body;

  /// Optional app bar (typically GlassAppBar)
  final PreferredSizeWidget? appBar;

  /// Optional bottom navigation bar (typically GlassBottomNav)
  final Widget? bottomNavigationBar;

  /// Optional floating action button
  final Widget? floatingActionButton;

  /// FAB location
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Whether to show the mesh gradient background
  final bool showMeshBackground;

  /// Background color override (defaults to glassBackground)
  final Color? backgroundColor;

  /// Whether to extend body behind app bar
  final bool extendBodyBehindAppBar;

  /// Whether to extend body behind bottom nav
  final bool extendBody;

  /// Whether to apply safe area padding
  final bool useSafeArea;

  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showMeshBackground = true,
    this.backgroundColor,
    this.extendBodyBehindAppBar = true,
    this.extendBody = true,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    // Set system UI to match dark theme
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.glassBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    Widget content = body;

    if (showMeshBackground) {
      content = Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.glassBackground,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.glassPrimary.withOpacity(0.08),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.8, -0.5),
              radius: 0.8,
              colors: [
                Colors.white.withOpacity(0.03),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3],
            ),
          ),
          child: content,
        ),
      );
    } else {
      content = Container(
        color: backgroundColor ?? AppColors.glassBackground,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
    );
  }
}
