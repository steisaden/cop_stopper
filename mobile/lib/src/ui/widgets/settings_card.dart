import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Base settings card component with consistent styling
class SettingsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;
  final VoidCallback? onTap;

  const SettingsCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.children,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: AppSpacing.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.cardBorderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.cardBorderRadius,
        child: Padding(
          padding: AppSpacing.cardPaddingResponsive(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header
              Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingSM,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: AppSpacing.radiusSM,
                    ),
                    child: Icon(
                      icon,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  AppSpacing.horizontalSpaceMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          AppSpacing.verticalSpaceXS,
                          Text(
                            subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (children.isNotEmpty) ...[
                AppSpacing.verticalSpaceMD,
                ...children,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings item within a card
class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const SettingsItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: AppSpacing.radiusSM,
      child: Padding(
        padding: AppSpacing.verticalPaddingSM,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: enabled 
                        ? colorScheme.onSurface 
                        : colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                  if (subtitle != null) ...[
                    AppSpacing.verticalSpaceXS,
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: enabled 
                          ? colorScheme.onSurfaceVariant 
                          : colorScheme.onSurfaceVariant.withOpacity(0.38),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              AppSpacing.horizontalSpaceSM,
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}