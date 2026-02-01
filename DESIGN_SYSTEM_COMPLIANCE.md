# Design System Compliance

This document outlines the compliance of the app's design system with the Figma design specifications.

## Colors

The app uses a centralized color system defined in `mobile/lib/src/ui/app_colors.dart`. The colors are defined for both light and dark themes and are based on the Figma design system.

### Light Theme Colors

| Name | Hex | Figma Value |
| --- | --- | --- |
| primary | #030213 | Very dark blue/black |
| onPrimary | #FFFFFF | White |
| primaryContainer | #F1F2F6 | Light blue-gray |
| onPrimaryContainer | #030213 | Very dark blue/black |
| secondary | #F1F2F6 | Light grayish blue |
| onSecondary | #030213 | Very dark blue/black |
| secondaryContainer | #ECECF0 | Muted color |
| onSecondaryContainer | #717182 | Muted foreground |
| surface | #FFFFFF | White |
| onSurface | #030213 | Very dark blue/black |
| surfaceVariant | #F3F3F5 | Input background |
| onSurfaceVariant | #717182 | Muted foreground |
| background | #FFFFFF | White |
| onBackground | #030213 | Very dark blue/black |
| outline | #1A000000 | rgba(0, 0, 0, 0.1) |

### Dark Theme Colors

| Name | Hex | Figma oklch Value |
| --- | --- | --- |
| darkPrimary | #FFFFFF | White in dark mode |
| darkOnPrimary | #252525 | oklch(0.145 0 0) |
| darkPrimaryContainer | #454545 | oklch(0.269 0 0) |
| darkOnPrimaryContainer | #FFFFFF | White |
| darkSecondary | #454545 | oklch(0.269 0 0) |
| darkOnSecondary | #FFFFFF | White |
| darkSecondaryContainer | #343434 | oklch(0.205 0 0) |
| darkOnSecondaryContainer | #FFFFFF | White |
| darkSurface | #343434 | oklch(0.205 0 0) |
| darkOnSurface | #FFFFFF | White |
| darkSurfaceVariant | #454545 | oklch(0.269 0 0) |
| darkOnSurfaceVariant | #CAC4D0 | -- |
| darkBackground | #252525 | oklch(0.145 0 0) |
| darkOnBackground | #FFFFFF | White |
| darkOutline | #454545 | oklch(0.269 0 0) |

## Typography

The app's typography is defined in `mobile/lib/src/ui/app_text_styles.dart` and follows the Material Design 3 typography scale, with adjustments to match the Figma design system.

| Name | Font Size | Font Weight | Figma Value |
| --- | --- | --- | --- |
| displayLarge | 48 | 500 (medium) | 2xl |
| displayMedium | 36 | 500 (medium) | xl |
| displaySmall | 28 | 500 (medium) | lg |
| headlineLarge | 24 | 500 (medium) | 2xl |
| headlineMedium | 20 | 500 (medium) | xl |
| headlineSmall | 18 | 500 (medium) | lg |
| titleLarge | 18 | 500 (medium) | lg |
| titleMedium | 16 | 500 (medium) | base |
| titleSmall | 14 | 500 (medium) | sm |
| labelLarge | 14 | 500 (medium) | sm |
| labelMedium | 12 | 500 (medium) | xs |
| labelSmall | 11 | 500 (medium) | -- |
| bodyLarge | 16 | 400 (normal) | base |
| bodyMedium | 14 | 400 (normal) | sm |
| bodySmall | 12 | 400 (normal) | xs |

## Spacing

The app uses an 8pt grid system for spacing, defined in `mobile/lib/src/ui/app_spacing.dart`.

| Name | Value (pt) |
| --- | --- |
| xs | 4 |
| sm | 8 |
| md | 16 |
| lg | 24 |
| xl | 32 |
| xxl | 48 |
| xxxl | 64 |

### Component-specific Spacing

| Name | Value (pt) | Figma Value |
| --- | --- | --- |
| cardPadding | 24 | 24pt |
| cardRadius | 10 | 0.625rem |
| buttonPadding | 16 | 16pt |
| buttonRadius | 10 | 0.625rem |

## Components

### ShadcnButton

A custom button component inspired by shadcn/ui. It supports different variants:

-   `ShadcnButton.primary`
-   `ShadcnButton.secondary`
-   `ShadcnButton.destructive`
-   `ShadcnButton.outline`
-   `ShadcnButton.ghost`
-   `ShadcnButton.link`

### ShadcnCard

A custom card component with a border radius of 10px, as specified in the Figma design.

### ShadcnInput

A custom input component that matches the Figma design for text fields.

### CustomToggleSwitch

A custom toggle switch with an iOS-style animation that matches the Figma design.