import 'package:flutter/material.dart';
import '../app_spacing.dart';

/// Responsive grid system that adapts to different screen sizes
/// Provides responsive breakpoints for phone, tablet, and desktop layouts
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  /// List of widgets to display in the grid
  final List<Widget> children;

  /// Number of columns (null for responsive behavior)
  final int? crossAxisCount;

  /// Aspect ratio of each grid item
  final double childAspectRatio;

  /// Spacing between columns
  final double? crossAxisSpacing;

  /// Spacing between rows
  final double? mainAxisSpacing;

  /// Padding around the grid
  final EdgeInsetsGeometry? padding;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Whether the grid should shrink wrap its content
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final int columns = crossAxisCount ?? _getResponsiveColumnCount(context);
    
    return Padding(
      padding: padding ?? AppSpacing.paddingMD,
      child: GridView.builder(
        physics: physics,
        shrinkWrap: shrinkWrap,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing ?? AppSpacing.sm,
          mainAxisSpacing: mainAxisSpacing ?? AppSpacing.sm,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  /// Determines the number of columns based on screen width
  int _getResponsiveColumnCount(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= AppSpacing.desktopBreakpoint) {
      return 4; // Desktop: 4 columns
    } else if (screenWidth >= AppSpacing.tabletBreakpoint) {
      return 3; // Tablet: 3 columns
    } else if (screenWidth >= AppSpacing.mobileBreakpoint) {
      return 2; // Large mobile: 2 columns
    } else {
      return 1; // Small mobile: 1 column
    }
  }
}

/// Responsive layout builder that provides different layouts for different screen sizes
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Layout for mobile screens
  final Widget mobile;

  /// Layout for tablet screens (falls back to mobile if null)
  final Widget? tablet;

  /// Layout for desktop screens (falls back to tablet or mobile if null)
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppSpacing.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= AppSpacing.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive card grid specifically designed for card layouts
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.cards,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  /// List of card widgets to display
  final List<Widget> cards;

  /// Padding around the grid
  final EdgeInsetsGeometry? padding;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Whether the grid should shrink wrap its content
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ListView.separated(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding ?? AppSpacing.paddingMD,
      itemCount: cards.length,
      separatorBuilder: (context, index) => AppSpacing.verticalSpaceSM,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return ResponsiveGrid(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: cards,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return ResponsiveGrid(
      crossAxisCount: 3,
      childAspectRatio: 1.1,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: cards,
    );
  }
}

/// Responsive container that adapts its layout based on screen size
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.alignment,
  });

  /// Child widget to display
  final Widget child;

  /// Maximum width of the container
  final double? maxWidth;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Alignment of the child
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerMaxWidth = maxWidth ?? _getResponsiveMaxWidth(screenWidth);

    return Container(
      width: double.infinity,
      margin: margin,
      alignment: alignment ?? Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: containerMaxWidth),
        child: Container(
          padding: padding ?? _getResponsivePadding(context),
          child: child,
        ),
      ),
    );
  }

  double _getResponsiveMaxWidth(double screenWidth) {
    if (screenWidth >= AppSpacing.desktopBreakpoint) {
      return AppSpacing.desktopBreakpoint * 0.8; // 80% of desktop breakpoint
    } else if (screenWidth >= AppSpacing.tabletBreakpoint) {
      return AppSpacing.tabletBreakpoint * 0.9; // 90% of tablet breakpoint
    } else {
      return double.infinity; // Full width on mobile
    }
  }

  EdgeInsetsGeometry _getResponsivePadding(BuildContext context) {
    return AppSpacing.cardPaddingResponsive(context);
  }
}

/// Safe area wrapper that handles notches and dynamic islands
class SafeAreaWrapper extends StatelessWidget {
  const SafeAreaWrapper({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
  });

  /// Child widget to wrap
  final Widget child;

  /// Whether to apply safe area to the top
  final bool top;

  /// Whether to apply safe area to the bottom
  final bool bottom;

  /// Whether to apply safe area to the left
  final bool left;

  /// Whether to apply safe area to the right
  final bool right;

  /// Minimum padding to apply
  final EdgeInsets minimum;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      child: child,
    );
  }
}

/// Orientation-aware layout that adapts to device orientation changes
class OrientationAwareLayout extends StatelessWidget {
  const OrientationAwareLayout({
    super.key,
    required this.portrait,
    this.landscape,
  });

  /// Layout for portrait orientation
  final Widget portrait;

  /// Layout for landscape orientation (falls back to portrait if null)
  final Widget? landscape;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}

/// Responsive breakpoint helper class
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppSpacing.tabletBreakpoint;
  }

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= AppSpacing.tabletBreakpoint && width < AppSpacing.desktopBreakpoint;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppSpacing.desktopBreakpoint;
  }

  /// Get current screen type
  static ScreenType getScreenType(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    
    if (width >= AppSpacing.desktopBreakpoint) {
      return ScreenType.desktop;
    } else if (width >= AppSpacing.tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final ScreenType screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
}

/// Screen type enumeration
enum ScreenType {
  mobile,
  tablet,
  desktop,
}