import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'dart:math';

/// Widget that handles keyboard navigation and shortcuts for the form builder
class KeyboardHandler extends StatefulWidget {
  /// The form layout controller
  final FormLayoutController controller;
  
  /// The child widget to wrap
  final Widget child;
  
  /// Whether to show a focus indicator when focused
  final bool showFocusIndicator;

  const KeyboardHandler({
    super.key,
    required this.controller,
    required this.child,
    this.showFocusIndicator = true,
  });

  @override
  State<KeyboardHandler> createState() => _KeyboardHandlerState();
}

class _KeyboardHandlerState extends State<KeyboardHandler> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
        },
        child: Container(
          decoration: widget.showFocusIndicator && _focusNode.hasFocus
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  ),
                )
              : null,
          child: widget.child,
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final isCtrlPressed = event.logicalKey == LogicalKeyboardKey.control ||
        HardwareKeyboard.instance.isControlPressed;
    final isCmdPressed = event.logicalKey == LogicalKeyboardKey.meta ||
        HardwareKeyboard.instance.isMetaPressed;
    final isShiftPressed = event.logicalKey == LogicalKeyboardKey.shift ||
        HardwareKeyboard.instance.isShiftPressed;
    
    // Use Cmd on macOS, Ctrl on other platforms
    final isModifierPressed = defaultTargetPlatform == TargetPlatform.macOS 
        ? isCmdPressed 
        : isCtrlPressed;

    try {
      // Navigation keys
      if (_handleNavigationKeys(event, isShiftPressed, isModifierPressed)) {
        return KeyEventResult.handled;
      }

      // Operation shortcuts
      if (_handleOperationShortcuts(event, isModifierPressed, isShiftPressed)) {
        return KeyEventResult.handled;
      }

      // Widget manipulation
      if (_handleWidgetManipulation(event, isModifierPressed, isShiftPressed)) {
        return KeyEventResult.handled;
      }
    } catch (e) {
      // Handle any errors gracefully - log but don't crash
      debugPrint('Keyboard handler error: $e');
    }

    return KeyEventResult.ignored;
  }

  bool _handleNavigationKeys(KeyEvent event, bool isShiftPressed, bool isModifierPressed) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.tab:
        if (isShiftPressed) {
          _selectPreviousWidget();
        } else {
          _selectNextWidget();
        }
        return true;

      case LogicalKeyboardKey.escape:
        // If in preview mode, exit preview mode
        if (widget.controller.isPreviewMode) {
          Actions.maybeInvoke<TogglePreviewModeIntent>(
            context,
            const TogglePreviewModeIntent(),
          );
        } else {
          // Otherwise, deselect widget
          Actions.maybeInvoke<SelectWidgetIntent>(
            context,
            const SelectWidgetIntent(widgetId: null),
          );
        }
        return true;

      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
        // Only handle navigation if no modifiers are pressed
        if (!isShiftPressed && !isModifierPressed) {
          _navigateWithArrows(event.logicalKey);
          return true;
        }
        return false;

      default:
        return false;
    }
  }

  bool _handleOperationShortcuts(KeyEvent event, bool isModifierPressed, bool isShiftPressed) {
    // Delete selected widget
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      final selectedId = widget.controller.selectedWidgetId;
      if (selectedId != null) {
        Actions.maybeInvoke<RemoveWidgetIntent>(
          context,
          RemoveWidgetIntent(widgetId: selectedId),
        );
      }
      return true;
    }

    if (!isModifierPressed) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyZ:
        if (isShiftPressed) {
          // Ctrl/Cmd+Shift+Z = Redo
          Actions.maybeInvoke<RedoIntent>(context, const RedoIntent());
        } else {
          // Ctrl/Cmd+Z = Undo
          Actions.maybeInvoke<UndoIntent>(context, const UndoIntent());
        }
        return true;

      case LogicalKeyboardKey.keyY:
        // Ctrl/Cmd+Y = Redo (Windows/Linux convention)
        Actions.maybeInvoke<RedoIntent>(context, const RedoIntent());
        return true;

      case LogicalKeyboardKey.keyD:
        // Ctrl/Cmd+D = Duplicate
        final selectedId = widget.controller.selectedWidgetId;
        if (selectedId != null) {
          Actions.maybeInvoke<DuplicateWidgetIntent>(
            context,
            DuplicateWidgetIntent(widgetId: selectedId),
          );
        }
        return true;

      case LogicalKeyboardKey.keyA:
        // Ctrl/Cmd+A = Select all (future feature)
        // For now, just select the first widget
        if (widget.controller.state.widgets.isNotEmpty) {
          Actions.maybeInvoke<SelectWidgetIntent>(
            context,
            SelectWidgetIntent(widgetId: widget.controller.state.widgets.first.id),
          );
        }
        return true;

      case LogicalKeyboardKey.keyP:
        // Ctrl/Cmd+P = Toggle preview mode
        Actions.maybeInvoke<TogglePreviewModeIntent>(
          context,
          const TogglePreviewModeIntent(),
        );
        return true;

      default:
        return false;
    }
  }

  bool _handleWidgetManipulation(KeyEvent event, bool isModifierPressed, bool isShiftPressed) {
    final selectedId = widget.controller.selectedWidgetId;
    if (selectedId == null) return false;

    final selectedWidget = widget.controller.state.getWidget(selectedId);
    if (selectedWidget == null) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        if (isShiftPressed) {
          _moveWidget(selectedWidget, 0, -1);
        } else if (isModifierPressed) {
          _resizeWidget(selectedWidget, 0, -1);
        }
        return isShiftPressed || isModifierPressed;

      case LogicalKeyboardKey.arrowDown:
        if (isShiftPressed) {
          _moveWidget(selectedWidget, 0, 1);
        } else if (isModifierPressed) {
          _resizeWidget(selectedWidget, 0, 1);
        }
        return isShiftPressed || isModifierPressed;

      case LogicalKeyboardKey.arrowLeft:
        if (isShiftPressed) {
          _moveWidget(selectedWidget, -1, 0);
        } else if (isModifierPressed) {
          _resizeWidget(selectedWidget, -1, 0);
        }
        return isShiftPressed || isModifierPressed;

      case LogicalKeyboardKey.arrowRight:
        if (isShiftPressed) {
          _moveWidget(selectedWidget, 1, 0);
        } else if (isModifierPressed) {
          _resizeWidget(selectedWidget, 1, 0);
        }
        return isShiftPressed || isModifierPressed;

      default:
        return false;
    }
  }

  void _selectNextWidget() {
    final widgets = widget.controller.state.widgets;
    if (widgets.isEmpty) return;

    final currentId = widget.controller.selectedWidgetId;
    if (currentId == null) {
      Actions.maybeInvoke<SelectWidgetIntent>(
        context,
        SelectWidgetIntent(widgetId: widgets.first.id),
      );
      return;
    }

    final currentIndex = widgets.indexWhere((w) => w.id == currentId);
    if (currentIndex == -1) {
      Actions.maybeInvoke<SelectWidgetIntent>(
        context,
        SelectWidgetIntent(widgetId: widgets.first.id),
      );
      return;
    }

    final nextIndex = (currentIndex + 1) % widgets.length;
    Actions.maybeInvoke<SelectWidgetIntent>(
      context,
      SelectWidgetIntent(widgetId: widgets[nextIndex].id),
    );
  }

  void _selectPreviousWidget() {
    final widgets = widget.controller.state.widgets;
    if (widgets.isEmpty) return;

    final currentId = widget.controller.selectedWidgetId;
    if (currentId == null) {
      Actions.maybeInvoke<SelectWidgetIntent>(
        context,
        SelectWidgetIntent(widgetId: widgets.last.id),
      );
      return;
    }

    final currentIndex = widgets.indexWhere((w) => w.id == currentId);
    if (currentIndex == -1) {
      Actions.maybeInvoke<SelectWidgetIntent>(
        context,
        SelectWidgetIntent(widgetId: widgets.last.id),
      );
      return;
    }

    final previousIndex = currentIndex == 0 ? widgets.length - 1 : currentIndex - 1;
    Actions.maybeInvoke<SelectWidgetIntent>(
      context,
      SelectWidgetIntent(widgetId: widgets[previousIndex].id),
    );
  }

  void _navigateWithArrows(LogicalKeyboardKey key) {
    final currentId = widget.controller.selectedWidgetId;
    if (currentId == null) {
      // No selection, select first widget
      if (widget.controller.state.widgets.isNotEmpty) {
        Actions.maybeInvoke<SelectWidgetIntent>(
          context,
          SelectWidgetIntent(widgetId: widget.controller.state.widgets.first.id),
        );
      }
      return;
    }

    final currentWidget = widget.controller.state.getWidget(currentId);
    if (currentWidget == null) return;

    WidgetPlacement? targetWidget;
    double minDistance = double.infinity;

    // Find the closest widget in the direction of the arrow
    for (final widget in widget.controller.state.widgets) {
      if (widget.id == currentId) continue;

      final dx = widget.column - currentWidget.column;
      final dy = widget.row - currentWidget.row;
      final distance = (dx * dx + dy * dy).toDouble();

      bool isInDirection = false;
      switch (key) {
        case LogicalKeyboardKey.arrowUp:
          isInDirection = dy < 0;
          break;
        case LogicalKeyboardKey.arrowDown:
          isInDirection = dy > 0;
          break;
        case LogicalKeyboardKey.arrowLeft:
          isInDirection = dx < 0;
          break;
        case LogicalKeyboardKey.arrowRight:
          isInDirection = dx > 0;
          break;
      }

      if (isInDirection && distance < minDistance) {
        minDistance = distance;
        targetWidget = widget;
      }
    }

    if (targetWidget != null) {
      Actions.maybeInvoke<SelectWidgetIntent>(
        context,
        SelectWidgetIntent(widgetId: targetWidget.id),
      );
    }
  }

  void _moveWidget(WidgetPlacement placement, int deltaColumn, int deltaRow) {
    final newColumn = (placement.column + deltaColumn).clamp(0, 
        widget.controller.state.dimensions.columns - placement.width).toInt();
    final newRow = (placement.row + deltaRow).clamp(0, 
        widget.controller.state.dimensions.rows - placement.height).toInt();

    if (newColumn != placement.column || newRow != placement.row) {
      Actions.maybeInvoke<MoveWidgetIntent>(
        context,
        MoveWidgetIntent(
          widgetId: placement.id,
          newPosition: Point(newColumn, newRow),
        ),
      );
    }
  }

  void _resizeWidget(WidgetPlacement placement, int deltaWidth, int deltaHeight) {
    final gridDimensions = widget.controller.state.dimensions;
    
    int newWidth = placement.width;
    int newHeight = placement.height;

    if (deltaWidth != 0) {
      newWidth = (placement.width + deltaWidth).clamp(1, 
          gridDimensions.columns - placement.column).toInt();
    }

    if (deltaHeight != 0) {
      newHeight = (placement.height + deltaHeight).clamp(1, 
          gridDimensions.rows - placement.row).toInt();
    }

    if (newWidth != placement.width || newHeight != placement.height) {
      Actions.maybeInvoke<ResizeWidgetIntent>(
        context,
        ResizeWidgetIntent(
          widgetId: placement.id,
          newSize: Size(newWidth.toDouble(), newHeight.toDouble()),
        ),
      );
    }
  }
}