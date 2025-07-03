import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

void main() {
  group('Grid Coordinate Calculation', () {
    testWidgets('grid coordinates should be based on actual grid height not container height', 
        (WidgetTester tester) async {
      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              height: 600, // Container is taller than grid
              color: Colors.grey[100],
              child: GridDragTarget(
                layoutState: layoutState,
                widgetBuilders: const {},
                toolbox: Toolbox(items: const []),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Get the GridDragTarget's render box
      final gridDragTargetFinder = find.byType(GridDragTarget);
      final renderBox = tester.renderObject(gridDragTargetFinder) as RenderBox;
      
      // Get theme to calculate expected grid height
      final context = tester.element(gridDragTargetFinder);
      final theme = FormLayoutTheme.of(context);
      
      // Calculate expected grid height
      final expectedGridHeight = layoutState.dimensions.rows * theme.rowHeight;
      final containerHeight = renderBox.size.height;
      
      print('Container height: $containerHeight');
      print('Expected grid height: $expectedGridHeight (${layoutState.dimensions.rows} rows × ${theme.rowHeight}px)');
      print('Row height: ${theme.rowHeight}px');
      
      // The grid should have intrinsic height, not fill the container
      expect(expectedGridHeight, equals(4 * 56.0)); // 4 rows × 56px
      expect(expectedGridHeight, lessThan(containerHeight)); // Grid smaller than container
      
      // Find the inner GridContainer
      final gridContainerFinder = find.byType(GridContainer);
      expect(gridContainerFinder, findsOneWidget);
      
      final gridContainerBox = tester.renderObject(gridContainerFinder) as RenderBox;
      print('GridContainer actual height: ${gridContainerBox.size.height}');
      
      // GridContainer should have the intrinsic height
      expect(gridContainerBox.size.height, equals(expectedGridHeight));
    });

    testWidgets('resize handles should appear on widgets in all rows', 
        (WidgetTester tester) async {
      // Create widgets in different rows
      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: [
          WidgetPlacement(
            id: 'row0',
            widgetName: 'TestWidget',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: 'row2',
            widgetName: 'TestWidget',
            column: 0,
            row: 2,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: 'row3',
            widgetName: 'TestWidget',
            column: 2,
            row: 3,
            width: 2,
            height: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              height: 600,
              child: GridDragTarget(
                layoutState: layoutState,
                widgetBuilders: {
                  'TestWidget': (context, placement) => Container(
                    color: Colors.blue.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        'Row ${placement.row}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                },
                toolbox: Toolbox(items: const []),
                selectedWidgetId: 'row2', // Select widget in row 2
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find resize handles for the selected widget
      final resizeHandles = find.byType(ResizeHandle);
      expect(resizeHandles, findsWidgets);
      expect(resizeHandles, findsNWidgets(8)); // 8 handles for selected widget
      
      // Verify the widget in row 2 is actually selected and showing handles
      final row2Text = find.text('Row 2');
      expect(row2Text, findsOneWidget);
    });
  });
}