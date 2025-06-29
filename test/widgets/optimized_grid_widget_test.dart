import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/optimized_grid_widget.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';

void main() {
  group('OptimizedGridWidget', () {
    test('should support const constructor', () {
      // This test verifies that the widget can be created as const
      const widget = OptimizedGridWidget(
        dimensions: GridDimensions(columns: 4, rows: 4),
      );

      expect(widget.dimensions.columns, equals(4));
      expect(widget.dimensions.rows, equals(4));
      expect(widget.lineColor, equals(Colors.grey));
      expect(widget.backgroundColor, equals(Colors.white));
    });

    testWidgets('should use RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OptimizedGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          )),
        ),
      );

      // Should contain RepaintBoundary as a descendant of OptimizedGridWidget
      final optimizedGridFinder = find.byType(OptimizedGridWidget);
      final repaintBoundaryFinder = find.descendant(
        of: optimizedGridFinder,
        matching: find.byType(RepaintBoundary),
      );
      expect(repaintBoundaryFinder, findsOneWidget);
    });

    testWidgets('should only repaint when necessary', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 4);
      final highlightedCells = ValueNotifier<Set<Point<int>>>({});

      // Create a custom painter with debug key to track paint counts
      final testPaintCount = <String, int>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return RepaintBoundary(
                  child: ValueListenableBuilder<Set<Point<int>>>(
                    valueListenable: highlightedCells,
                    builder: (context, cells, child) {
                      return CustomPaint(
                        painter: TestableOptimizedGridPainter(
                          dimensions: dimensions,
                          lineColor: Colors.grey,
                          backgroundColor: Colors.white,
                          lineWidth: 1.0,
                          highlightedCells: cells,
                          highlightColor: Colors.blue,
                          paintCounts: testPaintCount,
                          debugKey: 'test',
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      final initialPaintCount = testPaintCount['test'] ?? 0;
      expect(initialPaintCount, greaterThan(0));

      // Update highlighted cells
      highlightedCells.value = {const Point(1, 1)};
      await tester.pump();

      // Should have repainted
      final newPaintCount = testPaintCount['test'] ?? 0;
      expect(newPaintCount, greaterThan(initialPaintCount));
    });

    testWidgets('should not repaint for unrelated changes', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 4);
      final highlightedCells = ValueNotifier<Set<Point<int>>>({});
      final unrelatedNotifier = ValueNotifier<int>(0);
      final testPaintCount = <String, int>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: ValueListenableBuilder<Set<Point<int>>>(
                      valueListenable: highlightedCells,
                      builder: (context, cells, child) {
                        return CustomPaint(
                          painter: TestableOptimizedGridPainter(
                            dimensions: dimensions,
                            lineColor: Colors.grey,
                            backgroundColor: Colors.white,
                            lineWidth: 1.0,
                            highlightedCells: cells,
                            highlightColor: Colors.blue,
                            paintCounts: testPaintCount,
                            debugKey: 'grid-test',
                          ),
                          child: const SizedBox.expand(),
                        );
                      },
                    ),
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: unrelatedNotifier,
                  builder: (context, value, child) => Text('$value'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      final initialPaintCount = testPaintCount['grid-test'] ?? 0;
      expect(initialPaintCount, greaterThan(0));

      // Update unrelated value
      unrelatedNotifier.value = 1;
      await tester.pump();

      // Grid should not have repainted
      final newPaintCount = testPaintCount['grid-test'] ?? 0;
      expect(newPaintCount, equals(initialPaintCount));
    });

    testWidgets('should use efficient shouldRepaint', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedGridWidget(
              dimensions: const GridDimensions(columns: 12, rows: 12),
            ),
          ),
        ),
      );

      // Find the CustomPaint within OptimizedGridWidget
      final optimizedGridFinder = find.byType(OptimizedGridWidget);
      final customPaintFinder = find.descendant(
        of: optimizedGridFinder,
        matching: find.byType(CustomPaint),
      );
      final customPaint = tester.widget<CustomPaint>(customPaintFinder);
      final painter = customPaint.painter as OptimizedGridPainter;

      // Same painter should not need repaint
      expect(painter.shouldRepaint(painter), isFalse);

      // Different highlighted cells should need repaint
      final newPainter = OptimizedGridPainter(
        dimensions: dimensions,
        lineColor: painter.lineColor,
        backgroundColor: painter.backgroundColor,
        lineWidth: painter.lineWidth,
        highlightedCells: {const Point(2, 2)},
        highlightColor: painter.highlightColor,
      );
      expect(painter.shouldRepaint(newPainter), isTrue);

      // Same highlighted cells should not need repaint
      final samePainter = OptimizedGridPainter(
        dimensions: painter.dimensions,
        lineColor: painter.lineColor,
        backgroundColor: painter.backgroundColor,
        lineWidth: painter.lineWidth,
        highlightedCells: Set<Point<int>>.from(painter.highlightedCells),
        highlightColor: painter.highlightColor,
      );
      expect(painter.shouldRepaint(samePainter), isFalse);
    });

    testWidgets('should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedGridWidget(
              dimensions: GridDimensions(columns: 12, rows: 12),
            ),
          ),
        ),
      );

      expect(find.byType(OptimizedGridWidget), findsOneWidget);
    });
  });
}

/// Testable version of OptimizedGridPainter that uses an external paint count map
class TestableOptimizedGridPainter extends OptimizedGridPainter {
  final Map<String, int> paintCounts;

  TestableOptimizedGridPainter({
    required super.dimensions,
    required super.lineColor,
    required super.backgroundColor,
    required super.lineWidth,
    required super.highlightedCells,
    required super.highlightColor,
    required this.paintCounts,
    required String debugKey,
  }) : super(debugKey: debugKey);

  @override
  void paint(Canvas canvas, Size size) {
    // Increment paint count
    paintCounts[debugKey] = (paintCounts[debugKey] ?? 0) + 1;

    // Call parent paint method
    super.paint(canvas, size);
  }

  @override
  int get debugPaintCount => paintCounts[debugKey] ?? 0;
}
