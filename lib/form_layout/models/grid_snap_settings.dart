/// Enum representing different grid subdivision levels
enum GridSubdivision {
  none(1),
  half(2),
  quarter(4);

  final int divisor;
  const GridSubdivision(this.divisor);

  /// Convert string to GridSubdivision
  static GridSubdivision fromString(String value) {
    switch (value.toLowerCase()) {
      case 'half':
        return GridSubdivision.half;
      case 'quarter':
        return GridSubdivision.quarter;
      case 'none':
      default:
        return GridSubdivision.none;
    }
  }

  /// Convert to string for serialization
  String toStringValue() => name;
}

/// Settings for grid snapping behavior
class GridSnapSettings {
  /// Whether widgets snap to grid cells
  final bool snapToGrid;

  /// Whether widgets snap to other widget edges
  final bool snapToWidgets;

  /// Whether free positioning (pixel-perfect) is allowed
  final bool freePositioning;

  /// Whether magnetic edge alignment is enabled
  final bool magneticEdges;

  /// Grid subdivision level for fine positioning
  final GridSubdivision subdivisions;

  /// Distance threshold for snapping (in pixels)
  final double snapThreshold;

  const GridSnapSettings({
    this.snapToGrid = true,
    this.snapToWidgets = false,
    this.freePositioning = false,
    this.magneticEdges = false,
    this.subdivisions = GridSubdivision.none,
    this.snapThreshold = 8.0,
  });

  /// Create a copy with modified values
  GridSnapSettings copyWith({
    bool? snapToGrid,
    bool? snapToWidgets,
    bool? freePositioning,
    bool? magneticEdges,
    GridSubdivision? subdivisions,
    double? snapThreshold,
  }) {
    return GridSnapSettings(
      snapToGrid: snapToGrid ?? this.snapToGrid,
      snapToWidgets: snapToWidgets ?? this.snapToWidgets,
      freePositioning: freePositioning ?? this.freePositioning,
      magneticEdges: magneticEdges ?? this.magneticEdges,
      subdivisions: subdivisions ?? this.subdivisions,
      snapThreshold: snapThreshold ?? this.snapThreshold,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'snapToGrid': snapToGrid,
      'snapToWidgets': snapToWidgets,
      'freePositioning': freePositioning,
      'magneticEdges': magneticEdges,
      'subdivisions': subdivisions.toStringValue(),
      'snapThreshold': snapThreshold,
    };
  }

  /// Create from JSON
  factory GridSnapSettings.fromJson(Map<String, dynamic> json) {
    return GridSnapSettings(
      snapToGrid: json['snapToGrid'] ?? true,
      snapToWidgets: json['snapToWidgets'] ?? false,
      freePositioning: json['freePositioning'] ?? false,
      magneticEdges: json['magneticEdges'] ?? false,
      subdivisions: GridSubdivision.fromString(json['subdivisions'] ?? 'none'),
      snapThreshold: (json['snapThreshold'] ?? 8.0).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridSnapSettings &&
          runtimeType == other.runtimeType &&
          snapToGrid == other.snapToGrid &&
          snapToWidgets == other.snapToWidgets &&
          freePositioning == other.freePositioning &&
          magneticEdges == other.magneticEdges &&
          subdivisions == other.subdivisions &&
          snapThreshold == other.snapThreshold;

  @override
  int get hashCode =>
      snapToGrid.hashCode ^
      snapToWidgets.hashCode ^
      freePositioning.hashCode ^
      magneticEdges.hashCode ^
      subdivisions.hashCode ^
      snapThreshold.hashCode;
}
