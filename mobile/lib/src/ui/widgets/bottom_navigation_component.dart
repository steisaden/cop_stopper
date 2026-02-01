import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../../blocs/navigation/navigation_bloc.dart';
import '../../blocs/navigation/navigation_event.dart';
import '../../blocs/navigation/navigation_state.dart';

/// Custom bottom navigation component with glass morphism effect and haptic feedback
/// Provides 6 tabs: Record, Monitor, Officers, Documents, History, Settings
class BottomNavigationComponent extends StatelessWidget {
  const BottomNavigationComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Container(
          height: AppSpacing.bottomNavHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.glassMorphismBackground
                : AppColors.darkGlassMorphismBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.md),
              topRight: Radius.circular(AppSpacing.md),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.md),
              topRight: Radius.circular(AppSpacing.md),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: AppSpacing.bottomNavPaddingWithSafeArea(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavigationItem(
                      icon: Icons.shield_outlined,
                      activeIcon: Icons.shield,
                      label: 'Record',
                      tab: NavigationTab.record,
                      isActive: state.activeTab == NavigationTab.record,
                      showRecordingIndicator: state.isRecording,
                    ),
                    _NavigationItem(
                      icon: Icons.visibility_outlined,
                      activeIcon: Icons.visibility,
                      label: 'Monitor',
                      tab: NavigationTab.monitor,
                      isActive: state.activeTab == NavigationTab.monitor,
                      showRecordingIndicator: state.isRecording,
                    ),
                    _NavigationItem(
                      icon: Icons.badge_outlined,
                      activeIcon: Icons.badge,
                      label: 'Officers',
                      tab: NavigationTab.officers,
                      isActive: state.activeTab == NavigationTab.officers,
                      showRecordingIndicator: state.isRecording,
                    ),
                    _NavigationItem(
                      icon: Icons.folder_outlined,
                      activeIcon: Icons.folder,
                      label: 'Documents',
                      tab: NavigationTab.documents,
                      isActive: state.activeTab == NavigationTab.documents,
                      showRecordingIndicator: state.isRecording,
                    ),
                    _NavigationItem(
                      icon: Icons.history_outlined,
                      activeIcon: Icons.history,
                      label: 'History',
                      tab: NavigationTab.history,
                      isActive: state.activeTab == NavigationTab.history,
                      showRecordingIndicator: state.isRecording,
                    ),
                    _NavigationItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      label: 'Settings',
                      tab: NavigationTab.settings,
                      isActive: state.activeTab == NavigationTab.settings,
                      showRecordingIndicator: state.isRecording,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final NavigationTab tab;
  final bool isActive;
  final bool showRecordingIndicator;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.tab,
    required this.isActive,
    required this.showRecordingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          // Provide haptic feedback
          HapticFeedback.selectionClick();
          
          // Dispatch navigation event
          context.read<NavigationBloc>().add(NavigationTabChanged(tab));
        },
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: AppSpacing.animationDurationShort,
                    child: Icon(
                      isActive ? activeIcon : icon,
                      key: ValueKey(isActive),
                      size: AppSpacing.tabIconSize,
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                  // Recording indicator
                  if (showRecordingIndicator)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.recording,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.recording.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.verticalSpaceXS,
              AnimatedDefaultTextStyle(
                duration: AppSpacing.animationDurationShort,
                style: AppTextStyles.navigationLabel.copyWith(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withOpacity(0.6),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}