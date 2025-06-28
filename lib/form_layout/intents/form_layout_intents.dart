import 'dart:math';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Intent to add a widget to the form layout
class AddWidgetIntent extends Intent {
  /// The toolbox item to add
  final ToolboxItem item;

  /// The grid position where to place the widget
  final Point<int> position;

  const AddWidgetIntent({required this.item, required this.position});
}

/// Intent to remove a widget from the form layout
class RemoveWidgetIntent extends Intent {
  /// The ID of the widget to remove
  final String widgetId;

  const RemoveWidgetIntent({required this.widgetId});
}

/// Intent to move a widget to a new position
class MoveWidgetIntent extends Intent {
  /// The ID of the widget to move
  final String widgetId;

  /// The new grid position
  final Point<int> newPosition;

  const MoveWidgetIntent({required this.widgetId, required this.newPosition});
}

/// Intent to resize a widget
class ResizeWidgetIntent extends Intent {
  /// The ID of the widget to resize
  final String widgetId;

  /// The new size in grid units
  final Size newSize;

  const ResizeWidgetIntent({required this.widgetId, required this.newSize});
}

/// Intent to select or deselect a widget
class SelectWidgetIntent extends Intent {
  /// The ID of the widget to select, or null to deselect all
  final String? widgetId;

  const SelectWidgetIntent({this.widgetId});
}

/// Intent to resize the grid dimensions
class ResizeGridIntent extends Intent {
  /// The new grid dimensions
  final GridDimensions newDimensions;

  const ResizeGridIntent({required this.newDimensions});
}

/// Intent to undo the last operation
class UndoIntent extends Intent {
  const UndoIntent();
}

/// Intent to redo the last undone operation
class RedoIntent extends Intent {
  const RedoIntent();
}

/// Intent to toggle preview mode on/off
class TogglePreviewModeIntent extends Intent {
  const TogglePreviewModeIntent();
}

/// Intent to duplicate a widget
class DuplicateWidgetIntent extends Intent {
  /// The ID of the widget to duplicate
  final String widgetId;

  const DuplicateWidgetIntent({required this.widgetId});
}

/// Intent to start dragging a widget
class StartDraggingIntent extends Intent {
  /// The ID of the widget being dragged
  final String widgetId;

  const StartDraggingIntent({required this.widgetId});
}

/// Intent to stop dragging a widget
class StopDraggingIntent extends Intent {
  /// The ID of the widget that was being dragged
  final String widgetId;

  const StopDraggingIntent({required this.widgetId});
}

/// Intent to start resizing a widget
class StartResizingIntent extends Intent {
  /// The ID of the widget being resized
  final String widgetId;

  const StartResizingIntent({required this.widgetId});
}

/// Intent to stop resizing a widget
class StopResizingIntent extends Intent {
  /// The ID of the widget that was being resized
  final String widgetId;

  const StopResizingIntent({required this.widgetId});
}

/// Intent to clear the undo/redo history
class ClearHistoryIntent extends Intent {
  const ClearHistoryIntent();
}

/// Intent to export the current layout
class ExportLayoutIntent extends Intent {
  const ExportLayoutIntent();
}

/// Intent to import a layout from JSON string
class ImportLayoutIntent extends Intent {
  /// The JSON string containing the layout data
  final String jsonString;

  const ImportLayoutIntent({required this.jsonString});
}
