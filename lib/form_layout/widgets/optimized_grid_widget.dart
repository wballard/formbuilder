import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';

/// An optimized grid widget that minimizes repaints and uses const constructors
class OptimizedGridWidget extends StatelessWidget {
  /// Grid dimensions
  final GridDimensions dimensions;
  
  /// Grid line color
  final Color lineColor;
  
  /// Background color
  final Color backgroundColor;
  
  /// Line width
  final double lineWidth;
  
  /// Highlighted cells (optional, for dynamic updates)
  final ValueNotifier<Set<Point<int>>>? highlightedCells;
  
  /// Highlight color
  final Color highlightColor;

  /// Creates an optimized grid widget
  const OptimizedGridWidget({
    super.key,
    required this.dimensions,
    this.lineColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.lineWidth = 1.0,
    this.highlightedCells,
    this.highlightColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap in RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: highlightedCells != null
          ? ValueListenableBuilder<Set<Point<int>>>(
              valueListenable: highlightedCells!,
              builder: (context, cells, child) {
                return CustomPaint(
                  painter: OptimizedGridPainter(
                    dimensions: dimensions,
                    lineColor: lineColor,
                    backgroundColor: backgroundColor,
                    lineWidth: lineWidth,
                    highlightedCells: cells,
                    highlightColor: highlightColor,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            )
          : CustomPaint(
              painter: OptimizedGridPainter(
                dimensions: dimensions,
                lineColor: lineColor,
                backgroundColor: backgroundColor,
                lineWidth: lineWidth,
                highlightedCells: const {},
                highlightColor: highlightColor,
              ),
              child: const SizedBox.expand(),
            ),
    );
  }
}

/// Optimized grid painter with efficient shouldRepaint
class OptimizedGridPainter extends CustomPainter {
  final GridDimensions dimensions;
  final Color lineColor;
  final Color backgroundColor;
  final double lineWidth;
  final Set<Point<int>> highlightedCells;
  final Color highlightColor;
  
  // Debug paint counter
  static final Map<String, int> _paintCounts = {};
  @protected
  final String debugKey;
  
  OptimizedGridPainter({
    required this.dimensions,
    required this.lineColor,
    required this.backgroundColor,
    required this.lineWidth,
    required this.highlightedCells,
    required this.highlightColor,
    String? debugKey,
  }) : debugKey = debugKey ?? 'default';

  /// Debug paint count for testing
  int get debugPaintCount => _paintCounts[debugKey] ?? 0;

  @override
  void paint(Canvas canvas, Size size) {
    // Increment paint count for this instance
    _paintCounts[debugKey] = (_paintCounts[debugKey] ?? 0) + 1;
    
    final cellWidth = size.width / dimensions.columns;
    final cellHeight = size.height / dimensions.rows;
    
    // Paint background
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);
    
    // Paint highlighted cells
    if (highlightedCells.isNotEmpty) {
      final highlightPaint = Paint()
        ..color = highlightColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      
      for (final cell in highlightedCells) {
        final rect = Rect.fromLTWH(
          cell.x * cellWidth,
          cell.y * cellHeight,
          cellWidth,
          cellHeight,
        );
        canvas.drawRect(rect, highlightPaint);
      }
    }
    
    // Paint grid lines
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;
    
    // Vertical lines
    for (int i = 0; i <= dimensions.columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }
    
    // Horizontal lines
    for (int i = 0; i <= dimensions.rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant OptimizedGridPainter oldDelegate) {
    // Only repaint if something actually changed
    if (identical(this, oldDelegate)) return false;
    
    return dimensions != oldDelegate.dimensions ||
        lineColor != oldDelegate.lineColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        lineWidth != oldDelegate.lineWidth ||
        highlightColor != oldDelegate.highlightColor ||
        !_setEquals(highlightedCells, oldDelegate.highlightedCells);
  }
  
  /// Efficient set comparison
  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }
  
  @override
  bool shouldRebuildSemantics(covariant OptimizedGridPainter oldDelegate) => false;
}