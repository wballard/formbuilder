import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';

/// An animated wrapper for PlacedWidget that handles entrance, exit, and state change animations
class AnimatedPlacedWidget extends StatefulWidget {
  /// The placement information for this widget
  final WidgetPlacement placement;
  
  /// The child widget to display
  final Widget child;
  
  /// Callback when the widget is tapped
  final VoidCallback? onTap;
  
  /// Whether this widget is currently selected
  final bool isSelected;
  
  /// Whether this widget is being dragged
  final bool isDragging;
  
  /// Padding around the content
  final EdgeInsets contentPadding;
  
  /// Whether this widget can be dragged
  final bool canDrag;
  
  /// Callback when the widget should be deleted
  final VoidCallback? onDelete;
  
  /// Whether to show the delete button
  final bool showDeleteButton;
  
  /// Whether to show resize handles
  final bool showResizeHandles;
  
  /// Animation settings
  final AnimationSettings animationSettings;
  
  /// Whether the widget is being deleted
  final bool isDeleting;
  
  /// Callback when delete animation completes
  final VoidCallback? onDeleteAnimationComplete;

  const AnimatedPlacedWidget({
    super.key,
    required this.placement,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.isDragging = false,
    this.contentPadding = const EdgeInsets.all(8),
    this.canDrag = true,
    this.onDelete,
    this.showDeleteButton = true,
    this.showResizeHandles = true,
    this.animationSettings = const AnimationSettings(),
    this.isDeleting = false,
    this.onDeleteAnimationComplete,
  });

  @override
  State<AnimatedPlacedWidget> createState() => _AnimatedPlacedWidgetState();
}

class _AnimatedPlacedWidgetState extends State<AnimatedPlacedWidget>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _selectionController;
  late AnimationController _deleteController;
  late AnimationController _pulseController;
  
  late Animation<double> _entranceScale;
  late Animation<double> _entranceOpacity;
  late Animation<double> _selectionScale;
  late Animation<double> _deleteScale;
  late Animation<double> _deleteOpacity;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Entrance animation
    _entranceController = AnimationController(
      duration: widget.animationSettings.getDuration(AnimationType.medium),
      vsync: this,
    );
    
    _entranceScale = Tween<double>(
      begin: widget.animationSettings.entranceScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: widget.animationSettings.entranceCurve,
    ));
    
    _entranceOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    ));
    
    // Selection animation
    _selectionController = AnimationController(
      duration: widget.animationSettings.getDuration(AnimationType.short),
      vsync: this,
    );
    
    _selectionScale = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: widget.animationSettings.defaultCurve,
    ));
    
    // Delete animation
    _deleteController = AnimationController(
      duration: widget.animationSettings.getDuration(AnimationType.medium),
      vsync: this,
    );
    
    _deleteScale = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _deleteController,
      curve: widget.animationSettings.exitCurve,
    ));
    
    _deleteOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _deleteController,
      curve: Curves.easeOut,
    ));
    
    // Pulse animation for selection
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start entrance animation
    if (widget.animationSettings.enabled) {
      _entranceController.forward();
    } else {
      _entranceController.value = 1.0;
    }
    
    // Handle selection state
    if (widget.isSelected && widget.animationSettings.enabled) {
      _selectionController.forward();
      _pulseController.repeat(reverse: true);
    }
    
    // Handle delete animation
    _deleteController.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onDeleteAnimationComplete != null) {
        widget.onDeleteAnimationComplete!();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedPlacedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle selection changes
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        if (widget.animationSettings.enabled) {
          _selectionController.forward();
          _pulseController.repeat(reverse: true);
        }
      } else {
        _selectionController.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
    }
    
    // Handle delete animation
    if (widget.isDeleting && !oldWidget.isDeleting) {
      if (widget.animationSettings.enabled) {
        _deleteController.forward();
      } else {
        widget.onDeleteAnimationComplete?.call();
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _selectionController.dispose();
    _deleteController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = PlacedWidget(
      placement: widget.placement,
      onTap: widget.onTap,
      isSelected: widget.isSelected,
      isDragging: widget.isDragging,
      contentPadding: widget.contentPadding,
      canDrag: widget.canDrag,
      onDelete: widget.onDelete,
      showDeleteButton: widget.showDeleteButton && !widget.isDeleting,
      showResizeHandles: widget.showResizeHandles,
      child: widget.child,
    );
    
    // Apply animations
    if (widget.animationSettings.enabled) {
      // Delete animation
      if (widget.isDeleting) {
        child = AnimatedBuilder(
          animation: _deleteController,
          builder: (context, child) => Transform.scale(
            scale: _deleteScale.value,
            child: Opacity(
              opacity: _deleteOpacity.value,
              child: child,
            ),
          ),
          child: child,
        );
      } else {
        // Entrance animation
        child = AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) => Transform.scale(
            scale: _entranceScale.value,
            child: Opacity(
              opacity: _entranceOpacity.value,
              child: child,
            ),
          ),
          child: child,
        );
        
        // Selection animation
        if (widget.isSelected) {
          child = AnimatedBuilder(
            animation: Listenable.merge([_selectionController, _pulseController]),
            builder: (context, child) {
              final pulseScale = 1.0 + (_pulseAnimation.value * 0.02);
              return Transform.scale(
                scale: _selectionScale.value * pulseScale,
                child: child,
              );
            },
            child: child,
          );
        }
      }
    }
    
    // Position animation
    return AnimatedContainer(
      duration: widget.animationSettings.getDuration(AnimationType.medium),
      curve: widget.animationSettings.defaultCurve,
      child: child,
    );
  }
}