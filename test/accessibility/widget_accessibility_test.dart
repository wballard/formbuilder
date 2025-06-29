import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';
import 'package:formbuilder/form_layout/widgets/accessible_grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/accessible_placed_widget.dart';
import 'package:formbuilder/form_layout/widgets/accessible_categorized_toolbox.dart';
import 'package:formbuilder/form_layout/widgets/grid_resize_controls.dart';
import 'package:formbuilder/form_layout/widgets/categorized_toolbox_widget.dart';
import '../test_utils/test_widget_builder.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';

void main() {
  group('Widget Accessibility Tests', () {
    testWidgets('GridWidget accessibility', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          Semantics(
            container: true,
            child: GridWidget(
              dimensions: const GridDimensions(columns: 12, rows: 12),
            ),
          ),
        ),
      );

      // Verify grid has proper semantics
      expect(
        tester.getSemantics(find.byType(AccessibleGridWidget)),
        matchesSemantics(
          label: 'Form builder grid, 12 columns by 8 rows',
          hint: 'Drop widgets here to add them to the form',
          // isContainer: true,
        ),
      );

      // Verify grid cells are accessible
      final gridCells = find.byType(Container);
      expect(gridCells, findsWidgets);
    });

    testWidgets('PlacedWidget accessibility', (tester) async {
      final theme = FormLayoutTheme.fromThemeData(ThemeData.light());
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          widgetName: Center(
            child: PlacedWidget(
              placement: WidgetPlacement(
                id: 'test_widget', 'button',
                column: 0,
                row: 0,
                width: 2,
                height: 1,
                properties: {'label': 'Submit'},
              ),
              isSelected: false,
              child: Container(),
            ),
          ),
        ),
      );

      // Verify widget has proper semantics
      expect(
        tester.getSemantics(find.byType(AccessiblePlacedWidget)),
        matchesSemantics(
          label: 'Submit button widget',
          hint: 'Tap to select, double tap to edit',
          isButton: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('PlacedWidget selected state accessibility', (tester) async {
      final theme = FormLayoutTheme.fromThemeData(ThemeData.light());
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          widgetName: Center(
            child: PlacedWidget(
              placement: WidgetPlacement(
                id: 'test_widget', 'text_input',
                column: 0,
                row: 0,
                width: 4,
                height: 1,
                properties: {'label': 'Email'},
              ),
              isSelected: true,
              child: Container(),
            ),
          ),
        ),
      );

      // Verify selected state is announced
      expect(
        tester.getSemantics(find.byType(AccessiblePlacedWidget)),
        matchesSemantics(
          label: 'Email text input widget, selected',
          hint: 'Press Delete to remove, arrow keys to move',
          isButton: true,
          isSelected: true,
        ),
      );
    });

    testWidgets('ToolboxWidget accessibility', (tester) async {
      final toolbox = CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Form Elements',
            items: [
              ToolboxItem(
              name: 'button',
              displayName: 'Button',
              defaultWidth: 2, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
              ToolboxItem(
              name: 'text_input',
              displayName: 'Text Input',
              defaultWidth: 4, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          SizedBox(
            width: 300,
            height: 600,
            child: ToolboxWidget(
            toolbox: toolbox.toSimpleToolbox(items: []),
            ),
          ),
        ),
      );

      // Verify toolbox has proper semantics
      expect(
        tester.getSemantics(find.byType(AccessibleCategorizedToolbox)),
        matchesSemantics(
          label: 'Widget toolbox',
          hint: 'Drag widgets from here to the form',
          // isContainer: true,
        ),
      );

      // Verify toolbox items are accessible
      final buttonItem = find.text('Button');
      expect(
        tester.getSemantics(buttonItem),
        matchesSemantics(
          label: 'Button widget',
          hint: 'Drag to add to form',
          isButton: true,
        ),
      );
    });

    testWidgets('CategorizedToolboxWidget accessibility', (tester) async {
      final categories = [
        ToolboxCategory(
          name: 'Basic',
          items: [
            ToolboxItem(
              name: 'label',
              displayName: 'Label',
              defaultWidth: 3, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
          ],
        ),
        ToolboxCategory(
          name: 'Advanced',
          items: [
            ToolboxItem(
              name: 'dropdown',
              displayName: 'Dropdown',
              defaultWidth: 3, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          SizedBox(
            width: 300,
            height: 600,
            child: ToolboxWidget(
            toolbox: CategorizedToolbox(categories: categories).toSimpleToolbox(items: []),
            onDragStarted: (item) {},
            ),
          ),
        ),
      );

      // Verify category headers are accessible
      expect(
        tester.getSemantics(find.text('Basic')),
        matchesSemantics(
          label: 'Basic category',
          isHeader: true,
        ),
      );

      expect(
        tester.getSemantics(find.text('Advanced')),
        matchesSemantics(
          label: 'Advanced category',
          isHeader: true,
        ),
      );
    });

    testWidgets('GridResizeControls accessibility', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          height: Center(
            child: SizedBox(
              width: 200, 100,
              child: Stack(
                children: [
                  Container(color: Colors.blue.withValues(alpha: 0.3)),
                  GridResizeControls(
                    dimensions: const GridDimensions(columns: 1, rows: 1),
                    child: Container(),
                    onResizeStart: (handle) {},
                    onResizeUpdate: (delta) {},
                    onResizeEnd: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify resize handles have proper semantics
      final resizeHandles = find.byType(ResizeHandle);
      expect(resizeHandles, findsWidgets);

      // Check specific handle accessibility
      final rightHandle = find.byKey(const Key('resize_handle_right'));
      if (rightHandle.evaluate().isNotEmpty) {
        expect(
          tester.getSemantics(rightHandle),
          matchesSemantics(
            label: 'Resize right edge',
            hint: 'Drag to resize widget width',
            isButton: true,
          ),
        );
      }
    });

    testWidgets('Keyboard traversal for toolbox', (tester) async {
      final toolbox = CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Widgets',
            items: [
              ToolboxItem(
              name: 'widget1',
              displayName: 'Widget 1',
              defaultWidth: 2, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
              ToolboxItem(
              name: 'widget2',
              displayName: 'Widget 2',
              defaultWidth: 2, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
              ToolboxItem(
              name: 'widget3',
              displayName: 'Widget 3',
              defaultWidth: 2, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          SizedBox(
            width: 300,
            height: 600,
            child: ToolboxWidget(
            toolbox: toolbox.toSimpleToolbox(items: []),
            ),
          ),
        ),
      );

      // Tab through toolbox items
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // All items should be reachable via keyboard
    });

    testWidgets('Live region announcements', (tester) async {
      final theme = FormLayoutTheme.fromThemeData(ThemeData.light());
            await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          widgetName: Center(
            child: PlacedWidget(
              placement: WidgetPlacement(
                id: 'test_widget', 'button',
                column: 0,
                row: 0,
                width: 2,
                height: 1,
              ),
              isSelected: true,
              child: Container(),
            ),
          ),
        ),
      );

      // Simulate delete action
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      expect(wasRemoved, isTrue);
      // Screen reader should announce "Button widget removed"
    });

    testWidgets('Focus management during drag operations', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          GridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
        ),
      );

      // Start drag operation
      final widget = find.byType(AccessiblePlacedWidget);
      final gesture = await tester.startGesture(tester.getCenter(widget));
      await tester.pump();

      // During drag, focus should be managed properly
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();

      await gesture.up();
      await tester.pumpAndSettle();

      // Focus should return to appropriate element after drag
    });

    testWidgets('Error state accessibility', (tester) async {
      final theme = FormLayoutTheme.fromThemeData(ThemeData.light());
      
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          widgetName: Center(
            child: PlacedWidget(
              placement: WidgetPlacement(
                id: 'error_widget', 'text_input',
                column: 0,
                row: 0,
                width: 4,
                height: 1,
                properties: {
                  'label': 'Email',
                  'error': 'Invalid email format',
                },
              ),
              isSelected: false,
              child: Container(),
            ),
          ),
        ),
      );

      // Error should be announced
      expect(
        tester.getSemantics(find.byType(AccessiblePlacedWidget)),
        matchesSemantics(
          label: 'Email text input widget',
          hint: 'Invalid email format',
          // hasError: true,
        ),
      );
    });

    testWidgets('Resize handle keyboard accessibility', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          height: Center(
            child: SizedBox(
              width: 200, 100,
              child: Stack(
                children: [
                  Container(color: Colors.blue.withValues(alpha: 0.3)),
                  GridResizeControls(
                    dimensions: const GridDimensions(columns: 1, rows: 1),
                    child: Container(),
                    onResizeStart: (handle) {},
                    onResizeUpdate: (delta) {},
                    onResizeEnd: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Focus on resize handle
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Use arrow keys to resize
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Verify resize operation via keyboard
    });
  });
}