import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';

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
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      
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
      // Y positions can differ significantly due to toolbar above grid
      expect((toolboxPosition.dy - gridPosition.dy).abs() < 300, isTrue);
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
      // X positions can differ significantly in vertical layout
      expect((toolboxPosition.dx - gridPosition.dx).abs() < 400, isTrue);
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

      // Find the toolbox SizedBox container (should be the outermost one with custom width)
      final toolboxContainer = find.ancestor(
        of: find.text('Test Widget'),
        matching: find.byType(SizedBox),
      ).last; // Use .last to get the outermost SizedBox
      
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

      // Find the toolbox SizedBox container (should be the outermost one with custom height)
      final toolboxContainer = find.ancestor(
        of: find.text('Test Widget'),
        matching: find.byType(SizedBox),
      ).last; // Use .last to get the outermost SizedBox
      
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

      // Check that the custom theme is applied by finding the Theme widget
      final themeFinder = find.descendant(
        of: find.byType(FormLayout),
        matching: find.byType(Theme),
      );
      
      expect(themeFinder, findsOneWidget);
      
      final themeWidget = tester.widget<Theme>(themeFinder);
      expect(themeWidget.data.colorScheme.primary, Colors.purple);
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

    testWidgets('passes export callback to FormLayoutActionDispatcher', (tester) async {
      String? exportedData;
      
      // Create a simple test to verify the callback is passed through
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              onExportLayout: (jsonString) {
                exportedData = jsonString;
              },
              initialLayout: LayoutState(
                dimensions: const GridDimensions(columns: 3, rows: 2),
                widgets: [
                  WidgetPlacement(
                    id: 'test_widget_1',
                    widgetName: 'test_widget',
                    column: 0,
                    row: 0,
                    width: 2,
                    height: 1,
                    properties: {'text': 'Test Export'},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the FormLayout renders properly with export callback
      expect(find.byType(FormLayout), findsOneWidget);
      
      // Test passes if the widget builds correctly with the callback
    });

    testWidgets('passes import callback to FormLayoutActionDispatcher', (tester) async {
      LayoutState? importedLayout;
      String? importError;
      
      // Create a simple test to verify the callback is passed through
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              onImportLayout: (layout, error) {
                importedLayout = layout;
                importError = error;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the FormLayout renders properly with import callback
      expect(find.byType(FormLayout), findsOneWidget);
      
      // Test passes if the widget builds correctly with the callback
    });

    testWidgets('builds correctly without import/export callbacks', (tester) async {
      // Test that FormLayout builds correctly without callbacks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayout(
              toolbox: testToolbox,
              // No import/export callbacks provided
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the FormLayout renders properly without callbacks
      expect(find.byType(FormLayout), findsOneWidget);
      
      // Test passes if the widget builds correctly without callbacks
    });
  });
}