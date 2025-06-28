import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/animated_placed_widget.dart';
import 'package:formbuilder/form_layout/utils/accessibility_utils.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'dart:math';

/// An accessible wrapper for AnimatedPlacedWidget with full semantics support
class AccessiblePlacedWidget extends StatefulWidget {
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

  const AccessiblePlacedWidget({
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
  State<AccessiblePlacedWidget> createState() => _AccessiblePlacedWidgetState();
}

class _AccessiblePlacedWidgetState extends State<AccessiblePlacedWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  /// Handle keyboard input for the widget
  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Arrow keys for movement
    if (widget.canDrag && widget.isSelected) {
      int deltaX = 0;
      int deltaY = 0;

      if (key == LogicalKeyboardKey.arrowLeft) {
        deltaX = -1;
      } else if (key == LogicalKeyboardKey.arrowRight) {
        deltaX = 1;
      } else if (key == LogicalKeyboardKey.arrowUp) {
        deltaY = -1;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        deltaY = 1;
      }

      if (deltaX != 0 || deltaY != 0) {
        final newColumn = widget.placement.column + deltaX;
        final newRow = widget.placement.row + deltaY;

        Actions.maybeInvoke<MoveWidgetIntent>(
          context,
          MoveWidgetIntent(
            widgetId: widget.placement.id,
            newPosition: Point(newColumn, newRow),
          ),
        );

        AccessibilityUtils.announceStatus(
          context,
          'Moved to column ${newColumn + 1}, row ${newRow + 1}',
        );

        return KeyEventResult.handled;
      }
    }

    // Delete key
    if ((key == LogicalKeyboardKey.delete ||
            key == LogicalKeyboardKey.backspace) &&
        widget.isSelected &&
        widget.onDelete != null) {
      widget.onDelete!();
      AccessibilityUtils.announceStatus(
        context,
        '${widget.placement.widgetName} removed from grid',
      );
      return KeyEventResult.handled;
    }

    // Enter/Space to select
    if ((key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) &&
        widget.onTap != null) {
      widget.onTap!();
      AccessibilityUtils.announceStatus(
        context,
        widget.isSelected ? 'Widget deselected' : 'Widget selected',
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final semanticLabel = AccessibilityUtils.getWidgetSemanticLabel(
      widget.placement,
    );
    final semanticHint = AccessibilityUtils.getWidgetSemanticHint(
      widget.isSelected,
    );

    Widget placedWidget = AnimatedPlacedWidget(
      placement: widget.placement,
      onTap: widget.onTap,
      isSelected: widget.isSelected,
      isDragging: widget.isDragging,
      contentPadding: widget.contentPadding,
      canDrag: widget.canDrag,
      onDelete: widget.onDelete,
      showDeleteButton: widget.showDeleteButton,
      showResizeHandles: widget.showResizeHandles,
      animationSettings: widget.animationSettings,
      isDeleting: widget.isDeleting,
      onDeleteAnimationComplete: widget.onDeleteAnimationComplete,
      child: widget.child,
    );

    // Wrap with focus and keyboard handling
    placedWidget = Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) => _handleKeyEvent(event),
      child: AccessibleFocusIndicator(
        isFocused: _isFocused,
        child: placedWidget,
      ),
    );

    // Add semantics
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      selected: widget.isSelected,
      button: widget.onTap != null,
      enabled: !widget.isDeleting,
      // Ensure the widget is focusable
      focusable: true,
      child: placedWidget,
    );
  }
}
