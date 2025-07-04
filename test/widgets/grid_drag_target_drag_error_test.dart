import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('GridDragTarget Drag Error Reproduction', () {
    late LayoutState testLayoutState;
    late Map<String, Widget Function(BuildContext, WidgetPlacement)>
        testWidgetBuilders;
    late Toolbox testToolbox;

    setUp(() {
      // Create a small 3x3 grid
      testLayoutState = LayoutState(
        dimensions: const GridDimensions(columns: 3, rows: 3),
        widgets: [],
      );
      testWidgetBuilders = {
        'TextInput': (context, placement) => Container(color: Colors.blue),
        'Button': (context, placement) => Container(color: Colors.green),
      };
      testToolbox = Toolbox.withDefaults();
    });

    testWidgets('reproduces drag error when dropping widget in invalid position',
        (WidgetTester tester) async {
      // Add existing widgets to fill up the grid
      final existingWidget1 = WidgetPlacement(
        id: 'existing_1',
        widgetName: 'TextInput',
        column: 0,
        row: 0,
        width: 2,
        height: 2,
        properties: {},
      );
      final existingWidget2 = WidgetPlacement(
        id: 'existing_2',
        widgetName: 'Button',
        column: 2,
        row: 0,
        width: 1,
        height: 3,
        properties: {},
      );

      // Add these widgets to the layout state to create a crowded grid
      testLayoutState = testLayoutState.addWidget(existingWidget1);
      testLayoutState = testLayoutState.addWidget(existingWidget2);


      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              onWidgetDropped: (placement) {
                // This should throw an ArgumentError because the placement
                // conflicts with existing widgets or is out of bounds
                testLayoutState.addWidget(placement);
              },
            ),
          ),
        ),
      );

      // Try to drop a widget that would overlap with existing widgets
      final invalidPlacement = WidgetPlacement(
        id: 'invalid_widget_${DateTime.now().millisecondsSinceEpoch}',
        widgetName: 'TextInput',
        column: 1, // This would overlap with existing widget at (0,0) 2x2
        row: 1,
        width: 2,
        height: 2,
        properties: {},
      );

      // Simulate the drop operation that would cause the error
      expect(() {
        testLayoutState.addWidget(invalidPlacement);
      }, throwsA(isA<ArgumentError>()));

      // Verify the error message matches the expected pattern
      try {
        testLayoutState.addWidget(invalidPlacement);
      } catch (e) {
        expect(e.toString(), contains('Cannot add widget'));
      }
    });

    testWidgets('reproduces drag error when dropping widget out of bounds',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              onWidgetDropped: (placement) {
                testLayoutState.addWidget(placement);
              },
            ),
          ),
        ),
      );

      // Try to drop a widget that would exceed grid boundaries
      final outOfBoundsPlacement = WidgetPlacement(
        id: 'out_of_bounds_widget_${DateTime.now().millisecondsSinceEpoch}',
        widgetName: 'TextInput',
        column: 2, // With width 2, this would extend to column 4 (out of bounds in 3x3 grid)
        row: 2,    // With height 2, this would extend to row 4 (out of bounds in 3x3 grid)
        width: 2,
        height: 2,
        properties: {},
      );

      // Simulate the drop operation that would cause the error
      expect(() {
        testLayoutState.addWidget(outOfBoundsPlacement);
      }, throwsA(isA<ArgumentError>()));

      // Verify the error message matches the expected pattern
      try {
        testLayoutState.addWidget(outOfBoundsPlacement);
      } catch (e) {
        expect(e.toString(), contains('Cannot add widget'));
      }
    });

    testWidgets('reproduces drag error with duplicate widget ID',
        (WidgetTester tester) async {
      // Add an existing widget
      final existingWidget = WidgetPlacement(
        id: 'duplicate_id',
        widgetName: 'TextInput',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
        properties: {},
      );
      testLayoutState = testLayoutState.addWidget(existingWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              toolbox: testToolbox,
              onWidgetDropped: (placement) {
                testLayoutState.addWidget(placement);
              },
            ),
          ),
        ),
      );

      // Try to drop a widget with the same ID as an existing widget
      final duplicateIdPlacement = WidgetPlacement(
        id: 'duplicate_id', // Same ID as existing widget
        widgetName: 'Button',
        column: 1,
        row: 1,
        width: 1,
        height: 1,
        properties: {},
      );

      // Simulate the drop operation that would cause the error
      expect(() {
        testLayoutState.addWidget(duplicateIdPlacement);
      }, throwsA(isA<ArgumentError>()));

      // Verify the error message matches the expected pattern
      try {
        testLayoutState.addWidget(duplicateIdPlacement);
      } catch (e) {
        expect(e.toString(), contains('Cannot add widget'));
      }
    });
  });
}