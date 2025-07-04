import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_resize_controls.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';

void main() {
  group('Grid Resize Controls', () {
    late LayoutState testLayoutState;
    late CategorizedToolbox testToolbox;
    late Map<String, Widget Function(BuildContext, WidgetPlacement)>
    testWidgetBuilders;

    setUp(() {
      testLayoutState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TestWidget',
            column: 1,
            row: 1,
            width: 2,
            height: 2,
          ),
        ],
      );

      testToolbox = CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Test',
            items: [
          ToolboxItem(
            name: 'TestWidget',
            displayName: 'Test Widget',
            defaultWidth: 1,
            defaultHeight: 1,
            toolboxBuilder: (context) => Container(color: Colors.blue),
            gridBuilder: (context, placement) => Container(color: Colors.blue),
              ),
            ],
          ),
        ],
      );

      testWidgetBuilders = {
        'TestWidget': (context, placement) => Container(color: Colors.blue),
      };
    });

    testWidgets('GridResizeControls displays current dimensions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: GridResizeControls(
                dimensions: const GridDimensions(columns: 5, rows: 3),
                child: Container(color: Colors.grey),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display current column and row counts
      expect(find.text('5 cols'), findsOneWidget);
      expect(find.text('3 rows'), findsOneWidget);
    });

    testWidgets('GridResizeControls shows resize buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: GridResizeControls(
                dimensions: const GridDimensions(columns: 4, rows: 4),
                child: Container(color: Colors.grey),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find add and remove buttons for both columns and rows
      expect(
        find.byIcon(Icons.add),
        findsNWidgets(2),
      ); // One for columns, one for rows
      expect(
        find.byIcon(Icons.remove),
        findsNWidgets(2),
      ); // One for columns, one for rows
    });

    testWidgets(
      'GridResizeControls calls onGridResize when column button is pressed',
      (WidgetTester tester) async {
        GridDimensions? resizedDimensions;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width:
                    600, // Larger to accommodate resize controls positioned outside
                height: 600,
                child: GridResizeControls(
                  dimensions: const GridDimensions(columns: 4, rows: 4),
                  onGridResize: (dimensions) {
                    resizedDimensions = dimensions;
                  },
                  child: Container(color: Colors.grey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and invoke the add button for columns directly
        final addButtons = find.byIcon(Icons.add);
        expect(addButtons, findsNWidgets(2));

        // Find the IconButton that contains the first add icon and invoke its callback
        final firstIconButton = find.ancestor(
          of: addButtons.first,
          matching: find.byType(IconButton),
        );
        expect(firstIconButton, findsOneWidget);

        final iconButton = tester.widget<IconButton>(firstIconButton);
        if (iconButton.onPressed != null) {
          iconButton.onPressed!();
          await tester.pump();
        }

        // Verify callback was called with increased columns
        expect(resizedDimensions, isNotNull);
        expect(resizedDimensions!.columns, equals(5));
        expect(resizedDimensions!.rows, equals(4));
      },
    );

    testWidgets(
      'GridResizeControls calls onGridResize when row button is pressed',
      (WidgetTester tester) async {
        GridDimensions? resizedDimensions;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600, // Larger to accommodate resize controls
                height: 600,
                child: GridResizeControls(
                  dimensions: const GridDimensions(columns: 4, rows: 4),
                  onGridResize: (dimensions) {
                    resizedDimensions = dimensions;
                  },
                  child: Container(color: Colors.grey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and invoke the add button for rows directly
        final addButtons = find.byIcon(Icons.add);
        expect(addButtons, findsNWidgets(2));

        // Find the IconButton that contains the last add icon and invoke its callback
        final lastIconButton = find.ancestor(
          of: addButtons.last,
          matching: find.byType(IconButton),
        );
        expect(lastIconButton, findsOneWidget);

        final iconButton = tester.widget<IconButton>(lastIconButton);
        if (iconButton.onPressed != null) {
          iconButton.onPressed!();
          await tester.pump();
        }

        // Verify callback was called with increased rows
        expect(resizedDimensions, isNotNull);
        expect(resizedDimensions!.columns, equals(4));
        expect(resizedDimensions!.rows, equals(5));
      },
    );

    testWidgets('GridResizeControls respects minimum column constraints', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600, // Larger to accommodate resize controls
              height: 600,
              child: GridResizeControls(
                dimensions: const GridDimensions(
                  columns: 1,
                  rows: 4,
                ), // At minimum
                minColumns: 1,
                child: Container(color: Colors.grey),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the remove button for columns
      final removeButtons = find.byIcon(Icons.remove);
      expect(removeButtons, findsNWidgets(2));

      // The first remove button should be disabled when at minimum
      // Find the IconButton that contains the first remove icon
      final firstRemoveButton = find.ancestor(
        of: removeButtons.first,
        matching: find.byType(IconButton),
      );
      expect(firstRemoveButton, findsOneWidget);

      final iconButton = tester.widget<IconButton>(firstRemoveButton);
      expect(iconButton.onPressed, isNull); // Should be disabled
    });

    testWidgets('GridResizeControls respects maximum column constraints', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600, // Larger to accommodate resize controls
              height: 600,
              child: GridResizeControls(
                dimensions: const GridDimensions(
                  columns: 12,
                  rows: 4,
                ), // At maximum
                maxColumns: 12,
                child: Container(color: Colors.grey),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the add button for columns
      final addButtons = find.byIcon(Icons.add);
      expect(addButtons, findsNWidgets(2));

      // The first add button should be disabled when at maximum
      final firstAddButton = find.ancestor(
        of: addButtons.first,
        matching: find.byType(IconButton),
      );
      expect(firstAddButton, findsOneWidget);

      final iconButton = tester.widget<IconButton>(firstAddButton);
      expect(iconButton.onPressed, isNull); // Should be disabled
    });

    testWidgets('GridResizeControls respects minimum row constraints', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600, // Larger to accommodate resize controls
              height: 600,
              child: GridResizeControls(
                dimensions: const GridDimensions(
                  columns: 4,
                  rows: 1,
                ), // At minimum
                minRows: 1,
                child: Container(color: Colors.grey),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the remove button for rows
      final removeButtons = find.byIcon(Icons.remove);
      expect(removeButtons, findsNWidgets(2));

      // The second remove button should be disabled when at minimum
      final secondRemoveButton = find.ancestor(
        of: removeButtons.last,
        matching: find.byType(IconButton),
      );
      expect(secondRemoveButton, findsOneWidget);

      final iconButton = tester.widget<IconButton>(secondRemoveButton);
      expect(iconButton.onPressed, isNull); // Should be disabled
    });

    testWidgets('GridResizeControls respects maximum row constraints', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600, // Larger to accommodate resize controls
              height: 600,
              child: GridResizeControls(
                dimensions: const GridDimensions(
                  columns: 4,
                  rows: 20,
                ), // At maximum
                maxRows: 20,
                child: Container(color: Colors.grey),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the add button for rows
      final addButtons = find.byIcon(Icons.add);
      expect(addButtons, findsNWidgets(2));

      // The second add button should be disabled when at maximum
      final secondAddButton = find.ancestor(
        of: addButtons.last,
        matching: find.byType(IconButton),
      );
      expect(secondAddButton, findsOneWidget);

      final iconButton = tester.widget<IconButton>(secondAddButton);
      expect(iconButton.onPressed, isNull); // Should be disabled
    });

    group('Integration with GridDragTarget', () {
      testWidgets('GridDragTarget includes resize controls', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: GridDragTarget(
                  layoutState: testLayoutState,
                  widgetBuilders: testWidgetBuilders,
                  toolbox: testToolbox.toSimpleToolbox(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should find the GridResizeControls widget
        expect(find.byType(GridResizeControls), findsOneWidget);

        // Should display current dimensions
        expect(find.text('4 cols'), findsOneWidget);
        expect(find.text('4 rows'), findsOneWidget);
      });

      testWidgets('GridDragTarget passes onGridResize callback', (
        WidgetTester tester,
      ) async {
        GridDimensions? resizedDimensions;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600, // Larger to accommodate resize controls
                height: 600,
                child: GridDragTarget(
                  layoutState: testLayoutState,
                  widgetBuilders: testWidgetBuilders,
                  toolbox: testToolbox.toSimpleToolbox(),
                  onGridResize: (dimensions) {
                    resizedDimensions = dimensions;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and invoke an add button directly
        final addButtons = find.byIcon(Icons.add);
        expect(addButtons, findsAtLeastNWidgets(1));

        // Find the IconButton that contains the first add icon and invoke its callback
        final firstIconButton = find.ancestor(
          of: addButtons.first,
          matching: find.byType(IconButton),
        );
        expect(firstIconButton, findsOneWidget);

        final iconButton = tester.widget<IconButton>(firstIconButton);
        if (iconButton.onPressed != null) {
          iconButton.onPressed!();
          await tester.pump();
        }

        // Verify callback was called
        expect(resizedDimensions, isNotNull);
      });
    });

    group('Visual feedback', () {
      testWidgets('Resize controls show drag indicators', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: GridResizeControls(
                  dimensions: const GridDimensions(columns: 4, rows: 4),
                  child: Container(color: Colors.grey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should find drag indicators
        expect(
          find.byIcon(Icons.drag_indicator),
          findsNWidgets(2),
        ); // One for columns, one for rows
      });

      testWidgets('Resize controls position correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: GridResizeControls(
                  dimensions: const GridDimensions(columns: 4, rows: 4),
                  child: Container(color: Colors.grey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find positioned widgets for column and row controls
        final positionedWidgets = find.byType(Positioned);
        expect(
          positionedWidgets,
          findsNWidgets(2),
        ); // One for columns, one for rows
      });
    });

    group('Button functionality', () {
      testWidgets('Column increase button works correctly', (
        WidgetTester tester,
      ) async {
        GridDimensions? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600, // Larger to accommodate resize controls
                height: 600,
                child: GridResizeControls(
                  dimensions: const GridDimensions(columns: 3, rows: 4),
                  onGridResize: (dimensions) => result = dimensions,
                  child: Container(color: Colors.grey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and invoke column increase button directly
        final addButtons = find.byIcon(Icons.add);
        final firstIconButton = find.ancestor(
          of: addButtons.first,
          matching: find.byType(IconButton),
        );
        expect(firstIconButton, findsOneWidget);

        final iconButton = tester.widget<IconButton>(firstIconButton);
        if (iconButton.onPressed != null) {
          iconButton.onPressed!();
          await tester.pump();
        }

        expect(result, isNotNull);
        expect(result!.columns, equals(4));
        expect(result!.rows, equals(4));
      });

      testWidgets('Column decrease button works correctly', (
        WidgetTester tester,
      ) async {
        GridDimensions? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600, // Larger to accommodate resize controls
                height: 600,
                child: GridResizeControls(
                  dimensions: const GridDimensions(columns: 5, rows: 4),
                  onGridResize: (dimensions) => result = dimensions,
                  child: Container(color: Colors.grey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and invoke column decrease button directly
        final removeButtons = find.byIcon(Icons.remove);
        final firstIconButton = find.ancestor(
          of: removeButtons.first,
          matching: find.byType(IconButton),
        );
        expect(firstIconButton, findsOneWidget);

        final iconButton = tester.widget<IconButton>(firstIconButton);
        if (iconButton.onPressed != null) {
          iconButton.onPressed!();
          await tester.pump();
        }

        expect(result, isNotNull);
        expect(result!.columns, equals(4));
        expect(result!.rows, equals(4));
      });

      testWidgets('Row increase button works correctly', (
        WidgetTester tester,
      ) async {
        GridDimensions? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600, // Larger to accommodate resize controls
                height: 600,
                child: GridResizeControls(
                  dimensions: const GridDimensions(columns: 4, rows: 3),
                  onGridResize: (dimensions) => result = dimensions,
                  child: Container(color: Colors.grey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and invoke row increase button directly
        final addButtons = find.byIcon(Icons.add);
        final lastIconButton = find.ancestor(
          of: addButtons.last,
          matching: find.byType(IconButton),
        );
        expect(lastIconButton, findsOneWidget);

        final iconButton = tester.widget<IconButton>(lastIconButton);
        if (iconButton.onPressed != null) {
          iconButton.onPressed!();
          await tester.pump();
        }

        expect(result, isNotNull);
        expect(result!.columns, equals(4));
        expect(result!.rows, equals(4));
      });

      testWidgets('Row decrease button works correctly', (
        WidgetTester tester,
      ) async {
        GridDimensions? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600, // Larger to accommodate resize controls
                height: 600,
                child: GridResizeControls(
                  dimensions: const GridDimensions(columns: 4, rows: 5),
                  onGridResize: (dimensions) => result = dimensions,
                  child: Container(color: Colors.grey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and invoke row decrease button directly
        final removeButtons = find.byIcon(Icons.remove);
        final lastIconButton = find.ancestor(
          of: removeButtons.last,
          matching: find.byType(IconButton),
        );
        expect(lastIconButton, findsOneWidget);

        final iconButton = tester.widget<IconButton>(lastIconButton);
        if (iconButton.onPressed != null) {
          iconButton.onPressed!();
          await tester.pump();
        }

        expect(result, isNotNull);
        expect(result!.columns, equals(4));
        expect(result!.rows, equals(4));
      });
    });
  });
}
