import 'dart:math';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

class LayoutState {
  final GridDimensions dimensions;
  final List<WidgetPlacement> widgets;

  LayoutState({
    required this.dimensions,
    required List<WidgetPlacement> widgets,
  }) : widgets = List.unmodifiable(widgets) {
    // Validate no duplicate IDs
    final ids = widgets.map((w) => w.id).toSet();
    if (ids.length != widgets.length) {
      throw ArgumentError('Duplicate widget IDs found');
    }

    // Validate all widgets fit in grid
    for (final widget in widgets) {
      if (!widget.fitsInGrid(dimensions)) {
        throw ArgumentError(
          'Widget ${widget.id} does not fit in grid: $widget',
        );
      }
    }

    // Validate no overlapping widgets
    for (int i = 0; i < widgets.length; i++) {
      for (int j = i + 1; j < widgets.length; j++) {
        if (widgets[i].overlaps(widgets[j])) {
          throw ArgumentError(
            'Widgets ${widgets[i].id} and ${widgets[j].id} overlap',
          );
        }
      }
    }
  }

  factory LayoutState.empty() {
    return LayoutState(
      dimensions: const GridDimensions(columns: 4, rows: 4),
      widgets: [],
    );
  }

  bool canAddWidget(WidgetPlacement placement) {
    // Check if fits in grid
    if (!placement.fitsInGrid(dimensions)) {
      return false;
    }

    // Check for duplicate ID
    if (widgets.any((w) => w.id == placement.id)) {
      return false;
    }

    // Check for overlaps
    for (final existing in widgets) {
      if (placement.overlaps(existing)) {
        return false;
      }
    }

    return true;
  }

  LayoutState addWidget(WidgetPlacement placement) {
    if (!canAddWidget(placement)) {
      throw ArgumentError('Cannot add widget: $placement');
    }

    return LayoutState(
      dimensions: dimensions,
      widgets: [...widgets, placement],
    );
  }

  LayoutState removeWidget(String widgetId) {
    final newWidgets = widgets.where((w) => w.id != widgetId).toList();

    // Return same instance if nothing was removed
    if (newWidgets.length == widgets.length) {
      return this;
    }

    return LayoutState(dimensions: dimensions, widgets: newWidgets);
  }

  LayoutState updateWidget(String widgetId, WidgetPlacement newPlacement) {
    // Check if widget exists
    final existingIndex = widgets.indexWhere((w) => w.id == widgetId);
    if (existingIndex == -1) {
      throw ArgumentError('Widget with id $widgetId not found');
    }

    // Check if IDs match
    if (widgetId != newPlacement.id) {
      throw ArgumentError('Widget ID cannot be changed during update');
    }

    // Create temporary state without the widget to check if new placement is valid
    final tempWidgets = [...widgets];
    tempWidgets.removeAt(existingIndex);

    // Check if new placement fits
    if (!newPlacement.fitsInGrid(dimensions)) {
      throw ArgumentError('New placement does not fit in grid');
    }

    // Check for overlaps with other widgets
    for (final other in tempWidgets) {
      if (newPlacement.overlaps(other)) {
        throw ArgumentError('New placement overlaps with widget ${other.id}');
      }
    }

    // Create new state with updated widget
    final newWidgets = [...widgets];
    newWidgets[existingIndex] = newPlacement;

    return LayoutState(dimensions: dimensions, widgets: newWidgets);
  }

  WidgetPlacement? getWidget(String widgetId) {
    try {
      return widgets.firstWhere((w) => w.id == widgetId);
    } catch (_) {
      return null;
    }
  }

  LayoutState resizeGrid(GridDimensions newDimensions) {
    // Filter out widgets that don't fit in the new grid
    final fittingWidgets = widgets
        .where((widget) => widget.fitsInGrid(newDimensions))
        .toList();

    return LayoutState(dimensions: newDimensions, widgets: fittingWidgets);
  }

  List<WidgetPlacement> getWidgetsInArea(Rectangle<int> area) {
    return widgets.where((widget) {
      return widget.bounds.intersects(area);
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': {
        'widgetCount': widgets.length,
        'gridSize': dimensions.columns * dimensions.rows,
        'totalArea': widgets.fold<int>(
          0,
          (sum, widget) => sum + widget.width * widget.height,
        ),
      },
      'dimensions': dimensions.toJson(),
      'widgets': widgets.map((widget) => widget.toJson()).toList(),
    };
  }

  factory LayoutState.fromJson(Map<String, dynamic> json) {
    // Handle both new and legacy formats
    final dimensionsData = json['dimensions'] as Map<String, dynamic>;
    final GridDimensions dimensions;

    if (dimensionsData.containsKey('columns')) {
      // Direct format or GridDimensions.toJson format
      dimensions = GridDimensions.fromJson(dimensionsData);
    } else {
      // Legacy format
      dimensions = GridDimensions(
        columns: dimensionsData['columns'] as int,
        rows: dimensionsData['rows'] as int,
      );
    }

    final widgets = (json['widgets'] as List).map((widgetJson) {
      // Check if this is the new format with WidgetPlacement.toJson
      if (widgetJson.containsKey('properties')) {
        return WidgetPlacement.fromJson(widgetJson as Map<String, dynamic>);
      } else {
        // Legacy format without properties
        return WidgetPlacement(
          id: widgetJson['id'] as String,
          widgetName: widgetJson['widgetName'] as String,
          column: widgetJson['column'] as int,
          row: widgetJson['row'] as int,
          width: widgetJson['width'] as int,
          height: widgetJson['height'] as int,
          properties: {}, // Empty properties for legacy format
        );
      }
    }).toList();

    return LayoutState(dimensions: dimensions, widgets: widgets);
  }

  LayoutState copyWith({
    GridDimensions? dimensions,
    List<WidgetPlacement>? widgets,
  }) {
    // If no changes, return same instance
    if (dimensions == null && widgets == null) {
      return this;
    }

    return LayoutState(
      dimensions: dimensions ?? this.dimensions,
      widgets: widgets ?? this.widgets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutState &&
          runtimeType == other.runtimeType &&
          dimensions == other.dimensions &&
          widgets.length == other.widgets.length &&
          _widgetListsEqual(widgets, other.widgets);

  bool _widgetListsEqual(List<WidgetPlacement> a, List<WidgetPlacement> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => dimensions.hashCode ^ widgets.hashCode;

  @override
  String toString() {
    return 'LayoutState(dimensions: $dimensions, widgets: ${widgets.length} items)';
  }
}
