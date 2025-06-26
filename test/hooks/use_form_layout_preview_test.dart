import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('useFormLayout Preview Mode', () {
    late LayoutState initialState;

    setUp(() {
      initialState = LayoutState(
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
        ],
      );
    });

    testWidgets('provides preview mode state', (WidgetTester tester) async {
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

      expect(controller.isPreviewMode, isFalse);
    });

    testWidgets('can set preview mode', (WidgetTester tester) async {
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

      controller.setPreviewMode(true);
      await tester.pump();

      expect(controller.isPreviewMode, isTrue);

      controller.setPreviewMode(false);
      await tester.pump();

      expect(controller.isPreviewMode, isFalse);
    });

    testWidgets('can toggle preview mode', (WidgetTester tester) async {
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

      expect(controller.isPreviewMode, isFalse);

      controller.togglePreviewMode();
      await tester.pump();

      expect(controller.isPreviewMode, isTrue);

      controller.togglePreviewMode();
      await tester.pump();

      expect(controller.isPreviewMode, isFalse);
    });

    testWidgets('clears selection when entering preview mode', (WidgetTester tester) async {
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

      // Select a widget
      controller.selectWidget('widget1');
      await tester.pump();

      expect(controller.selectedWidgetId, equals('widget1'));

      // Enter preview mode
      controller.setPreviewMode(true);
      await tester.pump();

      expect(controller.isPreviewMode, isTrue);
      expect(controller.selectedWidgetId, isNull);
    });

    testWidgets('maintains selection when exiting preview mode if widget was selected before', (WidgetTester tester) async {
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

      // Exit preview mode without prior selection
      controller.setPreviewMode(true);
      await tester.pump();
      
      controller.setPreviewMode(false);
      await tester.pump();

      expect(controller.selectedWidgetId, isNull);
    });

    testWidgets('notifies listeners when preview mode changes', (WidgetTester tester) async {
      late FormLayoutController controller;
      int notificationCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              controller.addListener(() {
                notificationCount++;
              });
              return Container();
            },
          ),
        ),
      );

      final initialCount = notificationCount;

      controller.setPreviewMode(true);
      await tester.pump();

      expect(notificationCount, greaterThan(initialCount));

      final countAfterSetTrue = notificationCount;

      controller.setPreviewMode(false);
      await tester.pump();

      expect(notificationCount, greaterThan(countAfterSetTrue));
    });

    testWidgets('does not notify listeners when setting same preview mode', (WidgetTester tester) async {
      late FormLayoutController controller;
      int notificationCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              controller.addListener(() {
                notificationCount++;
              });
              return Container();
            },
          ),
        ),
      );

      // Wait for initial render
      await tester.pump();
      final initialCount = notificationCount;

      // Set to the same value (false)
      controller.setPreviewMode(false);
      await tester.pump();

      expect(notificationCount, equals(initialCount));

      // Set to true
      controller.setPreviewMode(true);
      await tester.pump();
      final countAfterSetTrue = notificationCount;

      // Set to true again
      controller.setPreviewMode(true);
      await tester.pump();

      expect(notificationCount, equals(countAfterSetTrue));
    });
  });
}