import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  testWidgets('minimal grid widget visibility test', (WidgetTester tester) async {
    // Create a minimal toolbox with one widget
    final toolbox = CategorizedToolbox(
      categories: [
        ToolboxCategory(
          name: 'Test',
          items: [
        ToolboxItem(
          name: 'test_widget',
          displayName: 'Test Widget',
          toolboxBuilder: (context) => const Icon(Icons.widgets),
          gridBuilder: (context, placement) => Container(
            color: Colors.red, // Bright red to be clearly visible
            child: const Center(
              child: Text(
                'TEST WIDGET',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          defaultWidth: 2,
          defaultHeight: 1,
        ),
          ],
        ),
      ],
    );
    
    // Create initial layout with one widget
    final initialLayout = LayoutState(
      dimensions: const GridDimensions(columns: 4, rows: 4),
      widgets: [
        WidgetPlacement(
          id: 'test_widget_1',
          widgetName: 'test_widget',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
          properties: {},
        ),
      ],
    );
    
    // Build a minimal FormLayout
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormLayout(
            toolbox: toolbox,
            initialLayout: initialLayout,
            onLayoutChanged: (layout) {
              print('Layout changed: ${layout.widgets.length} widgets');
            },
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Debug: Print widget tree
    print('\n=== WIDGET TREE ===');
    debugDumpApp();
    
    // Check if we can find the red container
    final redContainers = find.byWidgetPredicate(
      (widget) => widget is Container && widget.color == Colors.red,
    );
    
    print('\nFound ${redContainers.evaluate().length} red containers');
    
    // Check if we can find the test text
    final testText = find.text('TEST WIDGET');
    print('Found ${testText.evaluate().length} TEST WIDGET texts');
    
    // Try to get the render object of the FormLayout
    final formLayout = find.byType(FormLayout);
    if (formLayout.evaluate().isNotEmpty) {
      final renderBox = tester.renderObject(formLayout.first) as RenderBox;
      print('\nFormLayout size: ${renderBox.size}');
    }
    
    // Expectations
    expect(redContainers, findsOneWidget,
        reason: 'Should find one red container in the grid');
    expect(testText, findsOneWidget,
        reason: 'Should find TEST WIDGET text');
  });
}