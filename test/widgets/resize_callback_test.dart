import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  group('Resize Callback Connection', () {
    testWidgets('resize callbacks flow through widget hierarchy', 
        (WidgetTester tester) async {
      ResizeData? capturedStartData;
      ResizeData? capturedUpdateData;
      Offset? capturedUpdateDelta;
      bool endCalled = false;

      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 3),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TestWidget',
            column: 1,
            row: 1,
            width: 2,
            height: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: layoutState,
              widgetBuilders: {
                'TestWidget': (_, __) => Container(
                  color: Colors.blue,
                  child: const Center(child: Text('Test')),
                ),
              },
              selectedWidgetId: 'widget1',
              onWidgetResizeStart: (data) {
                capturedStartData = data;
              },
              onWidgetResizeUpdate: (data, delta) {
                capturedUpdateData = data;
                capturedUpdateDelta = delta;
              },
              onWidgetResizeEnd: () {
                endCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Find resize handles
      final handleFinder = find.byType(ResizeHandle);
      expect(handleFinder, findsWidgets);
      
      // Should find 8 handles for a selected widget
      expect(handleFinder, findsNWidgets(8));

      // Get the first handle widget
      final handle = tester.widget<ResizeHandle>(handleFinder.first);
      
      // Verify callbacks are wired
      expect(handle.onResizeStart, isNotNull);
      expect(handle.onResizeUpdate, isNotNull);
      expect(handle.onResizeEnd, isNotNull);

      // Simulate callbacks being called
      handle.onResizeStart?.call(ResizeData(
        widgetId: 'widget1',
        handleType: ResizeHandleType.bottomRight,
        startPlacement: layoutState.widgets.first,
      ));

      expect(capturedStartData, isNotNull);
      expect(capturedStartData!.widgetId, equals('widget1'));

      handle.onResizeUpdate?.call(
        ResizeData(
          widgetId: 'widget1',
          handleType: ResizeHandleType.bottomRight,
          startPlacement: layoutState.widgets.first,
        ),
        const Offset(10, 10),
      );

      expect(capturedUpdateData, isNotNull);
      expect(capturedUpdateDelta, equals(const Offset(10, 10)));

      handle.onResizeEnd?.call();
      expect(endCalled, isTrue);
    });

    testWidgets('resize handles not shown when widget not selected', 
        (WidgetTester tester) async {
      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 3),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TestWidget',
            column: 1,
            row: 1,
            width: 2,
            height: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: layoutState,
              widgetBuilders: {
                'TestWidget': (_, __) => Container(color: Colors.blue),
              },
              selectedWidgetId: null, // No widget selected
            ),
          ),
        ),
      );

      await tester.pump();

      // No resize handles should be shown
      expect(find.byType(ResizeHandle), findsNothing);
    });
  });
}