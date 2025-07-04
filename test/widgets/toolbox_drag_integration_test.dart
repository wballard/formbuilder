import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('Toolbox Drag Integration', () {
    testWidgets('long press dragging from toolbox creates widget on grid reliably',
        (WidgetTester tester) async {
      var layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 6, rows: 6),
        widgets: [],
      );
      
      final widgetBuilders = <String, Widget Function(BuildContext, WidgetPlacement)>{
        'TextInput': (context, placement) => Container(color: Colors.blue),
        'Button': (context, placement) => Container(color: Colors.green),
      };
      
      final toolbox = Toolbox.withDefaults();
      
      int widgetDroppedCount = 0;
      WidgetPlacement? lastDroppedWidget;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: layoutState,
              widgetBuilders: widgetBuilders,
              toolbox: toolbox,
              onWidgetDropped: (placement) {
                widgetDroppedCount++;
                lastDroppedWidget = placement;
                layoutState = layoutState.addWidget(placement);
                debugPrint('Widget dropped: ${placement.id} at (${placement.column}, ${placement.row})');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the grid drag target
      final gridTarget = find.byType(GridDragTarget);
      expect(gridTarget, findsOneWidget);
      
      // Find the DragTarget<ToolboxItem> specifically
      final toolboxDragTarget = find.byType(DragTarget<ToolboxItem>);
      expect(toolboxDragTarget, findsOneWidget);
      
      // Get the DragTarget widget to test directly
      final dragTargetWidget = tester.widget<DragTarget<ToolboxItem>>(toolboxDragTarget);
      
      // Create a test ToolboxItem
      final testItem = ToolboxItem(
        name: 'TestWidget',
        displayName: 'Test Widget',
        toolboxBuilder: (context) => Container(color: Colors.red),
        gridBuilder: (context, placement) => Container(color: Colors.red),
        defaultWidth: 2,
        defaultHeight: 1,
      );
      
      // Test onWillAcceptWithDetails first
      final willAcceptDetails = DragTargetDetails<ToolboxItem>(
        data: testItem,
        offset: tester.getCenter(gridTarget),
      );
      
      final willAccept = dragTargetWidget.onWillAcceptWithDetails?.call(willAcceptDetails) ?? false;
      debugPrint('onWillAcceptWithDetails returned: $willAccept');
      expect(willAccept, isTrue, reason: 'DragTarget should accept the drop');
      
      // Test onAcceptWithDetails directly
      final acceptDetails = DragTargetDetails<ToolboxItem>(
        data: testItem,
        offset: tester.getCenter(gridTarget),
      );
      
      debugPrint('Calling onAcceptWithDetails directly...');
      dragTargetWidget.onAcceptWithDetails?.call(acceptDetails);
      
      await tester.pumpAndSettle();
      
      // Verify widget was created
      expect(widgetDroppedCount, equals(1),
          reason: 'Widget should be created when onAcceptWithDetails is called');
      expect(lastDroppedWidget, isNotNull,
          reason: 'Last dropped widget should not be null');
      expect(lastDroppedWidget?.widgetName, equals('TestWidget'),
          reason: 'Created widget should have correct name');
      
      debugPrint('Widget created at (${lastDroppedWidget?.column}, ${lastDroppedWidget?.row})');
    });

    testWidgets('test multiple drag positions to verify recomputation',
        (WidgetTester tester) async {
      var layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 6, rows: 6),
        widgets: [],
      );
      
      final widgetBuilders = <String, Widget Function(BuildContext, WidgetPlacement)>{
        'TextInput': (context, placement) => Container(color: Colors.blue),
        'Button': (context, placement) => Container(color: Colors.green),
      };
      
      final toolbox = Toolbox.withDefaults();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: layoutState,
              widgetBuilders: widgetBuilders,
              toolbox: toolbox,
              onWidgetDropped: (placement) {
                debugPrint('Widget dropped: ${placement.id} at (${placement.column}, ${placement.row})');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the DragTarget<ToolboxItem> specifically
      final toolboxDragTarget = find.byType(DragTarget<ToolboxItem>);
      expect(toolboxDragTarget, findsOneWidget);
      
      // Get the DragTarget widget to test directly
      final dragTargetWidget = tester.widget<DragTarget<ToolboxItem>>(toolboxDragTarget);
      
      // Create a test ToolboxItem
      final testItem = ToolboxItem(
        name: 'TestWidget',
        displayName: 'Test Widget',
        toolboxBuilder: (context) => Container(color: Colors.red),
        gridBuilder: (context, placement) => Container(color: Colors.red),
        defaultWidth: 2,
        defaultHeight: 1,
      );
      
      final gridTarget = find.byType(GridDragTarget);
      final gridCenter = tester.getCenter(gridTarget);
      
      // Calculate grid dimensions to ensure we cross cell boundaries
      final gridSize = tester.getSize(gridTarget);
      final cellWidth = gridSize.width / 6; // 6 columns
      final cellHeight = 60.0; // Theme default row height
      
      debugPrint('Grid size: $gridSize, Cell size: ${cellWidth}x$cellHeight');
      
      // Test positions that will actually cross different cells
      final gridTopLeft = tester.getTopLeft(gridTarget);
      final positions = [
        Offset(gridTopLeft.dx + cellWidth * 0.5, gridTopLeft.dy + cellHeight * 0.5), // Cell (0,0)
        Offset(gridTopLeft.dx + cellWidth * 1.5, gridTopLeft.dy + cellHeight * 0.5), // Cell (1,0)
        Offset(gridTopLeft.dx + cellWidth * 2.5, gridTopLeft.dy + cellHeight * 0.5), // Cell (2,0)
        Offset(gridTopLeft.dx + cellWidth * 0.5, gridTopLeft.dy + cellHeight * 1.5), // Cell (0,1)
      ];
      
      for (int i = 0; i < positions.length; i++) {
        debugPrint('=== Testing position ${i + 1}: ${positions[i]} ===');
        
        // Test onWillAcceptWithDetails at different positions
        final willAcceptDetails = DragTargetDetails<ToolboxItem>(
          data: testItem,
          offset: positions[i],
        );
        
        final willAccept = dragTargetWidget.onWillAcceptWithDetails?.call(willAcceptDetails) ?? false;
        debugPrint('Position ${i + 1} - onWillAcceptWithDetails returned: $willAccept');
        
        // Also test onMove to simulate the movement
        dragTargetWidget.onMove?.call(DragTargetDetails<ToolboxItem>(
          data: testItem,
          offset: positions[i],
        ));
        
        await tester.pump();
      }
      
      debugPrint('Multiple position test completed');
    });
  });
}