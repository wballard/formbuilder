import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/widgets/animated_drag_feedback.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';

/// A widget that renders a placed widget on the grid with interaction states
class PlacedWidget extends StatefulWidget {
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
  
  /// Callback when drag starts
  final void Function(WidgetPlacement)? onDragStarted;
  
  /// Callback when drag ends
  final VoidCallback? onDragEnd;
  
  /// Callback when drag is completed
  final void Function(DraggableDetails)? onDragCompleted;
  
  /// Whether to show resize handles
  final bool showResizeHandles;
  
  /// Callback when resize starts
  final void Function(ResizeData)? onResizeStart;
  
  /// Callback when resize updates
  final void Function(ResizeData, Offset delta)? onResizeUpdate;
  
  /// Callback when resize ends
  final VoidCallback? onResizeEnd;
  
  /// Callback when the widget should be deleted
  final VoidCallback? onDelete;
  
  /// Whether to show the delete button
  final bool showDeleteButton;

  const PlacedWidget({
    super.key,
    required this.placement,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.isDragging = false,
    this.contentPadding = const EdgeInsets.all(8),
    this.canDrag = false,
    this.onDragStarted,
    this.onDragEnd,
    this.onDragCompleted,
    this.showResizeHandles = false,
    this.onResizeStart,
    this.onResizeUpdate,
    this.onResizeEnd,
    this.onDelete,
    this.showDeleteButton = false,
  });

  @override
  State<PlacedWidget> createState() => _PlacedWidgetState();
}

class _PlacedWidgetState extends State<PlacedWidget> 
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux
    );
    
    // Calculate elevation based on state
    double elevation = 2.0;
    if (_isHovering && isDesktop) {
      elevation = 4.0;
    }
    
    // Build the content
    Widget content = Padding(
      padding: widget.contentPadding,
      child: widget.child,
    );
    
    // Wrap in Material for elevation and ink effects
    content = Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(4),
      color: Colors.white,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            border: widget.isSelected
                ? Border.all(
                    color: theme.primaryColor,
                    width: 2.0,
                  )
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: content,
        ),
      ),
    );
    
    // Apply dragging opacity
    if (widget.isDragging) {
      content = Opacity(
        opacity: 0.5,
        child: content,
      );
    }
    
    // Add mouse region for desktop hover effects
    if (isDesktop) {
      content = MouseRegion(
        cursor: widget.canDrag ? SystemMouseCursors.grab : SystemMouseCursors.move,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: content,
      );
    }
    
    // Apply scale animation when draggable
    if (widget.canDrag) {
      final contentForAnimation = content;
      content = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: contentForAnimation,
      );
      
      // Wrap with Draggable
      content = Draggable<WidgetPlacement>(
        data: widget.placement,
        feedback: DraggingPlacedWidget(
          placement: widget.placement,
          contentPadding: widget.contentPadding,
          child: widget.child,
        ),
        childWhenDragging: Container(),
        onDragStarted: () {
          _scaleController.forward();
          widget.onDragStarted?.call(widget.placement);
        },
        onDragEnd: (details) {
          _scaleController.reverse();
          widget.onDragEnd?.call();
        },
        onDragCompleted: () => widget.onDragCompleted?.call(DraggableDetails(
          wasAccepted: true,
          velocity: Velocity.zero,
          offset: Offset.zero,
        )),
        child: content,
      );
    }
    
    // Add resize handles and/or delete button if enabled
    if (widget.showResizeHandles || widget.showDeleteButton) {
      final overlayChildren = <Widget>[content];
      
      if (widget.showResizeHandles) {
        overlayChildren.addAll(_buildResizeHandles());
      }
      
      if (widget.showDeleteButton) {
        overlayChildren.add(_buildDeleteButton());
      }
      
      content = Stack(
        clipBehavior: Clip.none,
        children: overlayChildren,
      );
    }
    
    return content;
  }

  /// Build all resize handles
  List<Widget> _buildResizeHandles() {
    return [
      ResizeHandle(
        type: ResizeHandleType.topLeft,
        placement: widget.placement,
        onResizeStart: widget.onResizeStart,
        onResizeUpdate: widget.onResizeUpdate,
        onResizeEnd: widget.onResizeEnd,
      ),
      ResizeHandle(
        type: ResizeHandleType.top,
        placement: widget.placement,
        onResizeStart: widget.onResizeStart,
        onResizeUpdate: widget.onResizeUpdate,
        onResizeEnd: widget.onResizeEnd,
      ),
      ResizeHandle(
        type: ResizeHandleType.topRight,
        placement: widget.placement,
        onResizeStart: widget.onResizeStart,
        onResizeUpdate: widget.onResizeUpdate,
        onResizeEnd: widget.onResizeEnd,
      ),
      ResizeHandle(
        type: ResizeHandleType.left,
        placement: widget.placement,
        onResizeStart: widget.onResizeStart,
        onResizeUpdate: widget.onResizeUpdate,
        onResizeEnd: widget.onResizeEnd,
      ),
      ResizeHandle(
        type: ResizeHandleType.right,
        placement: widget.placement,
        onResizeStart: widget.onResizeStart,
        onResizeUpdate: widget.onResizeUpdate,
        onResizeEnd: widget.onResizeEnd,
      ),
      ResizeHandle(
        type: ResizeHandleType.bottomLeft,
        placement: widget.placement,
        onResizeStart: widget.onResizeStart,
        onResizeUpdate: widget.onResizeUpdate,
        onResizeEnd: widget.onResizeEnd,
      ),
      ResizeHandle(
        type: ResizeHandleType.bottom,
        placement: widget.placement,
        onResizeStart: widget.onResizeStart,
        onResizeUpdate: widget.onResizeUpdate,
        onResizeEnd: widget.onResizeEnd,
      ),
      ResizeHandle(
        type: ResizeHandleType.bottomRight,
        placement: widget.placement,
        onResizeStart: widget.onResizeStart,
        onResizeUpdate: widget.onResizeUpdate,
        onResizeEnd: widget.onResizeEnd,
      ),
    ];
  }
  
  /// Build the delete button
  Widget _buildDeleteButton() {
    return Positioned(
      top: -8,
      right: -8,
      child: Material(
        type: MaterialType.circle,
        color: Colors.red.withValues(alpha: 0.9),
        elevation: 2,
        child: Tooltip(
          message: 'Delete widget',
          child: InkWell(
            onTap: () {
              // Call the direct callback if provided
              widget.onDelete?.call();
              
              // Also invoke the intent for action handling
              Actions.maybeInvoke<RemoveWidgetIntent>(
                context, 
                RemoveWidgetIntent(widgetId: widget.placement.id),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget used as feedback when dragging a PlacedWidget
class DraggingPlacedWidget extends StatelessWidget {
  /// The placement information for this widget
  final WidgetPlacement placement;
  
  /// The child widget to display
  final Widget child;
  
  /// Padding around the content
  final EdgeInsets contentPadding;
  
  /// Animation settings
  final AnimationSettings animationSettings;

  const DraggingPlacedWidget({
    super.key,
    required this.placement,
    required this.child,
    this.contentPadding = const EdgeInsets.all(8),
    this.animationSettings = const AnimationSettings(),
  });

  @override
  Widget build(BuildContext context) {
    // Build the content
    Widget content = Padding(
      padding: contentPadding,
      child: child,
    );
    
    // Wrap in Material for elevation and shadow
    content = Material(
      elevation: 8.0,
      borderRadius: BorderRadius.circular(4),
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: content,
      ),
    );
    
    // Wrap with animated drag feedback
    return AnimatedDragFeedback(
      animationSettings: animationSettings,
      opacity: 0.7,
      child: content,
    );
  }
}