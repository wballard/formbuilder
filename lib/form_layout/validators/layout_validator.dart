import 'package:formbuilder/form_layout/models/validation_result.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';
import 'dart:ui';

/// Validator for layout operations
class LayoutValidator {
  /// Validates adding a widget to the layout
  static ValidationResult validateAddWidget(
    LayoutState state,
    WidgetPlacement placement,
  ) {
    // Check if widget fits in grid
    if (!placement.fitsInGrid(state.dimensions)) {
      final endCol = placement.column + placement.width;
      final endRow = placement.row + placement.height;
      
      if (endCol > state.dimensions.columns) {
        return ValidationResult.error(
          'Widget would extend beyond grid boundary.\n'
          'Widget ends at column $endCol but grid only has ${state.dimensions.columns} columns.',
          context: {
            'placement': placement,
            'gridColumns': state.dimensions.columns,
            'widgetEndColumn': endCol,
          },
        );
      }
      
      if (endRow > state.dimensions.rows) {
        return ValidationResult.error(
          'Widget would extend beyond grid boundary.\n'
          'Widget ends at row $endRow but grid only has ${state.dimensions.rows} rows.',
          context: {
            'placement': placement,
            'gridRows': state.dimensions.rows,
            'widgetEndRow': endRow,
          },
        );
      }
    }
    
    // Check for overlaps
    final overlappingWidgets = state.widgets
        .where((w) => w.overlaps(placement))
        .toList();
    
    if (overlappingWidgets.isNotEmpty) {
      final names = overlappingWidgets
          .map((w) => state.widgets.indexOf(w) + 1)
          .join(', ');
      
      return ValidationResult.error(
        'Space is occupied by another widget.\n'
        'Overlaps with widget${overlappingWidgets.length > 1 ? 's' : ''}: $names',
        context: {
          'placement': placement,
          'overlappingWidgets': overlappingWidgets,
        },
      );
    }
    
    // Check if ID already exists
    if (state.widgets.any((w) => w.id == placement.id)) {
      return ValidationResult.error(
        'A widget with ID "${placement.id}" already exists.',
        context: {
          'placement': placement,
          'existingId': placement.id,
        },
      );
    }
    
    return const ValidationResult.success();
  }

  /// Validates moving a widget to a new position
  static ValidationResult validateMoveWidget(
    LayoutState state,
    String widgetId,
    Point<int> newPosition,
  ) {
    final widget = state.getWidget(widgetId);
    if (widget == null) {
      return ValidationResult.error(
        'Widget with ID "$widgetId" not found.',
        context: {'widgetId': widgetId},
      );
    }
    
    final newPlacement = widget.copyWith(
      column: newPosition.x,
      row: newPosition.y,
    );
    
    // Check if new position fits in grid
    if (!newPlacement.fitsInGrid(state.dimensions)) {
      return ValidationResult.error(
        'Widget would extend beyond grid boundary at new position.',
        context: {
          'widget': widget,
          'newPosition': newPosition,
          'gridDimensions': state.dimensions,
        },
      );
    }
    
    // Check for overlaps (excluding self)
    final overlappingWidgets = state.widgets
        .where((w) => w.id != widgetId && w.overlaps(newPlacement))
        .toList();
    
    if (overlappingWidgets.isNotEmpty) {
      return ValidationResult.error(
        'New position would overlap with existing widgets.',
        context: {
          'widget': widget,
          'newPosition': newPosition,
          'overlappingWidgets': overlappingWidgets,
        },
      );
    }
    
    return const ValidationResult.success();
  }

  /// Validates resizing a widget
  static ValidationResult validateResizeWidget(
    LayoutState state,
    String widgetId,
    Size newSize,
  ) {
    final widget = state.getWidget(widgetId);
    if (widget == null) {
      return ValidationResult.error(
        'Widget with ID "$widgetId" not found.',
        context: {'widgetId': widgetId},
      );
    }
    
    // Check minimum size
    if (newSize.width < 1 || newSize.height < 1) {
      return ValidationResult.error(
        'Widget size must be at least 1x1.',
        context: {
          'widget': widget,
          'newSize': newSize,
        },
      );
    }
    
    final newPlacement = widget.copyWith(
      width: newSize.width.toInt(),
      height: newSize.height.toInt(),
    );
    
    // Check if new size fits in grid
    if (!newPlacement.fitsInGrid(state.dimensions)) {
      return ValidationResult.error(
        'Widget would extend beyond grid boundary with new size.',
        context: {
          'widget': widget,
          'newSize': newSize,
          'gridDimensions': state.dimensions,
        },
      );
    }
    
    // Check for overlaps (excluding self)
    final overlappingWidgets = state.widgets
        .where((w) => w.id != widgetId && w.overlaps(newPlacement))
        .toList();
    
    if (overlappingWidgets.isNotEmpty) {
      return ValidationResult.error(
        'New size would overlap with existing widgets.',
        context: {
          'widget': widget,
          'newSize': newSize,
          'overlappingWidgets': overlappingWidgets,
        },
      );
    }
    
    return const ValidationResult.success();
  }

  /// Validates resizing the grid
  static ValidationResult validateResizeGrid(
    LayoutState state,
    GridDimensions newDimensions,
  ) {
    // Find widgets that would be removed
    final affectedWidgets = state.widgets
        .where((w) => !w.fitsInGrid(newDimensions))
        .toList();
    
    if (affectedWidgets.isEmpty) {
      return const ValidationResult.success();
    }
    
    // Return warning with affected widgets
    final widgetNames = affectedWidgets
        .map((w) => 'Widget ${state.widgets.indexOf(w) + 1} at (${w.column}, ${w.row})')
        .join('\n');
    
    return ValidationResult.warning(
      'Resizing the grid will remove ${affectedWidgets.length} widget${affectedWidgets.length > 1 ? 's' : ''}:\n$widgetNames',
      context: {
        'affectedWidgets': affectedWidgets,
        'oldDimensions': state.dimensions,
        'newDimensions': newDimensions,
      },
    );
  }

  /// Validates removing a widget
  static ValidationResult validateRemoveWidget(
    LayoutState state,
    String widgetId,
  ) {
    final widget = state.getWidget(widgetId);
    if (widget == null) {
      return ValidationResult.error(
        'Widget with ID "$widgetId" not found.',
        context: {'widgetId': widgetId},
      );
    }
    
    // Always allow removal, but could add warnings in the future
    return const ValidationResult.success();
  }

  /// Validates widget placement bounds
  static ValidationResult validateBounds(
    WidgetPlacement placement,
    GridDimensions dimensions,
  ) {
    if (placement.column < 0 || placement.row < 0) {
      return ValidationResult.error(
        'Widget position cannot be negative.',
        context: {
          'placement': placement,
          'gridDimensions': dimensions,
        },
      );
    }
    
    if (!placement.fitsInGrid(dimensions)) {
      return ValidationResult.error(
        'Widget extends beyond grid boundaries.',
        context: {
          'placement': placement,
          'gridDimensions': dimensions,
        },
      );
    }
    
    return const ValidationResult.success();
  }

  /// Validates overlap between two widgets
  static ValidationResult validateNoOverlap(
    WidgetPlacement widget1,
    WidgetPlacement widget2,
  ) {
    if (widget1.overlaps(widget2)) {
      return ValidationResult.error(
        'Widgets overlap each other.',
        context: {
          'widget1': widget1,
          'widget2': widget2,
        },
      );
    }
    
    return const ValidationResult.success();
  }
}