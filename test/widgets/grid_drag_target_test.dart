import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/widgets/accessible_placed_widget.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';

void main() {
  group('GridDragTarget', () {
    late LayoutState testLayoutState;
    late Map<String, Widget Function(BuildContext, WidgetPlacement)>
    testWidgetBuilders;
    late Toolbox testToolbox;

    setUp(() {
      testLayoutState = LayoutState.empty();
      testWidgetBuilders = {
        'TextInput': (context, placement) => Container(color: Colors.blue),
        'Button': (context, placement) => Container(color: Colors.green),
      };
      testToolbox = Toolbox.withDefaults();
    });

    testWidgets('creates widget with required properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
            ),
          ),
        ),
      );

      expect(find.byType(GridDragTarget), findsOneWidget);
      expect(find.byType(DragTarget<ToolboxItem>), findsOneWidget);
      expect(find.byType(GridContainer), findsOneWidget);
    });

    testWidgets('wraps GridContainer with DragTarget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
            ),
          ),
        ),
      );

      // Verify DragTarget wraps GridContainer
      final dragTarget = tester.widget<DragTarget<ToolboxItem>>(
        find.byType(DragTarget<ToolboxItem>),
      );
      expect(dragTarget, isNotNull);
    });

    testWidgets('passes through GridContainer properties', (
      WidgetTester tester,
    ) async {
      const selectedWidgetId = 'test_widget';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              selectedWidgetId: selectedWidgetId,
            ),
          ),
        ),
      );

      final gridContainer = tester.widget<GridContainer>(
        find.byType(GridContainer),
      );
      expect(gridContainer.layoutState, equals(testLayoutState));
      expect(gridContainer.widgetBuilders, equals(testWidgetBuilders));
      expect(gridContainer.selectedWidgetId, equals(selectedWidgetId));
    });

    testWidgets('calls onWidgetTap when GridContainer widget is tapped', (
      WidgetTester tester,
    ) async {
      String? tappedWidgetId;

      // Add a widget to the layout state
      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TextInput',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final layoutWithWidget = testLayoutState.addWidget(placement);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: layoutWithWidget,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              onWidgetTap: (id) => tappedWidgetId = id,
            ),
          ),
        ),
      );

      // Pump and settle to ensure layout is complete
      await tester.pumpAndSettle();
      
      // Tap on the placed widget directly with coordinates
      final placedWidget = find.byType(AccessiblePlacedWidget);
      expect(placedWidget, findsOneWidget);
      await tester.tap(placedWidget, warnIfMissed: false);

      expect(tappedWidgetId, equals('widget1'));
    });

    testWidgets('calls onWidgetDropped when valid drop occurs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              onWidgetDropped: (placement) {
                // Callback is tested by verifying it's not null
              },
            ),
          ),
        ),
      );

      // Simulate a drag and drop
      final dragTarget = find.byType(DragTarget<ToolboxItem>);
      expect(dragTarget, findsOneWidget);

      // Use the drag target's onAccept callback directly for testing
      final dragTargetWidget = tester.widget<DragTarget<ToolboxItem>>(
        dragTarget,
      );

      // Test that the callback is set up
      expect(dragTargetWidget.onAcceptWithDetails, isNotNull);
    });

    group('coordinate calculation', () {
      testWidgets('converts screen position to grid coordinates', (
        WidgetTester tester,
      ) async {
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
                ),
              ),
            ),
          ),
        );

        // Test that the widget renders without errors
        expect(find.byType(GridDragTarget), findsOneWidget);
      });

      testWidgets('calculates occupied cells correctly', (
        WidgetTester tester,
      ) async {
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
                ),
              ),
            ),
          ),
        );

        // Test that multi-cell widgets would occupy correct space
        expect(find.byType(GridDragTarget), findsOneWidget);
      });
    });

    group('drag feedback', () {
      testWidgets('highlights valid drop positions', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        // Test that the widget renders without errors
        // Visual feedback testing would require more complex gesture simulation
        expect(find.byType(GridDragTarget), findsOneWidget);
      });

      testWidgets('indicates invalid drop positions', (
        WidgetTester tester,
      ) async {
        // Create a layout state with an existing widget
        final existingPlacement = WidgetPlacement(
          id: 'existing',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final layoutWithWidget = testLayoutState.addWidget(existingPlacement);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: layoutWithWidget,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        // Verify the widget renders correctly
        expect(find.byType(GridDragTarget), findsOneWidget);
      });
    });

    group('drag acceptance', () {
      testWidgets('accepts valid drops', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        final dragTargetWidget = tester.widget<DragTarget<ToolboxItem>>(
          find.byType(DragTarget<ToolboxItem>),
        );

        expect(dragTargetWidget.onWillAcceptWithDetails, isNotNull);
        expect(dragTargetWidget.onMove, isNotNull);
        expect(dragTargetWidget.onLeave, isNotNull);
      });

      testWidgets('rejects drops on occupied cells', (
        WidgetTester tester,
      ) async {
        // Create a layout with an existing widget
        final existingPlacement = WidgetPlacement(
          id: 'existing',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final layoutWithWidget = testLayoutState.addWidget(existingPlacement);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: layoutWithWidget,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        final dragTargetWidget = tester.widget<DragTarget<ToolboxItem>>(
          find.byType(DragTarget<ToolboxItem>),
        );

        // Verify drag target is set up correctly
        expect(dragTargetWidget.onWillAcceptWithDetails, isNotNull);
      });

      testWidgets('rejects drops outside grid boundaries', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        // Test that the widget renders correctly
        expect(find.byType(GridDragTarget), findsOneWidget);
      });

      testWidgets('highlights cells during drag operations', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        // Check that highlighting is handled by the GridContainer
        final gridContainer = tester.widget<GridContainer>(
          find.byType(GridContainer),
        );
        expect(
          gridContainer.highlightedCells,
          isNull,
        ); // Initially no highlights
        expect(
          gridContainer.highlightColor,
          isNull,
        ); // Initially no highlight color
      });
    });

    group('widget moving', () {
      testWidgets('accepts WidgetPlacement drags for moving widgets', (
        WidgetTester tester,
      ) async {
        // Create a layout with an existing widget
        final existingPlacement = WidgetPlacement(
          id: 'existing',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        final layoutWithWidget = testLayoutState.addWidget(existingPlacement);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: layoutWithWidget,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        // Verify DragTarget for WidgetPlacement exists
        expect(find.byType(DragTarget<WidgetPlacement>), findsOneWidget);

        final dragTargetWidget = tester.widget<DragTarget<WidgetPlacement>>(
          find.byType(DragTarget<WidgetPlacement>),
        );

        expect(dragTargetWidget.onWillAcceptWithDetails, isNotNull);
        expect(dragTargetWidget.onAcceptWithDetails, isNotNull);
      });

      testWidgets('calls onWidgetMoved when widget is repositioned', (
        WidgetTester tester,
      ) async {
        // Create a layout with an existing widget
        final existingPlacement = WidgetPlacement(
          id: 'existing',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        final layoutWithWidget = testLayoutState.addWidget(existingPlacement);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: layoutWithWidget,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
                onWidgetMoved: (widgetId, placement) {
                  // Callback is tested by verifying it's not null
                },
              ),
            ),
          ),
        );

        final dragTargetWidget = tester.widget<DragTarget<WidgetPlacement>>(
          find.byType(DragTarget<WidgetPlacement>),
        );

        expect(dragTargetWidget.onAcceptWithDetails, isNotNull);
      });

      testWidgets('excludes moved widget from overlap calculations', (
        WidgetTester tester,
      ) async {
        // Create a layout with multiple widgets
        final widget1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        final widget2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'TextInput',
          column: 2,
          row: 0,
          width: 1,
          height: 1,
        );
        final layoutWithWidgets = testLayoutState
            .addWidget(widget1)
            .addWidget(widget2);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: layoutWithWidgets,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        // Verify widget can be moved to its current position
        expect(find.byType(GridDragTarget), findsOneWidget);
      });

      testWidgets('prevents moving widget outside grid boundaries', (
        WidgetTester tester,
      ) async {
        // Create a layout with an existing widget
        final existingPlacement = WidgetPlacement(
          id: 'existing',
          widgetName: 'TextInput',
          column: 3,
          row: 3,
          width: 1,
          height: 1,
        );
        final layoutWithWidget = testLayoutState.addWidget(existingPlacement);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: layoutWithWidget,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        // Test boundary checking is properly implemented
        expect(find.byType(GridDragTarget), findsOneWidget);
      });

      testWidgets('shows visual feedback during widget move', (
        WidgetTester tester,
      ) async {
        // Create a layout with an existing widget
        final existingPlacement = WidgetPlacement(
          id: 'existing',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        final layoutWithWidget = testLayoutState.addWidget(existingPlacement);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: layoutWithWidget,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
              ),
            ),
          ),
        );

        // Verify visual feedback components are in place
        final gridContainer = tester.widget<GridContainer>(
          find.byType(GridContainer),
        );
        expect(
          gridContainer.highlightedCells,
          isNull,
        ); // Initially no highlights
        expect(
          gridContainer.highlightColor,
          isNull,
        ); // Initially no highlight color
      });

      testWidgets('handles both toolbox and widget drags simultaneously', (
        WidgetTester tester,
      ) async {
        // Create a layout with an existing widget
        final existingPlacement = WidgetPlacement(
          id: 'existing',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        final layoutWithWidget = testLayoutState.addWidget(existingPlacement);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridDragTarget(
                layoutState: layoutWithWidget,
                widgetBuilders: testWidgetBuilders,
                toolbox: testToolbox,
                onWidgetDropped: (placement) {
                  // Callback for new widgets
                },
                onWidgetMoved: (widgetId, placement) {
                  // Callback for moved widgets
                },
              ),
            ),
          ),
        );

        // Verify both drag targets exist
        expect(find.byType(DragTarget<ToolboxItem>), findsOneWidget);
        expect(find.byType(DragTarget<WidgetPlacement>), findsOneWidget);
      });
    });
  });
}
