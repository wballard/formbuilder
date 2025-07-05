import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'dart:math';

/// An animated wrapper for GridWidget that handles grid animations
class AnimatedGridWidget extends StatefulWidget {
  /// The grid dimensions
  final GridDimensions dimensions;

  /// Color for the grid lines
  final Color lineColor;

  /// Width of the grid lines
  final double lineWidth;

  /// Background color
  final Color backgroundColor;

  /// Cells to highlight
  final Set<Point<int>>? highlightedCells;

  /// Color for highlighted cells
  final Color? highlightColor;

  /// Function to determine if a cell is valid
  final bool Function(Point<int>)? isCellValid;

  /// Animation settings
  final AnimationSettings animationSettings;

  /// Whether to show grid lines (for preview mode)
  final bool showGridLines;

  const AnimatedGridWidget({
    super.key,
    required this.dimensions,
    this.lineColor = Colors.transparent, // Will be overridden in build method with theme color
    this.lineWidth = 1.0,
    this.backgroundColor = Colors.transparent,
    this.highlightedCells,
    this.highlightColor,
    this.isCellValid,
    this.animationSettings = const AnimationSettings(),
    this.showGridLines = true,
  });

  @override
  State<AnimatedGridWidget> createState() => _AnimatedGridWidgetState();
}

class _AnimatedGridWidgetState extends State<AnimatedGridWidget>
    with TickerProviderStateMixin {
  late AnimationController _gridLinesController;
  late Animation<double> _gridLinesOpacity;

  final Map<Point<int>, AnimationController> _cellHighlightControllers = {};
  final Map<Point<int>, Animation<double>> _cellHighlightAnimations = {};

  @override
  void initState() {
    super.initState();

    // Grid lines fade animation
    _gridLinesController = AnimationController(
      duration: widget.animationSettings.getDuration(AnimationType.medium),
      vsync: this,
    );

    // Start with visible grid lines if showGridLines is true
    final initialValue = widget.showGridLines ? 1.0 : 0.0;
    _gridLinesOpacity = Tween<double>(begin: initialValue, end: 1.0).animate(
      CurvedAnimation(
        parent: _gridLinesController,
        curve: widget.animationSettings.defaultCurve,
      ),
    );

    if (widget.showGridLines) {
      _gridLinesController.value = 1.0; // Set immediately to full opacity
    }
  }

  @override
  void didUpdateWidget(AnimatedGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle grid lines visibility change
    if (widget.showGridLines != oldWidget.showGridLines) {
      if (widget.showGridLines) {
        // Immediately show grid lines if animations are disabled, otherwise animate
        if (widget.animationSettings.enabled) {
          _gridLinesController.forward();
        } else {
          _gridLinesController.value = 1.0;
        }
      } else {
        if (widget.animationSettings.enabled) {
          _gridLinesController.reverse();
        } else {
          _gridLinesController.value = 0.0;
        }
      }
    }

    // Handle highlighted cells changes
    if (widget.highlightedCells != oldWidget.highlightedCells) {
      _updateCellHighlights(oldWidget.highlightedCells);
    }
  }

  void _updateCellHighlights(Set<Point<int>>? oldCells) {
    if (!widget.animationSettings.enabled) return;

    final oldCellsSet = oldCells ?? <Point<int>>{};
    final newCellsSet = widget.highlightedCells ?? <Point<int>>{};

    // Remove animations for cells no longer highlighted
    final removedCells = oldCellsSet.difference(newCellsSet);
    for (final cell in removedCells) {
      _cellHighlightControllers[cell]?.reverse().then((_) {
        _cellHighlightControllers[cell]?.dispose();
        _cellHighlightControllers.remove(cell);
        _cellHighlightAnimations.remove(cell);
        if (mounted) setState(() {});
      });
    }

    // Add animations for newly highlighted cells
    final addedCells = newCellsSet.difference(oldCellsSet);
    for (final cell in addedCells) {
      if (!_cellHighlightControllers.containsKey(cell)) {
        final controller = AnimationController(
          duration: widget.animationSettings.getDuration(AnimationType.short),
          vsync: this,
        );

        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: widget.animationSettings.defaultCurve,
          ),
        );

        _cellHighlightControllers[cell] = controller;
        _cellHighlightAnimations[cell] = animation;
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _gridLinesController.dispose();
    for (final controller in _cellHighlightControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor = widget.lineColor != Colors.transparent 
        ? widget.lineColor 
        : theme.dividerColor;
    // Build highlighted cells with animation
    final animatedHighlightedCells = <Point<int>>{};
    final highlightOpacities = <Point<int>, double>{};

    if (widget.animationSettings.enabled && widget.highlightedCells != null) {
      for (final cell in widget.highlightedCells!) {
        final animation = _cellHighlightAnimations[cell];
        if (animation != null) {
          animatedHighlightedCells.add(cell);
          highlightOpacities[cell] = animation.value;
        }
      }
    }

    Widget gridWidget;

    if (widget.animationSettings.enabled) {
      // Animated grid with custom painter for smooth cell highlights
      gridWidget = AnimatedBuilder(
        animation: Listenable.merge([
          _gridLinesController,
          ..._cellHighlightControllers.values,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: _AnimatedGridPainter(
              dimensions: widget.dimensions,
              lineColor: widget.showGridLines 
                  ? effectiveLineColor.withValues(
                      alpha: effectiveLineColor.a * _gridLinesOpacity.value,
                    )
                  : Colors.transparent,
              lineWidth: widget.lineWidth,
              backgroundColor: widget.backgroundColor,
              highlightedCells: animatedHighlightedCells,
              highlightColor: widget.highlightColor,
              highlightOpacities: highlightOpacities,
              isCellValid: widget.isCellValid,
              errorColor: theme.colorScheme.error,
            ),
            child: Container(), // Empty container as child
          );
        },
      );
    } else {
      // Non-animated grid
      gridWidget = GridWidget(
        dimensions: widget.dimensions,
        gridLineColor: widget.showGridLines
            ? effectiveLineColor
            : Colors.transparent,
        gridLineWidth: widget.lineWidth,
        backgroundColor: widget.backgroundColor,
        highlightedCells: widget.highlightedCells,
        highlightColor: widget.highlightColor,
        isCellValid: widget.isCellValid,
      );
    }

    // Animate grid size changes
    return AnimatedContainer(
      duration: widget.animationSettings.getDuration(AnimationType.long),
      curve: widget.animationSettings.defaultCurve,
      child: gridWidget,
    );
  }
}

/// Custom painter for animated grid with smooth cell highlight transitions
class _AnimatedGridPainter extends CustomPainter {
  final GridDimensions dimensions;
  final Color lineColor;
  final double lineWidth;
  final Color backgroundColor;
  final Set<Point<int>>? highlightedCells;
  final Color? highlightColor;
  final Map<Point<int>, double> highlightOpacities;
  final bool Function(Point<int>)? isCellValid;
  final Color errorColor;

  _AnimatedGridPainter({
    required this.dimensions,
    required this.lineColor,
    required this.lineWidth,
    required this.backgroundColor,
    this.highlightedCells,
    this.highlightColor,
    required this.highlightOpacities,
    this.isCellValid,
    required this.errorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // We don't have direct access to context here, so we'll need to pass error color from widget
    final paint = Paint();
    final cellWidth = size.width / dimensions.columns;
    final cellHeight = size.height / dimensions.rows;

    // Draw background
    paint.color = backgroundColor;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw highlighted cells with animation
    if (highlightedCells != null && highlightColor != null) {
      for (final cell in highlightedCells!) {
        final opacity = highlightOpacities[cell] ?? 1.0;
        final isValid = isCellValid?.call(cell) ?? true;

        paint.color = isValid
            ? highlightColor!.withValues(alpha: highlightColor!.a * opacity)
            : errorColor.withValues(alpha: 0.3 * opacity);

        final rect = Rect.fromLTWH(
          cell.x * cellWidth,
          cell.y * cellHeight,
          cellWidth,
          cellHeight,
        );

        canvas.drawRect(rect, paint);
      }
    }

    // Draw grid lines
    if (lineColor.a > 0) {
      paint.color = lineColor;
      paint.strokeWidth = lineWidth;

      // Vertical lines
      for (int i = 1; i < dimensions.columns; i++) {
        final x = i * cellWidth;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }

      // Horizontal lines
      for (int i = 1; i < dimensions.rows; i++) {
        final y = i * cellHeight;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }

      // Border
      paint.style = PaintingStyle.stroke;
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(_AnimatedGridPainter oldDelegate) {
    return dimensions != oldDelegate.dimensions ||
        lineColor != oldDelegate.lineColor ||
        lineWidth != oldDelegate.lineWidth ||
        backgroundColor != oldDelegate.backgroundColor ||
        highlightedCells != oldDelegate.highlightedCells ||
        highlightColor != oldDelegate.highlightColor ||
        highlightOpacities != oldDelegate.highlightOpacities ||
        isCellValid != oldDelegate.isCellValid ||
        errorColor != oldDelegate.errorColor;
  }
}
