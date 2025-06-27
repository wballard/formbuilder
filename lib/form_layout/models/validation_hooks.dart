import 'package:flutter/foundation.dart';
import 'package:formbuilder/form_layout/models/validation_result.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';
import 'dart:ui';

/// Type definitions for validation callbacks
typedef ValidateAddWidget = Future<ValidationResult> Function(
  LayoutState state,
  WidgetPlacement placement,
);

typedef ValidateMoveWidget = Future<ValidationResult> Function(
  LayoutState state,
  String widgetId,
  Point<int> newPosition,
);

typedef ValidateResizeWidget = Future<ValidationResult> Function(
  LayoutState state,
  String widgetId,
  Size newSize,
);

typedef ValidateRemoveWidget = Future<ValidationResult> Function(
  LayoutState state,
  String widgetId,
);

typedef ValidateResizeGrid = Future<ValidationResult> Function(
  LayoutState state,
  GridDimensions newDimensions,
);

/// Validation hooks for form layout operations
@immutable
class ValidationHooks {
  /// Hook called before adding a widget
  final ValidateAddWidget? beforeAddWidget;
  
  /// Hook called before moving a widget
  final ValidateMoveWidget? beforeMoveWidget;
  
  /// Hook called before resizing a widget
  final ValidateResizeWidget? beforeResizeWidget;
  
  /// Hook called before removing a widget
  final ValidateRemoveWidget? beforeRemoveWidget;
  
  /// Hook called before resizing the grid
  final ValidateResizeGrid? beforeResizeGrid;

  const ValidationHooks({
    this.beforeAddWidget,
    this.beforeMoveWidget,
    this.beforeResizeWidget,
    this.beforeRemoveWidget,
    this.beforeResizeGrid,
  });

  /// Empty validation hooks (no custom validation)
  static const ValidationHooks none = ValidationHooks();

  /// Creates a copy with some hooks replaced
  ValidationHooks copyWith({
    ValidateAddWidget? beforeAddWidget,
    ValidateMoveWidget? beforeMoveWidget,
    ValidateResizeWidget? beforeResizeWidget,
    ValidateRemoveWidget? beforeRemoveWidget,
    ValidateResizeGrid? beforeResizeGrid,
  }) {
    return ValidationHooks(
      beforeAddWidget: beforeAddWidget ?? this.beforeAddWidget,
      beforeMoveWidget: beforeMoveWidget ?? this.beforeMoveWidget,
      beforeResizeWidget: beforeResizeWidget ?? this.beforeResizeWidget,
      beforeRemoveWidget: beforeRemoveWidget ?? this.beforeRemoveWidget,
      beforeResizeGrid: beforeResizeGrid ?? this.beforeResizeGrid,
    );
  }

  /// Combines multiple validation hooks
  ValidationHooks combine(ValidationHooks other) {
    return ValidationHooks(
      beforeAddWidget: _combineValidators(beforeAddWidget, other.beforeAddWidget),
      beforeMoveWidget: _combineMoveValidators(beforeMoveWidget, other.beforeMoveWidget),
      beforeResizeWidget: _combineResizeValidators(beforeResizeWidget, other.beforeResizeWidget),
      beforeRemoveWidget: _combineRemoveValidators(beforeRemoveWidget, other.beforeRemoveWidget),
      beforeResizeGrid: _combineGridValidators(beforeResizeGrid, other.beforeResizeGrid),
    );
  }

  static ValidateAddWidget? _combineValidators(
    ValidateAddWidget? first,
    ValidateAddWidget? second,
  ) {
    if (first == null) return second;
    if (second == null) return first;
    
    return (state, placement) async {
      final result1 = await first(state, placement);
      if (!result1.isValid) return result1;
      
      final result2 = await second(state, placement);
      return result2;
    };
  }

  static ValidateMoveWidget? _combineMoveValidators(
    ValidateMoveWidget? first,
    ValidateMoveWidget? second,
  ) {
    if (first == null) return second;
    if (second == null) return first;
    
    return (state, widgetId, newPosition) async {
      final result1 = await first(state, widgetId, newPosition);
      if (!result1.isValid) return result1;
      
      final result2 = await second(state, widgetId, newPosition);
      return result2;
    };
  }

  static ValidateResizeWidget? _combineResizeValidators(
    ValidateResizeWidget? first,
    ValidateResizeWidget? second,
  ) {
    if (first == null) return second;
    if (second == null) return first;
    
    return (state, widgetId, newSize) async {
      final result1 = await first(state, widgetId, newSize);
      if (!result1.isValid) return result1;
      
      final result2 = await second(state, widgetId, newSize);
      return result2;
    };
  }

  static ValidateRemoveWidget? _combineRemoveValidators(
    ValidateRemoveWidget? first,
    ValidateRemoveWidget? second,
  ) {
    if (first == null) return second;
    if (second == null) return first;
    
    return (state, widgetId) async {
      final result1 = await first(state, widgetId);
      if (!result1.isValid) return result1;
      
      final result2 = await second(state, widgetId);
      return result2;
    };
  }

  static ValidateResizeGrid? _combineGridValidators(
    ValidateResizeGrid? first,
    ValidateResizeGrid? second,
  ) {
    if (first == null) return second;
    if (second == null) return first;
    
    return (state, newDimensions) async {
      final result1 = await first(state, newDimensions);
      if (!result1.isValid) return result1;
      
      final result2 = await second(state, newDimensions);
      return result2;
    };
  }
}

/// Extension to add validation support to layout operations
extension ValidationSupport on LayoutState {
  /// Validates if a widget can be added
  Future<ValidationResult> canAddWidgetWithHooks(
    WidgetPlacement placement,
    ValidationHooks? hooks,
  ) async {
    if (hooks?.beforeAddWidget != null) {
      return await hooks!.beforeAddWidget!(this, placement);
    }
    return const ValidationResult.success();
  }

  /// Validates if a widget can be moved
  Future<ValidationResult> canMoveWidgetWithHooks(
    String widgetId,
    Point<int> newPosition,
    ValidationHooks? hooks,
  ) async {
    if (hooks?.beforeMoveWidget != null) {
      return await hooks!.beforeMoveWidget!(this, widgetId, newPosition);
    }
    return const ValidationResult.success();
  }

  /// Validates if a widget can be resized
  Future<ValidationResult> canResizeWidgetWithHooks(
    String widgetId,
    Size newSize,
    ValidationHooks? hooks,
  ) async {
    if (hooks?.beforeResizeWidget != null) {
      return await hooks!.beforeResizeWidget!(this, widgetId, newSize);
    }
    return const ValidationResult.success();
  }

  /// Validates if a widget can be removed
  Future<ValidationResult> canRemoveWidgetWithHooks(
    String widgetId,
    ValidationHooks? hooks,
  ) async {
    if (hooks?.beforeRemoveWidget != null) {
      return await hooks!.beforeRemoveWidget!(this, widgetId);
    }
    return const ValidationResult.success();
  }

  /// Validates if the grid can be resized
  Future<ValidationResult> canResizeGridWithHooks(
    GridDimensions newDimensions,
    ValidationHooks? hooks,
  ) async {
    if (hooks?.beforeResizeGrid != null) {
      return await hooks!.beforeResizeGrid!(this, newDimensions);
    }
    return const ValidationResult.success();
  }
}