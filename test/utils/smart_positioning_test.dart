import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/utils/smart_positioning.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';

void main() {
  group('SmartPositioning', () {
    late SmartPositioning smartPositioning;
    const gridDimensions = GridDimensions(columns: 6, rows: 4);

    setUp(() {
      smartPositioning = SmartPositioning();
    });

    test('should find next available space in empty grid', () {
      final existingWidgets = <WidgetPlacement>[];

      final position = smartPositioning.findNextAvailableSpace(
        width: 2,
        height: 1,
        existingWidgets: existingWidgets,
        gridDimensions: gridDimensions,
      );

      expect(position, equals(Point(0, 0)));
    });

    test('should find next available space with existing widgets', () {
      final existingWidgets = [
        WidgetPlacement(
          id: '1',
          widgetName: 'widget1',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        ),
        WidgetPlacement(
          id: '2',
          widgetName: 'widget2',
          column: 2,
          row: 0,
          width: 2,
          height: 1,
        ),
      ];

      // Should find space at (4, 0)
      final position = smartPositioning.findNextAvailableSpace(
        width: 2,
        height: 1,
        existingWidgets: existingWidgets,
        gridDimensions: gridDimensions,
      );

      expect(position, equals(Point(4, 0)));
    });

    test('should return null when no space available', () {
      final existingWidgets = [
        WidgetPlacement(
          id: '1',
          widgetName: 'widget1',
          column: 0,
          row: 0,
          width: 6,
          height: 4,
        ),
      ];

      final position = smartPositioning.findNextAvailableSpace(
        width: 1,
        height: 1,
        existingWidgets: existingWidgets,
        gridDimensions: gridDimensions,
      );

      expect(position, isNull);
    });

    test('should auto-flow widgets left to right, top to bottom', () {
      final existingWidgets = <WidgetPlacement>[];
      final widgetsToPlace = [
        Size(2, 1), // Widget 1
        Size(2, 1), // Widget 2
        Size(2, 1), // Widget 3
        Size(3, 2), // Widget 4
      ];

      final placements = smartPositioning.autoFlowLayout(
        widgetsToPlace: widgetsToPlace,
        existingWidgets: existingWidgets,
        gridDimensions: gridDimensions,
      );

      expect(placements.length, equals(4));
      expect(placements[0], equals(Point(0, 0))); // First widget at top-left
      expect(placements[1], equals(Point(2, 0))); // Second widget to the right
      expect(
        placements[2],
        equals(Point(4, 0)),
        ); // Third widget continues right
      expect(
        placements[3],
        equals(Point(0, 1)),
        ); // Fourth widget wraps to next row
    });

    test('should compact layout by filling gaps', () {
      final existingWidgets = [
        WidgetPlacement(
          id: '1',
          widgetName: 'widget1',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        ),
        WidgetPlacement(
          id: '2',
          widgetName: 'widget2',
          column: 4,
          row: 0,
          width: 2,
          height: 1,
        ),
        // Gap at (2,0) with size 2x2
      ];

      final compacted = smartPositioning.compactLayout(
        widgets: existingWidgets,
        gridDimensions: gridDimensions,
        direction: CompactDirection.left,
      );

      expect(compacted.length, equals(2));
      // Widget 2 should move left to fill the gap
      expect(compacted[1].column, equals(2));
      expect(compacted[1].row, equals(0));
    });

    test('should fill gaps with new widgets', () {
      final existingWidgets = [
        WidgetPlacement(
          id: '1',
          widgetName: 'widget1',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        ),
        WidgetPlacement(
          id: '2',
          widgetName: 'widget2',
          column: 4,
          row: 0,
          width: 2,
          height: 1,
        ),
        // Gap at (2,0) with size 2x1
      ];

      final gaps = smartPositioning.findGaps(
        existingWidgets: existingWidgets,
        gridDimensions: gridDimensions,
      );

      expect(gaps.length, greaterThan(0));
      expect(gaps.any((gap) => gap.left == 2 && gap.top == 0), isTrue);
    });

    test('should respect minimum widget size when finding gaps', () {
      final existingWidgets = [
        WidgetPlacement(
          id: '1',
          widgetName: 'widget1',
          column: 0,
          row: 0,
          width: 5,
          height: 1,
        ),
        // Gap at (5,0) with size 1x1 - too small for minimum size
      ];

      final gaps = smartPositioning.findGaps(
        existingWidgets: existingWidgets,
        gridDimensions: gridDimensions,
        minWidth: 2,
        minHeight: 1,
      );

      // Should not include the 1x1 gap
      expect(gaps.where((gap) => gap.left == 5 && gap.top == 0), isEmpty);
    });

    test('should optimize layout for minimum total area', () {
      final widgets = [
        WidgetPlacement(
          id: '1',
          widgetName: 'widget1',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        ),
        WidgetPlacement(
          id: '2',
          widgetName: 'widget2',
          column: 0,
          row: 2,
          width: 2,
          height: 1,
        ),
        WidgetPlacement(
          id: '3',
          widgetName: 'widget3',
          column: 4,
          row: 1,
          width: 2,
          height: 1,
        ),
      ];

      final optimized = smartPositioning.optimizeLayout(
        widgets: widgets,
        gridDimensions: gridDimensions,
        strategy: OptimizationStrategy.minimizeArea,
      );

      // All widgets should be moved to top-left area
      final maxColumn = optimized.map((w) => w.column + w.width).reduce(max);
      final maxRow = optimized.map((w) => w.row + w.height).reduce(max);

      expect(maxColumn * maxRow, lessThanOrEqualTo(12)); // Optimized area
    });
  });

  group('CompactDirection', () {
    test('should have all directional values', () {
      expect(CompactDirection.values, contains(CompactDirection.left));
      expect(CompactDirection.values, contains(CompactDirection.right));
      expect(CompactDirection.values, contains(CompactDirection.up));
      expect(CompactDirection.values, contains(CompactDirection.down));
    });
  });

  group('OptimizationStrategy', () {
    test('should have all strategy values', () {
      expect(
        OptimizationStrategy.values,
        contains(OptimizationStrategy.minimizeArea),
      );
      expect(
        OptimizationStrategy.values,
        contains(OptimizationStrategy.minimizeGaps),
      );
      expect(
        OptimizationStrategy.values,
        contains(OptimizationStrategy.maintainOrder),
      );
    });
  });
}
