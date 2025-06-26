import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';

/// Animated drag feedback widget that provides visual feedback during drag operations
class AnimatedDragFeedback extends StatefulWidget {
  /// The child widget to display as feedback
  final Widget child;
  
  /// Animation settings
  final AnimationSettings animationSettings;
  
  /// Scale factor for the feedback
  final double scaleFactor;
  
  /// Opacity for the feedback
  final double opacity;

  const AnimatedDragFeedback({
    super.key,
    required this.child,
    this.animationSettings = const AnimationSettings(),
    this.scaleFactor = 1.05,
    this.opacity = 0.8,
  });

  @override
  State<AnimatedDragFeedback> createState() => _AnimatedDragFeedbackState();
}

class _AnimatedDragFeedbackState extends State<AnimatedDragFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationSettings.getDuration(AnimationType.short),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationSettings.defaultCurve,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.opacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    if (widget.animationSettings.enabled) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animationSettings.enabled) {
      return Transform.scale(
        scale: widget.scaleFactor,
        child: Opacity(
          opacity: widget.opacity,
          child: widget.child,
        ),
      );
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: widget.child,
      ),
    );
  }
}

/// Widget that animates when a draggable is dropped
class AnimatedDropTarget extends StatefulWidget {
  /// The child widget
  final Widget child;
  
  /// Whether the target is currently active (has a draggable over it)
  final bool isActive;
  
  /// Animation settings
  final AnimationSettings animationSettings;
  
  /// Scale factor when active
  final double activeScale;
  
  /// Color overlay when active
  final Color? activeColor;

  const AnimatedDropTarget({
    super.key,
    required this.child,
    required this.isActive,
    this.animationSettings = const AnimationSettings(),
    this.activeScale = 1.02,
    this.activeColor,
  });

  @override
  State<AnimatedDropTarget> createState() => _AnimatedDropTargetState();
}

class _AnimatedDropTargetState extends State<AnimatedDropTarget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationSettings.getDuration(AnimationType.short),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.activeScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationSettings.defaultCurve,
    ));
    
    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationSettings.defaultCurve,
    ));
    
    if (widget.isActive && widget.animationSettings.enabled) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedDropTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive && widget.animationSettings.enabled) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animationSettings.enabled) {
      return widget.isActive
          ? Transform.scale(
              scale: widget.activeScale,
              child: widget.child,
            )
          : widget.child;
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.activeColor != null
              ? Container(
                  foregroundDecoration: BoxDecoration(
                    color: widget.activeColor!.withValues(
                      alpha: widget.activeColor!.alpha * _colorAnimation.value / 255,
                    ),
                  ),
                  child: child,
                )
              : child!,
        );
      },
      child: widget.child,
    );
  }
}