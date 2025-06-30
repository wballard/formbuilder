import 'dart:math';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// Represents the complete state of a form layout.
/// 
/// This is the core model class that holds all information about a form's
/// current state, including the grid dimensions and all placed widgets.
/// The class is immutable - all operations return a new instance.
/// 
/// ## Example
/// 
/// ```dart
/// // Create an empty layout with a 4x4 grid
/// final layout = LayoutState.empty();
/// 
/// // Add a widget to the layout
/// final widget = WidgetPlacement(
///   id: 'text-1',
///   widgetName: 'text_field',
///   column: 0,
///   row: 0,
///   width: 2,
///   height: 1,
/// );
/// 
/// if (layout.canAddWidget(widget)) {
///   final newLayout = layout.addWidget(widget);
///   print('Widget added successfully');
/// }
/// 
/// // Serialize to JSON for persistence
/// final json = layout.toJson();
/// 
/// // Restore from JSON
/// final restoredLayout = LayoutState.fromJson(json);
/// ```
/// 
/// @see [GridDimensions] for grid configuration
/// @see [WidgetPlacement] for widget positioning
/// @see [FormLayout] for the main widget that uses this state
class LayoutState {
  /// The dimensions of the grid (number of columns and rows).
  final GridDimensions dimensions;
  
  /// The list of widgets placed in the grid.
  /// 
  /// This list is immutable and guaranteed to contain no overlapping widgets
  /// or duplicate IDs. All widgets are validated to fit within the grid bounds.
  final List<WidgetPlacement> widgets;

  /// Creates a new [LayoutState] with the specified dimensions and widgets.
  /// 
  /// The constructor validates that:
  /// - No duplicate widget IDs exist
  /// - All widgets fit within the grid bounds
  /// - No widgets overlap with each other
  /// 
  /// Throws [ArgumentError] if any validation fails.
  /// 
  /// The [widgets] list is made immutable internally.
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

  /// Creates an empty layout with default 4x4 grid dimensions.
  /// 
  /// This is a convenient starting point for new forms.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final emptyLayout = LayoutState.empty();
  /// print(emptyLayout.dimensions); // GridDimensions(columns: 4, rows: 4)
  /// print(emptyLayout.widgets.length); // 0
  /// ```
  factory LayoutState.empty() {
    return LayoutState(
      dimensions: const GridDimensions(columns: 4, rows: 4),
      widgets: [],
    );
  }

  /// Checks if a widget can be added to the layout without conflicts.
  /// 
  /// Returns `true` if the widget:
  /// - Fits within the grid bounds
  /// - Has a unique ID (no duplicates)
  /// - Does not overlap with existing widgets
  /// 
  /// This method should be called before [addWidget] to avoid exceptions.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final placement = WidgetPlacement(
  ///   id: 'button-1',
  ///   widgetName: 'button',
  ///   column: 2,
  ///   row: 2,
  ///   width: 1,
  ///   height: 1,
  /// );
  /// 
  /// if (layout.canAddWidget(placement)) {
  ///   final newLayout = layout.addWidget(placement);
  /// } else {
  ///   print('Cannot add widget - check for overlaps or bounds');
  /// }
  /// ```
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

  /// Adds a new widget to the layout.
  /// 
  /// Returns a new [LayoutState] instance with the widget added.
  /// 
  /// Throws [ArgumentError] if the widget cannot be added (check with
  /// [canAddWidget] first to avoid exceptions).
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// try {
  ///   final newLayout = layout.addWidget(placement);
  ///   print('Widget added: ${placement.id}');
  /// } catch (e) {
  ///   print('Failed to add widget: $e');
  /// }
  /// ```
  /// 
  /// @see [canAddWidget] to check if addition is valid
  /// @see [removeWidget] to remove widgets
  LayoutState addWidget(WidgetPlacement placement) {
    if (!canAddWidget(placement)) {
      throw ArgumentError('Cannot add widget: $placement');
    }

    return LayoutState(
      dimensions: dimensions,
      widgets: [...widgets, placement],
    );
  }

  /// Removes a widget from the layout by its ID.
  /// 
  /// Returns a new [LayoutState] instance with the widget removed, or the
  /// same instance if no widget with the given ID exists.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final updatedLayout = layout.removeWidget('text-field-1');
  /// 
  /// if (updatedLayout == layout) {
  ///   print('Widget not found');
  /// } else {
  ///   print('Widget removed successfully');
  /// }
  /// ```
  /// 
  /// @see [addWidget] to add widgets
  /// @see [updateWidget] to modify existing widgets
  LayoutState removeWidget(String widgetId) {
    final newWidgets = widgets.where((w) => w.id != widgetId).toList();

    // Return same instance if nothing was removed
    if (newWidgets.length == widgets.length) {
      return this;
    }

    return LayoutState(dimensions: dimensions, widgets: newWidgets);
  }

  /// Updates an existing widget's placement in the layout.
  /// 
  /// The widget ID must remain the same - only position and size can change.
  /// The new placement must fit within the grid and not overlap other widgets.
  /// 
  /// Returns a new [LayoutState] instance with the updated widget.
  /// 
  /// Throws [ArgumentError] if:
  /// - Widget with given ID doesn't exist
  /// - The new placement has a different ID
  /// - The new placement doesn't fit in the grid
  /// - The new placement overlaps with other widgets
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Move a widget to a new position
  /// final widget = layout.getWidget('button-1')!;
  /// final movedWidget = widget.copyWith(column: 2, row: 3);
  /// 
  /// try {
  ///   final newLayout = layout.updateWidget('button-1', movedWidget);
  ///   print('Widget moved successfully');
  /// } catch (e) {
  ///   print('Failed to move widget: $e');
  /// }
  /// ```
  /// 
  /// @see [addWidget] to add new widgets
  /// @see [removeWidget] to remove widgets
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

  /// Retrieves a widget by its ID.
  /// 
  /// Returns the [WidgetPlacement] with the given ID, or `null` if not found.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final widget = layout.getWidget('text-field-1');
  /// if (widget != null) {
  ///   print('Widget found at column ${widget.column}, row ${widget.row}');
  /// } else {
  ///   print('Widget not found');
  /// }
  /// ```
  WidgetPlacement? getWidget(String widgetId) {
    try {
      return widgets.firstWhere((w) => w.id == widgetId);
    } catch (_) {
      return null;
    }
  }

  /// Resizes the grid to new dimensions.
  /// 
  /// Widgets that don't fit in the new grid size are automatically removed.
  /// This ensures the layout remains valid after resizing.
  /// 
  /// Returns a new [LayoutState] with the updated dimensions and filtered widgets.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Resize grid from 4x4 to 6x6
  /// final newDimensions = GridDimensions(columns: 6, rows: 6);
  /// final resizedLayout = layout.resizeGrid(newDimensions);
  /// 
  /// // Some widgets may have been removed if they didn't fit
  /// if (resizedLayout.widgets.length < layout.widgets.length) {
  ///   print('${layout.widgets.length - resizedLayout.widgets.length} widgets removed');
  /// }
  /// ```
  /// 
  /// @see [GridDimensions] for grid configuration
  LayoutState resizeGrid(GridDimensions newDimensions) {
    // Filter out widgets that don't fit in the new grid
    final fittingWidgets = widgets
        .where((widget) => widget.fitsInGrid(newDimensions))
        .toList();

    return LayoutState(dimensions: newDimensions, widgets: fittingWidgets);
  }

  /// Gets all widgets that intersect with the specified area.
  /// 
  /// Useful for finding widgets in a selection rectangle or checking
  /// what widgets are affected by an operation in a specific area.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Find all widgets in the top-left quadrant
  /// final area = Rectangle(0, 0, 2, 2);
  /// final widgetsInArea = layout.getWidgetsInArea(area);
  /// 
  /// for (final widget in widgetsInArea) {
  ///   print('Found widget: ${widget.id}');
  /// }
  /// ```
  List<WidgetPlacement> getWidgetsInArea(Rectangle<int> area) {
    return widgets.where((widget) {
      return widget.bounds.intersects(area);
    }).toList();
  }

  /// Converts the layout state to a JSON representation.
  /// 
  /// The JSON includes version information, metadata, and all layout data.
  /// This format can be used for persistence, export, or API communication.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Save layout to JSON
  /// final json = layout.toJson();
  /// 
  /// // Save to SharedPreferences or file
  /// await prefs.setString('saved_layout', jsonEncode(json));
  /// 
  /// // The JSON structure includes:
  /// // - version: Schema version for compatibility
  /// // - timestamp: When the export was created
  /// // - metadata: Statistics about the layout
  /// // - dimensions: Grid configuration
  /// // - widgets: All placed widgets
  /// ```
  /// 
  /// @see [fromJson] to restore from JSON
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

  /// Creates a [LayoutState] from a JSON representation.
  /// 
  /// Supports both current and legacy JSON formats for backward compatibility.
  /// Validates the reconstructed state to ensure it's valid.
  /// 
  /// Throws [ArgumentError] if the JSON results in an invalid state.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Load layout from JSON
  /// final jsonString = await prefs.getString('saved_layout');
  /// if (jsonString != null) {
  ///   final json = jsonDecode(jsonString);
  ///   final layout = LayoutState.fromJson(json);
  ///   print('Loaded ${layout.widgets.length} widgets');
  /// }
  /// ```
  /// 
  /// @see [toJson] to convert to JSON
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
