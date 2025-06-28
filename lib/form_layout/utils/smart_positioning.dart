import 'dart:math';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Direction for compacting layout
enum CompactDirection { left, right, up, down }

/// Strategy for optimizing layout
enum OptimizationStrategy { minimizeArea, minimizeGaps, maintainOrder }

/// Provides smart positioning algorithms for grid layouts
class SmartPositioning {
  /// Find the next available space in the grid
  Point<int>? findNextAvailableSpace({
    required int width,
    required int height,
    required List<WidgetPlacement> existingWidgets,
    required GridDimensions gridDimensions,
  }) {
    // Create a 2D grid to track occupied cells
    final grid = List.generate(
      gridDimensions.rows,
      (_) => List.filled(gridDimensions.columns, false),
    );

    // Mark occupied cells
    for (final widget in existingWidgets) {
      for (
        int r = widget.row;
        r < widget.row + widget.height && r < gridDimensions.rows;
        r++
      ) {
        for (
          int c = widget.column;
          c < widget.column + widget.width && c < gridDimensions.columns;
          c++
        ) {
          grid[r][c] = true;
        }
      }
    }

    // Find first available space that fits the widget
    for (int row = 0; row <= gridDimensions.rows - height; row++) {
      for (int col = 0; col <= gridDimensions.columns - width; col++) {
        if (_canFitAt(grid, col, row, width, height)) {
          return Point(col, row);
        }
      }
    }

    return null;
  }

  /// Check if a widget can fit at the given position
  bool _canFitAt(
    List<List<bool>> grid,
    int col,
    int row,
    int width,
    int height,
  ) {
    for (int r = row; r < row + height && r < grid.length; r++) {
      for (int c = col; c < col + width && c < grid[0].length; c++) {
        if (grid[r][c]) {
          return false;
        }
      }
    }
    return true;
  }

  /// Auto-flow layout for multiple widgets
  List<Point<int>> autoFlowLayout({
    required List<Size> widgetsToPlace,
    required List<WidgetPlacement> existingWidgets,
    required GridDimensions gridDimensions,
  }) {
    final placements = <Point<int>>[];
    final currentWidgets = List<WidgetPlacement>.from(existingWidgets);

    for (int i = 0; i < widgetsToPlace.length; i++) {
      final size = widgetsToPlace[i];
      final position = findNextAvailableSpace(
        width: size.width.toInt(),
        height: size.height.toInt(),
        existingWidgets: currentWidgets,
        gridDimensions: gridDimensions,
      );

      if (position != null) {
        placements.add(position);
        // Add to current widgets to avoid overlaps with next placement
        currentWidgets.add(
          WidgetPlacement(
            id: 'temp_$i',
            widgetName: 'temp',
            column: position.x,
            row: position.y,
            width: size.width.toInt(),
            height: size.height.toInt(),
          ),
        );
      }
    }

    return placements;
  }

  /// Compact the layout by moving widgets in the specified direction
  List<WidgetPlacement> compactLayout({
    required List<WidgetPlacement> widgets,
    required GridDimensions gridDimensions,
    required CompactDirection direction,
  }) {
    final compacted = List<WidgetPlacement>.from(widgets);
    bool changed = true;

    while (changed) {
      changed = false;

      for (int i = 0; i < compacted.length; i++) {
        final widget = compacted[i];
        Point<int>? newPosition;

        switch (direction) {
          case CompactDirection.left:
            newPosition = _findLeftmostPosition(widget, compacted, i);
            break;
          case CompactDirection.right:
            newPosition = _findRightmostPosition(
              widget,
              compacted,
              gridDimensions,
              i,
            );
            break;
          case CompactDirection.up:
            newPosition = _findTopmostPosition(widget, compacted, i);
            break;
          case CompactDirection.down:
            newPosition = _findBottommostPosition(
              widget,
              compacted,
              gridDimensions,
              i,
            );
            break;
        }

        if (newPosition != null &&
            (newPosition.x != widget.column || newPosition.y != widget.row)) {
          compacted[i] = widget.copyWith(
            column: newPosition.x,
            row: newPosition.y,
          );
          changed = true;
        }
      }
    }

    return compacted;
  }

  Point<int>? _findLeftmostPosition(
    WidgetPlacement widget,
    List<WidgetPlacement> allWidgets,
    int currentIndex,
  ) {
    for (int col = 0; col < widget.column; col++) {
      final testPlacement = widget.copyWith(column: col);
      if (!_hasOverlap(testPlacement, allWidgets, currentIndex)) {
        return Point(col, widget.row);
      }
    }
    return null;
  }

  Point<int>? _findRightmostPosition(
    WidgetPlacement widget,
    List<WidgetPlacement> allWidgets,
    GridDimensions grid,
    int currentIndex,
  ) {
    for (int col = grid.columns - widget.width; col > widget.column; col--) {
      final testPlacement = widget.copyWith(column: col);
      if (!_hasOverlap(testPlacement, allWidgets, currentIndex)) {
        return Point(col, widget.row);
      }
    }
    return null;
  }

  Point<int>? _findTopmostPosition(
    WidgetPlacement widget,
    List<WidgetPlacement> allWidgets,
    int currentIndex,
  ) {
    for (int row = 0; row < widget.row; row++) {
      final testPlacement = widget.copyWith(row: row);
      if (!_hasOverlap(testPlacement, allWidgets, currentIndex)) {
        return Point(widget.column, row);
      }
    }
    return null;
  }

  Point<int>? _findBottommostPosition(
    WidgetPlacement widget,
    List<WidgetPlacement> allWidgets,
    GridDimensions grid,
    int currentIndex,
  ) {
    for (int row = grid.rows - widget.height; row > widget.row; row--) {
      final testPlacement = widget.copyWith(row: row);
      if (!_hasOverlap(testPlacement, allWidgets, currentIndex)) {
        return Point(widget.column, row);
      }
    }
    return null;
  }

  bool _hasOverlap(
    WidgetPlacement widget,
    List<WidgetPlacement> allWidgets,
    int excludeIndex,
  ) {
    for (int i = 0; i < allWidgets.length; i++) {
      if (i != excludeIndex && widget.overlaps(allWidgets[i])) {
        return true;
      }
    }
    return false;
  }

  /// Find gaps in the current layout
  List<Rectangle<int>> findGaps({
    required List<WidgetPlacement> existingWidgets,
    required GridDimensions gridDimensions,
    int minWidth = 1,
    int minHeight = 1,
  }) {
    final gaps = <Rectangle<int>>[];

    // Create a 2D grid to track occupied cells
    final grid = List.generate(
      gridDimensions.rows,
      (_) => List.filled(gridDimensions.columns, false),
    );

    // Mark occupied cells
    for (final widget in existingWidgets) {
      for (
        int r = widget.row;
        r < widget.row + widget.height && r < gridDimensions.rows;
        r++
      ) {
        for (
          int c = widget.column;
          c < widget.column + widget.width && c < gridDimensions.columns;
          c++
        ) {
          grid[r][c] = true;
        }
      }
    }

    // Find rectangular gaps
    final visited = List.generate(
      gridDimensions.rows,
      (_) => List.filled(gridDimensions.columns, false),
    );

    for (int row = 0; row < gridDimensions.rows; row++) {
      for (int col = 0; col < gridDimensions.columns; col++) {
        if (!grid[row][col] && !visited[row][col]) {
          // Found an empty cell, find the largest rectangle starting here
          final gap = _findLargestRectangle(
            grid,
            visited,
            col,
            row,
            gridDimensions,
          );
          if (gap.width >= minWidth && gap.height >= minHeight) {
            gaps.add(gap);
          }
        }
      }
    }

    return gaps;
  }

  Rectangle<int> _findLargestRectangle(
    List<List<bool>> grid,
    List<List<bool>> visited,
    int startCol,
    int startRow,
    GridDimensions dimensions,
  ) {
    int width = 0;
    int height = 0;

    // Find maximum width
    for (int c = startCol; c < dimensions.columns && !grid[startRow][c]; c++) {
      width++;
    }

    // Find maximum height that maintains the width
    outerLoop:
    for (int r = startRow; r < dimensions.rows; r++) {
      for (int c = startCol; c < startCol + width; c++) {
        if (grid[r][c]) {
          break outerLoop;
        }
      }
      height++;
    }

    // Mark cells as visited
    for (int r = startRow; r < startRow + height; r++) {
      for (int c = startCol; c < startCol + width; c++) {
        visited[r][c] = true;
      }
    }

    return Rectangle(startCol, startRow, width, height);
  }

  /// Optimize layout based on strategy
  List<WidgetPlacement> optimizeLayout({
    required List<WidgetPlacement> widgets,
    required GridDimensions gridDimensions,
    required OptimizationStrategy strategy,
  }) {
    switch (strategy) {
      case OptimizationStrategy.minimizeArea:
        return _minimizeArea(widgets, gridDimensions);
      case OptimizationStrategy.minimizeGaps:
        return _minimizeGaps(widgets, gridDimensions);
      case OptimizationStrategy.maintainOrder:
        return _maintainOrder(widgets, gridDimensions);
    }
  }

  List<WidgetPlacement> _minimizeArea(
    List<WidgetPlacement> widgets,
    GridDimensions gridDimensions,
  ) {
    // Sort widgets by size (largest first) to pack better
    final sorted = List<WidgetPlacement>.from(widgets)
      ..sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));

    final optimized = <WidgetPlacement>[];

    for (final widget in sorted) {
      final position = findNextAvailableSpace(
        width: widget.width,
        height: widget.height,
        existingWidgets: optimized,
        gridDimensions: gridDimensions,
      );

      if (position != null) {
        optimized.add(widget.copyWith(column: position.x, row: position.y));
      }
    }

    return optimized;
  }

  List<WidgetPlacement> _minimizeGaps(
    List<WidgetPlacement> widgets,
    GridDimensions gridDimensions,
  ) {
    // First compact left and up to minimize gaps
    var result = compactLayout(
      widgets: widgets,
      gridDimensions: gridDimensions,
      direction: CompactDirection.left,
    );
    result = compactLayout(
      widgets: result,
      gridDimensions: gridDimensions,
      direction: CompactDirection.up,
    );
    return result;
  }

  List<WidgetPlacement> _maintainOrder(
    List<WidgetPlacement> widgets,
    GridDimensions gridDimensions,
  ) {
    // Auto-flow while maintaining relative order
    final sizes = widgets
        .map((w) => Size(w.width.toDouble(), w.height.toDouble()))
        .toList();
    final positions = autoFlowLayout(
      widgetsToPlace: sizes,
      existingWidgets: [],
      gridDimensions: gridDimensions,
    );

    final result = <WidgetPlacement>[];
    for (int i = 0; i < min(widgets.length, positions.length); i++) {
      result.add(
        widgets[i].copyWith(column: positions[i].x, row: positions[i].y),
      );
    }

    return result;
  }
}
