class GridDimensions {
  static const int minColumns = 1;
  static const int maxColumns = 12;
  static const int minRows = 1;
  static const int maxRows = 20;

  final int columns;
  final int rows;

  const GridDimensions({required this.columns, required this.rows})
    : assert(
        columns >= minColumns && columns <= maxColumns,
        'Columns must be between $minColumns and $maxColumns',
      ),
      assert(
        rows >= minRows && rows <= maxRows,
        'Rows must be between $minRows and $maxRows',
      );

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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'columns': columns, 'rows': rows};
  }

  /// Create from JSON
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
