import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Network error component for displaying connectivity issues
class NetworkErrorComponent extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showOfflineMode;

  const NetworkErrorComponent({
    Key? key,
    this.message = 'No internet connection',
    this.onRetry,
    this.showOfflineMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(
          color: colorScheme.error,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: colorScheme.onErrorContainer,
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: Text(
                  'Network Error',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
          if (showOfflineMode) ...[
            AppSpacing.verticalSpaceMD,
            Container(
              padding: AppSpacing.paddingSM,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: AppSpacing.radiusSM,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  AppSpacing.horizontalSpaceXS,
                  Expanded(
                    child: Text(
                      'Offline mode enabled. Some features may be limited.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onRetry != null) ...[
            AppSpacing.verticalSpaceMD,
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}