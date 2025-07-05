import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/widgets/accessible_grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';

void main() {
  group('GridWidget', () {
    testWidgets('renders with correct dimensions', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 3, rows: 2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AccessibleGridWidget(
            dimensions: dimensions,
          )),
        ),
      );

      expect(find.byType(AccessibleGridWidget), findsOneWidget);

      // The widget should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('applies custom grid line color', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      const customColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
              dimensions: dimensions,
              lineColor: customColor,
            ),
          ),
        ),
      );

      // Verify the widget renders with custom color
      final gridWidget = tester.widget<AccessibleGridWidget>(find.byType(AccessibleGridWidget));
      expect(gridWidget.lineColor, equals(customColor));
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      const customBackground = Colors.yellow;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
              dimensions: dimensions,
              backgroundColor: customBackground,
            ),
          ),
        ),
      );

      // Verify the widget renders with custom background color
      final gridWidget = tester.widget<AccessibleGridWidget>(find.byType(AccessibleGridWidget));
      expect(gridWidget.backgroundColor, equals(customBackground));
    });

    testWidgets('applies custom grid line width', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      const customWidth = 3.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
              dimensions: dimensions,
              lineWidth: customWidth,
            ),
          ),
        ),
      );

      // Verify the widget renders with custom line width
      final gridWidget = tester.widget<AccessibleGridWidget>(find.byType(AccessibleGridWidget));
      expect(gridWidget.lineWidth, equals(customWidth));
    });

    testWidgets('uses default values when not specified', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AccessibleGridWidget(
            dimensions: dimensions,
          )),
        ),
      );

      final gridWidget = tester.widget<AccessibleGridWidget>(find.byType(AccessibleGridWidget));
      expect(gridWidget.lineColor, equals(Colors.transparent));
      expect(gridWidget.lineWidth, equals(1.0));
      expect(gridWidget.backgroundColor, equals(Colors.transparent));
    });

    testWidgets('renders cells with hover', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: AccessibleGridWidget(
                  dimensions: const GridDimensions(columns: 3, rows: 3),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the grid renders without errors
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    group('highlight functionality', () {
      testWidgets('highlights specified cells', (WidgetTester tester) async {
        const dimensions = GridDimensions(columns: 3, rows: 3);
        final highlightedCells = <Point<int>>{
          const Point(0, 0),
          const Point(1, 1),
          const Point(2, 2),
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleGridWidget(
                dimensions: dimensions,
                highlightedCells: highlightedCells,
                highlightColor: Colors.red.withValues(alpha: 0.3),
              ),
            ),
          ),
        );

        // Verify the widget renders with highlighted cells
        expect(find.byType(AccessibleGridWidget), findsOneWidget);
      });

      testWidgets('uses default highlight color when not specified', (WidgetTester tester) async {
        const dimensions = GridDimensions(columns: 2, rows: 2);
        final highlightedCells = <Point<int>>{const Point(0, 0)};

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleGridWidget(
                dimensions: dimensions,
                highlightedCells: highlightedCells,
              ),
            ),
          ),
        );

        // Verify the widget renders without error
        expect(find.byType(AccessibleGridWidget), findsOneWidget);
      });

      testWidgets('handles empty highlight set', (WidgetTester tester) async {
        const dimensions = GridDimensions(columns: 2, rows: 2);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleGridWidget(
                dimensions: dimensions,
                highlightedCells: const {},
              ),
            ),
          ),
        );

        // Verify the widget renders without error
        expect(find.byType(AccessibleGridWidget), findsOneWidget);
      });
    });

    group('custom cell validation', () {
      testWidgets('applies custom cell validation', (WidgetTester tester) async {
        const dimensions = GridDimensions(columns: 3, rows: 3);
        // Only cells on the diagonal are valid
        bool isCellValid(Point<int> cell) => cell.x == cell.y;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleGridWidget(
                dimensions: dimensions,
                isCellValid: isCellValid,
              ),
            ),
          ),
        );

        // Verify the widget renders with validation
        expect(find.byType(AccessibleGridWidget), findsOneWidget);
      });

      testWidgets('handles null validation function', (WidgetTester tester) async {
        const dimensions = GridDimensions(columns: 2, rows: 2);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleGridWidget(
                dimensions: dimensions,
                isCellValid: null,
              ),
            ),
          ),
        );

        // Verify the widget renders without error
        expect(find.byType(AccessibleGridWidget), findsOneWidget);
      });
    });

    group('responsive behavior', () {
      testWidgets('handles minimum dimensions', (WidgetTester tester) async {
        const dimensions = GridDimensions(columns: 1, rows: 1);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleGridWidget(
                dimensions: dimensions,
              ),
            ),
          ),
        );

        // Should render without crashing
        expect(find.byType(AccessibleGridWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles maximum grid dimensions', (WidgetTester tester) async {
        const dimensions = GridDimensions(columns: 12, rows: 12);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleGridWidget(
                dimensions: dimensions,
              ),
            ),
          ),
        );

        // Should render without crashing
        expect(find.byType(AccessibleGridWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('cell calculation', () {
      test('calculates cells in rectangle correctly', () {
        // Single cell
        final cells = GridWidget.getCellsInRectangle(2, 2, 1, 1);
        expect(cells, equals({const Point(2, 2)}));
      });

      test('calculates 2x2 rectangle', () {
        final cells = GridWidget.getCellsInRectangle(1, 1, 2, 2);
        expect(cells, equals({
          const Point(1, 1),
          const Point(2, 1),
          const Point(1, 2),
          const Point(2, 2),
        }));
      });

      test('calculates horizontal rectangle', () {
        final cells = GridWidget.getCellsInRectangle(0, 2, 4, 1);
        expect(cells, equals({
          const Point(0, 2),
          const Point(1, 2),
          const Point(2, 2),
          const Point(3, 2),
        }));
      });

      test('calculates vertical rectangle', () {
        final cells = GridWidget.getCellsInRectangle(2, 0, 1, 3);
        expect(cells, equals({
          const Point(2, 0),
          const Point(2, 1),
          const Point(2, 2),
        }));
      });

      test('handles edge cases', () {
        // Zero width/height
        final cells = GridWidget.getCellsInRectangle(0, 0, 0, 0);
        expect(cells, isEmpty);

        // Negative coordinates (should still work)
        final negativeCells = GridWidget.getCellsInRectangle(-1, -1, 2, 2);
        expect(negativeCells.length, equals(4));
      });
    });
  });
}