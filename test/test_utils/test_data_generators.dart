import 'dart:math';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';

/// Utility class for generating test data
class TestDataGenerators {
  static final _random = Random();

  /// Generates a random widget placement
  static WidgetPlacement randomWidget({
    String? id,
    GridDimensions? constraints,
    int? maxWidth,
    int? maxHeight,
  }) {
    final gridConstraints = constraints ?? const GridDimensions(columns: 12, rows: 12);
    final widgetMaxWidth = maxWidth ?? 4;
    final widgetMaxHeight = maxHeight ?? 2;
    
    final width = _random.nextInt(widgetMaxWidth) + 1;
    final height = _random.nextInt(widgetMaxHeight) + 1;
    final column = _random.nextInt(gridConstraints.columns - width + 1);
    final row = _random.nextInt(gridConstraints.rows - height + 1);
    
    final widgetTypes = [
      'text_input',
      'button',
      'label',
      'dropdown',
      'checkbox',
      'radio',
      'text_area',
      'date_picker',
    ];
    
    return WidgetPlacement(
      id: id ?? 'widget_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      widgetName: widgetTypes[_random.nextInt(widgetTypes.length)],
      column: column,
      row: row,
      width: width,
      height: height,
      properties: _generateRandomProperties(),
    );
  }

  /// Generates random widget properties
  static Map<String, dynamic> _generateRandomProperties() {
    final properties = <String, dynamic>{};
    
    if (_random.nextBool()) {
      properties['label'] = 'Label ${_random.nextInt(100)}';
    }
    
    if (_random.nextBool()) {
      properties['required'] = _random.nextBool();
    }
    
    if (_random.nextBool()) {
      properties['placeholder'] = 'Placeholder ${_random.nextInt(100)}';
    }
    
    return properties;
  }

  /// Generates a random layout with non-overlapping widgets
  static LayoutState randomLayout({
    int widgetCount = 5,
    GridDimensions? dimensions,
    int maxAttempts = 100,
  }) {
    final gridDimensions = dimensions ?? GridDimensions(columns: 12, rows: 12);
    final widgets = <WidgetPlacement>[];
    
    for (int i = 0; i < widgetCount; i++) {
      WidgetPlacement? newWidget;
      int attempts = 0;
      
      // Try to place widget without overlap
      while (attempts < maxAttempts) {
        newWidget = randomWidget(
          constraints: gridDimensions,
          maxWidth: min(4, gridDimensions.columns ~/ 2),
          maxHeight: min(2, gridDimensions.rows ~/ 2),
        );
        
        // Check if it overlaps with existing widgets
        bool hasOverlap = false;
        for (final existing in widgets) {
          if (newWidget.overlaps(existing)) {
            hasOverlap = true;
            break;
          }
        }
        
        if (!hasOverlap) {
          widgets.add(newWidget);
          break;
        }
        
        attempts++;
      }
    }
    
    return LayoutState(dimensions: gridDimensions, widgets: widgets);
  }

  /// Generates a dense layout (fills most of the grid)
  static LayoutState denseLayout({
    GridDimensions? dimensions,
    double fillRatio = 0.8,
  }) {
    final gridDimensions = dimensions ?? GridDimensions(columns: 12, rows: 12);
    final totalCells = gridDimensions.columns * gridDimensions.rows;
    final targetFilledCells = (totalCells * fillRatio).round();
    
    final widgets = <WidgetPlacement>[];
    final occupiedCells = <Point<int>>{};
    
    int attempts = 0;
    while (occupiedCells.length < targetFilledCells && attempts < 1000) {
      final widget = randomWidget(
        constraints: gridDimensions,
        maxWidth: 3,
        maxHeight: 2,
      );
      
      // Check if placement is valid
      bool canPlace = true;
      for (int r = widget.row; r < widget.row + widget.height; r++) {
        for (int c = widget.column; c < widget.column + widget.width; c++) {
          if (occupiedCells.contains(Point(c, r))) {
            canPlace = false;
            break;
          }
        }
        if (!canPlace) break;
      }
      
      if (canPlace) {
        widgets.add(widget);
        // Mark cells as occupied
        for (int r = widget.row; r < widget.row + widget.height; r++) {
          for (int c = widget.column; c < widget.column + widget.width; c++) {
            occupiedCells.add(Point(c, r));
          }
        }
      }
      
      attempts++;
    }
    
    return LayoutState(dimensions: gridDimensions, widgets: widgets);
  }

  /// Generates an edge case layout with widgets at boundaries
  static LayoutState edgeCaseLayout({GridDimensions? dimensions}) {
    final gridDimensions = dimensions ?? GridDimensions(columns: 12, rows: 12);
    
    return LayoutState(
      dimensions: gridDimensions,
      widgets: [
        // Top-left corner
        WidgetPlacement(
          id: 'top_left',
          widgetName: 'button',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        ),
        // Top-right corner
        WidgetPlacement(
          id: 'top_right',
          widgetName: 'button',
          column: gridDimensions.columns - 2,
          row: 0,
          width: 2,
          height: 1,
        ),
        // Bottom-left corner
        WidgetPlacement(
          id: 'bottom_left',
          widgetName: 'button',
          column: 0,
          row: gridDimensions.rows - 1,
          width: 2,
          height: 1,
        ),
        // Bottom-right corner
        WidgetPlacement(
          id: 'bottom_right',
          widgetName: 'button',
          column: gridDimensions.columns - 2,
          row: gridDimensions.rows - 1,
          width: 2,
          height: 1,
        ),
        // Center (moved to avoid overlap with full_height)
        WidgetPlacement(
          id: 'center',
          widgetName: 'text_area',
          column: gridDimensions.columns ~/ 2 + 1,
          row: gridDimensions.rows ~/ 2 - 1,
          width: 2,
          height: 2,
        ),
        // Full width at bottom
        WidgetPlacement(
          id: 'full_width',
          widgetName: 'label',
          column: 0,
          row: gridDimensions.rows - 2,
          width: gridDimensions.columns,
          height: 1,
        ),
        // Full height (narrow)
        WidgetPlacement(
          id: 'full_height',
          widgetName: 'label',
          column: 4,
          row: 0,
          width: 1,
          height: gridDimensions.rows,
        ),
      ],
    );
  }

  /// Generates a stress test layout with many small widgets
  static LayoutState stressTestLayout({
    GridDimensions? dimensions,
    int widgetCount = 100,
  }) {
    final gridDimensions = dimensions ?? GridDimensions(columns: 24, rows: 24);
    final widgets = <WidgetPlacement>[];
    
    // Create a grid of 1x1 widgets
    int widgetIndex = 0;
    for (int row = 0; row < gridDimensions.rows && widgetIndex < widgetCount; row += 2) {
      for (int col = 0; col < gridDimensions.columns && widgetIndex < widgetCount; col += 2) {
        widgets.add(WidgetPlacement(
          id: 'stress_widget_$widgetIndex',
          widgetName: 'button',
          column: col,
          row: row,
          width: 1,
          height: 1,
        ));
        widgetIndex++;
      }
    }
    
    return LayoutState(dimensions: gridDimensions, widgets: widgets);
  }

  /// Generates a layout with specific patterns
  static LayoutState patternLayout(String pattern, {GridDimensions? dimensions}) {
    final gridDimensions = dimensions ?? GridDimensions(columns: 12, rows: 12);
    
    switch (pattern) {
      case 'checkerboard':
        return _checkerboardLayout(gridDimensions);
      case 'columns':
        return _columnsLayout(gridDimensions);
      case 'rows':
        return _rowsLayout(gridDimensions);
      case 'diagonal':
        return _diagonalLayout(gridDimensions);
      default:
        return LayoutState.empty();
    }
  }

  static LayoutState _checkerboardLayout(GridDimensions dimensions) {
    final widgets = <WidgetPlacement>[];
    
    for (int row = 0; row < dimensions.rows; row += 2) {
      for (int col = row.isEven ? 0 : 1; col < dimensions.columns; col += 2) {
        widgets.add(WidgetPlacement(
          id: 'checker_${row}_$col',
          widgetName: 'button',
          column: col,
          row: row,
          width: 1,
          height: 1,
        ));
      }
    }
    
    return LayoutState(dimensions: dimensions, widgets: widgets);
  }

  static LayoutState _columnsLayout(GridDimensions dimensions) {
    final widgets = <WidgetPlacement>[];
    final columnWidth = 2;
    final spacing = 1;
    
    for (int col = 0; col < dimensions.columns; col += columnWidth + spacing) {
      widgets.add(WidgetPlacement(
        id: 'column_$col',
        widgetName: 'text_area',
        column: col,
        row: 0,
        width: columnWidth,
        height: dimensions.rows,
      ));
    }
    
    return LayoutState(dimensions: dimensions, widgets: widgets);
  }

  static LayoutState _rowsLayout(GridDimensions dimensions) {
    final widgets = <WidgetPlacement>[];
    final rowHeight = 2;
    final spacing = 1;
    
    for (int row = 0; row < dimensions.rows; row += rowHeight + spacing) {
      widgets.add(WidgetPlacement(
        id: 'row_$row',
        widgetName: 'label',
        column: 0,
        row: row,
        width: dimensions.columns,
        height: rowHeight,
      ));
    }
    
    return LayoutState(dimensions: dimensions, widgets: widgets);
  }

  static LayoutState _diagonalLayout(GridDimensions dimensions) {
    final widgets = <WidgetPlacement>[];
    final size = min(dimensions.columns, dimensions.rows);
    
    for (int i = 0; i < size - 1; i++) {
      widgets.add(WidgetPlacement(
        id: 'diagonal_$i',
        widgetName: 'button',
        column: i,
        row: i,
        width: 2,
        height: 1,
      ));
    }
    
    return LayoutState(dimensions: dimensions, widgets: widgets);
  }
}