import 'dart:math';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Represents a widget placed within a form layout grid.
/// 
/// This class encapsulates all information about a single widget's placement
/// in the grid, including its position, size, and custom properties. Each
/// widget has a unique identifier and is positioned using grid coordinates.
/// 
/// The placement is immutable - all operations that would modify the placement
/// return a new instance via [copyWith].
/// 
/// ## Coordinate System
/// 
/// The grid uses a zero-based coordinate system:
/// - Columns are numbered from left to right starting at 0
/// - Rows are numbered from top to bottom starting at 0
/// - Width and height are in grid cells (minimum 1)
/// 
/// ## Example
/// 
/// ```dart
/// // Create a text field that spans 2 columns and 1 row
/// final textField = WidgetPlacement(
///   id: 'email-field',
///   widgetName: 'text_field',
///   column: 1,
///   row: 2,
///   width: 2,
///   height: 1,
///   properties: {
///     'label': 'Email Address',
///     'required': true,
///     'placeholder': 'user@example.com',
///   },
/// );
/// 
/// // Check if it fits in a 4x4 grid
/// final grid = GridDimensions(columns: 4, rows: 4);
/// if (textField.fitsInGrid(grid)) {
///   print('Widget fits in grid');
/// }
/// 
/// // Move the widget to a new position
/// final moved = textField.copyWith(column: 0, row: 0);
/// ```
/// 
/// @see [LayoutState] for managing multiple widget placements
/// @see [GridDimensions] for grid configuration
/// @see [FormWidget] for the actual widget rendering
class WidgetPlacement {
  /// Unique identifier for this widget placement.
  /// 
  /// This ID must be unique within a [LayoutState]. It's used to identify
  /// the widget for updates, removal, and persistence.
  final String id;
  
  /// The type of widget to render.
  /// 
  /// This should match a registered widget type in the [WidgetToolbox].
  /// Common values include 'text_field', 'button', 'checkbox', etc.
  final String widgetName;
  
  /// The column position in the grid (0-based).
  /// 
  /// Must be >= 0 and < grid columns when combined with width.
  final int column;
  
  /// The row position in the grid (0-based).
  /// 
  /// Must be >= 0 and < grid rows when combined with height.
  final int row;
  
  /// The width in grid cells.
  /// 
  /// Must be >= 1. The widget will span from [column] to [column] + [width] - 1.
  final int width;
  
  /// The height in grid cells.
  /// 
  /// Must be >= 1. The widget will span from [row] to [row] + [height] - 1.
  final int height;
  
  /// Custom properties for the widget.
  /// 
  /// This map contains widget-specific configuration such as labels, values,
  /// validation rules, styling, etc. The properties are immutable once set.
  /// 
  /// Example properties for a text field:
  /// ```dart
  /// {
  ///   'label': 'Email',
  ///   'placeholder': 'Enter email',
  ///   'required': true,
  ///   'validation': 'email',
  /// }
  /// ```
  final Map<String, dynamic> properties;

  /// Creates a new widget placement.
  /// 
  /// All parameters except [properties] are required. The placement will be
  /// validated to ensure:
  /// - [id] is not empty
  /// - [widgetName] is not empty
  /// - [column] and [row] are non-negative
  /// - [width] and [height] are at least 1
  /// 
  /// The [properties] map is made immutable internally.
  /// 
  /// Example:
  /// ```dart
  /// final button = WidgetPlacement(
  ///   id: 'submit-btn',
  ///   widgetName: 'button',
  ///   column: 2,
  ///   row: 3,
  ///   width: 1,
  ///   height: 1,
  ///   properties: {'label': 'Submit', 'style': 'primary'},
  /// );
  /// ```
  WidgetPlacement({
    required this.id,
    required this.widgetName,
    required this.column,
    required this.row,
    required this.width,
    required this.height,
    Map<String, dynamic>? properties,
  }) : properties = Map.unmodifiable(properties ?? {}),
       assert(id.isNotEmpty, 'ID cannot be empty'),
       assert(widgetName.isNotEmpty, 'Widget name cannot be empty'),
       assert(column >= 0, 'Column must be non-negative'),
       assert(row >= 0, 'Row must be non-negative'),
       assert(width >= 1, 'Width must be at least 1'),
       assert(height >= 1, 'Height must be at least 1');

  /// Gets the bounding rectangle for this widget placement.
  /// 
  /// Returns a [Rectangle] that represents the area occupied by this widget
  /// in the grid. This is useful for intersection and overlap calculations.
  /// 
  /// Example:
  /// ```dart
  /// final placement = WidgetPlacement(
  ///   id: 'widget-1',
  ///   widgetName: 'text_field',
  ///   column: 1,
  ///   row: 2,
  ///   width: 2,
  ///   height: 1,
  /// );
  /// 
  /// final rect = placement.bounds; // Rectangle(1, 2, 2, 1)
  /// print('Top-left: (${rect.left}, ${rect.top})');
  /// print('Bottom-right: (${rect.right - 1}, ${rect.bottom - 1})');
  /// ```
  Rectangle<int> get bounds {
    return Rectangle(column, row, width, height);
  }

  /// Checks if this widget placement fits within the given grid dimensions.
  /// 
  /// Returns `true` if the widget, considering its position and size, fits
  /// completely within the grid boundaries. Returns `false` if any part of
  /// the widget would extend beyond the grid edges.
  /// 
  /// This method is commonly used before adding a widget to a layout to
  /// ensure it won't exceed the grid boundaries.
  /// 
  /// Example:
  /// ```dart
  /// final grid = GridDimensions(columns: 4, rows: 4);
  /// final placement = WidgetPlacement(
  ///   id: 'large-widget',
  ///   widgetName: 'container',
  ///   column: 2,
  ///   row: 2,
  ///   width: 3, // Would extend beyond column 4
  ///   height: 2,
  /// );
  /// 
  /// if (!placement.fitsInGrid(grid)) {
  ///   print('Widget is too large for the grid');
  /// }
  /// ```
  /// 
  /// @see [GridDimensions] for grid configuration
  /// @see [LayoutState.canAddWidget] which uses this method
  bool fitsInGrid(GridDimensions dimensions) {
    return column >= 0 &&
        row >= 0 &&
        column + width <= dimensions.columns &&
        row + height <= dimensions.rows;
  }

  /// Checks if this widget placement overlaps with another placement.
  /// 
  /// Returns `true` if the two placements share any interior grid cells.
  /// Note that widgets that only touch at edges or corners are not
  /// considered overlapping.
  /// 
  /// This method is essential for preventing widget collisions in the layout.
  /// 
  /// Example:
  /// ```dart
  /// final widget1 = WidgetPlacement(
  ///   id: 'widget-1',
  ///   widgetName: 'button',
  ///   column: 0,
  ///   row: 0,
  ///   width: 2,
  ///   height: 2,
  /// );
  /// 
  /// final widget2 = WidgetPlacement(
  ///   id: 'widget-2',
  ///   widgetName: 'text_field',
  ///   column: 1,
  ///   row: 1,
  ///   width: 2,
  ///   height: 1,
  /// );
  /// 
  /// if (widget1.overlaps(widget2)) {
  ///   print('Widgets overlap - cannot place both');
  /// }
  /// ```
  /// 
  /// @see [LayoutState.canAddWidget] which uses this to prevent overlaps
  bool overlaps(WidgetPlacement other) {
    // Two rectangles overlap if they share any interior points
    // (not just edges or corners)
    final thisRight = column + width;
    final thisBottom = row + height;
    final otherRight = other.column + other.width;
    final otherBottom = other.row + other.height;

    // Check if one rectangle is to the left, right, above, or below the other
    return !(thisRight <= other.column ||
        otherRight <= column ||
        thisBottom <= other.row ||
        otherBottom <= row);
  }

  /// Creates a copy of this placement with optionally modified values.
  /// 
  /// Any parameter can be provided to override the corresponding value in
  /// the copy. Parameters that are not provided will retain their original
  /// values.
  /// 
  /// This method is useful for:
  /// - Moving a widget to a new position
  /// - Resizing a widget
  /// - Updating widget properties
  /// - Creating variations of existing widgets
  /// 
  /// Example:
  /// ```dart
  /// final original = WidgetPlacement(
  ///   id: 'btn-1',
  ///   widgetName: 'button',
  ///   column: 0,
  ///   row: 0,
  ///   width: 1,
  ///   height: 1,
  ///   properties: {'label': 'Click me'},
  /// );
  /// 
  /// // Move to a new position
  /// final moved = original.copyWith(column: 2, row: 3);
  /// 
  /// // Resize the widget
  /// final resized = original.copyWith(width: 2);
  /// 
  /// // Update properties
  /// final updated = original.copyWith(
  ///   properties: {'label': 'Submit', 'style': 'primary'},
  /// );
  /// ```
  WidgetPlacement copyWith({
    String? id,
    String? widgetName,
    int? column,
    int? row,
    int? width,
    int? height,
    Map<String, dynamic>? properties,
  }) {
    return WidgetPlacement(
      id: id ?? this.id,
      widgetName: widgetName ?? this.widgetName,
      column: column ?? this.column,
      row: row ?? this.row,
      width: width ?? this.width,
      height: height ?? this.height,
      properties: properties ?? this.properties,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetPlacement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          widgetName == other.widgetName &&
          column == other.column &&
          row == other.row &&
          width == other.width &&
          height == other.height &&
          _mapEquals(properties, other.properties);

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      widgetName.hashCode ^
      column.hashCode ^
      row.hashCode ^
      width.hashCode ^
      height.hashCode ^
      _mapHashCode(properties);

  int _mapHashCode(Map<String, dynamic> map) {
    int hash = 0;
    for (final entry in map.entries) {
      hash ^= entry.key.hashCode ^ entry.value.hashCode;
    }
    return hash;
  }

  /// Converts this widget placement to a JSON representation.
  /// 
  /// The returned map contains all the necessary data to reconstruct
  /// the placement using [fromJson]. This includes position, size,
  /// widget type, and all custom properties.
  /// 
  /// The JSON format is:
  /// ```json
  /// {
  ///   "id": "widget-id",
  ///   "widgetName": "text_field",
  ///   "column": 0,
  ///   "row": 0,
  ///   "width": 2,
  ///   "height": 1,
  ///   "properties": {
  ///     "label": "Name",
  ///     "required": true
  ///   }
  /// }
  /// ```
  /// 
  /// Example:
  /// ```dart
  /// final placement = WidgetPlacement(
  ///   id: 'email-field',
  ///   widgetName: 'text_field',
  ///   column: 1,
  ///   row: 2,
  ///   width: 2,
  ///   height: 1,
  ///   properties: {'label': 'Email', 'type': 'email'},
  /// );
  /// 
  /// final json = placement.toJson();
  /// // Save to storage or send to API
  /// await storage.save('placement', json);
  /// ```
  /// 
  /// @see [fromJson] to restore from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'widgetName': widgetName,
      'column': column,
      'row': row,
      'width': width,
      'height': height,
      'properties': Map<String, dynamic>.from(properties),
    };
  }

  /// Creates a [WidgetPlacement] from a JSON representation.
  /// 
  /// This factory constructor restores a widget placement from the JSON
  /// format produced by [toJson]. It handles type conversion and
  /// validates the data structure.
  /// 
  /// The method includes backward compatibility support for different
  /// property formats and ensures the properties map is properly typed.
  /// 
  /// Throws [TypeError] if required fields are missing or have wrong types.
  /// 
  /// Example:
  /// ```dart
  /// // Load from storage
  /// final jsonData = await storage.load('placement');
  /// 
  /// try {
  ///   final placement = WidgetPlacement.fromJson(jsonData);
  ///   print('Loaded widget: ${placement.id}');
  /// } catch (e) {
  ///   print('Invalid placement data: $e');
  /// }
  /// 
  /// // Load from API response
  /// final response = await api.getWidget(widgetId);
  /// final placement = WidgetPlacement.fromJson(response.data);
  /// ```
  /// 
  /// @see [toJson] for the JSON format
  /// @see [LayoutState.fromJson] which uses this to restore layouts
  factory WidgetPlacement.fromJson(Map<String, dynamic> json) {
    // Handle properties with proper type conversion
    Map<String, dynamic> properties = {};
    if (json.containsKey('properties') && json['properties'] != null) {
      final propsData = json['properties'];
      if (propsData is Map<String, dynamic>) {
        properties = propsData;
      } else if (propsData is Map) {
        // Convert dynamic map to typed map
        properties = Map<String, dynamic>.from(propsData);
      }
    }

    return WidgetPlacement(
      id: json['id'] as String,
      widgetName: json['widgetName'] as String,
      column: json['column'] as int,
      row: json['row'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      properties: properties,
    );
  }

  @override
  String toString() {
    return 'WidgetPlacement(id: $id, widgetName: $widgetName, '
        'column: $column, row: $row, width: $width, height: $height, '
        'properties: $properties)';
  }
}
