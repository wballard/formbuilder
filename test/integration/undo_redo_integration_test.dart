import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/accessible_categorized_toolbox.dart';
import '../test_utils/test_widget_builder.dart';
import '../test_utils/state_assertions.dart';
import '../test_utils/form_layout_test_wrapper.dart';

void main() {
  group('Undo/Redo Integration Tests', () {
    late CategorizedToolbox toolbox;

    setUp(() {
      toolbox = CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Basic',
            items: [
              ToolboxItem(
              name: 'button',
              displayName: 'Button',
              defaultWidth: 2, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
              ToolboxItem(
              name: 'text_input',
              displayName: 'Text Input',
              defaultWidth: 4, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
            ],
          ),
        ],
      );
    });

    testWidgets('Undo/redo widget additions', (tester) async {
      late FormLayoutController controller;
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          FormLayoutTestWrapper(
            toolbox: toolbox,
            initialLayout: LayoutState(
              dimensions: const GridDimensions(columns: 12, rows: 12),
              widgets: [],
            ),
            onControllerCreated: (c) => controller = c,
          ),
        ),
      );

      // Wait for everything to be ready
      await tester.pumpAndSettle();
      
      // Add three widgets
      final buttonItem = find.descendant(
        of: find.byType(AccessibleCategorizedToolbox),
        matching: find.text('Button'),
      );
      
      // Check if we can find the button
      expect(buttonItem, findsOneWidget, reason: 'Should find Button in toolbox');
      
      // Try a different approach - directly add widgets using the controller
      for (int i = 0; i < 3; i++) {
        controller.addWidget(WidgetPlacement(
          id: 'widget_$i',
          widgetName: 'button',
          column: i * 2,
          row: 0,
          width: 2,
          height: 1,
        ));
        await tester.pumpAndSettle();
      }

      expect(controller.state.widgets.length, 3);
      final widget3Id = controller.state.widgets.last.id;
      final widget2Id = controller.state.widgets[1].id;
      final widget1Id = controller.state.widgets.first.id;

      // Undo additions one by one
      controller.undo();
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 2);
      expect(controller.state.getWidget(widget3Id), isNull);

      controller.undo();
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 1);
      expect(controller.state.getWidget(widget2Id), isNull);

      controller.undo();
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 0);
      expect(controller.state.getWidget(widget1Id), isNull);

      // Verify can't undo further
      expect(controller.canUndo, isFalse);

      // Redo additions
      controller.redo();
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 1);
      expect(controller.state.getWidget(widget1Id), isNotNull);

      controller.redo();
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 2);
      expect(controller.state.getWidget(widget2Id), isNotNull);

      controller.redo();
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 3);
      expect(controller.state.getWidget(widget3Id), isNotNull);

      // Verify can't redo further
      expect(controller.canRedo, isFalse);
    });

    testWidgets('Undo/redo widget moves', (tester) async {
      late FormLayoutController controller;
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          FormLayoutTestWrapper(
            toolbox: toolbox,
            initialLayout: LayoutState(
              dimensions: const GridDimensions(columns: 12, rows: 12),
              widgets: [
                WidgetPlacement(
                  id: 'movable',
                  widgetName: 'button',
                  column: 2,
                  row: 2,
                  width: 2,
                  height: 1,
                ),
              ],
            ),
            onControllerCreated: (c) => controller = c,
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Record initial position
      final initialColumn = controller.state.widgets.first.column;
      final initialRow = controller.state.widgets.first.row;

      // Move widget multiple times
      // Move 1: from (2,2) to (4,2)
      controller.updateWidget('movable', WidgetPlacement(
        id: 'movable',
        widgetName: 'button',
        column: 4,
        row: 2,
        width: 2,
        height: 1,
      ));
      await tester.pumpAndSettle();
      final pos1Column = 4;
      final pos1Row = 2;

      // Move 2: from (4,2) to (4,4)
      controller.updateWidget('movable', WidgetPlacement(
        id: 'movable',
        widgetName: 'button',
        column: 4,
        row: 4,
        width: 2,
        height: 1,
      ));
      await tester.pumpAndSettle();
      final pos2Column = 4;
      final pos2Row = 4;

      // Move 3: from (4,4) to (3,3)
      controller.updateWidget('movable', WidgetPlacement(
        id: 'movable',
        widgetName: 'button',
        column: 3,
        row: 3,
        width: 2,
        height: 1,
      ));
      await tester.pumpAndSettle();
      final pos3Column = 3;
      final pos3Row = 3;

      // Undo moves
      controller.undo();
      await tester.pumpAndSettle();
      StateAssertions.assertWidgetPosition(
        controller.state,
        'movable',
        column: pos2Column,
        row: pos2Row,
      );

      controller.undo();
      await tester.pumpAndSettle();
      StateAssertions.assertWidgetPosition(
        controller.state,
        'movable',
        column: pos1Column,
        row: pos1Row,
      );

      controller.undo();
      await tester.pumpAndSettle();
      StateAssertions.assertWidgetPosition(
        controller.state,
        'movable',
        column: initialColumn,
        row: initialRow,
      );

      // Redo moves
      controller.redo();
      await tester.pumpAndSettle();
      StateAssertions.assertWidgetPosition(
        controller.state,
        'movable',
        column: pos1Column,
        row: pos1Row,
      );

      controller.redo();
      await tester.pumpAndSettle();
      StateAssertions.assertWidgetPosition(
        controller.state,
        'movable',
        column: pos2Column,
        row: pos2Row,
      );

      controller.redo();
      await tester.pumpAndSettle();
      StateAssertions.assertWidgetPosition(
        controller.state,
        'movable',
        column: pos3Column,
        row: pos3Row,
      );
    });

    testWidgets('Undo/redo widget deletions', (tester) async {
      late FormLayoutController controller;
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          FormLayoutTestWrapper(
            toolbox: toolbox,
            initialLayout: LayoutState(
              dimensions: const GridDimensions(columns: 12, rows: 12),
              widgets: [
                WidgetPlacement(
                  id: 'widget1',
                  widgetName: 'button',
                  column: 1,
                  row: 1,
                  width: 2,
                  height: 1,
                ),
                WidgetPlacement(
                  id: 'widget2',
                  widgetName: 'text_input',
                  column: 4,
                  row: 1,
                  width: 4,
                  height: 1,
                ),
                WidgetPlacement(
                  id: 'widget3',
                  widgetName: 'button',
                  column: 1,
                  row: 3,
                  width: 2,
                  height: 1,
                ),
              ],
            ),
            onControllerCreated: (c) => controller = c,
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Delete widgets one by one
      expect(controller.state.widgets.length, 3);

      // Delete widget1
      controller.removeWidget('widget1');
      await tester.pumpAndSettle();
      
      expect(controller.state.widgets.length, 2);
      expect(controller.state.getWidget('widget1'), isNull);

      // Delete widget2
      controller.removeWidget('widget2');
      await tester.pumpAndSettle();
      
      expect(controller.state.widgets.length, 1);
      expect(controller.state.getWidget('widget2'), isNull);

      // Undo deletions
      controller.undo();
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 2);
      expect(controller.state.getWidget('widget2'), isNotNull);

      controller.undo();
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 3);
      expect(controller.state.getWidget('widget1'), isNotNull);

      // Verify all widgets are restored with correct positions
      StateAssertions.assertWidgetPosition(
        controller.state,
        'widget1',
        column: 1,
        row: 1,
      );
      StateAssertions.assertWidgetPosition(
        controller.state,
        'widget2',
        column: 4,
        row: 1,
      );
      StateAssertions.assertWidgetPosition(
        controller.state,
        'widget3',
        column: 1,
        row: 3,
      );
    });

    testWidgets('Undo/redo grid dimension changes', (tester) async {
      late FormLayoutController controller;
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          FormLayoutTestWrapper(
            toolbox: toolbox,
            initialLayout: LayoutState(
              dimensions: const GridDimensions(columns: 12, rows: 12),
              widgets: [
                WidgetPlacement(
                  id: 'widget1',
                  widgetName: 'button',
                  column: 10,
                  row: 10,
                  width: 2,
                  height: 2,
                ),
              ],
            ),
            onControllerCreated: (c) => controller = c,
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Change grid dimensions multiple times
      controller.resizeGrid(const GridDimensions(columns: 10, rows: 10));
      await tester.pumpAndSettle();
      StateAssertions.assertGridDimensions(controller.state, columns: 10, rows: 10);

      controller.resizeGrid(const GridDimensions(columns: 8, rows: 8));
      await tester.pumpAndSettle();
      StateAssertions.assertGridDimensions(controller.state, columns: 8, rows: 8);

      controller.resizeGrid(const GridDimensions(columns: 6, rows: 6));
      await tester.pumpAndSettle();
      StateAssertions.assertGridDimensions(controller.state, columns: 6, rows: 6);

      // Widget should be repositioned to fit or removed
      if (controller.state.widgets.isNotEmpty) {
        final adjustedWidget = controller.state.widgets.first;
        expect(adjustedWidget.column + adjustedWidget.width, lessThanOrEqualTo(6));
        expect(adjustedWidget.row + adjustedWidget.height, lessThanOrEqualTo(6));
      }

      // Undo dimension changes
      controller.undo();
      await tester.pumpAndSettle();
      StateAssertions.assertGridDimensions(controller.state, columns: 8, rows: 8);

      controller.undo();
      await tester.pumpAndSettle();
      StateAssertions.assertGridDimensions(controller.state, columns: 10, rows: 10);

      controller.undo();
      await tester.pumpAndSettle();
      StateAssertions.assertGridDimensions(controller.state, columns: 12, rows: 12);

      // Widget should be back at original position
      StateAssertions.assertWidgetPosition(
        controller.state,
        'widget1',
        column: 10,
        row: 10,
      );
    });

    testWidgets('Complex undo/redo scenario', (tester) async {
      late FormLayoutController controller;
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          FormLayoutTestWrapper(
            toolbox: toolbox,
            initialLayout: LayoutState(
              dimensions: const GridDimensions(columns: 12, rows: 12),
              widgets: [],
            ),
            onControllerCreated: (c) => controller = c,
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Perform a series of operations
      // 1. Add widget
      controller.addWidget(WidgetPlacement(
        id: 'widget_1',
        widgetName: 'button',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      ));
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 1);
      final firstWidgetId = controller.state.widgets.first.id;

      // 2. Move widget
      controller.updateWidget(firstWidgetId, WidgetPlacement(
        id: firstWidgetId,
        widgetName: 'button',
        column: 2,
        row: 2,
        width: 2,
        height: 1,
      ));
      await tester.pumpAndSettle();

      // 3. Add another widget
      controller.addWidget(WidgetPlacement(
        id: 'widget_2',
        widgetName: 'text_input',
        column: 0,
        row: 0,
        width: 4,
        height: 1,
      ));
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 2);

      // 4. Change grid dimensions
      controller.resizeGrid(const GridDimensions(columns: 10, rows: 10));
      await tester.pumpAndSettle();

      // 5. Delete first widget
      controller.removeWidget(firstWidgetId);
      await tester.pumpAndSettle();
      expect(controller.state.widgets.length, 1);

      // Now undo everything
      controller.undo(); // Undo delete
      expect(controller.state.widgets.length, 2);

      controller.undo(); // Undo dimension change
      StateAssertions.assertGridDimensions(controller.state, columns: 12, rows: 12);

      controller.undo(); // Undo add second widget
      expect(controller.state.widgets.length, 1);

      controller.undo(); // Undo move
      controller.undo(); // Undo add first widget
      expect(controller.state.widgets.length, 0);

      // Redo some operations
      controller.redo(); // Redo add first widget
      expect(controller.state.widgets.length, 1);

      controller.redo(); // Redo move
      controller.redo(); // Redo add second widget
      expect(controller.state.widgets.length, 2);

      // New operation breaks redo chain
      controller.removeWidget(controller.state.widgets.first.id);
      await tester.pumpAndSettle();
      
      expect(controller.canRedo, isFalse);
      expect(controller.state.widgets.length, 1);
    });

    testWidgets('Undo/redo limits and history management', (tester) async {
      late FormLayoutController controller;
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          FormLayoutTestWrapper(
            toolbox: toolbox,
            initialLayout: LayoutState(
              dimensions: const GridDimensions(columns: 12, rows: 12),
              widgets: [],
            ),
            onControllerCreated: (c) => controller = c,
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      // Add many widgets to test history limits
      for (int i = 0; i < 20; i++) {
        controller.addWidget(WidgetPlacement(
          id: 'widget_$i',
          widgetName: 'button',
          column: (i * 2) % 10,
          row: (i ~/ 5) * 2,
          width: 2,
          height: 1,
        ));
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(controller.state.widgets.length, 20);

      // Undo all operations (up to history limit)
      int undoCount = 0;
      while (controller.canUndo && undoCount < 50) {
        controller.undo();
        await tester.pump();
        undoCount++;
      }

      // Verify we can undo a reasonable number of operations
      expect(undoCount, greaterThanOrEqualTo(10));

      // Redo all operations
      int redoCount = 0;
      while (controller.canRedo && redoCount < 50) {
        controller.redo();
        await tester.pump();
        redoCount++;
      }

      expect(redoCount, equals(undoCount));
    });
  });
}