/// Represents the dimensions of a form layout grid.
/// 
/// This class defines the size of the grid in terms of columns and rows.
/// The grid system provides a flexible foundation for responsive form layouts.
/// 
/// ## Grid Constraints
/// 
/// The grid has the following size constraints:
/// - Columns: 1-12 (optimized for responsive design)
/// - Rows: 1-20 (suitable for most form layouts)
/// 
/// These constraints ensure reasonable performance and usability while
/// providing flexibility for various form designs.
/// 
/// ## Example
/// 
/// ```dart
/// // Create a standard 4x4 grid
/// const grid = GridDimensions(columns: 4, rows: 4);
/// 
/// // Create a wide grid for complex forms
/// const wideGrid = GridDimensions(columns: 12, rows: 10);
/// 
/// // Resize an existing grid
/// final resized = grid.copyWith(rows: 6);
/// ```
/// 
/// @see [LayoutState] which uses these dimensions
/// @see [WidgetPlacement.fitsInGrid] for boundary checking
class GridDimensions {
  /// Minimum number of columns allowed in a grid.
  static const int minColumns = 1;
  
  /// Maximum number of columns allowed in a grid.
  static const int maxColumns = 12;
  
  /// Minimum number of rows allowed in a grid.
  static const int minRows = 1;
  
  /// Maximum number of rows allowed in a grid.
  static const int maxRows = 20;

  /// The number of columns in the grid.
  /// 
  /// Must be between [minColumns] and [maxColumns] inclusive.
  final int columns;
  
  /// The number of rows in the grid.
  /// 
  /// Must be between [minRows] and [maxRows] inclusive.
  final int rows;

  /// Creates a new grid dimensions instance.
  /// 
  /// The [columns] and [rows] parameters must be within the allowed ranges:
  /// - columns: [minColumns] to [maxColumns]
  /// - rows: [minRows] to [maxRows]
  /// 
  /// Throws [AssertionError] in debug mode if the values are out of range.
  /// 
  /// Example:
  /// ```dart
  /// // Create a 4x4 grid
  /// const dimensions = GridDimensions(columns: 4, rows: 4);
  /// 
  /// // Create a wide responsive grid
  /// const responsive = GridDimensions(columns: 12, rows: 6);
  /// ```
  const GridDimensions({required this.columns, required this.rows})
    : assert(
        columns >= minColumns && columns <= maxColumns,
        'Columns must be between $minColumns and $maxColumns',
      ),
      assert(
        rows >= minRows && rows <= maxRows,
        'Rows must be between $minRows and $maxRows',
      );

  /// Creates a new grid dimensions instance with runtime validation.
  /// 
  /// Unlike the default constructor, this factory throws [ArgumentError]
  /// at runtime if the values are out of range, making it suitable for
  /// handling user input or dynamic values.
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final dimensions = GridDimensions.validated(
  ///     columns: userInputColumns,
  ///     rows: userInputRows,
  ///   );
  ///   print('Valid grid created');
  /// } catch (e) {
  ///   print('Invalid dimensions: $e');
  /// }
  /// ```
  factory GridDimensions.validated({required int columns, required int rows}) {
    if (columns < minColumns || columns > maxColumns) {
      throw ArgumentError(
        'Columns must be between $minColumns and $maxColumns',
      );
    }
    if (rows < minRows || rows > maxRows) {
      throw ArgumentError('Rows must be between $minRows and $maxRows');
    }
    return GridDimensions(columns: columns, rows: rows);
  }

  /// Creates a copy of these dimensions with optionally modified values.
  /// 
  /// Any parameter can be provided to override the corresponding value.
  /// The new values are validated using [validated] to ensure they're
  /// within allowed ranges.
  /// 
  /// Example:
  /// ```dart
  /// final original = GridDimensions(columns: 4, rows: 4);
  /// 
  /// // Expand columns only
  /// final wider = original.copyWith(columns: 6);
  /// 
  /// // Expand rows only
  /// final taller = original.copyWith(rows: 8);
  /// 
  /// // Resize both dimensions
  /// final larger = original.copyWith(columns: 8, rows: 10);
  /// ```
  GridDimensions copyWith({int? columns, int? rows}) {
    return GridDimensions.validated(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridDimensions &&
          runtimeType == other.runtimeType &&
          columns == other.columns &&
          rows == other.rows;

  @override
  int get hashCode => columns.hashCode ^ rows.hashCode;

  /// Converts these grid dimensions to a JSON representation.
  /// 
  /// Returns a map with 'columns' and 'rows' keys that can be
  /// serialized to JSON for storage or API communication.
  /// 
  /// Example:
  /// ```dart
  /// final dimensions = GridDimensions(columns: 4, rows: 6);
  /// final json = dimensions.toJson();
  /// // Result: {'columns': 4, 'rows': 6}
  /// 
  /// // Save to storage
  /// await prefs.setString('grid_size', jsonEncode(json));
  /// ```
  /// 
  /// @see [fromJson] to restore from JSON
  Map<String, dynamic> toJson() {
    return {'columns': columns, 'rows': rows};
  }

  /// Creates [GridDimensions] from a JSON representation.
  /// 
  /// This factory constructor restores grid dimensions from the JSON
  /// format produced by [toJson]. The values are validated to ensure
  /// they're within allowed ranges.
  /// 
  /// Throws [ArgumentError] if the values are out of range.
  /// Throws [TypeError] if the JSON structure is invalid.
  /// 
  /// Example:
  /// ```dart
  /// // Load from storage
  /// final jsonString = await prefs.getString('grid_size');
  /// if (jsonString != null) {
  ///   final json = jsonDecode(jsonString);
  ///   final dimensions = GridDimensions.fromJson(json);
  ///   print('Loaded ${dimensions.columns}x${dimensions.rows} grid');
  /// }
  /// 
  /// // From API response
  /// final response = await api.getGridConfig();
  /// final dimensions = GridDimensions.fromJson(response.data);
  /// ```
  /// 
  /// @see [toJson] for the JSON format
  factory GridDimensions.fromJson(Map<String, dynamic> json) {
    return GridDimensions.validated(
      columns: json['columns'] as int,
      rows: json['rows'] as int,
    );
  }

  @override
  String toString() {
    return 'GridDimensions(columns: $columns, rows: $rows)';
  }
}
