import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';

void main() {
  group('FormLayout', () {
    late CategorizedToolbox testToolbox;

    setUp(() {
      testToolbox = CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Test Widgets',
            items: [
              ToolboxItem(
                name: 'test_widget',
                displayName: 'Test Widget',
                toolboxBuilder: (context) => Container(
                  color: Colors.blue,
                  child: const Center(child: Text('Test')),
                ),
                gridBuilder: (context, placement) => Container(
                  color: Colors.blue.withValues(alpha: 0.5),
                  child: Center(child: Text(placement.id)),
                ),
                defaultWidth: 2,
                defaultHeight: 1,
              ),
            ],
          ),
        ],
      );
    });

    testWidgets('renders with default configuration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
            ),
          ),
        ),
      );

      // Check that toolbox is visible
      expect(find.text('Test Widgets'), findsOneWidget);
      expect(find.text('Test Widget'), findsOneWidget);
      
      // Check that toolbar is visible
      expect(find.byIcon(Icons.undo), findsOneWidget);
      expect(find.byIcon(Icons.redo), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      
      // Check grid size indicator
      expect(find.text('4 × 5'), findsOneWidget);
    });

    testWidgets('hides toolbox when showToolbox is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              showToolbox: false,
            ),
          ),
        ),
      );

      // Check that toolbox is not visible
      expect(find.text('Test Widgets'), findsNothing);
      expect(find.text('Test Widget'), findsNothing);
      
      // But toolbar should still be visible
      expect(find.byIcon(Icons.undo), findsOneWidget);
    });

    testWidgets('renders with initial layout', (tester) async {
      final initialLayout = LayoutState(
        dimensions: const GridDimensions(columns: 6, rows: 8),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'test_widget',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              initialLayout: initialLayout,
            ),
          ),
        ),
      );

      // Check grid size indicator shows custom size
      expect(find.text('6 × 8'), findsOneWidget);
      
      // Check that initial widget is rendered
      expect(find.text('widget1'), findsOneWidget);
    });

    testWidgets('calls onLayoutChanged callback', (tester) async {
      LayoutState? lastState;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              onLayoutChanged: (state) {
                lastState = state;
              },
            ),
          ),
        ),
      );

      // Wait for any initial callbacks
      await tester.pump(const Duration(milliseconds: 200));
      
      // The callback should have been called with initial state
      expect(lastState, isNotNull);
      expect(lastState!.dimensions.columns, 4);
      expect(lastState!.dimensions.rows, 5);
    });

    testWidgets('disables undo/redo when enableUndo is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              enableUndo: false,
            ),
          ),
        ),
      );

      // Check that undo/redo buttons are not visible
      expect(find.byIcon(Icons.undo), findsNothing);
      expect(find.byIcon(Icons.redo), findsNothing);
    });

    testWidgets('toggles preview mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
            ),
          ),
        ),
      );

      // Initially should show visibility icon (not in preview mode)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
      
      // Toggle preview mode
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      
      // Should now show visibility_off icon (in preview mode)
      expect(find.byIcon(Icons.visibility), findsNothing);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('renders toolbox horizontally by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
            ),
          ),
        ),
      );

      // Get positions of toolbox and grid
      final toolboxPosition = tester.getCenter(find.text('Test Widget'));
      final gridPosition = tester.getCenter(find.byType(GridDragTarget));
      
      // Toolbox should be to the left of grid
      expect(toolboxPosition.dx < gridPosition.dx, isTrue);
      expect((toolboxPosition.dy - gridPosition.dy).abs() < 100, isTrue); // Similar Y position
    });

    testWidgets('renders toolbox vertically when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              toolboxPosition: Axis.vertical,
            ),
          ),
        ),
      );

      // Get positions of toolbox and grid
      final toolboxPosition = tester.getCenter(find.text('Test Widget'));
      final gridPosition = tester.getCenter(find.byType(GridDragTarget));
      
      // Toolbox should be above grid
      expect(toolboxPosition.dy < gridPosition.dy, isTrue);
      expect((toolboxPosition.dx - gridPosition.dx).abs() < 100, isTrue); // Similar X position
    });

    testWidgets('uses custom toolbox width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              toolboxWidth: 300,
            ),
          ),
        ),
      );

      // Find the toolbox widget container
      final toolboxContainer = find.ancestor(
        of: find.text('Test Widget'),
        matching: find.byType(SizedBox),
      ).first;
      
      final size = tester.getSize(toolboxContainer);
      expect(size.width, 300);
    });

    testWidgets('uses custom toolbox height in vertical layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              toolboxPosition: Axis.vertical,
              toolboxHeight: 200,
            ),
          ),
        ),
      );

      // Find the toolbox widget container
      final toolboxContainer = find.ancestor(
        of: find.text('Test Widget'),
        matching: find.byType(SizedBox),
      ).first;
      
      final size = tester.getSize(toolboxContainer);
      expect(size.height, 200);
    });

    testWidgets('applies custom theme', (tester) async {
      final customTheme = ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: const ColorScheme.light(
          primary: Colors.purple,
          surface: Colors.purple,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              theme: customTheme,
            ),
          ),
        ),
      );

      // Check that the custom theme is applied
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FormLayout),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.decoration, isNotNull);
    });

    testWidgets('switches to vertical layout on small screens', (tester) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              toolboxPosition: Axis.horizontal, // Request horizontal
            ),
          ),
        ),
      );

      // Get positions of toolbox and grid
      final toolboxPosition = tester.getCenter(find.text('Test Widget'));
      final gridPosition = tester.getCenter(find.byType(GridDragTarget));
      
      // Should be vertical layout due to small screen
      expect(toolboxPosition.dy < gridPosition.dy, isTrue);
      
      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}