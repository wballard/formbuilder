import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';

/// Animated switcher for transitioning between edit and preview modes
class AnimatedModeSwitcher extends StatelessWidget {
  /// Whether we're in preview mode
  final bool isPreviewMode;

  /// The edit mode child widget
  final Widget editChild;

  /// The preview mode child widget
  final Widget previewChild;

  /// Animation settings
  final AnimationSettings animationSettings;

  /// Custom transition builder
  final Widget Function(Widget, Animation<double>)? transitionBuilder;

  const AnimatedModeSwitcher({
    super.key,
    required this.isPreviewMode,
    required this.editChild,
    required this.previewChild,
    this.animationSettings = const AnimationSettings(),
    this.transitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (!animationSettings.enabled) {
      return isPreviewMode ? previewChild : editChild;
    }

    return AnimatedSwitcher(
      duration: animationSettings.getDuration(AnimationType.long),
      switchInCurve: animationSettings.entranceCurve,
      switchOutCurve: animationSettings.exitCurve,
      transitionBuilder: transitionBuilder ?? _defaultTransitionBuilder,
      child: KeyedSubtree(
        key: ValueKey(isPreviewMode),
        child: isPreviewMode ? previewChild : editChild,
      ),
    );
  }

  Widget _defaultTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: animation, child: child),
    );
  }
}

/// Animated toolbar that slides in/out based on visibility
class AnimatedToolbar extends StatelessWidget {
  /// Whether the toolbar is visible
  final bool isVisible;

  /// The toolbar child widget
  final Widget child;

  /// Animation settings
  final AnimationSettings animationSettings;

  /// Slide direction
  final AxisDirection slideFrom;

  const AnimatedToolbar({
    super.key,
    required this.isVisible,
    required this.child,
    this.animationSettings = const AnimationSettings(),
    this.slideFrom = AxisDirection.up,
  });

  @override
  Widget build(BuildContext context) {
    if (!animationSettings.enabled) {
      return isVisible ? child : const SizedBox.shrink();
    }

    final Offset beginOffset;
    switch (slideFrom) {
      case AxisDirection.up:
        beginOffset = const Offset(0.0, -1.0);
        break;
      case AxisDirection.down:
        beginOffset = const Offset(0.0, 1.0);
        break;
      case AxisDirection.left:
        beginOffset = const Offset(-1.0, 0.0);
        break;
      case AxisDirection.right:
        beginOffset = const Offset(1.0, 0.0);
        break;
    }

    return AnimatedSlide(
      duration: animationSettings.getDuration(AnimationType.medium),
      curve: animationSettings.defaultCurve,
      offset: isVisible ? Offset.zero : beginOffset,
      child: AnimatedOpacity(
        duration: animationSettings.getDuration(AnimationType.medium),
        curve: animationSettings.defaultCurve,
        opacity: isVisible ? 1.0 : 0.0,
        child: child,
      ),
    );
  }
}

/// Crossfade between two widgets with custom animation
class AnimatedCrossfade extends StatelessWidget {
  /// Whether to show the first child
  final bool showFirst;

  /// The first child widget
  final Widget firstChild;

  /// The second child widget
  final Widget secondChild;

  /// Animation settings
  final AnimationSettings animationSettings;

  /// Layout builder for size transitions
  final AnimatedCrossFadeBuilder? layoutBuilder;

  const AnimatedCrossfade({
    super.key,
    required this.showFirst,
    required this.firstChild,
    required this.secondChild,
    this.animationSettings = const AnimationSettings(),
    this.layoutBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (!animationSettings.enabled) {
      return showFirst ? firstChild : secondChild;
    }

    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState: showFirst
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: animationSettings.getDuration(AnimationType.medium),
      firstCurve: animationSettings.defaultCurve,
      secondCurve: animationSettings.defaultCurve,
      sizeCurve: animationSettings.defaultCurve,
      layoutBuilder: layoutBuilder ?? AnimatedCrossFade.defaultLayoutBuilder,
    );
  }
}
