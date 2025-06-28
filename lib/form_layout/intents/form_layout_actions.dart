import 'dart:math';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/utils/layout_serializer.dart';

/// Action that handles adding widgets to the form layout
class AddWidgetAction extends Action<AddWidgetIntent> {
  final FormLayoutController controller;

  AddWidgetAction(this.controller);

  @override
  bool invoke(AddWidgetIntent intent) {
    try {
      final placement = WidgetPlacement(
        id: '${intent.item.name}_${DateTime.now().millisecondsSinceEpoch}',
        widgetName: intent.item.name,
        column: intent.position.x,
        row: intent.position.y,
        width: intent.item.defaultWidth,
        height: intent.item.defaultHeight,
      );

      controller.addWidget(placement);
      return true;
    } catch (e) {
      debugPrint('Failed to add widget: $e');
      return false;
    }
  }
}

/// Action that handles removing widgets from the form layout
class RemoveWidgetAction extends Action<RemoveWidgetIntent> {
  final FormLayoutController controller;

  RemoveWidgetAction(this.controller);

  @override
  bool invoke(RemoveWidgetIntent intent) {
    try {
      controller.removeWidget(intent.widgetId);
      return true;
    } catch (e) {
      debugPrint('Failed to remove widget: $e');
      return false;
    }
  }
}

/// Action that handles moving widgets to new positions
class MoveWidgetAction extends Action<MoveWidgetIntent> {
  final FormLayoutController controller;

  MoveWidgetAction(this.controller);

  @override
  bool invoke(MoveWidgetIntent intent) {
    try {
      controller.moveWidget(
        intent.widgetId,
        intent.newPosition.x,
        intent.newPosition.y,
      );
      return true;
    } catch (e) {
      debugPrint('Failed to move widget: $e');
      return false;
    }
  }
}

/// Action that handles resizing widgets
class ResizeWidgetAction extends Action<ResizeWidgetIntent> {
  final FormLayoutController controller;

  ResizeWidgetAction(this.controller);

  @override
  bool invoke(ResizeWidgetIntent intent) {
    try {
      controller.resizeWidget(
        intent.widgetId,
        intent.newSize.width.toInt(),
        intent.newSize.height.toInt(),
      );
      return true;
    } catch (e) {
      debugPrint('Failed to resize widget: $e');
      return false;
    }
  }
}

/// Action that handles widget selection
class SelectWidgetAction extends Action<SelectWidgetIntent> {
  final FormLayoutController controller;

  SelectWidgetAction(this.controller);

  @override
  bool invoke(SelectWidgetIntent intent) {
    try {
      controller.selectWidget(intent.widgetId);
      return true;
    } catch (e) {
      debugPrint('Failed to select widget: $e');
      return false;
    }
  }
}

/// Action that handles grid resizing
class ResizeGridAction extends Action<ResizeGridIntent> {
  final FormLayoutController controller;

  ResizeGridAction(this.controller);

  @override
  bool invoke(ResizeGridIntent intent) {
    try {
      controller.resizeGrid(intent.newDimensions);
      return true;
    } catch (e) {
      debugPrint('Failed to resize grid: $e');
      return false;
    }
  }
}

/// Action that handles undo operations
class UndoAction extends Action<UndoIntent> {
  final FormLayoutController controller;

  UndoAction(this.controller);

  @override
  bool invoke(UndoIntent intent) {
    if (controller.canUndo) {
      controller.undo();
      return true;
    }
    return false;
  }
}

/// Action that handles redo operations
class RedoAction extends Action<RedoIntent> {
  final FormLayoutController controller;

  RedoAction(this.controller);

  @override
  bool invoke(RedoIntent intent) {
    if (controller.canRedo) {
      controller.redo();
      return true;
    }
    return false;
  }
}

/// Action that handles toggling preview mode
class TogglePreviewModeAction extends Action<TogglePreviewModeIntent> {
  final FormLayoutController controller;

  TogglePreviewModeAction(this.controller);

  @override
  bool invoke(TogglePreviewModeIntent intent) {
    try {
      controller.togglePreviewMode();
      return true;
    } catch (e) {
      debugPrint('Failed to toggle preview mode: $e');
      return false;
    }
  }
}

/// Action that handles widget duplication
class DuplicateWidgetAction extends Action<DuplicateWidgetIntent> {
  final FormLayoutController controller;

  DuplicateWidgetAction(this.controller);

  @override
  bool invoke(DuplicateWidgetIntent intent) {
    try {
      final selectedWidget = controller.state.getWidget(intent.widgetId);
      if (selectedWidget == null) return false;

      // Try to place the duplicate next to the original
      final gridDimensions = controller.state.dimensions;

      // Try different positions around the original widget
      final positions = [
        // Right of original
        Point(selectedWidget.column + selectedWidget.width, selectedWidget.row),
        // Below original
        Point(
          selectedWidget.column,
          selectedWidget.row + selectedWidget.height,
        ),
        // Left of original
        Point(selectedWidget.column - selectedWidget.width, selectedWidget.row),
        // Above original
        Point(
          selectedWidget.column,
          selectedWidget.row - selectedWidget.height,
        ),
      ];

      for (final position in positions) {
        if (position.x >= 0 &&
            position.y >= 0 &&
            position.x + selectedWidget.width <= gridDimensions.columns &&
            position.y + selectedWidget.height <= gridDimensions.rows) {
          final duplicateWidget = WidgetPlacement(
            id: '${selectedWidget.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
            widgetName: selectedWidget.widgetName,
            column: position.x,
            row: position.y,
            width: selectedWidget.width,
            height: selectedWidget.height,
          );

          try {
            controller.addWidget(duplicateWidget);
            controller.selectWidget(duplicateWidget.id);
            return true;
          } catch (e) {
            // This position didn't work, try the next one
            continue;
          }
        }
      }

      return false; // Could not find a valid position
    } catch (e) {
      debugPrint('Failed to duplicate widget: $e');
      return false;
    }
  }
}

/// Action that handles starting widget drag operations
class StartDraggingAction extends Action<StartDraggingIntent> {
  final FormLayoutController controller;

  StartDraggingAction(this.controller);

  @override
  bool invoke(StartDraggingIntent intent) {
    try {
      controller.startDragging(intent.widgetId);
      return true;
    } catch (e) {
      debugPrint('Failed to start dragging: $e');
      return false;
    }
  }
}

/// Action that handles stopping widget drag operations
class StopDraggingAction extends Action<StopDraggingIntent> {
  final FormLayoutController controller;

  StopDraggingAction(this.controller);

  @override
  bool invoke(StopDraggingIntent intent) {
    try {
      controller.stopDragging(intent.widgetId);
      return true;
    } catch (e) {
      debugPrint('Failed to stop dragging: $e');
      return false;
    }
  }
}

/// Action that handles starting widget resize operations
class StartResizingAction extends Action<StartResizingIntent> {
  final FormLayoutController controller;

  StartResizingAction(this.controller);

  @override
  bool invoke(StartResizingIntent intent) {
    try {
      controller.startResizing(intent.widgetId);
      return true;
    } catch (e) {
      debugPrint('Failed to start resizing: $e');
      return false;
    }
  }
}

/// Action that handles stopping widget resize operations
class StopResizingAction extends Action<StopResizingIntent> {
  final FormLayoutController controller;

  StopResizingAction(this.controller);

  @override
  bool invoke(StopResizingIntent intent) {
    try {
      controller.stopResizing(intent.widgetId);
      return true;
    } catch (e) {
      debugPrint('Failed to stop resizing: $e');
      return false;
    }
  }
}

/// Action that handles clearing the undo/redo history
class ClearHistoryAction extends Action<ClearHistoryIntent> {
  final FormLayoutController controller;

  ClearHistoryAction(this.controller);

  @override
  bool invoke(ClearHistoryIntent intent) {
    try {
      controller.clearHistory();
      return true;
    } catch (e) {
      debugPrint('Failed to clear history: $e');
      return false;
    }
  }
}

/// Action that handles exporting the current layout
class ExportLayoutAction extends Action<ExportLayoutIntent> {
  final FormLayoutController controller;
  final void Function(String jsonString)? onExportLayout;

  ExportLayoutAction(this.controller, this.onExportLayout);

  @override
  bool invoke(ExportLayoutIntent intent) {
    try {
      if (onExportLayout == null) {
        debugPrint('Export callback not provided');
        return false;
      }

      final jsonString = LayoutSerializer.toJsonString(controller.state);
      onExportLayout!(jsonString);
      return true;
    } catch (e) {
      debugPrint('Failed to export layout: $e');
      return false;
    }
  }
}

/// Action that handles importing a layout from JSON
class ImportLayoutAction extends Action<ImportLayoutIntent> {
  final FormLayoutController controller;
  final void Function(LayoutState? layout, String? error)? onImportLayout;

  ImportLayoutAction(this.controller, this.onImportLayout);

  @override
  bool invoke(ImportLayoutIntent intent) {
    try {
      final layout = LayoutSerializer.fromJsonString(intent.jsonString);

      if (layout != null) {
        // Successfully imported, update the controller state
        controller.loadLayout(layout);
        onImportLayout?.call(layout, null);
        return true;
      } else {
        // Import failed due to invalid JSON or validation
        onImportLayout?.call(null, 'Invalid layout data or validation failed');
        return false;
      }
    } catch (e) {
      debugPrint('Failed to import layout: $e');
      onImportLayout?.call(null, 'Import error: $e');
      return false;
    }
  }
}
