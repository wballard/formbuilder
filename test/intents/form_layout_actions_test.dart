import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/intents/form_layout_actions.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

LayoutState _createInitialState() {
  return LayoutState(
    dimensions: GridDimensions(columns: 4, rows: 5),
    widgets: [],
  );
}

void main() {
  group('FormLayout Actions', () {
    late FormLayoutController controller;
    late ToolboxItem testItem;

    setUp(() {
      testItem = ToolboxItem(
        name: 'test_widget',
        displayName: 'Test Widget',
        toolboxBuilder: (context) => Container(),
        gridBuilder: (context, placement) => Container(),
        defaultWidth: 2,
        defaultHeight: 1,
      );
    });

    testWidgets('AddWidgetAction adds widget through controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = AddWidgetAction(controller);
                  final intent = AddWidgetIntent(
                    item: testItem,
                    position: const Point(1, 2),
                  );
                  action.invoke(intent);
                },
                child: const Text('Add Widget'),
              );
            },
          ),
        ),
      );

      expect(controller.state.widgets.length, 0);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.state.widgets.length, 1);
      final widget = controller.state.widgets.first;
      expect(widget.widgetName, 'test_widget');
      expect(widget.column, 1);
      expect(widget.row, 2);
    });

    testWidgets('RemoveWidgetAction removes widget through controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = RemoveWidgetAction(controller);
                  final intent = RemoveWidgetIntent(
                    widgetId: 'widget_to_remove',
                  );
                  action.invoke(intent);
                },
                child: const Text('Remove Widget'),
              );
            },
          ),
        ),
      );

      // Add a widget first
      controller.addWidget(WidgetPlacement(
        id: 'widget_to_remove',
        widgetName: 'test_widget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      ));
      await tester.pump();

      expect(controller.state.widgets.length, 1);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.state.widgets.length, 0);
    });

    testWidgets('MoveWidgetAction moves widget through controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = MoveWidgetAction(controller);
                  final intent = MoveWidgetIntent(
                    widgetId: 'widget_to_move',
                    newPosition: const Point(2, 3),
                  );
                  action.invoke(intent);
                },
                child: const Text('Move Widget'),
              );
            },
          ),
        ),
      );

      // Add a widget first
      controller.addWidget(WidgetPlacement(
        id: 'widget_to_move',
        widgetName: 'test_widget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      ));
      await tester.pump();

      final widget = controller.state.widgets.first;
      expect(widget.column, 0);
      expect(widget.row, 0);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      final movedWidget = controller.state.widgets.first;
      expect(movedWidget.column, 2);
      expect(movedWidget.row, 3);
    });

    testWidgets('ResizeWidgetAction resizes widget through controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = ResizeWidgetAction(controller);
                  final intent = ResizeWidgetIntent(
                    widgetId: 'widget_to_resize',
                    newSize: const Size(3, 2),
                  );
                  action.invoke(intent);
                },
                child: const Text('Resize Widget'),
              );
            },
          ),
        ),
      );

      // Add a widget first
      controller.addWidget(WidgetPlacement(
        id: 'widget_to_resize',
        widgetName: 'test_widget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      ));
      await tester.pump();

      final widget = controller.state.widgets.first;
      expect(widget.width, 2);
      expect(widget.height, 1);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      final resizedWidget = controller.state.widgets.first;
      expect(resizedWidget.width, 3);
      expect(resizedWidget.height, 2);
    });

    testWidgets('SelectWidgetAction selects widget through controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = SelectWidgetAction(controller);
                  final intent = SelectWidgetIntent(
                    widgetId: 'widget_to_select',
                  );
                  action.invoke(intent);
                },
                child: const Text('Select Widget'),
              );
            },
          ),
        ),
      );

      // Add a widget first
      controller.addWidget(WidgetPlacement(
        id: 'widget_to_select',
        widgetName: 'test_widget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      ));
      await tester.pump();

      expect(controller.selectedWidgetId, isNull);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.selectedWidgetId, 'widget_to_select');
    });

    testWidgets('UndoAction performs undo through controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = UndoAction(controller);
                  final intent = UndoIntent();
                  action.invoke(intent);
                },
                child: const Text('Undo'),
              );
            },
          ),
        ),
      );

      // Add a widget to create history
      controller.addWidget(WidgetPlacement(
        id: 'widget_for_undo',
        widgetName: 'test_widget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      ));
      await tester.pump();

      expect(controller.state.widgets.length, 1);
      expect(controller.canUndo, true);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.state.widgets.length, 0);
    });

    testWidgets('RedoAction performs redo through controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = RedoAction(controller);
                  final intent = RedoIntent();
                  action.invoke(intent);
                },
                child: const Text('Redo'),
              );
            },
          ),
        ),
      );

      // Add a widget and undo to create redo history
      controller.addWidget(WidgetPlacement(
        id: 'widget_for_redo',
        widgetName: 'test_widget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      ));
      controller.undo();
      await tester.pump();

      expect(controller.state.widgets.length, 0);
      expect(controller.canRedo, true);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.state.widgets.length, 1);
    });

    testWidgets('TogglePreviewModeAction toggles preview mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = TogglePreviewModeAction(controller);
                  final intent = TogglePreviewModeIntent();
                  action.invoke(intent);
                },
                child: const Text('Toggle Preview'),
              );
            },
          ),
        ),
      );

      expect(controller.isPreviewMode, false);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.isPreviewMode, true);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.isPreviewMode, false);
    });

    testWidgets('DuplicateWidgetAction duplicates widget at valid position', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = DuplicateWidgetAction(controller);
                  final intent = DuplicateWidgetIntent(
                    widgetId: 'widget_to_duplicate',
                  );
                  action.invoke(intent);
                },
                child: const Text('Duplicate Widget'),
              );
            },
          ),
        ),
      );

      // Add a widget to duplicate
      controller.addWidget(WidgetPlacement(
        id: 'widget_to_duplicate',
        widgetName: 'test_widget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      ));
      await tester.pump();

      expect(controller.state.widgets.length, 1);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.state.widgets.length, 2);
      final duplicated = controller.state.widgets.last;
      expect(duplicated.widgetName, 'test_widget');
      expect(duplicated.id, contains('copy'));
    });

    testWidgets('ResizeGridAction resizes grid through controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());
              
              return ElevatedButton(
                onPressed: () {
                  final action = ResizeGridAction(controller);
                  final intent = ResizeGridIntent(
                    newDimensions: const GridDimensions(columns: 6, rows: 8),
                  );
                  action.invoke(intent);
                },
                child: const Text('Resize Grid'),
              );
            },
          ),
        ),
      );

      expect(controller.state.dimensions.columns, 4);
      expect(controller.state.dimensions.rows, 5);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(controller.state.dimensions.columns, 6);
      expect(controller.state.dimensions.rows, 8);
    });
  });
}