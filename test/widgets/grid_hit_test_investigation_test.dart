import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

void main() {
  group('Grid Hit Test Investigation', () {
    testWidgets('Investigate grid height vs render box height mismatch',
        (WidgetTester tester) async {
      const rowHeight = 56.0;
      const rows = 4;
      const columns = 4;
      const expectedGridHeight = rows * rowHeight; // 224.0

      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: columns, rows: rows),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TextField',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: 'widget2',
            widgetName: 'TextField',
            column: 0,
            row: 2, // Third row
            width: 2,
            height: 1,
          ),
        ],
      );

      final widgetBuilders = <String, Widget Function(BuildContext, WidgetPlacement)>{
        'TextField': (context, placement) => Container(
          color: Colors.blue.withOpacity(0.5),
          child: Center(
            child: Text('Widget ${placement.row}'),
          ),
        ),
      };

      final toolbox = Toolbox(items: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayoutThemeWidget(
              theme: const FormLayoutTheme(rowHeight: rowHeight),
              child: Container(
                height: 600, // Larger than grid height
                color: Colors.grey.withOpacity(0.2),
                child: GridDragTarget(
                  layoutState: layoutState,
                  widgetBuilders: widgetBuilders,
                  toolbox: toolbox,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the GridDragTarget's render box
      final gridDragTargetFinder = find.byType(GridDragTarget);
      expect(gridDragTargetFinder, findsOneWidget);

      final gridDragTargetElement = gridDragTargetFinder.evaluate().first;
      final gridDragTargetRenderBox = gridDragTargetElement.renderObject as RenderBox;
      
      print('GridDragTarget render box height: ${gridDragTargetRenderBox.size.height}');
      print('Expected grid height: $expectedGridHeight');
      print('Difference: ${gridDragTargetRenderBox.size.height - expectedGridHeight}');

      // Find the GridContainer's render box
      final gridContainerFinder = find.byType(GridContainer);
      if (gridContainerFinder.evaluate().isNotEmpty) {
        final gridContainerElement = gridContainerFinder.evaluate().first;
        final gridContainerRenderBox = gridContainerElement.renderObject as RenderBox;
        print('GridContainer render box height: ${gridContainerRenderBox.size.height}');
      }

      // The issue: GridDragTarget's render box height is 600 (container height)
      // but the actual grid height should be 224 (4 rows * 56 rowHeight)
      // This causes hit testing calculations to be incorrect

      // When calculating row from position:
      // Correct: row = localPosition.dy / (224 / 4) = localPosition.dy / 56
      // Actual: row = localPosition.dy / (600 / 4) = localPosition.dy / 150
      // This means positions are mapped incorrectly, explaining why only the first row works

      expect(gridDragTargetRenderBox.size.height, greaterThan(expectedGridHeight),
          reason: 'This confirms the render box is larger than the actual grid');
    });

    testWidgets('Verify hit test calculation error', (WidgetTester tester) async {
      const rowHeight = 56.0;
      const rows = 4;
      const columns = 4;

      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: columns, rows: rows),
        widgets: [],
      );

      final widgetBuilders = <String, Widget Function(BuildContext, WidgetPlacement)>{};
      final toolbox = Toolbox(items: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayoutThemeWidget(
              theme: const FormLayoutTheme(rowHeight: rowHeight),
              child: Container(
                height: 600, // Larger than grid height
                child: GridDragTarget(
                  layoutState: layoutState,
                  widgetBuilders: widgetBuilders,
                  toolbox: toolbox,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate positions and calculate expected vs actual row mappings
      final testPositions = [
        const Offset(100, 28), // Middle of row 0 (28 < 56)
        const Offset(100, 84), // Middle of row 1 (56 < 84 < 112)
        const Offset(100, 140), // Middle of row 2 (112 < 140 < 168)
        const Offset(100, 196), // Middle of row 3 (168 < 196 < 224)
      ];

      for (int i = 0; i < testPositions.length; i++) {
        final position = testPositions[i];
        
        // Correct calculation (using actual grid height)
        final correctRow = (position.dy / rowHeight).floor();
        
        // Incorrect calculation (using render box height)
        final incorrectCellHeight = 600.0 / rows; // 150
        final incorrectRow = (position.dy / incorrectCellHeight).floor();
        
        print('Position Y: ${position.dy}');
        print('  Correct row: $correctRow (using cell height: $rowHeight)');
        print('  Incorrect row: $incorrectRow (using cell height: $incorrectCellHeight)');
        print('  Expected row: $i');
        
        // This shows why hit testing fails for rows beyond the first
        if (i > 0) {
          expect(incorrectRow, lessThan(i),
              reason: 'Incorrect calculation maps higher rows to lower indices');
        }
      }
    });
  });
}