import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('useFormLayout', () {
    late LayoutState initialState;

    setUp(() {
      initialState = LayoutState.empty();
    });

    testWidgets('creates controller with initial state', (WidgetTester tester) async {
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

      expect(controller, isNotNull);
      expect(controller.state, equals(initialState));
      expect(controller.selectedWidgetId, isNull);
      expect(controller.draggingWidgetIds, isEmpty);
      expect(controller.resizingWidgetIds, isEmpty);
    });

    testWidgets('adds widget successfully', (WidgetTester tester) async {
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

      expect(controller.state.widgets, contains(placement));
    });

    testWidgets('removes widget successfully', (WidgetTester tester) async {
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
    });

    testWidgets('updates widget successfully', (WidgetTester tester) async {
      late FormLayoutController controller;
      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final updatedPlacement = placement.copyWith(column: 1, row: 1);
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

      controller.updateWidget('widget1', updatedPlacement);
      await tester.pump();

      expect(controller.state.getWidget('widget1'), equals(updatedPlacement));
    });

    testWidgets('moves widget successfully', (WidgetTester tester) async {
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
    });

    testWidgets('resizes widget successfully', (WidgetTester tester) async {
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
    });

    testWidgets('selects widget', (WidgetTester tester) async {
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

      controller.selectWidget('widget1');
      await tester.pump();

      expect(controller.selectedWidgetId, equals('widget1'));
    });

    testWidgets('clears selection', (WidgetTester tester) async {
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

      controller.selectWidget('widget1');
      await tester.pump();
      expect(controller.selectedWidgetId, equals('widget1'));

      controller.selectWidget(null);
      await tester.pump();
      expect(controller.selectedWidgetId, isNull);
    });

    testWidgets('resizes grid successfully', (WidgetTester tester) async {
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

      final newDimensions = const GridDimensions(columns: 6, rows: 6);
      controller.resizeGrid(newDimensions);
      await tester.pump();

      expect(controller.state.dimensions, equals(newDimensions));
    });

    testWidgets('manages dragging state', (WidgetTester tester) async {
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

      controller.startDragging('widget1');
      await tester.pump();
      expect(controller.draggingWidgetIds, contains('widget1'));

      controller.stopDragging('widget1');
      await tester.pump();
      expect(controller.draggingWidgetIds, isNot(contains('widget1')));
    });

    testWidgets('manages resizing state', (WidgetTester tester) async {
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

      controller.startResizing('widget1');
      await tester.pump();
      expect(controller.resizingWidgetIds, contains('widget1'));

      controller.stopResizing('widget1');
      await tester.pump();
      expect(controller.resizingWidgetIds, isNot(contains('widget1')));
    });

    testWidgets('validates widget addition - prevents overlaps', (WidgetTester tester) async {
      late FormLayoutController controller;
      final placement1 = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 2,
        height: 2,
      );
      final placement2 = WidgetPlacement(
        id: 'widget2',
        widgetName: 'TestWidget',
        column: 1,
        row: 1,
        width: 1,
        height: 1,
      );
      final stateWithWidget = initialState.addWidget(placement1);

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

      expect(() => controller.addWidget(placement2), throwsA(isA<ArgumentError>()));
    });

    testWidgets('validates widget addition - prevents out of bounds', (WidgetTester tester) async {
      late FormLayoutController controller;
      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 5,
        row: 5,
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

      expect(() => controller.addWidget(placement), throwsA(isA<ArgumentError>()));
    });

    testWidgets('validates widget move - prevents overlaps', (WidgetTester tester) async {
      late FormLayoutController controller;
      final placement1 = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final placement2 = WidgetPlacement(
        id: 'widget2',
        widgetName: 'TestWidget',
        column: 2,
        row: 2,
        width: 1,
        height: 1,
      );
      final stateWithWidgets = initialState.addWidget(placement1).addWidget(placement2);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(stateWithWidgets);
              return Container();
            },
          ),
        ),
      );

      expect(() => controller.moveWidget('widget1', 2, 2), throwsA(isA<ArgumentError>()));
    });

    testWidgets('validates widget resize - prevents overlaps', (WidgetTester tester) async {
      late FormLayoutController controller;
      final placement1 = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      final placement2 = WidgetPlacement(
        id: 'widget2',
        widgetName: 'TestWidget',
        column: 2,
        row: 2,
        width: 1,
        height: 1,
      );
      final stateWithWidgets = initialState.addWidget(placement1).addWidget(placement2);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(stateWithWidgets);
              return Container();
            },
          ),
        ),
      );

      expect(() => controller.resizeWidget('widget1', 4, 4), throwsA(isA<ArgumentError>()));
    });

    testWidgets('handles nonexistent widget operations gracefully', (WidgetTester tester) async {
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

      expect(() => controller.removeWidget('nonexistent'), throwsA(isA<ArgumentError>()));
      expect(() => controller.updateWidget('nonexistent', WidgetPlacement(
        id: 'test',
        widgetName: 'Test',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      )), throwsA(isA<ArgumentError>()));
      expect(() => controller.moveWidget('nonexistent', 0, 0), throwsA(isA<ArgumentError>()));
      expect(() => controller.resizeWidget('nonexistent', 1, 1), throwsA(isA<ArgumentError>()));
    });

    testWidgets('widget rebuilds on state changes', (WidgetTester tester) async {
      late FormLayoutController controller;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              buildCount++;
              return Text('Build count: $buildCount');
            },
          ),
        ),
      );

      expect(buildCount, equals(1));
      expect(find.text('Build count: 1'), findsOneWidget);

      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );

      controller.addWidget(placement);
      await tester.pump();

      expect(buildCount, equals(2));
      expect(find.text('Build count: 2'), findsOneWidget);
    });

    testWidgets('preserves controller identity across rebuilds', (WidgetTester tester) async {
      late FormLayoutController controller1;
      late FormLayoutController controller2;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller1 = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller2 = useFormLayout(initialState);
              return Container();
            },
          ),
        ),
      );

      expect(identical(controller1, controller2), isTrue);
    });
  });

  group('FormLayoutController', () {
    test('equality comparison works correctly', () {
      final state1 = LayoutState.empty();
      final state2 = LayoutState.empty();
      
      final controller1 = FormLayoutController(state1);
      final controller2 = FormLayoutController(state2);
      
      expect(controller1.state, equals(controller2.state));
    });
  });
}