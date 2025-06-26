import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Abstract base class for all form layout commands
abstract class FormLayoutCommand {
  /// Execute the command on the given state
  LayoutState execute(LayoutState state);
  
  /// Undo the command on the given state
  LayoutState undo(LayoutState state);
}

/// Command to add a widget to the layout
class AddWidgetCommand extends FormLayoutCommand {
  final WidgetPlacement placement;

  AddWidgetCommand(this.placement);

  @override
  LayoutState execute(LayoutState state) {
    if (!state.canAddWidget(placement)) {
      throw ArgumentError('Cannot add widget: placement conflicts with existing widgets or is out of bounds');
    }
    return state.addWidget(placement);
  }

  @override
  LayoutState undo(LayoutState state) {
    return state.removeWidget(placement.id);
  }
}

/// Command to remove a widget from the layout
class RemoveWidgetCommand extends FormLayoutCommand {
  final String widgetId;
  final WidgetPlacement removedWidget;

  RemoveWidgetCommand(this.widgetId, this.removedWidget);

  @override
  LayoutState execute(LayoutState state) {
    final widget = state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }
    return state.removeWidget(widgetId);
  }

  @override
  LayoutState undo(LayoutState state) {
    return state.addWidget(removedWidget);
  }
}

/// Command to move a widget to a new position
class MoveWidgetCommand extends FormLayoutCommand {
  final String widgetId;
  final WidgetPlacement oldPlacement;
  final WidgetPlacement newPlacement;

  MoveWidgetCommand(this.widgetId, this.oldPlacement, this.newPlacement);

  @override
  LayoutState execute(LayoutState state) {
    final widget = state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }
    
    // Create a temporary state without the current widget to check if the new placement is valid
    final tempState = state.removeWidget(widgetId);
    if (!tempState.canAddWidget(newPlacement)) {
      throw ArgumentError('Cannot move widget: new placement conflicts with existing widgets or is out of bounds');
    }
    
    return state.updateWidget(widgetId, newPlacement);
  }

  @override
  LayoutState undo(LayoutState state) {
    return state.updateWidget(widgetId, oldPlacement);
  }
}

/// Command to resize a widget
class ResizeWidgetCommand extends FormLayoutCommand {
  final String widgetId;
  final WidgetPlacement oldPlacement;
  final WidgetPlacement newPlacement;

  ResizeWidgetCommand(this.widgetId, this.oldPlacement, this.newPlacement);

  @override
  LayoutState execute(LayoutState state) {
    final widget = state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }
    
    // Create a temporary state without the current widget to check if the new placement is valid
    final tempState = state.removeWidget(widgetId);
    if (!tempState.canAddWidget(newPlacement)) {
      throw ArgumentError('Cannot resize widget: new placement conflicts with existing widgets or is out of bounds');
    }
    
    return state.updateWidget(widgetId, newPlacement);
  }

  @override
  LayoutState undo(LayoutState state) {
    return state.updateWidget(widgetId, oldPlacement);
  }
}

/// Command to update a widget's placement
class UpdateWidgetCommand extends FormLayoutCommand {
  final String widgetId;
  final WidgetPlacement oldPlacement;
  final WidgetPlacement newPlacement;

  UpdateWidgetCommand(this.widgetId, this.oldPlacement, this.newPlacement);

  @override
  LayoutState execute(LayoutState state) {
    final widget = state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }
    
    // Create a temporary state without the current widget to check if the new placement is valid
    final tempState = state.removeWidget(widgetId);
    if (!tempState.canAddWidget(newPlacement)) {
      throw ArgumentError('Cannot update widget: new placement conflicts with existing widgets or is out of bounds');
    }
    
    return state.updateWidget(widgetId, newPlacement);
  }

  @override
  LayoutState undo(LayoutState state) {
    return state.updateWidget(widgetId, oldPlacement);
  }
}

/// Command to resize the grid
class ResizeGridCommand extends FormLayoutCommand {
  final GridDimensions oldDimensions;
  final GridDimensions newDimensions;

  ResizeGridCommand(this.oldDimensions, this.newDimensions);

  @override
  LayoutState execute(LayoutState state) {
    return state.resizeGrid(newDimensions);
  }

  @override
  LayoutState undo(LayoutState state) {
    return state.resizeGrid(oldDimensions);
  }
}

