import 'dart:math';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/grid_snap_settings.dart';

/// Calculates snapping positions based on grid settings
class GridSnapCalculator {
  /// Snap a position to the grid based on settings
  Point<double> snapPosition(
    Point<double> position,
    Size cellSize,
    GridSnapSettings settings,
  ) {
    if (!settings.snapToGrid || settings.freePositioning) {
      return position;
    }

    final divisor = settings.subdivisions.divisor;
    final snapUnitX = cellSize.width / divisor;
    final snapUnitY = cellSize.height / divisor;

    final snappedX = (position.x / snapUnitX).round() * snapUnitX;
    final snappedY = (position.y / snapUnitY).round() * snapUnitY;

    return Point(snappedX, snappedY);
  }

  /// Convert position to grid coordinate with subdivision support
  double positionToGridCoordinate(
    double position,
    double cellSize,
    GridSubdivision subdivision,
  ) {
    return position / cellSize;
  }

  /// Convert grid coordinate to position with subdivision support
  double gridCoordinateToPosition(
    double coordinate,
    double cellSize,
    GridSubdivision subdivision,
  ) {
    return coordinate * cellSize;
  }

  /// Detect snap points based on nearby widgets
  Point<double>? detectWidgetSnapPoint(
    Rectangle<int> movingWidget,
    List<Rectangle<int>> existingWidgets,
    GridSnapSettings settings,
  ) {
    if (!settings.snapToWidgets) {
      return null;
    }

    double? snapX;
    double? snapY;
    double minDistanceX = double.infinity;
    double minDistanceY = double.infinity;

    for (final widget in existingWidgets) {
      // Check horizontal edges
      final leftDistance = (movingWidget.left - widget.left).abs().toDouble();
      final rightToLeftDistance = (movingWidget.left - widget.right)
          .abs()
          .toDouble();
      final rightDistance = (movingWidget.right - widget.right)
          .abs()
          .toDouble();
      final leftToRightDistance = (movingWidget.right - widget.left)
          .abs()
          .toDouble();

      if (leftDistance <= settings.snapThreshold &&
          leftDistance < minDistanceX) {
        minDistanceX = leftDistance;
        snapX = widget.left.toDouble();
      }
      if (rightToLeftDistance <= settings.snapThreshold &&
          rightToLeftDistance < minDistanceX) {
        minDistanceX = rightToLeftDistance;
        snapX = widget.right.toDouble();
      }
      if (rightDistance <= settings.snapThreshold &&
          rightDistance < minDistanceX) {
        minDistanceX = rightDistance;
        snapX = widget.right.toDouble() - movingWidget.width;
      }
      if (leftToRightDistance <= settings.snapThreshold &&
          leftToRightDistance < minDistanceX) {
        minDistanceX = leftToRightDistance;
        snapX = widget.left.toDouble() - movingWidget.width;
      }

      // Check vertical edges
      final topDistance = (movingWidget.top - widget.top).abs().toDouble();
      final bottomToTopDistance = (movingWidget.top - widget.bottom)
          .abs()
          .toDouble();
      final bottomDistance = (movingWidget.bottom - widget.bottom)
          .abs()
          .toDouble();
      final topToBottomDistance = (movingWidget.bottom - widget.top)
          .abs()
          .toDouble();

      if (topDistance <= settings.snapThreshold && topDistance < minDistanceY) {
        minDistanceY = topDistance;
        snapY = widget.top.toDouble();
      }
      if (bottomToTopDistance <= settings.snapThreshold &&
          bottomToTopDistance < minDistanceY) {
        minDistanceY = bottomToTopDistance;
        snapY = widget.bottom.toDouble();
      }
      if (bottomDistance <= settings.snapThreshold &&
          bottomDistance < minDistanceY) {
        minDistanceY = bottomDistance;
        snapY = widget.bottom.toDouble() - movingWidget.height;
      }
      if (topToBottomDistance <= settings.snapThreshold &&
          topToBottomDistance < minDistanceY) {
        minDistanceY = topToBottomDistance;
        snapY = widget.top.toDouble() - movingWidget.height;
      }
    }

    if (snapX != null || snapY != null) {
      return Point(
        snapX ?? movingWidget.left.toDouble(),
        snapY ?? movingWidget.top.toDouble(),
      );
    }

    return null;
  }

  /// Calculate subdivision grid lines for visual display
  List<double> getSubdivisionLines(
    double start,
    double end,
    double cellSize,
    GridSubdivision subdivision,
  ) {
    if (subdivision == GridSubdivision.none) {
      return [];
    }

    final lines = <double>[];
    final divisor = subdivision.divisor;
    final subdivisionSize = cellSize / divisor;

    // Start from the first cell boundary
    final firstCell = (start / cellSize).floor() * cellSize;

    // Generate subdivision lines
    for (double pos = firstCell; pos <= end; pos += subdivisionSize) {
      // Skip main grid lines (they're drawn separately)
      if ((pos % cellSize).abs() > 0.001) {
        lines.add(pos);
      }
    }

    return lines;
  }

  /// Apply magnetic edge alignment if enabled
  Point<double> applyMagneticEdges(
    Point<double> position,
    Size widgetSize,
    List<Rectangle<int>> existingWidgets,
    GridSnapSettings settings,
  ) {
    if (!settings.magneticEdges) {
      return position;
    }

    double resultX = position.x;
    double resultY = position.y;
    const magnetStrength = 20.0; // Distance at which magnetic effect starts

    for (final widget in existingWidgets) {
      // Horizontal magnetic alignment
      final leftDiff = (position.x - widget.left).abs();
      final rightDiff = (position.x + widgetSize.width - widget.right).abs();

      if (leftDiff < magnetStrength) {
        resultX = widget.left.toDouble();
      } else if (rightDiff < magnetStrength) {
        resultX = widget.right - widgetSize.width;
      }

      // Vertical magnetic alignment
      final topDiff = (position.y - widget.top).abs();
      final bottomDiff = (position.y + widgetSize.height - widget.bottom).abs();

      if (topDiff < magnetStrength) {
        resultY = widget.top.toDouble();
      } else if (bottomDiff < magnetStrength) {
        resultY = widget.bottom - widgetSize.height;
      }
    }

    return Point(resultX, resultY);
  }
}
