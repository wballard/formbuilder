import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';

/// A widget that displays a grid layout with visual indicators
class GridWidget extends StatefulWidget {
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
  
  /// Cells to highlight
  final Set<Point<int>>? highlightedCells;
  
  /// Color for highlighted cells
  final Color? highlightColor;
  
  /// Color for invalid highlighted cells
  final Color? invalidHighlightColor;
  
  /// Function to determine if a cell is valid
  final bool Function(Point<int>)? isCellValid;

  const GridWidget({
    super.key,
    required this.dimensions,
    Color? gridLineColor,
    this.gridLineWidth = 1.0,
    Color? backgroundColor,
    this.padding = const EdgeInsets.all(8),
    this.highlightedCells,
    this.highlightColor,
    this.invalidHighlightColor,
    this.isCellValid,
  }) : gridLineColor = gridLineColor ?? const Color(0xFFE0E0E0), // Colors.grey.shade300
       backgroundColor = backgroundColor ?? Colors.white;

  /// Helper method to calculate cells in a rectangle
  static Set<Point<int>> getCellsInRectangle(int col, int row, int width, int height) {
    final cells = <Point<int>>{};
    for (int r = row; r < row + height; r++) {
      for (int c = col; c < col + width; c++) {
        cells.add(Point(c, r));
      }
    }
    return cells;
  }

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> with TickerProviderStateMixin {
  late Map<Point<int>, AnimationController> _animationControllers;
  late Map<Point<int>, Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationControllers = {};
    _animations = {};
    _updateAnimations();
  }

  @override
  void didUpdateWidget(GridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightedCells != widget.highlightedCells) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    final currentCells = widget.highlightedCells ?? {};
    
    // Remove animations for cells that are no longer highlighted
    final cellsToRemove = _animationControllers.keys.where((cell) => !currentCells.contains(cell)).toList();
    for (final cell in cellsToRemove) {
      _animationControllers[cell]!.reverse().then((_) {
        _animationControllers[cell]!.dispose();
        _animationControllers.remove(cell);
        _animations.remove(cell);
      });
    }
    
    // Add animations for newly highlighted cells
    for (final cell in currentCells) {
      if (!_animationControllers.containsKey(cell)) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 200),
          vsync: this,
        );
        final animation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        );
        _animationControllers[cell] = controller;
        _animations[cell] = animation;
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultHighlightColor = widget.highlightColor ?? 
        theme.primaryColor.withValues(alpha: 0.3);
    final defaultInvalidColor = widget.invalidHighlightColor ?? 
        Colors.red.withValues(alpha: 0.3);
    
    return Container(
      color: widget.backgroundColor,
      child: Padding(
        padding: widget.padding,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.gridLineColor,
              width: widget.gridLineWidth,
            ),
          ),
          child: LayoutGrid(
            areas: _generateAreas(),
            columnSizes: List.generate(
              widget.dimensions.columns,
              (_) => 1.fr,
            ),
            rowSizes: List.generate(
              widget.dimensions.rows,
              (_) => 1.fr,
            ),
            columnGap: 0,
            rowGap: 0,
            children: _generateCells(defaultHighlightColor, defaultInvalidColor),
          ),
        ),
      ),
    );
  }

  /// Generate area names for the grid
  String _generateAreas() {
    final buffer = StringBuffer();
    for (int row = 0; row < widget.dimensions.rows; row++) {
      if (row > 0) buffer.write('\n');
      for (int col = 0; col < widget.dimensions.columns; col++) {
        if (col > 0) buffer.write(' ');
        buffer.write('cell_${row}_$col');
      }
    }
    return buffer.toString();
  }

  /// Generate cells for the grid
  List<Widget> _generateCells(Color highlightColor, Color invalidHighlightColor) {
    final cells = <Widget>[];
    
    for (int row = 0; row < widget.dimensions.rows; row++) {
      for (int col = 0; col < widget.dimensions.columns; col++) {
        final cellPoint = Point(col, row);
        final isHighlighted = widget.highlightedCells?.contains(cellPoint) ?? false;
        final animation = _animations[cellPoint];
        
        Color? cellHighlightColor;
        if (isHighlighted && animation != null) {
          final isValid = widget.isCellValid?.call(cellPoint) ?? true;
          cellHighlightColor = isValid ? highlightColor : invalidHighlightColor;
        }
        
        cells.add(
          _GridCell(
            area: 'cell_${row}_$col',
            gridLineColor: widget.gridLineColor,
            gridLineWidth: widget.gridLineWidth,
            isTopEdge: row == 0,
            isLeftEdge: col == 0,
            isBottomEdge: row == widget.dimensions.rows - 1,
            isRightEdge: col == widget.dimensions.columns - 1,
            highlightColor: cellHighlightColor,
            animation: animation,
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
  final Color? highlightColor;
  final Animation<double>? animation;

  const _GridCell({
    required this.area,
    required this.gridLineColor,
    required this.gridLineWidth,
    required this.isTopEdge,
    required this.isLeftEdge,
    required this.isBottomEdge,
    required this.isRightEdge,
    this.highlightColor,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Widget cell = Container(
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
    );
    
    // Add highlight overlay if needed
    if (highlightColor != null && animation != null) {
      cell = Stack(
        children: [
          cell,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animation!,
              builder: (context, child) {
                return Container(
                  color: highlightColor!.withValues(
                    alpha: highlightColor!.a * animation!.value,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    
    return cell.inGridArea(area);
  }
}