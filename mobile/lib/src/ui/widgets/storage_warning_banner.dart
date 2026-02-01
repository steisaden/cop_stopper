import 'package:flutter/material.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Storage warning banner with cleanup options and progress indicators
class StorageWarningBanner extends StatelessWidget {
  final double usagePercentage;
  final String availableSpace;
  final List<CleanupOption> cleanupOptions;

  const StorageWarningBanner({
    Key? key,
    required this.usagePercentage,
    required this.availableSpace,
    this.cleanupOptions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCritical = usagePercentage > 90;
    final isWarning = usagePercentage > 75;

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isCritical
            ? colorScheme.errorContainer
            : isWarning
                ? colorScheme.errorContainer.withValues(alpha: 0.7)
                : colorScheme.primaryContainer,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(
          color: isCritical
              ? colorScheme.error
              : isWarning
                  ? colorScheme.error.withValues(alpha: 0.7)
                  : colorScheme.primary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCritical
                    ? Icons.sd_card_alert
                    : isWarning
                        ? Icons.sd_storage
                        : Icons.sd_card,
                color: isCritical
                    ? colorScheme.onErrorContainer
                    : isWarning
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: Text(
                  isCritical
                      ? 'Storage Critical'
                      : isWarning
                          ? 'Storage Warning'
                          : 'Storage Information',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isCritical
                        ? colorScheme.onErrorContainer
                        : isWarning
                            ? colorScheme.onErrorContainer
                            : colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          LinearProgressIndicator(
            value: usagePercentage / 100,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCritical
                  ? colorScheme.error
                  : isWarning
                      ? colorScheme.error
                      : colorScheme.primary,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            'Usage: ${usagePercentage.toStringAsFixed(1)}% ($availableSpace remaining)',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isCritical
                  ? colorScheme.onErrorContainer
                  : isWarning
                      ? colorScheme.onErrorContainer
                      : colorScheme.onPrimaryContainer,
            ),
          ),
          if (cleanupOptions.isNotEmpty) ...[
            AppSpacing.verticalSpaceMD,
            Text(
              'Cleanup Options:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isCritical
                    ? colorScheme.onErrorContainer
                    : isWarning
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: cleanupOptions.map((option) {
                return OutlinedButton.icon(
                  onPressed: option.onPressed,
                  icon: Icon(option.icon, size: 16),
                  label: Text(option.label),
                  style: OutlinedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Data model for cleanup options
class CleanupOption {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  CleanupOption({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}