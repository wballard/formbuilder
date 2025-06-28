import 'dart:math';

/// Type of alignment guide
enum GuideType { horizontal, vertical, centerHorizontal, centerVertical }

/// Represents an alignment guide for visual feedback during dragging
class AlignmentGuide {
  /// Type of guide (horizontal or vertical)
  final GuideType type;

  /// Position of the guide (x for vertical, y for horizontal)
  final double position;

  /// Start point of the guide line
  final double start;

  /// End point of the guide line
  final double end;

  /// Whether this is a temporary guide (shown during drag)
  final bool isTemporary;

  const AlignmentGuide({
    required this.type,
    required this.position,
    required this.start,
    required this.end,
    this.isTemporary = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlignmentGuide &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          position == other.position &&
          start == other.start &&
          end == other.end &&
          isTemporary == other.isTemporary;

  @override
  int get hashCode =>
      type.hashCode ^
      position.hashCode ^
      start.hashCode ^
      end.hashCode ^
      isTemporary.hashCode;
}

/// Detects alignment guides based on widget positions
class AlignmentGuideDetector {
  /// Distance threshold for detecting alignment
  final double threshold;

  const AlignmentGuideDetector({this.threshold = 8.0});

  /// Detect center alignment guides
  List<AlignmentGuide> detectCenterAlignment(
    Rectangle<int> movingWidget,
    List<Rectangle<int>> otherWidgets,
  ) {
    final guides = <AlignmentGuide>[];

    final movingCenterX = movingWidget.left + movingWidget.width / 2.0;
    final movingCenterY = movingWidget.top + movingWidget.height / 2.0;

    for (final widget in otherWidgets) {
      final widgetCenterX = widget.left + widget.width / 2.0;
      final widgetCenterY = widget.top + widget.height / 2.0;

      // Check horizontal center alignment
      if ((movingCenterY - widgetCenterY).abs() <= threshold) {
        guides.add(
          AlignmentGuide(
            type: GuideType.horizontal,
            position: widgetCenterY,
            start: min(movingWidget.left, widget.left).toDouble(),
            end: max(movingWidget.right, widget.right).toDouble(),
            isTemporary: true,
          ),
        );
      }

      // Check vertical center alignment
      if ((movingCenterX - widgetCenterX).abs() <= threshold) {
        guides.add(
          AlignmentGuide(
            type: GuideType.vertical,
            position: widgetCenterX,
            start: min(movingWidget.top, widget.top).toDouble(),
            end: max(movingWidget.bottom, widget.bottom).toDouble(),
            isTemporary: true,
          ),
        );
      }
    }

    return guides;
  }

  /// Detect edge alignment guides
  List<AlignmentGuide> detectEdgeAlignment(
    Rectangle<int> movingWidget,
    List<Rectangle<int>> otherWidgets,
  ) {
    final guides = <AlignmentGuide>[];

    for (final widget in otherWidgets) {
      // Check left edge alignment
      if ((movingWidget.left - widget.left).abs() <= threshold) {
        guides.add(
          _createVerticalGuide(widget.left.toDouble(), movingWidget, widget),
        );
      }
      if ((movingWidget.left - widget.right).abs() <= threshold) {
        guides.add(
          _createVerticalGuide(widget.right.toDouble(), movingWidget, widget),
        );
      }

      // Check right edge alignment
      if ((movingWidget.right - widget.right).abs() <= threshold) {
        guides.add(
          _createVerticalGuide(widget.right.toDouble(), movingWidget, widget),
        );
      }
      if ((movingWidget.right - widget.left).abs() <= threshold) {
        guides.add(
          _createVerticalGuide(widget.left.toDouble(), movingWidget, widget),
        );
      }

      // Check top edge alignment
      if ((movingWidget.top - widget.top).abs() <= threshold) {
        guides.add(
          _createHorizontalGuide(widget.top.toDouble(), movingWidget, widget),
        );
      }
      if ((movingWidget.top - widget.bottom).abs() <= threshold) {
        guides.add(
          _createHorizontalGuide(
            widget.bottom.toDouble(),
            movingWidget,
            widget,
          ),
        );
      }

      // Check bottom edge alignment
      if ((movingWidget.bottom - widget.bottom).abs() <= threshold) {
        guides.add(
          _createHorizontalGuide(
            widget.bottom.toDouble(),
            movingWidget,
            widget,
          ),
        );
      }
      if ((movingWidget.bottom - widget.top).abs() <= threshold) {
        guides.add(
          _createHorizontalGuide(widget.top.toDouble(), movingWidget, widget),
        );
      }
    }

    return guides;
  }

  /// Detect equal spacing guides
  List<AlignmentGuide> detectEqualSpacing(
    Rectangle<int> movingWidget,
    List<Rectangle<int>> otherWidgets,
  ) {
    final guides = <AlignmentGuide>[];

    if (otherWidgets.length < 2) return guides;

    // Sort widgets by position for easier spacing calculation
    final sortedByX = List<Rectangle<int>>.from(otherWidgets)
      ..sort((a, b) => a.left.compareTo(b.left));
    final sortedByY = List<Rectangle<int>>.from(otherWidgets)
      ..sort((a, b) => a.top.compareTo(b.top));

    // Check horizontal spacing
    for (int i = 0; i < sortedByX.length - 1; i++) {
      final spacing = sortedByX[i + 1].left - sortedByX[i].right;
      final expectedPosition = sortedByX[i + 1].right + spacing;

      if ((movingWidget.left - expectedPosition).abs() <= threshold) {
        guides.add(
          AlignmentGuide(
            type: GuideType.vertical,
            position: expectedPosition.toDouble(),
            start: min(
              sortedByX[i].top,
              min(sortedByX[i + 1].top, movingWidget.top),
            ).toDouble(),
            end: max(
              sortedByX[i].bottom,
              max(sortedByX[i + 1].bottom, movingWidget.bottom),
            ).toDouble(),
            isTemporary: true,
          ),
        );
      }
    }

    // Check vertical spacing
    for (int i = 0; i < sortedByY.length - 1; i++) {
      final spacing = sortedByY[i + 1].top - sortedByY[i].bottom;
      final expectedPosition = sortedByY[i + 1].bottom + spacing;

      if ((movingWidget.top - expectedPosition).abs() <= threshold) {
        guides.add(
          AlignmentGuide(
            type: GuideType.horizontal,
            position: expectedPosition.toDouble(),
            start: min(
              sortedByY[i].left,
              min(sortedByY[i + 1].left, movingWidget.left),
            ).toDouble(),
            end: max(
              sortedByY[i].right,
              max(sortedByY[i + 1].right, movingWidget.right),
            ).toDouble(),
            isTemporary: true,
          ),
        );
      }
    }

    return guides;
  }

  AlignmentGuide _createVerticalGuide(
    double position,
    Rectangle<int> widget1,
    Rectangle<int> widget2,
  ) {
    return AlignmentGuide(
      type: GuideType.vertical,
      position: position,
      start: min(widget1.top, widget2.top).toDouble(),
      end: max(widget1.bottom, widget2.bottom).toDouble(),
      isTemporary: true,
    );
  }

  AlignmentGuide _createHorizontalGuide(
    double position,
    Rectangle<int> widget1,
    Rectangle<int> widget2,
  ) {
    return AlignmentGuide(
      type: GuideType.horizontal,
      position: position,
      start: min(widget1.left, widget2.left).toDouble(),
      end: max(widget1.right, widget2.right).toDouble(),
      isTemporary: true,
    );
  }
}
