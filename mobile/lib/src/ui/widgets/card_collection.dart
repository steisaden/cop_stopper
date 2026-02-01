import 'package:flutter/material.dart';
import 'base_card.dart';
import 'info_card.dart';
import 'action_card.dart';
import 'animated_card.dart';

/// Collection of all card components for easy importing and usage
/// Provides a centralized access point for all card types in the app.
class CardCollection {
  CardCollection._();

  /// Base card component
  static BaseCard base({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? elevation,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    VoidCallback? onTap,
    String? semanticLabel,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return BaseCard(
      key: key,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      semanticLabel: semanticLabel,
      clipBehavior: clipBehavior,
      child: child,
    );
  }

  /// Information card component
  static InfoCard info({
    Key? key,
    IconData? icon,
    String? title,
    String? description,
    Widget? content,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? iconColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return InfoCard(
      key: key,
      icon: icon,
      title: title,
      description: description,
      content: content,
      actions: actions,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  /// Status information card component
  static StatusInfoCard status({
    Key? key,
    required String title,
    required String description,
    required StatusType status,
    IconData? icon,
    List<Widget>? actions,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return StatusInfoCard(
      key: key,
      title: title,
      description: description,
      status: status,
      icon: icon,
      actions: actions,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  /// Action card component
  static ActionCard action({
    Key? key,
    IconData? icon,
    required String title,
    String? description,
    required ActionButton primaryAction,
    ActionButton? secondaryAction,
    Color? backgroundColor,
    Color? iconColor,
    bool isDestructive = false,
    bool isEmergency = false,
    String? semanticLabel,
  }) {
    return ActionCard(
      key: key,
      icon: icon,
      title: title,
      description: description,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      isDestructive: isDestructive,
      isEmergency: isEmergency,
      semanticLabel: semanticLabel,
    );
  }

  /// Animated card component
  static AnimatedCard animated({
    Key? key,
    required Widget child,
    CardState state = CardState.normal,
    VoidCallback? onTap,
    ValueChanged<CardState>? onStateChanged,
    Duration? animationDuration,
    Widget? loadingWidget,
    Widget? errorWidget,
    Widget? successWidget,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    String? semanticLabel,
  }) {
    return AnimatedCard(
      key: key,
      state: state,
      onTap: onTap,
      onStateChanged: onStateChanged,
      animationDuration: animationDuration,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      successWidget: successWidget,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Stateful animated card component
  static StatefulAnimatedCard statefulAnimated({
    Key? key,
    required Widget child,
    CardState initialState = CardState.normal,
    VoidCallback? onTap,
    Duration? animationDuration,
    Widget? loadingWidget,
    Widget? errorWidget,
    Widget? successWidget,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    String? semanticLabel,
  }) {
    return StatefulAnimatedCard(
      key: key,
      initialState: initialState,
      onTap: onTap,
      animationDuration: animationDuration,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      successWidget: successWidget,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}

/// Export all card-related classes for easy importing
export 'base_card.dart';
export 'info_card.dart';
export 'action_card.dart';
export 'animated_card.dart';