import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('GridDragTarget Timing Fix', () {
    late LayoutState testLayoutState;
    late Map<String, Widget Function(BuildContext, WidgetPlacement)>
        testWidgetBuilders;
    late Toolbox testToolbox;

    setUp(() {
      testLayoutState = LayoutState(
        dimensions: const GridDimensions(columns: 6, rows: 6),
        widgets: [],
      );
      testWidgetBuilders = {
        'TextInput': (context, placement) => Container(color: Colors.blue),
        'Button': (context, placement) => Container(color: Colors.green),
      };
      testToolbox = Toolbox.withDefaults();
    });

    testWidgets('drag and drop works without coordinate timing issues',
        (WidgetTester tester) async {
      WidgetPlacement? droppedWidget;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              onWidgetDropped: (placement) {
                droppedWidget = placement;
                // This should not throw an error anymore
                testLayoutState.addWidget(placement);
              },
            ),
          ),
        ),
      );

      // Verify that the widget can be found
      expect(find.byType(GridDragTarget), findsOneWidget);
      expect(find.byType(DragTarget<ToolboxItem>), findsOneWidget);
      
      // Get the DragTarget widget
      final dragTarget = tester.widget<DragTarget<ToolboxItem>>(
        find.byType(DragTarget<ToolboxItem>),
      );
      
      // Create a toolbox item for dragging
      final toolboxItem = ToolboxItem(
        name: 'TextInput',
        displayName: 'Text Input',
        toolboxBuilder: (context) => Container(color: Colors.blue),
        gridBuilder: (context, placement) => Container(color: Colors.blue),
        defaultWidth: 2,
        defaultHeight: 1,
      );
      
      // Simulate drag details
      final dragDetails = DragTargetDetails<ToolboxItem>(
        data: toolboxItem,
        offset: const Offset(100, 100), // A position within the grid
      );
      
      // Test that onWillAcceptWithDetails works
      final willAccept = dragTarget.onWillAcceptWithDetails?.call(dragDetails);
      expect(willAccept, isTrue);
      
      // Test that onAcceptWithDetails works without throwing
      expect(() {
        dragTarget.onAcceptWithDetails?.call(dragDetails);
      }, returnsNormally);
      
      // Verify that the widget was actually dropped
      expect(droppedWidget, isNotNull);
      expect(droppedWidget?.widgetName, equals('TextInput'));
      expect(droppedWidget?.width, equals(2));
      expect(droppedWidget?.height, equals(1));
    });

    testWidgets('widget movement works without coordinate timing issues',
        (WidgetTester tester) async {
      // Add an existing widget to move
      final existingWidget = WidgetPlacement(
        id: 'widget_to_move',
        widgetName: 'Button',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
        properties: {},
      );
      testLayoutState = testLayoutState.addWidget(existingWidget);
      
      WidgetPlacement? movedWidget;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              onWidgetMoved: (widgetId, newPlacement) {
                movedWidget = newPlacement;
                // This should not throw an error anymore
                testLayoutState.updateWidget(widgetId, newPlacement);
              },
            ),
          ),
        ),
      );

      // Verify that the widget can be found
      expect(find.byType(GridDragTarget), findsOneWidget);
      expect(find.byType(DragTarget<WidgetPlacement>), findsOneWidget);
      
      // Get the DragTarget widget for WidgetPlacement
      final dragTarget = tester.widget<DragTarget<WidgetPlacement>>(
        find.byType(DragTarget<WidgetPlacement>),
      );
      
      // Simulate moving the widget
      final dragDetails = DragTargetDetails<WidgetPlacement>(
        data: existingWidget,
        offset: const Offset(200, 200), // A different position within the grid
      );
      
      // Test that onWillAcceptWithDetails works
      final willAccept = dragTarget.onWillAcceptWithDetails?.call(dragDetails);
      expect(willAccept, isTrue);
      
      // Test that onAcceptWithDetails works without throwing
      expect(() {
        dragTarget.onAcceptWithDetails?.call(dragDetails);
      }, returnsNormally);
      
      // Verify that the widget was actually moved
      expect(movedWidget, isNotNull);
      expect(movedWidget?.id, equals('widget_to_move'));
      expect(movedWidget?.widgetName, equals('Button'));
      // The exact coordinates depend on the grid calculation, but should be valid
      expect(movedWidget?.column, greaterThanOrEqualTo(0));
      expect(movedWidget?.row, greaterThanOrEqualTo(0));
    });
  });
}