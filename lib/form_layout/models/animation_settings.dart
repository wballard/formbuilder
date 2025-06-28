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

  /// Convert curve to string representation
  static String _curveToString(Curve curve) {
    if (curve == Curves.linear) return 'linear';
    if (curve == Curves.ease) return 'ease';
    if (curve == Curves.easeIn) return 'easeIn';
    if (curve == Curves.easeOut) return 'easeOut';
    if (curve == Curves.easeInOut) return 'easeInOut';
    if (curve == Curves.easeInCubic) return 'easeInCubic';
    if (curve == Curves.easeOutCubic) return 'easeOutCubic';
    if (curve == Curves.easeInOutCubic) return 'easeInOutCubic';
    if (curve == Curves.easeInBack) return 'easeInBack';
    if (curve == Curves.easeOutBack) return 'easeOutBack';
    if (curve == Curves.easeInOutBack) return 'easeInOutBack';
    if (curve == Curves.bounceIn) return 'bounceIn';
    if (curve == Curves.bounceOut) return 'bounceOut';
    if (curve == Curves.bounceInOut) return 'bounceInOut';
    if (curve == Curves.elasticIn) return 'elasticIn';
    if (curve == Curves.elasticOut) return 'elasticOut';
    if (curve == Curves.elasticInOut) return 'elasticInOut';
    if (curve == Curves.fastOutSlowIn) return 'fastOutSlowIn';
    if (curve == Curves.slowMiddle) return 'slowMiddle';
    return 'easeInOut'; // Default fallback
  }

  /// Convert string to curve representation
  static Curve _stringToCurve(String? curveString) {
    switch (curveString) {
      case 'linear':
        return Curves.linear;
      case 'ease':
        return Curves.ease;
      case 'easeIn':
        return Curves.easeIn;
      case 'easeOut':
        return Curves.easeOut;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'easeInCubic':
        return Curves.easeInCubic;
      case 'easeOutCubic':
        return Curves.easeOutCubic;
      case 'easeInOutCubic':
        return Curves.easeInOutCubic;
      case 'easeInBack':
        return Curves.easeInBack;
      case 'easeOutBack':
        return Curves.easeOutBack;
      case 'easeInOutBack':
        return Curves.easeInOutBack;
      case 'bounceIn':
        return Curves.bounceIn;
      case 'bounceOut':
        return Curves.bounceOut;
      case 'bounceInOut':
        return Curves.bounceInOut;
      case 'elasticIn':
        return Curves.elasticIn;
      case 'elasticOut':
        return Curves.elasticOut;
      case 'elasticInOut':
        return Curves.elasticInOut;
      case 'fastOutSlowIn':
        return Curves.fastOutSlowIn;
      case 'slowMiddle':
        return Curves.slowMiddle;
      default:
        return Curves.easeInOut; // Default fallback
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'shortDuration': shortDuration.inMilliseconds,
      'mediumDuration': mediumDuration.inMilliseconds,
      'longDuration': longDuration.inMilliseconds,
      'defaultCurve': _curveToString(defaultCurve),
      'entranceCurve': _curveToString(entranceCurve),
      'exitCurve': _curveToString(exitCurve),
      'dragStartScale': dragStartScale,
      'entranceScale': entranceScale,
    };
  }

  /// Create from JSON
  factory AnimationSettings.fromJson(Map<String, dynamic> json) {
    return AnimationSettings(
      enabled: json['enabled'] as bool? ?? true,
      shortDuration: Duration(
        milliseconds: json['shortDuration'] as int? ?? 150,
      ),
      mediumDuration: Duration(
        milliseconds: json['mediumDuration'] as int? ?? 250,
      ),
      longDuration: Duration(milliseconds: json['longDuration'] as int? ?? 350),
      defaultCurve: json.containsKey('defaultCurve')
          ? _stringToCurve(json['defaultCurve'] as String?)
          : Curves.easeInOut,
      entranceCurve: json.containsKey('entranceCurve')
          ? _stringToCurve(json['entranceCurve'] as String?)
          : Curves.easeOutBack,
      exitCurve: json.containsKey('exitCurve')
          ? _stringToCurve(json['exitCurve'] as String?)
          : Curves.easeInCubic,
      dragStartScale: (json['dragStartScale'] as num?)?.toDouble() ?? 1.05,
      entranceScale: (json['entranceScale'] as num?)?.toDouble() ?? 0.8,
    );
  }
}

/// Types of animations in the form builder
enum AnimationType { short, medium, long, entrance, exit }
