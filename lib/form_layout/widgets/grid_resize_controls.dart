import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Widget that provides controls for resizing the grid dimensions
class GridResizeControls extends StatefulWidget {
  /// Current grid dimensions
  final GridDimensions dimensions;
  
  /// Callback when grid is resized
  final void Function(GridDimensions)? onGridResize;
  
  /// Child widget to wrap with resize controls
  final Widget child;
  
  /// Minimum number of columns
  final int minColumns;
  
  /// Maximum number of columns
  final int maxColumns;
  
  /// Minimum number of rows
  final int minRows;
  
  /// Maximum number of rows
  final int maxRows;

  const GridResizeControls({
    super.key,
    required this.dimensions,
    required this.child,
    this.onGridResize,
    this.minColumns = 1,
    this.maxColumns = 12,
    this.minRows = 1,
    this.maxRows = 20,
  });

  @override
  State<GridResizeControls> createState() => _GridResizeControlsState();
}

class _GridResizeControlsState extends State<GridResizeControls> {
  bool _isResizingColumns = false;
  bool _isResizingRows = false;
  bool _isHoveringColumnResize = false;
  bool _isHoveringRowResize = false;
  
  /// Handle column resize drag
  void _onColumnResizePanUpdate(DragUpdateDetails details) {
    if (!_isResizingColumns) return;
    
    // Calculate new column count based on drag delta
    final containerWidth = context.size?.width ?? 400;
    final currentColumns = widget.dimensions.columns;
    final columnWidth = containerWidth / currentColumns;
    final deltaColumns = (details.delta.dx / columnWidth).round();
    
    if (deltaColumns != 0) {
      final newColumns = (currentColumns + deltaColumns)
          .clamp(widget.minColumns, widget.maxColumns);
      
      if (newColumns != currentColumns) {
        _updateDimensions(columns: newColumns);
      }
    }
  }
  
  /// Handle row resize drag
  void _onRowResizePanUpdate(DragUpdateDetails details) {
    if (!_isResizingRows) return;
    
    // Calculate new row count based on drag delta
    final containerHeight = context.size?.height ?? 300;
    final currentRows = widget.dimensions.rows;
    final rowHeight = containerHeight / currentRows;
    final deltaRows = (details.delta.dy / rowHeight).round();
    
    if (deltaRows != 0) {
      final newRows = (currentRows + deltaRows)
          .clamp(widget.minRows, widget.maxRows);
      
      if (newRows != currentRows) {
        _updateDimensions(rows: newRows);
      }
    }
  }
  
  /// Update grid dimensions
  void _updateDimensions({int? columns, int? rows}) {
    final newDimensions = GridDimensions(
      columns: columns ?? widget.dimensions.columns,
      rows: rows ?? widget.dimensions.rows,
    );
    
    widget.onGridResize?.call(newDimensions);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,
        
        // Column resize control (right edge)
        _buildColumnResizeControl(),
        
        // Row resize control (bottom edge)
        _buildRowResizeControl(),
      ],
    );
  }
  
  /// Build the column resize control on the right edge
  Widget _buildColumnResizeControl() {
    return Positioned(
      top: 0,
      right: -20,
      bottom: 0,
      width: 40,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        onEnter: (_) => setState(() => _isHoveringColumnResize = true),
        onExit: (_) => setState(() => _isHoveringColumnResize = false),
        child: GestureDetector(
          onPanStart: (_) => setState(() => _isResizingColumns = true),
          onPanUpdate: _onColumnResizePanUpdate,
          onPanEnd: (_) => setState(() => _isResizingColumns = false),
          child: Container(
            decoration: BoxDecoration(
              color: (_isHoveringColumnResize || _isResizingColumns)
                  ? Colors.blue.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
              border: Border.all(
                color: (_isHoveringColumnResize || _isResizingColumns)
                    ? Colors.blue
                    : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.drag_indicator,
                  color: (_isHoveringColumnResize || _isResizingColumns)
                      ? Colors.blue
                      : Colors.grey,
                  size: 16,
                ),
                const SizedBox(height: 8),
                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    '${widget.dimensions.columns} cols',
                    style: TextStyle(
                      fontSize: 12,
                      color: (_isHoveringColumnResize || _isResizingColumns)
                          ? Colors.blue
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Plus/minus buttons
                Column(
                  children: [
                    _buildResizeButton(
                      icon: Icons.add,
                      onPressed: widget.dimensions.columns < widget.maxColumns
                          ? () => _updateDimensions(columns: widget.dimensions.columns + 1)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    _buildResizeButton(
                      icon: Icons.remove,
                      onPressed: widget.dimensions.columns > widget.minColumns
                          ? () => _updateDimensions(columns: widget.dimensions.columns - 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build the row resize control on the bottom edge
  Widget _buildRowResizeControl() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: -20,
      height: 40,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        onEnter: (_) => setState(() => _isHoveringRowResize = true),
        onExit: (_) => setState(() => _isHoveringRowResize = false),
        child: GestureDetector(
          onPanStart: (_) => setState(() => _isResizingRows = true),
          onPanUpdate: _onRowResizePanUpdate,
          onPanEnd: (_) => setState(() => _isResizingRows = false),
          child: Container(
            decoration: BoxDecoration(
              color: (_isHoveringRowResize || _isResizingRows)
                  ? Colors.blue.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
              border: Border.all(
                color: (_isHoveringRowResize || _isResizingRows)
                    ? Colors.blue
                    : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    Icons.drag_indicator,
                    color: (_isHoveringRowResize || _isResizingRows)
                        ? Colors.blue
                        : Colors.grey,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.dimensions.rows} rows',
                  style: TextStyle(
                    fontSize: 12,
                    color: (_isHoveringRowResize || _isResizingRows)
                        ? Colors.blue
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                // Plus/minus buttons
                Row(
                  children: [
                    _buildResizeButton(
                      icon: Icons.add,
                      onPressed: widget.dimensions.rows < widget.maxRows
                          ? () => _updateDimensions(rows: widget.dimensions.rows + 1)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    _buildResizeButton(
                      icon: Icons.remove,
                      onPressed: widget.dimensions.rows > widget.minRows
                          ? () => _updateDimensions(rows: widget.dimensions.rows - 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build a small resize button
  Widget _buildResizeButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: 14,
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.blue : Colors.grey,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          foregroundColor: Colors.blue,
          side: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}