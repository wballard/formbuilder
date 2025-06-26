import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('GridWidget', () {
    testWidgets('renders with correct dimensions', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 3, rows: 2);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridWidget(
              dimensions: dimensions,
            ),
          ),
        ),
      );
      
      expect(find.byType(GridWidget), findsOneWidget);
      
      // The widget should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('applies custom grid line color', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      const customColor = Colors.blue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridWidget(
              dimensions: dimensions,
              gridLineColor: customColor,
            ),
          ),
        ),
      );
      
      // Verify the widget renders with custom color
      final gridWidget = tester.widget<GridWidget>(find.byType(GridWidget));
      expect(gridWidget.gridLineColor, equals(customColor));
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      const customBackground = Colors.yellow;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridWidget(
              dimensions: dimensions,
              backgroundColor: customBackground,
            ),
          ),
        ),
      );
      
      // Verify the widget renders with custom background
      final gridWidget = tester.widget<GridWidget>(find.byType(GridWidget));
      expect(gridWidget.backgroundColor, equals(customBackground));
    });

    testWidgets('respects custom padding', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      const customPadding = EdgeInsets.all(16.0);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridWidget(
              dimensions: dimensions,
              padding: customPadding,
            ),
          ),
        ),
      );
      
      // Verify padding is applied
      final gridWidget = tester.widget<GridWidget>(find.byType(GridWidget));
      expect(gridWidget.padding, equals(customPadding));
      
      // Check that Padding widget exists in the tree
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('uses default values when not specified', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridWidget(
              dimensions: dimensions,
            ),
          ),
        ),
      );
      
      final gridWidget = tester.widget<GridWidget>(find.byType(GridWidget));
      expect(gridWidget.gridLineColor, equals(Colors.grey.shade300));
      expect(gridWidget.gridLineWidth, equals(1.0));
      expect(gridWidget.backgroundColor, equals(Colors.white));
      expect(gridWidget.padding, equals(const EdgeInsets.all(8)));
    });

    testWidgets('fills available space', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: GridWidget(
                  dimensions: dimensions,
                ),
              ),
            ),
          ),
        ),
      );
      
      // The grid should expand to fill the available space
      final gridBox = tester.getRect(find.byType(GridWidget));
      expect(gridBox.width, equals(400));
      expect(gridBox.height, equals(400));
    });

    // Golden tests for visual regression
    testWidgets('renders 2x2 grid correctly - golden', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 2, rows: 2);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: GridWidget(
                  dimensions: dimensions,
                ),
              ),
            ),
          ),
        ),
      );
      
      await expectLater(
        find.byType(GridWidget),
        matchesGoldenFile('goldens/grid_widget_2x2.png'),
      );
    });

    testWidgets('renders 4x3 grid correctly - golden', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 3);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 300,
                child: GridWidget(
                  dimensions: dimensions,
                ),
              ),
            ),
          ),
        ),
      );
      
      await expectLater(
        find.byType(GridWidget),
        matchesGoldenFile('goldens/grid_widget_4x3.png'),
      );
    });

    testWidgets('renders with custom styling - golden', (WidgetTester tester) async {
      const dimensions = GridDimensions(columns: 3, rows: 3);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: GridWidget(
                  dimensions: dimensions,
                  gridLineColor: Colors.blue.shade200,
                  gridLineWidth: 2.0,
                  backgroundColor: Colors.blue.shade50,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ),
      );
      
      await expectLater(
        find.byType(GridWidget),
        matchesGoldenFile('goldens/grid_widget_custom.png'),
      );
    });
  });
}