import 'dart:math';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/intents/form_layout_actions.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Widget that provides all form layout actions to its descendants
class FormLayoutActionDispatcher extends StatelessWidget {
  /// The form layout controller to use for actions
  final FormLayoutController controller;
  
  /// The child widget to wrap with actions
  final Widget child;

  const FormLayoutActionDispatcher({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        // Widget manipulation actions
        AddWidgetIntent: AddWidgetAction(controller),
        RemoveWidgetIntent: RemoveWidgetAction(controller),
        MoveWidgetIntent: MoveWidgetAction(controller),
        ResizeWidgetIntent: ResizeWidgetAction(controller),
        SelectWidgetIntent: SelectWidgetAction(controller),
        DuplicateWidgetIntent: DuplicateWidgetAction(controller),
        
        // Grid actions
        ResizeGridIntent: ResizeGridAction(controller),
        
        // History actions
        UndoIntent: UndoAction(controller),
        RedoIntent: RedoAction(controller),
        ClearHistoryIntent: ClearHistoryAction(controller),
        
        // Mode actions
        TogglePreviewModeIntent: TogglePreviewModeAction(controller),
        
        // State management actions
        StartDraggingIntent: StartDraggingAction(controller),
        StopDraggingIntent: StopDraggingAction(controller),
        StartResizingIntent: StartResizingAction(controller),
        StopResizingIntent: StopResizingAction(controller),
      },
      child: child,
    );
  }
}

/// Extension to make invoking intents more convenient
extension ActionInvoker on BuildContext {
  /// Invokes an intent and returns whether it was handled
  bool maybeInvokeIntent<T extends Intent>(T intent) {
    final result = Actions.maybeInvoke<T>(this, intent);
    return result != null;
  }
  
  /// Invokes an intent and throws if not handled
  Object? invokeIntent<T extends Intent>(T intent) {
    return Actions.invoke<T>(this, intent);
  }
}

/// Mixin for widgets that need to invoke form layout intents
mixin FormLayoutIntentInvoker<T extends StatefulWidget> on State<T> {
  /// Add a widget at the specified position
  bool addWidget(ToolboxItem item, Point<int> position) {
    return context.maybeInvokeIntent(AddWidgetIntent(
      item: item,
      position: position,
    ));
  }
  
  /// Remove a widget by ID
  bool removeWidget(String widgetId) {
    return context.maybeInvokeIntent(RemoveWidgetIntent(
      widgetId: widgetId,
    ));
  }
  
  /// Move a widget to a new position
  bool moveWidget(String widgetId, Point<int> newPosition) {
    return context.maybeInvokeIntent(MoveWidgetIntent(
      widgetId: widgetId,
      newPosition: newPosition,
    ));
  }
  
  /// Resize a widget
  bool resizeWidget(String widgetId, Size newSize) {
    return context.maybeInvokeIntent(ResizeWidgetIntent(
      widgetId: widgetId,
      newSize: newSize,
    ));
  }
  
  /// Select a widget (or deselect all if null)
  bool selectWidget(String? widgetId) {
    return context.maybeInvokeIntent(SelectWidgetIntent(
      widgetId: widgetId,
    ));
  }
  
  /// Duplicate a widget
  bool duplicateWidget(String widgetId) {
    return context.maybeInvokeIntent(DuplicateWidgetIntent(
      widgetId: widgetId,
    ));
  }
  
  /// Resize the grid
  bool resizeGrid(GridDimensions newDimensions) {
    return context.maybeInvokeIntent(ResizeGridIntent(
      newDimensions: newDimensions,
    ));
  }
  
  /// Undo the last operation
  bool undo() {
    return context.maybeInvokeIntent(const UndoIntent());
  }
  
  /// Redo the last undone operation
  bool redo() {
    return context.maybeInvokeIntent(const RedoIntent());
  }
  
  /// Toggle preview mode
  bool togglePreviewMode() {
    return context.maybeInvokeIntent(const TogglePreviewModeIntent());
  }
  
  /// Start dragging a widget
  bool startDragging(String widgetId) {
    return context.maybeInvokeIntent(StartDraggingIntent(
      widgetId: widgetId,
    ));
  }
  
  /// Stop dragging a widget
  bool stopDragging(String widgetId) {
    return context.maybeInvokeIntent(StopDraggingIntent(
      widgetId: widgetId,
    ));
  }
  
  /// Start resizing a widget
  bool startResizing(String widgetId) {
    return context.maybeInvokeIntent(StartResizingIntent(
      widgetId: widgetId,
    ));
  }
  
  /// Stop resizing a widget
  bool stopResizing(String widgetId) {
    return context.maybeInvokeIntent(StopResizingIntent(
      widgetId: widgetId,
    ));
  }
  
  /// Clear the undo/redo history
  bool clearHistory() {
    return context.maybeInvokeIntent(const ClearHistoryIntent());
  }
}