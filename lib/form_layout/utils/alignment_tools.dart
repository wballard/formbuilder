import 'dart:math';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Types of widget alignment
enum WidgetAlignment {
  left,
  right,
  centerHorizontal,
  top,
  bottom,
  centerVertical,
}

/// Types of distribution
enum DistributionType { horizontalEvenly, verticalEvenly }

/// Types of size matching
enum SizeMatchType { width, height, both }

/// Types of group alignment
enum GroupAlignment { topLeft, topRight, bottomLeft, bottomRight, center }

/// Provides alignment and distribution tools for widgets
class AlignmentTools {
  /// Align widgets based on alignment type
  List<WidgetPlacement> alignWidgets({
    required List<WidgetPlacement> widgets,
    required WidgetAlignment alignment,
    required GridDimensions gridDimensions,
  }) {
    if (widgets.isEmpty) return [];

    final aligned = <WidgetPlacement>[];

    switch (alignment) {
      case WidgetAlignment.left:
        final leftmost = widgets.map((w) => w.column).reduce(min);
        for (final widget in widgets) {
          aligned.add(widget.copyWith(column: leftmost));
        }
        break;

      case WidgetAlignment.right:
        final rightmost = widgets.map((w) => w.column + w.width).reduce(max);
        for (final widget in widgets) {
          aligned.add(widget.copyWith(column: rightmost - widget.width));
        }
        break;

      case WidgetAlignment.centerHorizontal:
        // Find the average center position
        double totalCenterX = 0;
        for (final widget in widgets) {
          totalCenterX += widget.column + widget.width / 2.0;
        }
        final targetCenterX = totalCenterX / widgets.length;

        for (final widget in widgets) {
          final newColumn = (targetCenterX - widget.width / 2.0).round();
          aligned.add(
            widget.copyWith(
              column: newColumn.clamp(0, gridDimensions.columns - widget.width),
            ),
          );
        }
        break;

      case WidgetAlignment.top:
        final topmost = widgets.map((w) => w.row).reduce(min);
        for (final widget in widgets) {
          aligned.add(widget.copyWith(row: topmost));
        }
        break;

      case WidgetAlignment.bottom:
        final bottommost = widgets.map((w) => w.row + w.height).reduce(max);
        for (final widget in widgets) {
          aligned.add(widget.copyWith(row: bottommost - widget.height));
        }
        break;

      case WidgetAlignment.centerVertical:
        // Find the average center position
        double totalCenterY = 0;
        for (final widget in widgets) {
          totalCenterY += widget.row + widget.height / 2.0;
        }
        final targetCenterY = totalCenterY / widgets.length;

        for (final widget in widgets) {
          final newRow = (targetCenterY - widget.height / 2.0).round();
          aligned.add(
            widget.copyWith(
              row: newRow.clamp(0, gridDimensions.rows - widget.height),
            ),
          );
        }
        break;
    }

    return aligned;
  }

  /// Distribute widgets evenly
  List<WidgetPlacement> distributeWidgets({
    required List<WidgetPlacement> widgets,
    required DistributionType distribution,
    required GridDimensions gridDimensions,
  }) {
    if (widgets.length < 2) return widgets;

    final distributed = <WidgetPlacement>[];

    switch (distribution) {
      case DistributionType.horizontalEvenly:
        // Sort by column position
        final sorted = List<WidgetPlacement>.from(widgets)
          ..sort((a, b) => a.column.compareTo(b.column));

        if (widgets.length < 2) {
          return sorted;
        }

        // Calculate total space needed
        final totalWidth = sorted.fold(0, (sum, w) => sum + w.width);
        final firstColumn = sorted.first.column;
        final lastColumn = sorted.last.column + sorted.last.width;
        final totalSpace = lastColumn - firstColumn;

        // Calculate available space for gaps
        final availableForGaps = totalSpace - totalWidth;
        final numGaps = widgets.length - 1;

        if (numGaps > 0) {
          final gapSize = availableForGaps ~/ numGaps;
          final extraPixels = availableForGaps % numGaps;

          int currentX = firstColumn;
          for (int i = 0; i < sorted.length; i++) {
            distributed.add(sorted[i].copyWith(column: currentX));
            currentX += sorted[i].width;
            if (i < sorted.length - 1) {
              // Add gap
              currentX += gapSize;
              // Distribute extra pixels to first gaps
              if (i < extraPixels) {
                currentX += 1;
              }
            }
          }
        } else {
          return sorted;
        }
        break;

      case DistributionType.verticalEvenly:
        // Sort by row position
        final sorted = List<WidgetPlacement>.from(widgets)
          ..sort((a, b) => a.row.compareTo(b.row));

        if (widgets.length < 2) {
          return sorted;
        }

        // Calculate total space needed
        final totalHeight = sorted.fold(0, (sum, w) => sum + w.height);
        final firstRow = sorted.first.row;
        final lastRow = sorted.last.row + sorted.last.height;
        final totalSpace = lastRow - firstRow;

        // Calculate available space for gaps
        final availableForGaps = totalSpace - totalHeight;
        final numGaps = widgets.length - 1;

        if (numGaps > 0) {
          final gapSize = availableForGaps ~/ numGaps;
          final extraPixels = availableForGaps % numGaps;

          int currentY = firstRow;
          for (int i = 0; i < sorted.length; i++) {
            distributed.add(sorted[i].copyWith(row: currentY));
            currentY += sorted[i].height;
            if (i < sorted.length - 1) {
              // Add gap
              currentY += gapSize;
              // Distribute extra pixels to first gaps
              if (i < extraPixels) {
                currentY += 1;
              }
            }
          }
        } else {
          return sorted;
        }
        break;
    }

    return distributed.isEmpty ? widgets : distributed;
  }

  /// Match widget sizes
  List<WidgetPlacement> matchSizes({
    required List<WidgetPlacement> widgets,
    required SizeMatchType sizeType,
    required GridDimensions gridDimensions,
  }) {
    if (widgets.isEmpty) return [];

    final matched = <WidgetPlacement>[];

    switch (sizeType) {
      case SizeMatchType.width:
        final maxWidth = widgets.map((w) => w.width).reduce(max);
        for (final widget in widgets) {
          // Ensure widget doesn't exceed grid bounds
          final newWidth = min(
            maxWidth,
            gridDimensions.columns - widget.column,
          );
          matched.add(widget.copyWith(width: newWidth));
        }
        break;

      case SizeMatchType.height:
        final maxHeight = widgets.map((w) => w.height).reduce(max);
        for (final widget in widgets) {
          // Ensure widget doesn't exceed grid bounds
          final newHeight = min(maxHeight, gridDimensions.rows - widget.row);
          matched.add(widget.copyWith(height: newHeight));
        }
        break;

      case SizeMatchType.both:
        final maxWidth = widgets.map((w) => w.width).reduce(max);
        final maxHeight = widgets.map((w) => w.height).reduce(max);
        for (final widget in widgets) {
          // Ensure widget doesn't exceed grid bounds
          final newWidth = min(
            maxWidth,
            gridDimensions.columns - widget.column,
          );
          final newHeight = min(maxHeight, gridDimensions.rows - widget.row);
          matched.add(widget.copyWith(width: newWidth, height: newHeight));
        }
        break;
    }

    return matched;
  }

  /// Align a group of widgets while maintaining relative positions
  List<WidgetPlacement> groupAlign({
    required List<WidgetPlacement> widgets,
    required GroupAlignment alignment,
    required GridDimensions gridDimensions,
  }) {
    if (widgets.isEmpty) return [];

    // Find the bounding box of all widgets
    final minColumn = widgets.map((w) => w.column).reduce(min);
    final maxColumn = widgets.map((w) => w.column + w.width).reduce(max);
    final minRow = widgets.map((w) => w.row).reduce(min);
    final maxRow = widgets.map((w) => w.row + w.height).reduce(max);

    final groupWidth = maxColumn - minColumn;
    final groupHeight = maxRow - minRow;

    int offsetX = 0;
    int offsetY = 0;

    switch (alignment) {
      case GroupAlignment.topLeft:
        offsetX = -minColumn;
        offsetY = -minRow;
        break;

      case GroupAlignment.topRight:
        offsetX = gridDimensions.columns - maxColumn;
        offsetY = -minRow;
        break;

      case GroupAlignment.bottomLeft:
        offsetX = -minColumn;
        offsetY = gridDimensions.rows - maxRow;
        break;

      case GroupAlignment.bottomRight:
        offsetX = gridDimensions.columns - maxColumn;
        offsetY = gridDimensions.rows - maxRow;
        break;

      case GroupAlignment.center:
        offsetX =
            ((gridDimensions.columns - groupWidth) / 2).round() - minColumn;
        offsetY = ((gridDimensions.rows - groupHeight) / 2).round() - minRow;
        break;
    }

    // Apply offset to all widgets
    final aligned = <WidgetPlacement>[];
    for (final widget in widgets) {
      aligned.add(
        widget.copyWith(
          column: (widget.column + offsetX).clamp(
            0,
            gridDimensions.columns - widget.width,
          ),
          row: (widget.row + offsetY).clamp(
            0,
            gridDimensions.rows - widget.height,
          ),
        ),
      );
    }

    return aligned;
  }

  /// Calculate the spacing needed for even distribution
  double calculateEvenSpacing({
    required List<WidgetPlacement> widgets,
    required bool horizontal,
    required GridDimensions gridDimensions,
  }) {
    if (widgets.length < 2) return 0;

    if (horizontal) {
      final sorted = List<WidgetPlacement>.from(widgets)
        ..sort((a, b) => a.column.compareTo(b.column));

      final totalWidth = sorted.fold(0, (sum, w) => sum + w.width);
      final availableSpace = gridDimensions.columns - totalWidth;
      return availableSpace / (widgets.length + 1);
    } else {
      final sorted = List<WidgetPlacement>.from(widgets)
        ..sort((a, b) => a.row.compareTo(b.row));

      final totalHeight = sorted.fold(0, (sum, w) => sum + w.height);
      final availableSpace = gridDimensions.rows - totalHeight;
      return availableSpace / (widgets.length + 1);
    }
  }
}
