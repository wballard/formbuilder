import 'package:flutter/material.dart';
import 'dart:math';

/// Dimensions for virtual grids (can be much larger than regular grids)
class VirtualGridDimensions {
  const VirtualGridDimensions({required this.columns, required this.rows})
    : assert(columns > 0, 'Columns must be greater than 0'),
      assert(rows > 0, 'Rows must be greater than 0');

  final int columns;
  final int rows;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VirtualGridDimensions &&
          runtimeType == other.runtimeType &&
          columns == other.columns &&
          rows == other.rows;

  @override
  int get hashCode => columns.hashCode ^ rows.hashCode;

  @override
  String toString() => 'VirtualGridDimensions(columns: $columns, rows: $rows)';
}

/// A virtual grid that only renders visible cells for performance
class VirtualGrid extends StatefulWidget {
  const VirtualGrid({
    super.key,
    required this.dimensions,
    required this.cellSize,
    required this.cellBuilder,
    this.controller,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
  });

  final VirtualGridDimensions dimensions;
  final Size cellSize;
  final Widget Function(BuildContext context, int x, int y) cellBuilder;
  final VirtualGridController? controller;
  final ScrollPhysics? physics;
  final Clip clipBehavior;

  @override
  State<VirtualGrid> createState() => _VirtualGridState();
}

class _VirtualGridState extends State<VirtualGrid> {
  late VirtualGridController _controller;
  final ViewportCalculator _calculator = ViewportCalculator();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? VirtualGridController();
    _controller.addListener(_onScrollChanged);
  }

  @override
  void didUpdateWidget(VirtualGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onScrollChanged);
      _controller = widget.controller ?? VirtualGridController();
      _controller.addListener(_onScrollChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScrollChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onScrollChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        _controller.scrollBy(-details.delta.dx, -details.delta.dy);
      },
      child: ClipRect(
        clipBehavior: widget.clipBehavior,
        child: CustomPaint(
          painter: VirtualGridPainter(
            dimensions: widget.dimensions,
            cellSize: widget.cellSize,
            scrollX: _controller.scrollX,
            scrollY: _controller.scrollY,
            cellBuilder: widget.cellBuilder,
            context: context,
            calculator: _calculator,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Custom painter for the virtual grid
class VirtualGridPainter extends CustomPainter {
  VirtualGridPainter({
    required this.dimensions,
    required this.cellSize,
    required this.scrollX,
    required this.scrollY,
    required this.cellBuilder,
    required this.context,
    required this.calculator,
  });

  final VirtualGridDimensions dimensions;
  final Size cellSize;
  final double scrollX;
  final double scrollY;
  final Widget Function(BuildContext context, int x, int y) cellBuilder;
  final BuildContext context;
  final ViewportCalculator calculator;

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = Rect.fromLTWH(scrollX, scrollY, size.width, size.height);
    final visibleCells = calculator.getVisibleCells(viewport, cellSize);

    canvas.save();
    canvas.translate(-scrollX, -scrollY);

    // Render visible cells
    for (
      int x = visibleCells.startColumn;
      x < visibleCells.endColumn && x < dimensions.columns;
      x++
    ) {
      for (
        int y = visibleCells.startRow;
        y < visibleCells.endRow && y < dimensions.rows;
        y++
      ) {
        final cellRect = Rect.fromLTWH(
          x * cellSize.width,
          y * cellSize.height,
          cellSize.width,
          cellSize.height,
        );

        // Only render if cell is actually visible
        if (viewport.overlaps(cellRect)) {
          _paintCell(canvas, x, y, cellRect);
        }
      }
    }

    canvas.restore();
  }

  void _paintCell(Canvas canvas, int x, int y, Rect cellRect) {
    // Create a simplified cell representation for painting
    // In a real implementation, this would be more sophisticated
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke;

    canvas.drawRect(cellRect, paint);

    // Draw cell coordinates
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$x,$y',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        cellRect.left + (cellRect.width - textPainter.width) / 2,
        cellRect.top + (cellRect.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(VirtualGridPainter oldDelegate) {
    return scrollX != oldDelegate.scrollX ||
        scrollY != oldDelegate.scrollY ||
        dimensions != oldDelegate.dimensions ||
        cellSize != oldDelegate.cellSize;
  }
}

/// A widget-based virtual grid implementation
class WidgetVirtualGrid extends StatefulWidget {
  const WidgetVirtualGrid({
    super.key,
    required this.dimensions,
    required this.cellSize,
    required this.cellBuilder,
    this.controller,
  });

  final VirtualGridDimensions dimensions;
  final Size cellSize;
  final Widget Function(BuildContext context, int x, int y) cellBuilder;
  final VirtualGridController? controller;

  @override
  State<WidgetVirtualGrid> createState() => _WidgetVirtualGridState();
}

class _WidgetVirtualGridState extends State<WidgetVirtualGrid> {
  late VirtualGridController _controller;
  final ViewportCalculator _calculator = ViewportCalculator();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? VirtualGridController();
    _controller.addListener(_onScrollChanged);
  }

  @override
  void didUpdateWidget(WidgetVirtualGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onScrollChanged);
      _controller = widget.controller ?? VirtualGridController();
      _controller.addListener(_onScrollChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScrollChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onScrollChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Rect.fromLTWH(
          _controller.scrollX,
          _controller.scrollY,
          constraints.maxWidth,
          constraints.maxHeight,
        );

        final visibleCells = _calculator.getVisibleCells(
          viewport,
          widget.cellSize,
        );

        return GestureDetector(
          onPanUpdate: (details) {
            _controller.scrollBy(-details.delta.dx, -details.delta.dy);
          },
          child: ClipRect(
            child: Stack(
              children: [
                // Build visible cells as widgets
                for (
                  int x = visibleCells.startColumn;
                  x < visibleCells.endColumn && x < widget.dimensions.columns;
                  x++
                )
                  for (
                    int y = visibleCells.startRow;
                    y < visibleCells.endRow && y < widget.dimensions.rows;
                    y++
                  )
                    Positioned(
                      left: x * widget.cellSize.width - _controller.scrollX,
                      top: y * widget.cellSize.height - _controller.scrollY,
                      width: widget.cellSize.width,
                      height: widget.cellSize.height,
                      child: widget.cellBuilder(context, x, y),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Controller for virtual grid scrolling
class VirtualGridController extends ChangeNotifier {
  double _scrollX = 0.0;
  double _scrollY = 0.0;
  bool _disposed = false;

  double get scrollX => _scrollX;
  double get scrollY => _scrollY;

  void scrollTo(double x, double y) {
    if (_disposed) throw StateError('Controller has been disposed');

    if (_scrollX != x || _scrollY != y) {
      _scrollX = x;
      _scrollY = y;
      notifyListeners();
    }
  }

  void scrollBy(double deltaX, double deltaY) {
    scrollTo(_scrollX + deltaX, _scrollY + deltaY);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Calculator for determining visible cells in viewport
class ViewportCalculator {
  const ViewportCalculator();

  VisibleCellRange getVisibleCells(Rect viewport, Size cellSize) {
    if (cellSize.width <= 0 || cellSize.height <= 0) {
      return const VisibleCellRange(0, 0, 0, 0);
    }

    // Calculate which cells are visible, including partially visible ones
    final startColumn = max(0, (viewport.left / cellSize.width).floor());
    final startRow = max(0, (viewport.top / cellSize.height).floor());
    final endColumn = ((viewport.right / cellSize.width).ceil());
    final endRow = ((viewport.bottom / cellSize.height).ceil());

    return VisibleCellRange(startColumn, startRow, endColumn, endRow);
  }
}

/// Represents a range of visible cells
class VisibleCellRange {
  const VisibleCellRange(
    this.startColumn,
    this.startRow,
    this.endColumn,
    this.endRow,
  );

  final int startColumn;
  final int startRow;
  final int endColumn;
  final int endRow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisibleCellRange &&
          runtimeType == other.runtimeType &&
          startColumn == other.startColumn &&
          startRow == other.startRow &&
          endColumn == other.endColumn &&
          endRow == other.endRow;

  @override
  int get hashCode =>
      startColumn.hashCode ^
      startRow.hashCode ^
      endColumn.hashCode ^
      endRow.hashCode;
}

/// Lazy loading cell widget
class LazyGridCell extends StatefulWidget {
  const LazyGridCell({
    super.key,
    required this.cellKey,
    required this.builder,
    this.placeholder,
    this.loadDelay = const Duration(milliseconds: 50),
  });

  final String cellKey;
  final Widget Function() builder;
  final Widget? placeholder;
  final Duration loadDelay;

  @override
  State<LazyGridCell> createState() => _LazyGridCellState();
}

class _LazyGridCellState extends State<LazyGridCell> {
  Widget? _cachedContent;
  bool _isLoading = false;

  static final Map<String, Widget> _globalCache = {};

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  void _checkCache() {
    // Check global cache first
    if (_globalCache.containsKey(widget.cellKey)) {
      _cachedContent = _globalCache[widget.cellKey];
      return;
    }

    // Start lazy loading
    if (!_isLoading) {
      _isLoading = true;
      Future.delayed(widget.loadDelay, () {
        if (mounted) {
          final content = widget.builder();
          setState(() {
            _cachedContent = content;
            _globalCache[widget.cellKey] = content;
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedContent != null) {
      return _cachedContent!;
    }

    return widget.placeholder ?? const SizedBox();
  }
}

/// Grid viewport calculator (alias for backwards compatibility)
typedef GridViewportCalculator = ViewportCalculator;
