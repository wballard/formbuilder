import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// A widget that displays a grid layout with visual indicators
class GridWidget extends StatelessWidget {
  /// The dimensions of the grid (columns and rows)
  final GridDimensions dimensions;
  
  /// Color of the grid lines
  final Color gridLineColor;
  
  /// Width of the grid lines
  final double gridLineWidth;
  
  /// Background color of the grid
  final Color backgroundColor;
  
  /// Padding around the grid
  final EdgeInsets padding;

  const GridWidget({
    super.key,
    required this.dimensions,
    Color? gridLineColor,
    this.gridLineWidth = 1.0,
    Color? backgroundColor,
    this.padding = const EdgeInsets.all(8),
  }) : gridLineColor = gridLineColor ?? const Color(0xFFE0E0E0), // Colors.grey.shade300
       backgroundColor = backgroundColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: padding,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: gridLineColor,
              width: gridLineWidth,
            ),
          ),
          child: LayoutGrid(
            areas: _generateAreas(),
            columnSizes: List.generate(
              dimensions.columns,
              (_) => 1.fr,
            ),
            rowSizes: List.generate(
              dimensions.rows,
              (_) => 1.fr,
            ),
            columnGap: 0,
            rowGap: 0,
            children: _generateCells(),
          ),
        ),
      ),
    );
  }

  /// Generate area names for the grid
  String _generateAreas() {
    final buffer = StringBuffer();
    for (int row = 0; row < dimensions.rows; row++) {
      if (row > 0) buffer.write('\n');
      for (int col = 0; col < dimensions.columns; col++) {
        if (col > 0) buffer.write(' ');
        buffer.write('cell_${row}_$col');
      }
    }
    return buffer.toString();
  }

  /// Generate cells for the grid
  List<Widget> _generateCells() {
    final cells = <Widget>[];
    
    for (int row = 0; row < dimensions.rows; row++) {
      for (int col = 0; col < dimensions.columns; col++) {
        cells.add(
          _GridCell(
            area: 'cell_${row}_$col',
            gridLineColor: gridLineColor,
            gridLineWidth: gridLineWidth,
            isTopEdge: row == 0,
            isLeftEdge: col == 0,
            isBottomEdge: row == dimensions.rows - 1,
            isRightEdge: col == dimensions.columns - 1,
          ),
        );
      }
    }
    
    return cells;
  }
}

/// Individual cell in the grid
class _GridCell extends StatelessWidget {
  final String area;
  final Color gridLineColor;
  final double gridLineWidth;
  final bool isTopEdge;
  final bool isLeftEdge;
  final bool isBottomEdge;
  final bool isRightEdge;

  const _GridCell({
    required this.area,
    required this.gridLineColor,
    required this.gridLineWidth,
    required this.isTopEdge,
    required this.isLeftEdge,
    required this.isBottomEdge,
    required this.isRightEdge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: isTopEdge
              ? BorderSide.none
              : BorderSide(color: gridLineColor, width: gridLineWidth),
          left: isLeftEdge
              ? BorderSide.none
              : BorderSide(color: gridLineColor, width: gridLineWidth),
          bottom: BorderSide.none,
          right: BorderSide.none,
        ),
      ),
    ).inGridArea(area);
  }
}