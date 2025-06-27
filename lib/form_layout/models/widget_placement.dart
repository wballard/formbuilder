import 'dart:math';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

class WidgetPlacement {
  final String id;
  final String widgetName;
  final int column;
  final int row;
  final int width;
  final int height;
  final Map<String, dynamic> properties;

  WidgetPlacement({
    required this.id,
    required this.widgetName,
    required this.column,
    required this.row,
    required this.width,
    required this.height,
    Map<String, dynamic>? properties,
  })  : properties = Map.unmodifiable(properties ?? {}),
        assert(id.isNotEmpty, 'ID cannot be empty'),
        assert(widgetName.isNotEmpty, 'Widget name cannot be empty'),
        assert(column >= 0, 'Column must be non-negative'),
        assert(row >= 0, 'Row must be non-negative'),
        assert(width >= 1, 'Width must be at least 1'),
        assert(height >= 1, 'Height must be at least 1');

  Rectangle<int> get bounds {
    return Rectangle(column, row, width, height);
  }

  bool fitsInGrid(GridDimensions dimensions) {
    return column >= 0 &&
        row >= 0 &&
        column + width <= dimensions.columns &&
        row + height <= dimensions.rows;
  }

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
      properties.hashCode;

  /// Convert to JSON
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

  /// Create from JSON
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