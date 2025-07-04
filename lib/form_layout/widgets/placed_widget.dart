import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/widgets/animated_drag_feedback.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

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
  final EdgeInsets? contentPadding;

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
    this.contentPadding,
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
      duration: const Duration(milliseconds: 150), // Keep short duration for responsiveness
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.025, // Slightly less scale to be more subtle
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formTheme = FormLayoutTheme.of(context);
    final isDesktop =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);

    // Calculate elevation based on state
    double elevation = formTheme.elevations;
    if (_isHovering && isDesktop) {
      elevation = formTheme.elevations * 2;
    }

    // Build the content - wrap child with RepaintBoundary for performance
    Widget content = Padding(
      padding: widget.contentPadding ?? formTheme.defaultPadding,
      child: RepaintBoundary(child: widget.child),
    );

    // Wrap in Material for elevation and ink effects
    content = Material(
      elevation: elevation,
      borderRadius: formTheme.widgetBorderRadius,
      color: formTheme.gridBackgroundColor,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: formTheme.widgetBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            border: widget.isSelected
                ? Border.all(
                    color: formTheme.selectionBorderColor, 
                    width: Theme.of(context).dividerTheme.thickness ?? 1.0,
                  )
                : null,
            borderRadius: formTheme.widgetBorderRadius,
          ),
          child: content,
        ),
      ),
    );

    // Don't wrap with RepaintBoundary here - it causes issues with grid layout

    // Apply dragging opacity
    if (widget.isDragging) {
      content = Opacity(opacity: 0.6, child: content); // Slightly more visible when dragging
    }

    // Add mouse region for desktop hover effects
    if (isDesktop) {
      content = MouseRegion(
        cursor: widget.canDrag
            ? SystemMouseCursors.grab
            : SystemMouseCursors.move,
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
            alignment: Alignment.center,
            filterQuality: FilterQuality.none,
            child: child,
          );
        },
        child: contentForAnimation,
      );

      // Wrap with Draggable
      content = Draggable<WidgetPlacement>(
        data: widget.placement,
        feedback: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 300.0, // Reasonable max width for drag feedback
              maxHeight: 200.0, // Reasonable max height for drag feedback
            ),
            child: DraggingPlacedWidget(
              placement: widget.placement,
              contentPadding: widget.contentPadding,
              child: widget.child,
            ),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: () {
          _scaleController.forward();
          widget.onDragStarted?.call(widget.placement);
        },
        onDragEnd: (details) {
          _scaleController.reverse();
          widget.onDragEnd?.call();
        },
        onDragCompleted: () => widget.onDragCompleted?.call(
          DraggableDetails(
            wasAccepted: true,
            velocity: Velocity.zero,
            offset: Offset.zero,
          ),
        ),
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

      content = Stack(clipBehavior: Clip.none, children: overlayChildren);
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
        color: Theme.of(context).colorScheme.error,
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
            borderRadius: BorderRadius.circular(
              (Theme.of(context).iconTheme.size ?? 24) / 2,
            ),
            child: Container(
              width: Theme.of(context).iconTheme.size ?? 24,
              height: Theme.of(context).iconTheme.size ?? 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, 
                  width: Theme.of(context).dividerTheme.thickness ?? 1.0,
                ),
              ),
              child: Icon(
                Icons.close, 
                size: (Theme.of(context).iconTheme.size ?? 24) * 0.67, // 2/3 of container size
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
  final EdgeInsets? contentPadding;

  /// Animation settings
  final AnimationSettings animationSettings;

  const DraggingPlacedWidget({
    super.key,
    required this.placement,
    required this.child,
    this.contentPadding,
    this.animationSettings = const AnimationSettings(),
  });

  @override
  Widget build(BuildContext context) {
    final formTheme = FormLayoutTheme.of(context);
    
    // Build the content with appropriate constraints for drag feedback
    Widget content = DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 100.0,
          maxWidth: 400.0, // Prevent excessive width during drag
        ),
        padding: contentPadding ?? formTheme.defaultPadding,
        child: child,
      ),
    );

    // Wrap in Material for elevation and shadow
    content = Material(
      elevation: formTheme.elevations * 4, // Higher elevation for drag feedback
      borderRadius: formTheme.widgetBorderRadius,
      color: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(borderRadius: formTheme.widgetBorderRadius),
        child: content,
      ),
    );

    // Wrap with animated drag feedback
    return AnimatedDragFeedback(
      animationSettings: animationSettings,
      opacity: 0.75, // Slightly more visible
      child: content,
    );
  }
}
