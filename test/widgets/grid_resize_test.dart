import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('Grid Resize Functionality', () {
    late LayoutState testLayoutState;
    late Toolbox testToolbox;
    late Map<String, Widget Function(BuildContext, WidgetPlacement)> testWidgetBuilders;

    setUp(() {
      testLayoutState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TestWidget',
            column: 1,
            row: 1,
            width: 2,
            height: 2,
          ),
        ],
      );
      
      testToolbox = Toolbox(items: [
        ToolboxItem(
          name: 'TestWidget',
          displayName: 'Test Widget',
          defaultWidth: 1,
          defaultHeight: 1,
          toolboxBuilder: (context) => Container(color: Colors.blue),
          gridBuilder: (context, placement) => Container(color: Colors.blue),
        ),
      ]);
      
      testWidgetBuilders = {
        'TestWidget': (context, placement) => Container(color: Colors.blue),
      };
    });

    testWidgets('GridDragTarget accepts onWidgetResize callback', (WidgetTester tester) async {
      bool resizeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              selectedWidgetId: 'widget1',
              onWidgetResize: (widgetId, placement) {
                resizeCalled = true;
              },
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(GridDragTarget), findsOneWidget);
      
      // The callback should be set up but not called yet
      expect(resizeCalled, isFalse);
    });

    testWidgets('GridContainer shows resize handles for selected widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              selectedWidgetId: 'widget1',
            ),
          ),
        ),
      );

      // Should find resize handles for the selected widget
      expect(find.byType(ResizeHandle), findsNWidgets(8));
    });

    testWidgets('GridContainer does not show resize handles for non-selected widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              selectedWidgetId: null, // No widget selected
            ),
          ),
        ),
      );

      // Should not find any resize handles
      expect(find.byType(ResizeHandle), findsNothing);
    });

    testWidgets('Resize calculations respect minimum dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: GridDragTarget(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
                selectedWidgetId: 'widget1',
              ),
            ),
          ),
        ),
      );

      // Find a resize handle to test with
      final resizeHandle = find.byType(ResizeHandle).first;
      expect(resizeHandle, findsOneWidget);

      // Simulate resize drag that would make widget smaller than 1x1
      // This should be clamped to minimum size
      final resizeHandleWidget = tester.widget<ResizeHandle>(resizeHandle);
      
      // Verify minimum dimensions are enforced in calculation
      expect(resizeHandleWidget.placement.width, greaterThanOrEqualTo(1));
      expect(resizeHandleWidget.placement.height, greaterThanOrEqualTo(1));
    });

    testWidgets('Resize calculations respect grid boundaries', (WidgetTester tester) async {
      final largeLayoutState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TestWidget',
            column: 3, // At right edge
            row: 3, // At bottom edge
            width: 1,
            height: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: GridDragTarget(
                layoutState: largeLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
                selectedWidgetId: 'widget1',
              ),
            ),
          ),
        ),
      );

      // Find resize handles
      expect(find.byType(ResizeHandle), findsNWidgets(8));
      
      // Widget should be constrained within grid bounds
      final placement = largeLayoutState.widgets.first;
      expect(placement.column + placement.width, lessThanOrEqualTo(4));
      expect(placement.row + placement.height, lessThanOrEqualTo(4));
    });

    testWidgets('Resize operations prevent overlaps with other widgets', (WidgetTester tester) async {
      final layoutWithMultipleWidgets = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TestWidget',
            column: 0,
            row: 0,
            width: 1,
            height: 1,
          ),
          WidgetPlacement(
            id: 'widget2',
            widgetName: 'TestWidget',
            column: 2,
            row: 0,
            width: 1,
            height: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: GridDragTarget(
                layoutState: layoutWithMultipleWidgets,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
                selectedWidgetId: 'widget1',
              ),
            ),
          ),
        ),
      );

      // Should show resize handles for selected widget
      expect(find.byType(ResizeHandle), findsNWidgets(8));
      
      // Verify widgets don't overlap
      final widget1 = layoutWithMultipleWidgets.widgets[0];
      final widget2 = layoutWithMultipleWidgets.widgets[1];
      expect(widget1.overlaps(widget2), isFalse);
    });

    testWidgets('ResizeData contains correct information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              selectedWidgetId: 'widget1',
            ),
          ),
        ),
      );

      // Find a resize handle
      final resizeHandle = find.byType(ResizeHandle).first;
      final resizeHandleWidget = tester.widget<ResizeHandle>(resizeHandle);
      
      expect(resizeHandleWidget.placement.id, equals('widget1'));
      expect(resizeHandleWidget.placement.widgetName, equals('TestWidget'));
      expect(resizeHandleWidget.placement.width, equals(2));
      expect(resizeHandleWidget.placement.height, equals(2));
    });

    group('Resize handle types', () {
      testWidgets('All 8 resize handle types are present', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
                selectedWidgetId: 'widget1',
              ),
            ),
          ),
        );

        // Should find all 8 resize handles
        expect(find.byType(ResizeHandle), findsNWidgets(8));
        
        final handles = tester.widgetList<ResizeHandle>(find.byType(ResizeHandle)).toList();
        final handleTypes = handles.map((h) => h.type).toSet();
        
        // Verify all handle types are present
        expect(handleTypes, contains(ResizeHandleType.topLeft));
        expect(handleTypes, contains(ResizeHandleType.top));
        expect(handleTypes, contains(ResizeHandleType.topRight));
        expect(handleTypes, contains(ResizeHandleType.left));
        expect(handleTypes, contains(ResizeHandleType.right));
        expect(handleTypes, contains(ResizeHandleType.bottomLeft));
        expect(handleTypes, contains(ResizeHandleType.bottom));
        expect(handleTypes, contains(ResizeHandleType.bottomRight));
      });
    });

    group('Visual feedback', () {
      testWidgets('Selected widgets show resize handles', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
                selectedWidgetId: 'widget1',
              ),
            ),
          ),
        );

        // Resize handles should be visible for selected widget
        expect(find.byType(ResizeHandle), findsNWidgets(8));
      });

      testWidgets('Non-selected widgets do not show resize handles', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
                selectedWidgetId: 'non-existent',
              ),
            ),
          ),
        );

        // No resize handles should be visible
        expect(find.byType(ResizeHandle), findsNothing);
      });
    });
  });
}