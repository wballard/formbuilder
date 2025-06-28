import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/form_preview.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('FormPreview', () {
    late LayoutState testLayoutState;
    late Map<String, Widget Function(BuildContext, WidgetPlacement)>
    testWidgetBuilders;

    setUp(() {
      testLayoutState = LayoutState(
        dimensions: const GridDimensions(columns: 3, rows: 3),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TestButton',
            column: 0,
            row: 0,
            width: 1,
            height: 1,
          ),
          WidgetPlacement(
            id: 'widget2',
            widgetName: 'TestTextField',
            column: 1,
            row: 0,
            width: 1,
            height: 1,
          ),
          WidgetPlacement(
            id: 'widget3',
            widgetName: 'UnknownWidget',
            column: 0,
            row: 1,
            width: 2,
            height: 1,
          ),
        ],
      );

      testWidgetBuilders = {
        'TestButton': (context, placement) =>
            ElevatedButton(onPressed: () {}, child: const Text('Test Button')),
        'TestTextField': (context, placement) => const TextField(
          decoration: InputDecoration(labelText: 'Test Field'),
        ),
      };
    });

    testWidgets('creates widget with required properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormPreview(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      expect(find.byType(FormPreview), findsOneWidget);
    });

    testWidgets('shows preview mode indicator by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormPreview(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      expect(find.text('Preview Mode'), findsOneWidget);
    });

    testWidgets('can hide preview mode indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormPreview(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              showPreviewIndicator: false,
            ),
          ),
        ),
      );

      expect(find.text('Preview Mode'), findsNothing);
    });

    testWidgets('renders all widgets from layout state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormPreview(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows error widget for unknown widget types', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormPreview(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      expect(find.text('Unknown widget: UnknownWidget'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      const customColor = Colors.lightBlue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormPreview(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });

    testWidgets('widgets remain interactive in preview mode', (
      WidgetTester tester,
    ) async {
      bool buttonPressed = false;

      final interactiveWidgetBuilders = {
        'TestButton': (context, placement) => ElevatedButton(
          onPressed: () {
            buttonPressed = true;
          },
          child: const Text('Test Button'),
        ),
      };

      final simpleLayoutState = LayoutState(
        dimensions: const GridDimensions(columns: 2, rows: 2),
        widgets: [
          WidgetPlacement(
            id: 'button1',
            widgetName: 'TestButton',
            column: 0,
            row: 0,
            width: 1,
            height: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormPreview(
              layoutState: simpleLayoutState,
              widgetBuilders: interactiveWidgetBuilders,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(buttonPressed, isTrue);
    });

    testWidgets('handles empty layout state', (WidgetTester tester) async {
      final emptyState = LayoutState(
        dimensions: const GridDimensions(columns: 2, rows: 2),
        widgets: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormPreview(
              layoutState: emptyState,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      expect(find.byType(FormPreview), findsOneWidget);
      expect(find.text('Preview Mode'), findsOneWidget);
    });
  });
}
