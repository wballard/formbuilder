import 'package:flutter/material.dart';

/// Settings for controlling animations in the form builder
class AnimationSettings {
  /// Whether animations are enabled
  final bool enabled;
  
  /// Duration for short animations (selection, hover, etc.)
  final Duration shortDuration;
  
  /// Duration for medium animations (widget placement, movement)
  final Duration mediumDuration;
  
  /// Duration for long animations (mode transitions, grid resize)
  final Duration longDuration;
  
  /// Default animation curve
  final Curve defaultCurve;
  
  /// Curve for entrance animations
  final Curve entranceCurve;
  
  /// Curve for exit animations
  final Curve exitCurve;
  
  /// Scale factor for drag start animation
  final double dragStartScale;
  
  /// Scale factor for widget entrance
  final double entranceScale;

  const AnimationSettings({
    this.enabled = true,
    this.shortDuration = const Duration(milliseconds: 150),
    this.mediumDuration = const Duration(milliseconds: 250),
    this.longDuration = const Duration(milliseconds: 350),
    this.defaultCurve = Curves.easeInOut,
    this.entranceCurve = Curves.easeOutBack,
    this.exitCurve = Curves.easeInCubic,
    this.dragStartScale = 1.05,
    this.entranceScale = 0.8,
  });
  
  /// Creates animation settings with all animations disabled
  const AnimationSettings.noAnimations()
      : enabled = false,
        shortDuration = Duration.zero,
        mediumDuration = Duration.zero,
        longDuration = Duration.zero,
        defaultCurve = Curves.linear,
        entranceCurve = Curves.linear,
        exitCurve = Curves.linear,
        dragStartScale = 1.0,
        entranceScale = 1.0;
  
  /// Creates animation settings based on accessibility preferences
  factory AnimationSettings.fromMediaQuery(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final disableAnimations = mediaQuery.disableAnimations;
    
    if (disableAnimations) {
      return const AnimationSettings.noAnimations();
    }
    
    return const AnimationSettings();
  }
  
  /// Get duration based on animation type
  Duration getDuration(AnimationType type) {
    if (!enabled) return Duration.zero;
    
    switch (type) {
      case AnimationType.short:
        return shortDuration;
      case AnimationType.medium:
        return mediumDuration;
      case AnimationType.long:
        return longDuration;
      case AnimationType.entrance:
      case AnimationType.exit:
        return mediumDuration;
    }
  }
  
  /// Get curve based on animation type
  Curve getCurve(AnimationType type) {
    if (!enabled) return Curves.linear;
    
    switch (type) {
      case AnimationType.entrance:
        return entranceCurve;
      case AnimationType.exit:
        return exitCurve;
      default:
        return defaultCurve;
    }
  }
}

/// Types of animations in the form builder
enum AnimationType {
  short,
  medium,
  long,
  entrance,
  exit,
}