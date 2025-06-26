import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'dart:math';

/// A widget that wraps GridContainer with drag and drop functionality
class GridDragTarget extends StatefulWidget {
  /// The current layout state
  final LayoutState layoutState;
  
  /// Widget builders for rendering placed widgets
  final Map<String, Widget> widgetBuilders;
  
  /// The toolbox containing available widgets
  final Toolbox toolbox;
  
  /// Callback when a widget is dropped on the grid
  final void Function(WidgetPlacement)? onWidgetDropped;
  
  /// ID of the currently selected widget
  final String? selectedWidgetId;
  
  /// Callback when a widget is tapped
  final void Function(String)? onWidgetTap;

  const GridDragTarget({
    super.key,
    required this.layoutState,
    required this.widgetBuilders,
    required this.toolbox,
    this.onWidgetDropped,
    this.selectedWidgetId,
    this.onWidgetTap,
  });

  @override
  State<GridDragTarget> createState() => _GridDragTargetState();
}

class _GridDragTargetState extends State<GridDragTarget> {
  /// Current highlighted cells during drag
  Set<Point<int>>? _highlightedCells;
  
  /// Whether the current drag position is valid
  bool _isValidDrop = false;
  
  /// The current drag position
  Offset? _currentDragPosition;
  
  /// Convert screen position to grid coordinates
  Point<int>? _getGridCoordinates(Offset globalPosition) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    
    final localPosition = renderBox.globalToLocal(globalPosition);
    final size = renderBox.size;
    
    // Calculate cell size
    final cellWidth = size.width / widget.layoutState.dimensions.columns;
    final cellHeight = size.height / widget.layoutState.dimensions.rows;
    
    // Convert to grid coordinates
    final column = (localPosition.dx / cellWidth).floor();
    final row = (localPosition.dy / cellHeight).floor();
    
    // Clamp to grid boundaries
    final clampedColumn = column.clamp(0, widget.layoutState.dimensions.columns - 1);
    final clampedRow = row.clamp(0, widget.layoutState.dimensions.rows - 1);
    
    return Point(clampedColumn, clampedRow);
  }
  
  /// Calculate which cells would be occupied by a widget placement
  Set<Point<int>> _getOccupiedCells(int column, int row, int width, int height) {
    final cells = <Point<int>>{};
    
    for (int r = row; r < row + height; r++) {
      for (int c = column; c < column + width; c++) {
        if (r < widget.layoutState.dimensions.rows && 
            c < widget.layoutState.dimensions.columns) {
          cells.add(Point(c, r));
        }
      }
    }
    
    return cells;
  }
  
  /// Check if a placement would be valid (no overlaps, fits in grid)
  bool _isValidPlacement(int column, int row, int width, int height) {
    // Check if placement fits in grid
    if (column + width > widget.layoutState.dimensions.columns ||
        row + height > widget.layoutState.dimensions.rows ||
        column < 0 || row < 0) {
      return false;
    }
    
    // Create temporary placement to check for overlaps
    final tempPlacement = WidgetPlacement(
      id: 'temp',
      widgetName: 'temp',
      column: column,
      row: row,
      width: width,
      height: height,
    );
    
    // Check if it overlaps with existing widgets
    for (final existing in widget.layoutState.widgets) {
      if (tempPlacement.overlaps(existing)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Update highlighted cells based on drag position
  void _updateHighlightedCells(ToolboxItem item, Offset? dragPosition) {
    if (dragPosition == null) {
      setState(() {
        _highlightedCells = null;
        _isValidDrop = false;
        _currentDragPosition = null;
      });
      return;
    }
    
    final gridCoords = _getGridCoordinates(dragPosition);
    if (gridCoords == null) {
      setState(() {
        _highlightedCells = null;
        _isValidDrop = false;
        _currentDragPosition = dragPosition;
      });
      return;
    }
    
    final cells = _getOccupiedCells(
      gridCoords.x,
      gridCoords.y,
      item.defaultWidth,
      item.defaultHeight,
    );
    
    final isValid = _isValidPlacement(
      gridCoords.x,
      gridCoords.y,
      item.defaultWidth,
      item.defaultHeight,
    );
    
    setState(() {
      _highlightedCells = cells;
      _isValidDrop = isValid;
      _currentDragPosition = dragPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<ToolboxItem>(
      onWillAcceptWithDetails: (details) {
        // Accept if the current position is valid
        return _isValidDrop;
      },
      onAcceptWithDetails: (details) {
        if (widget.onWidgetDropped != null && _currentDragPosition != null) {
          final gridCoords = _getGridCoordinates(_currentDragPosition!);
          if (gridCoords != null) {
            final placement = WidgetPlacement(
              id: 'dropped_${DateTime.now().millisecondsSinceEpoch}',
              widgetName: details.data.name,
              column: gridCoords.x,
              row: gridCoords.y,
              width: details.data.defaultWidth,
              height: details.data.defaultHeight,
            );
            widget.onWidgetDropped!(placement);
          }
        }
        
        // Clear highlights after drop
        setState(() {
          _highlightedCells = null;
          _isValidDrop = false;
          _currentDragPosition = null;
        });
      },
      onMove: (details) {
        _updateHighlightedCells(details.data, details.offset);
      },
      onLeave: (data) {
        // Clear highlights when drag leaves the target
        setState(() {
          _highlightedCells = null;
          _isValidDrop = false;
          _currentDragPosition = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return GridContainer(
          layoutState: widget.layoutState,
          widgetBuilders: widget.widgetBuilders,
          selectedWidgetId: widget.selectedWidgetId,
          onWidgetTap: widget.onWidgetTap,
          highlightedCells: _highlightedCells,
          highlightColor: _highlightedCells != null 
              ? (_isValidDrop ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3))
              : null,
        );
      },
    );
  }
}