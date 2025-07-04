import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

void main() {
  group('Grid Cell Dimensions', () {
    testWidgets('GridWidget in 400x400 box with 2x4 grid should have fixed row heights',
        (WidgetTester tester) async {
      // Create a 2x4 grid in a 400x400 box
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
                alignment: Alignment.topCenter,
                child: GridWidget(
                  dimensions: const GridDimensions(columns: 2, rows: 4),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get the GridWidget's render object
      final gridFinder = find.byType(GridWidget);
      expect(gridFinder, findsOneWidget);

      // Get the actual size of the grid
      final RenderBox gridBox = tester.renderObject(gridFinder);
      print('GridWidget actual size: ${gridBox.size}');

      // With fixed row heights of 56px each:
      // - 4 rows × 56px = 224px total height
      // - Grid should NOT expand to fill 400px
      
      // Get the theme to check row height
      final context = tester.element(gridFinder);
      final theme = FormLayoutTheme.of(context);
      print('Theme row height: ${theme.rowHeight}');
      
      // Expected dimensions:
      // - Width: Should fill container width (400px minus padding)
      // - Height: Should be 4 × 56px = 224px (plus padding)
      
      // Account for default padding (8px on all sides) and border width (2px on all sides)
      final expectedInnerHeight = 4 * theme.rowHeight; // 224px
      final gridWidget = tester.widget<GridWidget>(gridFinder);
      final borderWidth = gridWidget.gridLineWidth * 2; // Top and bottom borders
      final expectedTotalHeight = expectedInnerHeight + theme.defaultPadding.vertical + borderWidth;
      
      print('Expected inner height: $expectedInnerHeight');
      print('Expected total height with padding: $expectedTotalHeight');
      
      // The grid should NOT fill the entire 400px container
      expect(gridBox.size.height, lessThan(400),
          reason: 'Grid should not expand to fill container');
      
      // The grid height should be based on row count × row height
      expect(gridBox.size.height, closeTo(expectedTotalHeight, 1.0),
          reason: 'Grid height should be rows × rowHeight + padding');
    });

    testWidgets('GridWidget cells should have proportional heights', 
        (WidgetTester tester) async {
      // Create a simple 2x2 grid for easier cell inspection
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                width: 300,
                height: 300,
                color: Colors.grey.shade200,
                child: GridWidget(
                  dimensions: const GridDimensions(columns: 2, rows: 2),
                  gridLineColor: Colors.blue,
                  gridLineWidth: 2.0,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all the grid cells by looking for containers with decorations
      final allContainers = find.byType(Container);
      final cellContainers = <Element>[];
      
      for (final element in allContainers.evaluate()) {
        final widget = element.widget as Container;
        if (widget.decoration is BoxDecoration) {
          cellContainers.add(element);
        }
      }

      print('Found ${cellContainers.length} potential grid cells');

      // Get the theme
      final gridFinder = find.byType(GridWidget);
      final context = tester.element(gridFinder);
      final theme = FormLayoutTheme.of(context);

      // GridWidget uses fractional sizing to fill available space
      // In a 300x300 container with 2x2 grid, each cell should be approximately 140x140
      // (accounting for borders and padding)
      int cellCount = 0;
      for (final element in cellContainers) {
        final RenderBox cellBox = element.renderObject as RenderBox;
        final size = cellBox.size;
        
        // Skip if this is the outer container or padding container
        if (size.width > 250 || size.height > 250) continue;
        
        cellCount++;
        print('Cell $cellCount size: $size');
        
        // Each cell should be approximately square in a 2x2 grid within 300x300 container
        // Expect cells to be around 140x140 (fill available space evenly)
        if (size.height > 0) {  // Skip empty decoration containers
          expect(size.height, greaterThan(100),
              reason: 'Cell $cellCount should fill proportional space in grid');
          expect(size.height, lessThan(160),
              reason: 'Cell $cellCount should not exceed reasonable bounds');
        }
      }
    });

    testWidgets('Compare grid with fractional vs fixed sizing',
        (WidgetTester tester) async {
      // Test both scenarios side by side
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                // Left: Grid that should use fixed heights
                Expanded(
                  child: Container(
                    height: 500,
                    color: Colors.blue.shade50,
                    child: Column(
                      children: [
                        const Text('Fixed Heights (Current)'),
                        GridWidget(
                          dimensions: const GridDimensions(columns: 2, rows: 3),
                          gridLineColor: Colors.blue,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(),
                // Right: Reference box showing expected size
                Expanded(
                  child: Container(
                    height: 500,
                    color: Colors.green.shade50,
                    child: Column(
                      children: [
                        const Text('Expected Size Reference'),
                        Container(
                          height: 3 * 56.0 + 16, // 3 rows + padding
                          color: Colors.green.shade200,
                          child: const Center(
                            child: Text('3 × 56px = 168px\n+ 16px padding\n= 184px total'),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the GridWidget
      final gridFinder = find.byType(GridWidget);
      expect(gridFinder, findsOneWidget);

      final RenderBox gridBox = tester.renderObject(gridFinder);
      print('Grid in Expanded - size: ${gridBox.size}');

      // The grid should NOT fill the Expanded height
      expect(gridBox.size.height, lessThan(450),
          reason: 'Grid should not expand to fill Expanded widget');
    });
  });
}