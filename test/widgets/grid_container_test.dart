import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/widgets/accessible_grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/accessible_placed_widget.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'dart:math';

void main() {
  group('GridContainer', () {
    late LayoutState testLayoutState;
    late Map<String, Widget Function(BuildContext, WidgetPlacement)>
    testWidgetBuilders;

    setUp(() {
      const dimensions = GridDimensions(columns: 4, rows: 4);
      final placement1 = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TextInput',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      );
      final placement2 = WidgetPlacement(
        id: 'widget2',
        widgetName: 'Button',
        column: 2,
        row: 1,
        width: 2,
        height: 1,
      );

      testLayoutState = LayoutState(
        dimensions: dimensions,
        widgets: [placement1, placement2],
      );

      testWidgetBuilders = {
        'TextInput': (context, placement) => const TextField(
          decoration: InputDecoration(hintText: 'Enter text'),
        ),
        'Button': (context, placement) =>
            ElevatedButton(onPressed: () {}, child: const Text('Submit')),
      };
    });

    testWidgets('renders grid and placed widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      // Should find the grid container
      expect(find.byType(GridContainer), findsOneWidget);

      // Should find placed widgets
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('applies selection state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Scaffold(
            body: GridContainer(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              selectedWidgetId: 'widget1',
            ),
          ),
        ),
      );

      // Should have one selected widget
      final placedWidgets = tester.widgetList(find.byType(AccessiblePlacedWidget));
      int selectedCount = 0;
      for (final widget in placedWidgets) {
        if ((widget as AccessiblePlacedWidget).isSelected) {
          selectedCount++;
        }
      }
      expect(selectedCount, equals(1));
    });

    testWidgets('applies dragging state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              draggingWidgetIds: {'widget2'},
            ),
          ),
        ),
      );

      // Should have one dragging widget
      final placedWidgets = tester.widgetList(find.byType(AccessiblePlacedWidget));
      int draggingCount = 0;
      for (final widget in placedWidgets) {
        if ((widget as AccessiblePlacedWidget).isDragging) {
          draggingCount++;
        }
      }
      expect(draggingCount, equals(1));
    });

    testWidgets('passes through grid highlighting', (
      WidgetTester tester,
    ) async {
      final highlightedCells = {const Point(0, 2), const Point(1, 2)};

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Scaffold(
            body: GridContainer(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              highlightedCells: highlightedCells,
            ),
          ),
        ),
      );

      // Find the AccessibleGridWidget and check its highlighting
      final gridWidget = tester.widget<AccessibleGridWidget>(
        find.byType(AccessibleGridWidget),
      );
      expect(gridWidget.highlightedCells, equals(highlightedCells));
    });

    testWidgets('passes tap callback to placed widgets', (
      WidgetTester tester,
    ) async {
      // Test that the GridContainer correctly passes the tap callback to PlacedWidgets
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: GridContainer(
                layoutState: testLayoutState,
                widgetBuilders: testWidgetBuilders,
                onWidgetTap: (widgetId) {},
              ),
            ),
          ),
        ),
      );

      // Verify that PlacedWidgets are created with tap callback
      final placedWidgets = tester.widgetList<AccessiblePlacedWidget>(
        find.byType(AccessiblePlacedWidget),
      );
      for (final widget in placedWidgets) {
        expect(widget.onTap, isNotNull);
      }
    });

    testWidgets('shows error for missing widget builder', (
      WidgetTester tester,
    ) async {
      // Create layout with widget that has no builder
      const dimensions = GridDimensions(columns: 4, rows: 4);
      final placement = WidgetPlacement(
        id: 'missing',
        widgetName: 'UnknownWidget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      );
      final layoutWithMissing = LayoutState(
        dimensions: dimensions,
        widgets: [placement],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: layoutWithMissing,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      // Should show error container
      expect(find.text('UnknownWidget'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('updates when layout state changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      // Initially should have 2 widgets
      expect(find.byType(AccessiblePlacedWidget), findsNWidgets(2));

      // Update with new layout state
      final newPlacement = WidgetPlacement(
        id: 'widget3',
        widgetName: 'TextInput',
        column: 0,
        row: 2,
        width: 2,
        height: 1,
      );
      final newLayoutState = testLayoutState.addWidget(newPlacement);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: newLayoutState,
              widgetBuilders: testWidgetBuilders,
            ),
          ),
        ),
      );

      // Should now have 3 widgets
      expect(find.byType(AccessiblePlacedWidget), findsNWidgets(3));
    });

    testWidgets('passes highlight validation function', (
      WidgetTester tester,
    ) async {
      bool validationCalled = false;
      bool isCellValid(Point<int> cell) {
        validationCalled = true;
        return cell.x > 0;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              highlightedCells: {const Point(0, 0)},
              isCellValid: isCellValid,
            ),
          ),
        ),
      );

      // Find the AccessibleGridWidget and check validation function was passed
      final gridWidget = tester.widget<AccessibleGridWidget>(
        find.byType(AccessibleGridWidget),
      );
      expect(gridWidget.isCellValid, equals(isCellValid));

      // Verify the validation function can be called
      expect(isCellValid(const Point(0, 0)), isFalse);
      expect(isCellValid(const Point(1, 0)), isTrue);
      expect(validationCalled, isTrue);
    });

    testWidgets('handles multiple selected and dragging widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridContainer(
              layoutState: testLayoutState,
              widgetBuilders: testWidgetBuilders,
              selectedWidgetId: 'widget1',
              draggingWidgetIds: {'widget1', 'widget2'},
            ),
          ),
        ),
      );

      // Widget1 should be both selected and dragging
      final placedWidgets = tester.widgetList<AccessiblePlacedWidget>(
        find.byType(AccessiblePlacedWidget),
      );
      AccessiblePlacedWidget? widget1;
      AccessiblePlacedWidget? widget2;

      for (final widget in placedWidgets) {
        if (widget.placement.id == 'widget1') widget1 = widget;
        if (widget.placement.id == 'widget2') widget2 = widget;
      }

      expect(widget1?.isSelected, isTrue);
      expect(widget1?.isDragging, isTrue);
      expect(widget2?.isSelected, isFalse);
      expect(widget2?.isDragging, isTrue);
    });
  });
}
