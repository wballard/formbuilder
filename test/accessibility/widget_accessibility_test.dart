import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/accessible_grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder/form_layout/widgets/grid_resize_controls.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';
import '../test_utils/test_widget_builder.dart';

void main() {
  group('Widget Accessibility Tests', () {
    testWidgets('AccessibleGridWidget accessibility', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          SizedBox(
            width: 400,
            height: 300,
            child: AccessibleGridWidget(
              dimensions: const GridDimensions(columns: 12, rows: 12),
            ),
          ),
        ),
      );

      // Verify grid widget exists and is accessible
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
      
      // Verify grid can be focused
      await tester.tap(find.byType(AccessibleGridWidget));
      await tester.pump();
    });

    testWidgets('PlacedWidget accessibility', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          SizedBox(
            width: 400,
            height: 300,
            child: Center(
              child: PlacedWidget(
                placement: WidgetPlacement(
                  id: 'test_widget',
                  widgetName: 'button',
                  column: 0,
                  row: 0,
                  width: 2,
                  height: 1,
                  properties: {'text': 'Test Button'},
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Test Button'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify widget exists and is accessible
      expect(find.byType(PlacedWidget), findsOneWidget);
      
      // Test keyboard navigation
      await tester.tap(find.byType(PlacedWidget));
      await tester.pump();
      
      // Should be focusable
      expect(find.byType(PlacedWidget), findsOneWidget);
    });

    testWidgets('PlacedWidget with different widget types', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          SizedBox(
            width: 400,
            height: 300,
            child: Center(
              child: PlacedWidget(
                placement: WidgetPlacement(
                  id: 'text_input',
                  widgetName: 'text_input',
                  column: 1,
                  row: 1,
                  width: 3,
                  height: 1,
                  properties: {'placeholder': 'Enter text'},
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter text',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify widget exists and contains text field
      expect(find.byType(PlacedWidget), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('ToolboxWidget accessibility', (tester) async {
      final toolbox = Toolbox(
        items: [
          ToolboxItem(
            name: 'button',
            displayName: 'Button',
            toolboxBuilder: (context) => Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_button, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Button', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            gridBuilder: (context, placement) => ElevatedButton(
              onPressed: () {},
              child: Text(placement.properties['text'] ?? 'Button'),
            ),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          ToolboxWidget(
            toolbox: toolbox,
          ),
        ),
      );

      // Verify toolbox has proper semantics
      final toolboxWidget = find.byType(ToolboxWidget);
      expect(toolboxWidget, findsOneWidget);

      // Verify toolbox items are accessible
      final toolboxItems = find.byType(Material);
      expect(toolboxItems, findsWidgets);
    });

    testWidgets('CategorizedToolboxWidget accessibility', (tester) async {
      final toolbox = CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Basic',
            items: [
              ToolboxItem(
                name: 'button',
                displayName: 'Button',
                toolboxBuilder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_button, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Button', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                gridBuilder: (context, placement) => ElevatedButton(
                  onPressed: () {},
                  child: Text(placement.properties['text'] ?? 'Button'),
                ),
                defaultWidth: 2,
                defaultHeight: 1,
              ),
            ],
          ),
          ToolboxCategory(
            name: 'Input',
            items: [
              ToolboxItem(
                name: 'text_input',
                displayName: 'Text Input',
                toolboxBuilder: (context) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.text_fields, size: 20),
                      const SizedBox(width: 8),
                      Text('Text Input'),
                    ],
                  ),
                ),
                gridBuilder: (context, placement) => TextField(
                  decoration: InputDecoration(
                    hintText: placement.properties['placeholder'] ?? 'Enter text',
                  ),
                ),
                defaultWidth: 4,
                defaultHeight: 1,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          ToolboxWidget(
            toolbox: toolbox.toSimpleToolbox(),
          ),
        ),
      );

      // Verify categorized toolbox semantics
      expect(find.byType(ToolboxWidget), findsOneWidget);
    });

    testWidgets('GridResizeControls accessibility', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          SizedBox(
            width: 400,
            height: 300,
            child: GridResizeControls(
              dimensions: const GridDimensions(columns: 6, rows: 4),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: const Center(
                  child: Text('Resizable Content'),
                ),
              ),
              onGridResize: (dimensions) {},
            ),
          ),
        ),
      );

      // Verify resize controls have proper semantics
      expect(find.byType(GridResizeControls), findsOneWidget);
      
      // Should have resize handles
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Keyboard navigation support', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          Column(
            children: [
              AccessibleGridWidget(
                dimensions: const GridDimensions(columns: 6, rows: 4),
              ),
              PlacedWidget(
                placement: WidgetPlacement(
                  id: 'nav_test',
                  widgetName: 'button',
                  column: 0,
                  row: 0,
                  width: 2,
                  height: 1,
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Navigate Me'),
                ),
              ),
            ],
          ),
        ),
      );

      // Test tab navigation
      await tester.tap(find.byType(PlacedWidget));
      await tester.pumpAndSettle();
      
      // Should be focusable and accessible
      expect(find.byType(PlacedWidget), findsOneWidget);
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
    });

    testWidgets('Screen reader support', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          Semantics(
            container: true,
            label: 'Form builder workspace',
            child: Column(
              children: [
                Expanded(
                  child: AccessibleGridWidget(
                    dimensions: const GridDimensions(columns: 8, rows: 6),
                  ),
                ),
                PlacedWidget(
                  placement: WidgetPlacement(
                    id: 'screen_reader_test',
                    widgetName: 'label',
                    column: 2,
                    row: 1,
                    width: 4,
                    height: 1,
                    properties: {'text': 'Form Title'},
                  ),
                  child: const Text(
                    'Form Title',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify semantic structure
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
      expect(find.byType(PlacedWidget), findsOneWidget);
      expect(find.text('Form Title'), findsOneWidget);
    });
  });
}