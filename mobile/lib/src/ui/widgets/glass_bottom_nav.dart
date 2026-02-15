import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Data class for a navigation item in GlassBottomNav
class GlassNavItem {
  /// Icon for unselected state
  final IconData icon;

  /// Optional icon for selected state
  final IconData? activeIcon;

  /// Label text
  final String label;

  /// Optional badge count
  final int? badgeCount;

  const GlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}

/// A frosted glass bottom navigation bar matching the Stitch design.
///
/// Example:
/// ```dart
/// GlassBottomNav(
///   currentIndex: 0,
///   onTap: (index) => setState(() => _currentIndex = index),
///   items: [
///     GlassNavItem(icon: Icons.grid_view, label: 'Home'),
///     GlassNavItem(icon: Icons.folder_open, label: 'Files'),
///     GlassNavItem(icon: Icons.map, label: 'Map'),
///     GlassNavItem(icon: Icons.person, label: 'Profile'),
///   ],
/// )
/// ```
class GlassBottomNav extends StatelessWidget {
  /// List of navigation items
  final List<GlassNavItem> items;

  /// Currently selected index
  final int currentIndex;

  /// Callback when an item is tapped
  final ValueChanged<int>? onTap;

  /// Height of the navigation bar
  final double height;

  /// Blur sigma for frosted effect
  final double blurSigma;

  const GlassBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.height = 80,
    this.blurSigma = 25,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          height: height + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: AppColors.glassSurfaceFrosted,
            border: const Border(
              top: BorderSide(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return _NavItem(
                item: item,
                isSelected: isSelected,
                onTap: () => onTap?.call(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final GlassNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                color: isSelected
                    ? AppColors.glassPrimary
                    : Colors.white.withOpacity(0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.glassPrimary : Colors.transparent,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.glassPrimary.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
