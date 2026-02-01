import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Theme switcher widget for changing between light, dark, and system themes
class ThemeSwitcher extends StatelessWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ThemeSwitcher({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            _ThemeOption(
              icon: Icons.brightness_auto,
              label: 'System',
              isSelected: currentTheme == ThemeMode.system,
              onTap: () => onThemeChanged(ThemeMode.system),
            ),
            AppSpacing.horizontalSpaceMD,
            _ThemeOption(
              icon: Icons.wb_sunny,
              label: 'Light',
              isSelected: currentTheme == ThemeMode.light,
              onTap: () => onThemeChanged(ThemeMode.light),
            ),
            AppSpacing.horizontalSpaceMD,
            _ThemeOption(
              icon: Icons.nights_stay,
              label: 'Dark',
              isSelected: currentTheme == ThemeMode.dark,
              onTap: () => onThemeChanged(ThemeMode.dark),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        _buildPreviewCards(context),
      ],
    );
  }

  Widget _buildPreviewCards(BuildContext context) {
    final isDark = currentTheme == ThemeMode.dark ||
        (currentTheme == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimaryContainer
                  : AppColors.primaryContainer,
              borderRadius: AppSpacing.radiusSM,
            ),
            child: Text(
              'This is how the app will look with the selected theme',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkOnPrimaryContainer
                    : AppColors.onPrimaryContainer,
              ),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: isDark ? AppColors.darkOnPrimary : AppColors.onPrimary,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: Text(
                  'Theme applied successfully',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.buttonBorderRadius,
        child: Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: AppSpacing.buttonBorderRadius,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                size: 32,
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme customization panel for accent color selection
class ThemeCustomizationPanel extends StatelessWidget {
  final Color currentAccentColor;
  final ValueChanged<Color> onAccentColorChanged;

  const ThemeCustomizationPanel({
    Key? key,
    required this.currentAccentColor,
    required this.onAccentColorChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize Theme',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.verticalSpaceMD,
        Text(
          'Accent Color',
          style: AppTextStyles.titleMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ColorOption(
              color: AppColors.primary,
              isSelected: currentAccentColor == AppColors.primary,
              onTap: () => onAccentColorChanged(AppColors.primary),
            ),
            _ColorOption(
              color: Colors.deepPurple,
              isSelected: currentAccentColor == Colors.deepPurple,
              onTap: () => onAccentColorChanged(Colors.deepPurple),
            ),
            _ColorOption(
              color: Colors.teal,
              isSelected: currentAccentColor == Colors.teal,
              onTap: () => onAccentColorChanged(Colors.teal),
            ),
            _ColorOption(
              color: Colors.orange,
              isSelected: currentAccentColor == Colors.orange,
              onTap: () => onAccentColorChanged(Colors.orange),
            ),
            _ColorOption(
              color: Colors.pink,
              isSelected: currentAccentColor == Colors.pink,
              onTap: () => onAccentColorChanged(Colors.pink),
            ),
            _ColorOption(
              color: Colors.indigo,
              isSelected: currentAccentColor == Colors.indigo,
              onTap: () => onAccentColorChanged(Colors.indigo),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: ThemeData.estimateBrightnessForColor(color) ==
                        Brightness.light
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}

/// High contrast theme toggle
class HighContrastToggle extends StatelessWidget {
  final bool isHighContrastEnabled;
  final ValueChanged<bool> onChanged;

  const HighContrastToggle({
    Key? key,
    required this.isHighContrastEnabled,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'High Contrast Mode',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                'Increase color contrast for better visibility',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.horizontalSpaceMD,
        Switch(
          value: isHighContrastEnabled,
          onChanged: onChanged,
          activeThumbColor: colorScheme.primary,
        ),
      ],
    );
  }
}