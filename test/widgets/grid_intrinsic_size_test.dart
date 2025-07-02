import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

void main() {
  group('Grid Intrinsic Size', () {
    testWidgets('GridWidget should size to content height, not expand',
        (WidgetTester tester) async {
      // Create a grid without constraining container
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  color: Colors.blue.shade100,
                  padding: const EdgeInsets.all(16),
                  child: const Text('Content before grid'),
                ),
                // Grid should size to its content
                Container(
                  color: Colors.red.shade100,
                  child: GridWidget(
                    dimensions: const GridDimensions(columns: 2, rows: 3),
                    gridLineColor: Colors.blue,
                  ),
                ),
                Container(
                  color: Colors.green.shade100,
                  padding: const EdgeInsets.all(16),
                  child: const Text('Content after grid'),
                ),
                const Spacer(), // This should take remaining space, not the grid
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
      print('GridWidget size in Column: ${gridBox.size}');
      
      // Get theme
      final context = tester.element(gridFinder);
      final theme = FormLayoutTheme.of(context);
      
      // Calculate expected height
      final expectedInnerHeight = 3 * theme.rowHeight; // 168px
      // Include padding and default border width (1.0 * 2)
      final expectedTotalHeight = expectedInnerHeight + theme.defaultPadding.vertical + 2.0;
      
      print('Expected height: $expectedTotalHeight');
      
      // Grid should have intrinsic height, not expand
      expect(gridBox.size.height, closeTo(expectedTotalHeight, 1.0),
          reason: 'Grid should size to content (3 rows × 56px + padding)');
    });

    testWidgets('GridWidget in Expanded should still have fixed row heights',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Header'),
                Expanded(
                  child: Container(
                    color: Colors.grey.shade200,
                    child: GridWidget(
                      dimensions: const GridDimensions(columns: 2, rows: 3),
                      gridLineColor: Colors.blue,
                    ),
                  ),
                ),
                const Text('Footer'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check individual cell heights
      final allContainers = find.byType(Container);
      final cells = <RenderBox>[];
      
      for (final element in allContainers.evaluate()) {
        final widget = element.widget as Container;
        if (widget.decoration is BoxDecoration) {
          final renderBox = element.renderObject as RenderBox;
          final size = renderBox.size;
          
          // Only track actual grid cells (not outer containers)
          if (size.width < 300 && size.height < 100 && size.height > 0) {
            cells.add(renderBox);
          }
        }
      }
      
      print('Found ${cells.length} grid cells');
      
      // Each cell should still have fixed height even in Expanded
      for (final cell in cells) {
        print('Cell size: ${cell.size}');
        expect(cell.size.height, closeTo(56.0, 1.0),
            reason: 'Cells should maintain fixed height even in Expanded');
      }
    });

    testWidgets('GridWidget with explicit height constraint',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                width: 400,
                height: 400,
                color: Colors.grey.shade300,
                alignment: Alignment.topCenter,
                child: GridWidget(
                  dimensions: const GridDimensions(columns: 2, rows: 3),
                  backgroundColor: Colors.white,
                  gridLineColor: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final gridFinder = find.byType(GridWidget);
      final RenderBox gridBox = tester.renderObject(gridFinder);
      
      print('Grid in 400x400 container - size: ${gridBox.size}');
      
      // Grid should NOT fill the 400px height
      expect(gridBox.size.height, lessThan(300),
          reason: 'Grid should not expand to fill container height');
    });
  });
}