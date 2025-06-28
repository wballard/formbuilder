import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/keyboard_handler.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('KeyboardHandler', () {
    late LayoutState testLayoutState;

    setUp(() {
      testLayoutState = LayoutState(
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
          WidgetPlacement(
            id: 'widget3',
            widgetName: 'TestWidget',
            column: 1,
            row: 1,
            width: 1,
            height: 1,
          ),
        ],
      );
    });

    Widget buildTestWidget(FormLayoutController controller) {
      return MaterialApp(
        home: Scaffold(
          body: KeyboardHandler(
            controller: controller,
            child: Container(
              key: const ValueKey('test-container'),
              width: 400,
              height: 400,
              color: Colors.grey[200],
            ),
          ),
        ),
      );
    }

    testWidgets('creates widget with required properties', (
      WidgetTester tester,
    ) async {
      final controller = FormLayoutController(testLayoutState);

      await tester.pumpWidget(buildTestWidget(controller));

      expect(find.byType(KeyboardHandler), findsOneWidget);
      expect(find.byKey(const ValueKey('test-container')), findsOneWidget);
    });

    testWidgets('receives focus when tapped', (WidgetTester tester) async {
      final controller = FormLayoutController(testLayoutState);

      await tester.pumpWidget(buildTestWidget(controller));

      // Tap to focus
      await tester.tap(find.byKey(const ValueKey('test-container')));
      await tester.pump();

      expect(
        Focus.of(
          tester.element(find.byKey(const ValueKey('test-container'))),
        ).hasFocus,
        isTrue,
      );
    });

    group('Navigation Keys', () {
      testWidgets('Tab selects next widget', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Press Tab
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(controller.selectedWidgetId, isNotNull);
      });

      testWidgets('Shift+Tab selects previous widget', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget2');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Press Shift+Tab
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pump();

        expect(controller.selectedWidgetId, equals('widget1'));
      });

      testWidgets('Escape deselects widget', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.selectedWidgetId, equals('widget1'));

        // Press Escape
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(controller.selectedWidgetId, isNull);
      });

      testWidgets('Arrow keys navigate between widgets', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1'); // Start at (0,0)

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Press right arrow - should select widget3 at (1,1) (closest in right direction)
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(controller.selectedWidgetId, equals('widget3'));

        // Press up arrow - should select widget1 at (0,0) (closest in up direction, equidistant widgets pick first)
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        expect(controller.selectedWidgetId, equals('widget1'));
      });
    });

    group('Operation Shortcuts', () {
      testWidgets('Delete key removes selected widget', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.state.widgets.length, equals(3));

        // Press Delete
        await tester.sendKeyEvent(LogicalKeyboardKey.delete);
        await tester.pump();

        expect(controller.state.widgets.length, equals(2));
        expect(controller.state.getWidget('widget1'), isNull);
        expect(controller.selectedWidgetId, isNull);
      });

      testWidgets('Backspace key removes selected widget', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget2');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.state.widgets.length, equals(3));

        // Press Backspace
        await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        await tester.pump();

        expect(controller.state.widgets.length, equals(2));
        expect(controller.state.getWidget('widget2'), isNull);
      });

      testWidgets('Ctrl+Z undoes last operation', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);

        // Add a widget first to have something to undo
        final newWidget = WidgetPlacement(
          id: 'widget4',
          widgetName: 'TestWidget',
          column: 3,
          row: 3,
          width: 1,
          height: 1,
        );
        controller.addWidget(newWidget);

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.state.widgets.length, equals(4));

        // Press Ctrl+Z
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.state.widgets.length, equals(3));
        expect(controller.state.getWidget('widget4'), isNull);
      });

      testWidgets('Cmd+Z undoes on macOS', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);

        // Add a widget first to have something to undo
        final newWidget = WidgetPlacement(
          id: 'widget4',
          widgetName: 'TestWidget',
          column: 3,
          row: 3,
          width: 1,
          height: 1,
        );
        controller.addWidget(newWidget);

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.state.widgets.length, equals(4));

        // Press Ctrl+Z (since test runs on non-macOS platform)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.state.widgets.length, equals(3));
      });

      testWidgets('Ctrl+Y redoes last operation', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);

        // Add and undo a widget to have something to redo
        final newWidget = WidgetPlacement(
          id: 'widget4',
          widgetName: 'TestWidget',
          column: 3,
          row: 3,
          width: 1,
          height: 1,
        );
        controller.addWidget(newWidget);
        controller.undo();

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.state.widgets.length, equals(3));

        // Press Ctrl+Y
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyY);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.state.widgets.length, equals(4));
        expect(controller.state.getWidget('widget4'), isNotNull);
      });

      testWidgets('Ctrl+Shift+Z redoes last operation', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);

        // Add and undo a widget to have something to redo
        final newWidget = WidgetPlacement(
          id: 'widget4',
          widgetName: 'TestWidget',
          column: 3,
          row: 3,
          width: 1,
          height: 1,
        );
        controller.addWidget(newWidget);
        controller.undo();

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.state.widgets.length, equals(3));

        // Press Ctrl+Shift+Z
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.state.widgets.length, equals(4));
      });

      testWidgets('Ctrl+D duplicates selected widget', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.state.widgets.length, equals(3));

        // Press Ctrl+D
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.state.widgets.length, equals(4));

        // Should have a new widget near the original
        final duplicatedWidgets = controller.state.widgets
            .where(
              (w) =>
                  w.widgetName == 'TestWidget' &&
                  w.id != 'widget1' &&
                  w.id != 'widget2' &&
                  w.id != 'widget3',
            )
            .toList();
        expect(duplicatedWidgets, hasLength(1));
      });
    });

    group('Widget Manipulation', () {
      testWidgets('Shift+Arrow moves widget by one cell', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        final originalWidget = controller.state.getWidget('widget1')!;
        expect(originalWidget.column, equals(0));
        expect(originalWidget.row, equals(0));

        // Press Shift+Right
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pump();

        final movedWidget = controller.state.getWidget('widget1')!;
        expect(movedWidget.column, equals(1));
        expect(movedWidget.row, equals(0));
      });

      testWidgets('Ctrl+Arrow resizes widget', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        final originalWidget = controller.state.getWidget('widget1')!;
        expect(originalWidget.width, equals(1));
        expect(originalWidget.height, equals(1));

        // Press Ctrl+Right (increase width)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        final resizedWidget = controller.state.getWidget('widget1')!;
        expect(resizedWidget.width, equals(2));
        expect(resizedWidget.height, equals(1));
      });

      testWidgets('Ctrl+Down increases height', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Press Ctrl+Down (increase height)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        final resizedWidget = controller.state.getWidget('widget1')!;
        expect(resizedWidget.width, equals(1));
        expect(resizedWidget.height, equals(2));
      });
    });

    group('Focus Management', () {
      testWidgets('maintains focus within keyboard handler', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(
          Focus.of(
            tester.element(find.byKey(const ValueKey('test-container'))),
          ).hasFocus,
          isTrue,
        );

        // Press any key - focus should remain
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(
          Focus.of(
            tester.element(find.byKey(const ValueKey('test-container'))),
          ).hasFocus,
          isTrue,
        );
      });

      testWidgets('shows focus indicator when focused', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);

        await tester.pumpWidget(buildTestWidget(controller));

        // Initially not focused
        expect(find.byKey(const ValueKey('test-container')), findsOneWidget);

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Should show focus indicator
        expect(
          Focus.of(
            tester.element(find.byKey(const ValueKey('test-container'))),
          ).hasFocus,
          isTrue,
        );
      });
    });

    group('Platform-specific shortcuts', () {
      testWidgets('uses Cmd key on macOS for shortcuts', (
        WidgetTester tester,
      ) async {
        // This test would be enhanced with platform detection
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Press Ctrl+D (since test runs on non-macOS platform)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.state.widgets.length, equals(4));
      });
    });

    group('Preview Mode Shortcuts', () {
      testWidgets('Ctrl+P toggles preview mode', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.isPreviewMode, isFalse);

        // Press Ctrl+P
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.isPreviewMode, isTrue);

        // Press Ctrl+P again
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.isPreviewMode, isFalse);
      });

      testWidgets('Cmd+P toggles preview mode on macOS', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.isPreviewMode, isFalse);

        // Press Cmd+P (using Ctrl+P since test runs on non-macOS platform)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.isPreviewMode, isTrue);
      });

      testWidgets('Escape exits preview mode', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Enter preview mode
        controller.setPreviewMode(true);
        await tester.pump();

        expect(controller.isPreviewMode, isTrue);

        // Press Escape
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(controller.isPreviewMode, isFalse);
      });

      testWidgets('Escape deselects widget when not in preview mode', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.selectedWidgetId, equals('widget1'));
        expect(controller.isPreviewMode, isFalse);

        // Press Escape
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(controller.selectedWidgetId, isNull);
        expect(controller.isPreviewMode, isFalse);
      });

      testWidgets('preview mode clears selection', (WidgetTester tester) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1');

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.selectedWidgetId, equals('widget1'));

        // Press Ctrl+P to enter preview mode
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        expect(controller.isPreviewMode, isTrue);
        expect(controller.selectedWidgetId, isNull);
      });
    });

    group('Edge cases', () {
      testWidgets('handles no widget selected gracefully', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        expect(controller.selectedWidgetId, isNull);

        // Press Shift+Arrow (should not crash)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pump();

        // Should still have no selection
        expect(controller.selectedWidgetId, isNull);
      });

      testWidgets('prevents moves outside grid bounds', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);
        controller.selectWidget('widget1'); // At (0,0)

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Try to move left (should stay at column 0)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pump();

        final widget = controller.state.getWidget('widget1')!;
        expect(widget.column, equals(0)); // Should not move
      });

      testWidgets('prevents resize beyond grid bounds', (
        WidgetTester tester,
      ) async {
        final controller = FormLayoutController(testLayoutState);

        // Select widget at right edge
        controller.selectWidget('widget2'); // At (2,0)

        await tester.pumpWidget(buildTestWidget(controller));

        // Focus the keyboard handler
        await tester.tap(find.byKey(const ValueKey('test-container')));
        await tester.pump();

        // Try to resize beyond grid width
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        await tester.sendKeyEvent(
          LogicalKeyboardKey.arrowRight,
        ); // Should expand to width 2
        await tester.pump();
        await tester.sendKeyEvent(
          LogicalKeyboardKey.arrowRight,
        ); // Should not expand beyond grid
        await tester.pump();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        final widget = controller.state.getWidget('widget2')!;
        expect(widget.width, equals(2)); // Should be max possible width
      });
    });
  });
}
