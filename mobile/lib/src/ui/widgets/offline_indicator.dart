import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_spacing.dart';
import 'package:mobile/src/services/offline_service.dart';

/// Widget that shows an offline mode indicator when the app is in offline mode
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineService>(
      builder: (context, offlineService, child) {
        if (!offlineService.isOfflineMode) {
          // Don't show anything when online
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning,
            borderRadius: BorderRadius.circular(AppSpacing.figmaRadius),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_off,
                color: AppColors.onWarning,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'OFFLINE MODE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onWarning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget that shows a connectivity status indicator (online/offline)
class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineService>(
      builder: (context, offlineService, child) {
        final isOffline = offlineService.isOfflineMode;
        final indicatorColor = isOffline ? AppColors.error : AppColors.success;
        final indicatorText = isOffline ? 'Offline' : 'Connected';
        final icon = isOffline ? Icons.signal_wifi_off : Icons.wifi;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs / 2,
          ),
          decoration: BoxDecoration(
            color: indicatorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: indicatorColor,
              ),
              const SizedBox(width: AppSpacing.xs / 2),
              Text(
                indicatorText,
                style: AppTextStyles.labelSmall.copyWith(
                  color: indicatorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}