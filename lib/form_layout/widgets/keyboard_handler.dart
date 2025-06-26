import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

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
          widget.controller.setPreviewMode(false);
        } else {
          // Otherwise, deselect widget
          widget.controller.selectWidget(null);
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
        widget.controller.removeWidget(selectedId);
      }
      return true;
    }

    if (!isModifierPressed) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyZ:
        if (isShiftPressed) {
          // Ctrl/Cmd+Shift+Z = Redo
          widget.controller.redo();
        } else {
          // Ctrl/Cmd+Z = Undo
          widget.controller.undo();
        }
        return true;

      case LogicalKeyboardKey.keyY:
        // Ctrl/Cmd+Y = Redo (Windows/Linux convention)
        widget.controller.redo();
        return true;

      case LogicalKeyboardKey.keyD:
        // Ctrl/Cmd+D = Duplicate
        _duplicateSelectedWidget();
        return true;

      case LogicalKeyboardKey.keyA:
        // Ctrl/Cmd+A = Select all (future feature)
        // For now, just select the first widget
        if (widget.controller.state.widgets.isNotEmpty) {
          widget.controller.selectWidget(widget.controller.state.widgets.first.id);
        }
        return true;

      case LogicalKeyboardKey.keyP:
        // Ctrl/Cmd+P = Toggle preview mode
        widget.controller.togglePreviewMode();
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
      widget.controller.selectWidget(widgets.first.id);
      return;
    }

    final currentIndex = widgets.indexWhere((w) => w.id == currentId);
    if (currentIndex == -1) {
      widget.controller.selectWidget(widgets.first.id);
      return;
    }

    final nextIndex = (currentIndex + 1) % widgets.length;
    widget.controller.selectWidget(widgets[nextIndex].id);
  }

  void _selectPreviousWidget() {
    final widgets = widget.controller.state.widgets;
    if (widgets.isEmpty) return;

    final currentId = widget.controller.selectedWidgetId;
    if (currentId == null) {
      widget.controller.selectWidget(widgets.last.id);
      return;
    }

    final currentIndex = widgets.indexWhere((w) => w.id == currentId);
    if (currentIndex == -1) {
      widget.controller.selectWidget(widgets.last.id);
      return;
    }

    final previousIndex = currentIndex == 0 ? widgets.length - 1 : currentIndex - 1;
    widget.controller.selectWidget(widgets[previousIndex].id);
  }

  void _navigateWithArrows(LogicalKeyboardKey key) {
    final currentId = widget.controller.selectedWidgetId;
    if (currentId == null) {
      // No selection, select first widget
      if (widget.controller.state.widgets.isNotEmpty) {
        widget.controller.selectWidget(widget.controller.state.widgets.first.id);
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
      widget.controller.selectWidget(targetWidget.id);
    }
  }

  void _moveWidget(WidgetPlacement placement, int deltaColumn, int deltaRow) {
    final newColumn = (placement.column + deltaColumn).clamp(0, 
        widget.controller.state.dimensions.columns - placement.width).toInt();
    final newRow = (placement.row + deltaRow).clamp(0, 
        widget.controller.state.dimensions.rows - placement.height).toInt();

    if (newColumn != placement.column || newRow != placement.row) {
      try {
        widget.controller.moveWidget(placement.id, newColumn, newRow);
      } catch (e) {
        // Move failed (likely overlap), ignore
        debugPrint('Move failed: $e');
      }
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
      try {
        widget.controller.resizeWidget(placement.id, newWidth, newHeight);
      } catch (e) {
        // Resize failed (likely overlap), ignore
        debugPrint('Resize failed: $e');
      }
    }
  }

  void _duplicateSelectedWidget() {
    final selectedId = widget.controller.selectedWidgetId;
    if (selectedId == null) return;

    final selectedWidget = widget.controller.state.getWidget(selectedId);
    if (selectedWidget == null) return;

    // Try to place the duplicate next to the original
    final gridDimensions = widget.controller.state.dimensions;
    
    // Try different positions around the original widget
    final positions = [
      // Right of original
      (selectedWidget.column + selectedWidget.width, selectedWidget.row),
      // Below original
      (selectedWidget.column, selectedWidget.row + selectedWidget.height),
      // Left of original
      (selectedWidget.column - selectedWidget.width, selectedWidget.row),
      // Above original
      (selectedWidget.column, selectedWidget.row - selectedWidget.height),
    ];

    for (final (newColumn, newRow) in positions) {
      if (newColumn >= 0 && 
          newRow >= 0 && 
          newColumn + selectedWidget.width <= gridDimensions.columns &&
          newRow + selectedWidget.height <= gridDimensions.rows) {
        
        final duplicateWidget = WidgetPlacement(
          id: '${selectedWidget.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
          widgetName: selectedWidget.widgetName,
          column: newColumn,
          row: newRow,
          width: selectedWidget.width,
          height: selectedWidget.height,
        );

        try {
          widget.controller.addWidget(duplicateWidget);
          widget.controller.selectWidget(duplicateWidget.id);
          return;
        } catch (e) {
          // This position didn't work, try the next one
          continue;
        }
      }
    }

    // If no position worked, just show a debug message
    debugPrint('Could not find a valid position to duplicate widget');
  }
}