import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('useFormLayout Undo/Redo', () {
    late LayoutState initialState;

    setUp(() {
      initialState = LayoutState.empty();
    });

    testWidgets('provides undo/redo capabilities', (WidgetTester tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);
    });

    testWidgets('tracks undo state after widget addition', (WidgetTester tester) async {
      late FormLayoutController controller;

      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      controller.addWidget(placement);
      await tester.pump();

      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);
      expect(controller.state.widgets, contains(placement));
    });

    testWidgets('undoes widget addition', (WidgetTester tester) async {
        late FormLayoutController controller;
        

      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      controller.addWidget(placement);
      await tester.pump();

      controller.undo();
      await tester.pump();

      expect(controller.state.widgets, isEmpty);
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isTrue);
    });

    testWidgets('redoes widget addition', (WidgetTester tester) async {
        late FormLayoutController controller;
        

      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      controller.addWidget(placement);
      await tester.pump();

      controller.undo();
      await tester.pump();

      controller.redo();
      await tester.pump();

      expect(controller.state.widgets, contains(placement));
      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);
    });

    testWidgets('tracks multiple operations in undo history', (WidgetTester tester) async {
      late FormLayoutController controller;

      final widget1 = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final widget2 = WidgetPlacement(
        id: 'widget2',
        widgetName: 'TestWidget',
        column: 1,
        row: 1,
        width: 1,
        height: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      controller.addWidget(widget1);
      await tester.pump();

      controller.addWidget(widget2);
      await tester.pump();

      expect(controller.state.widgets.length, equals(2));
      expect(controller.canUndo, isTrue);

      controller.undo();
      await tester.pump();

      expect(controller.state.widgets.length, equals(1));
      expect(controller.state.widgets, contains(widget1));
      expect(controller.canUndo, isTrue);

      controller.undo();
      await tester.pump();

      expect(controller.state.widgets, isEmpty);
      expect(controller.canUndo, isFalse);
    });

    testWidgets('undoes widget removal', (WidgetTester tester) async {
        late FormLayoutController controller;
        

      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final stateWithWidget = initialState.addWidget(placement);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(stateWithWidget);
              return Container();
            },
          ),
        ),
      );

      controller.removeWidget('widget1');
      await tester.pump();

      expect(controller.state.widgets, isEmpty);
      expect(controller.canUndo, isTrue);

      controller.undo();
      await tester.pump();

      expect(controller.state.widgets, contains(placement));
    });

    testWidgets('undoes widget move', (WidgetTester tester) async {
        late FormLayoutController controller;
        

      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final stateWithWidget = initialState.addWidget(placement);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(stateWithWidget);
              return Container();
            },
          ),
        ),
      );

      controller.moveWidget('widget1', 2, 2);
      await tester.pump();

      final movedWidget = controller.state.getWidget('widget1');
      expect(movedWidget?.column, equals(2));
      expect(movedWidget?.row, equals(2));

      controller.undo();
      await tester.pump();

      final restoredWidget = controller.state.getWidget('widget1');
      expect(restoredWidget?.column, equals(0));
      expect(restoredWidget?.row, equals(0));
    });

    testWidgets('undoes widget resize', (WidgetTester tester) async {
        late FormLayoutController controller;
        

      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final stateWithWidget = initialState.addWidget(placement);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(stateWithWidget);
              return Container();
            },
          ),
        ),
      );

      controller.resizeWidget('widget1', 2, 2);
      await tester.pump();

      final resizedWidget = controller.state.getWidget('widget1');
      expect(resizedWidget?.width, equals(2));
      expect(resizedWidget?.height, equals(2));

      controller.undo();
      await tester.pump();

      final restoredWidget = controller.state.getWidget('widget1');
      expect(restoredWidget?.width, equals(1));
      expect(restoredWidget?.height, equals(1));
    });

    testWidgets('undoes grid resize', (WidgetTester tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      const newDimensions = GridDimensions(columns: 6, rows: 6);
      controller.resizeGrid(newDimensions);
      await tester.pump();

      expect(controller.state.dimensions, equals(newDimensions));

      controller.undo();
      await tester.pump();

      expect(controller.state.dimensions, equals(initialState.dimensions));
    });

    testWidgets('respects undo history limit', (WidgetTester tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState, undoLimit: 3);
              return Container();
            },
          ),
        ),
      );

      // Add 5 widgets (exceeds limit of 3) - use different positions to avoid conflicts
      for (int i = 0; i < 5; i++) {
        final placement = WidgetPlacement(
          id: 'widget$i',
          widgetName: 'TestWidget',
          column: i % 4, // Spread across columns to avoid conflicts
          row: i ~/ 4, // Move to next row when columns are full
          width: 1,
          height: 1,
        );
        controller.addWidget(placement);
        await tester.pump();
      }

      expect(controller.state.widgets.length, equals(5));

      // Should only be able to undo 3 operations
      int undoCount = 0;
      while (controller.canUndo) {
        controller.undo();
        await tester.pump();
        undoCount++;
      }

      expect(undoCount, equals(3));
      expect(controller.state.widgets.length, equals(2)); // 5 - 3 = 2
    });

    testWidgets('clears redo history on new operation', (WidgetTester tester) async {
      late FormLayoutController controller;

      final widget1 = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final widget2 = WidgetPlacement(
        id: 'widget2',
        widgetName: 'TestWidget',
        column: 1,
        row: 1,
        width: 1,
        height: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      controller.addWidget(widget1);
      await tester.pump();

      controller.undo();
      await tester.pump();

      expect(controller.canRedo, isTrue);

      // New operation should clear redo history
      controller.addWidget(widget2);
      await tester.pump();

      expect(controller.canRedo, isFalse);
    });

    testWidgets('clears history', (WidgetTester tester) async {
        late FormLayoutController controller;
        

      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      controller.addWidget(placement);
      await tester.pump();

      expect(controller.canUndo, isTrue);

      controller.clearHistory();
      await tester.pump();

      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);
    });

    testWidgets('maintains state consistency during complex undo/redo sequence', (WidgetTester tester) async {
      late FormLayoutController controller;

        final widget1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TestWidget',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: HookBuilder(
              builder: (context) {
                controller = useFormLayout(initialState);
                return Container();
              },
            ),
          ),
        );

        // Add widget
        controller.addWidget(widget1);
        await tester.pump();

        // Move widget
        controller.moveWidget('widget1', 2, 2);
        await tester.pump();

        // Resize widget
        controller.resizeWidget('widget1', 2, 2);
        await tester.pump();

        final finalWidget = controller.state.getWidget('widget1');
        expect(finalWidget?.column, equals(2));
        expect(finalWidget?.row, equals(2));
        expect(finalWidget?.width, equals(2));
        expect(finalWidget?.height, equals(2));

        // Undo resize
        controller.undo();
        await tester.pump();

        var widget = controller.state.getWidget('widget1');
        expect(widget?.width, equals(1));
        expect(widget?.height, equals(1));
        expect(widget?.column, equals(2));
        expect(widget?.row, equals(2));

        // Undo move
        controller.undo();
        await tester.pump();

        widget = controller.state.getWidget('widget1');
        expect(widget?.column, equals(0));
        expect(widget?.row, equals(0));
        expect(widget?.width, equals(1));
        expect(widget?.height, equals(1));

        // Undo add
        controller.undo();
        await tester.pump();

        expect(controller.state.widgets, isEmpty);

        // Redo all operations
        controller.redo();
        await tester.pump();
        expect(controller.state.widgets.length, equals(1));

        controller.redo();
        await tester.pump();
        widget = controller.state.getWidget('widget1');
        expect(widget?.column, equals(2));
        expect(widget?.row, equals(2));

        controller.redo();
        await tester.pump();
        widget = controller.state.getWidget('widget1');
        expect(widget?.width, equals(2));
        expect(widget?.height, equals(2));
      },
    );
  });
}
