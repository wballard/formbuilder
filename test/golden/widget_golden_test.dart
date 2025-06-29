import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import '../test_utils/test_widget_builder.dart';

void main() {
  group('Widget Golden Tests', () {
    testWidgets('Grid widget appearance', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          GridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
        ),
      );

      await expectLater(
        find.byType(GridWidget),
        matchesGoldenFile('golden/widgets/grid_empty.png'),
      );

      // Grid with highlighted cells
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          GridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
            highlightedCells: {
              const Point(1, 1),
              const Point(2, 1),
              const Point(3, 3),
              const Point(4, 3),
              const Point(5, 3),
              const Point(6, 3),
            },
            highlightColor: Colors.blue.withValues(alpha: 0.3),
          ),
        ),
      );

      await expectLater(
        find.byType(GridWidget),
        matchesGoldenFile('golden/widgets/grid_with_widgets.png'),
      );
    });

    testWidgets('Toolbox widget variations', (tester) async {
      final toolbox = Toolbox(
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
              ToolboxItem(
              name: 'label',
              displayName: 'Label',
              defaultWidth: 3, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
          ToolboxItem(
              name: 'dropdown',
              displayName: 'Dropdown',
              defaultWidth: 3, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
              ToolboxItem(
              name: 'checkbox',
              displayName: 'Checkbox',
              defaultWidth: 1, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
        ],
      );

      // Collapsed toolbox
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 300,
            height: 600,
            child: ToolboxWidget(
              toolbox: toolbox,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ToolboxWidget),
        matchesGoldenFile('golden/widgets/toolbox_collapsed.png'),
      );

      // Expanded toolbox
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 300,
            height: 600,
            child: ToolboxWidget(
              toolbox: toolbox,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ToolboxWidget),
        matchesGoldenFile('golden/widgets/toolbox_expanded.png'),
      );
    });

    testWidgets('Placed widget states', (tester) async {
      
      // Normal state
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: PlacedWidget(
                placement: WidgetPlacement(
                  id: 'test',
                  widgetName: 'button',
                  column: 0,
                  row: 0,
                  width: 2,
                  height: 1,
                  properties: {'label': 'Click Me'},
                ),
                isSelected: false,
                showResizeHandles: false,
                onDelete: () {},
                onResizeStart: (_) {},
                onResizeUpdate: (_, __) {},
                onResizeEnd: () {},
                child: Container(
                  color: Colors.blue,
                  child: const Center(child: Text('Button')),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(PlacedWidget),
        matchesGoldenFile('golden/widgets/placed_widget_normal.png'),
      );

      // Selected state
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: PlacedWidget(
                placement: WidgetPlacement(
                  id: 'test',
                  widgetName: 'button',
                  column: 0,
                  row: 0,
                  width: 2,
                  height: 1,
                  properties: {'label': 'Selected'},
                ),
                isSelected: true,
                showResizeHandles: true,
                onDelete: () {},
                onResizeStart: (_) {},
                onResizeUpdate: (_, __) {},
                onResizeEnd: () {},
                child: Container(
                  color: Colors.blue,
                  child: const Center(child: Text('Selected')),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(PlacedWidget),
        matchesGoldenFile('golden/widgets/placed_widget_selected.png'),
      );

      // Drag target state
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: PlacedWidget(
                placement: WidgetPlacement(
                  id: 'test',
                  widgetName: 'button',
                  column: 0,
                  row: 0,
                  width: 2,
                  height: 1,
                  properties: {'label': 'Drop Here'},
                ),
                isSelected: false,
                isDragging: true,
                showResizeHandles: false,
                onDelete: () {},
                onResizeStart: (_) {},
                onResizeUpdate: (_, __) {},
                onResizeEnd: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.3),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Center(child: Text('Drop Here')),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(PlacedWidget),
        matchesGoldenFile('golden/widgets/placed_widget_drag_target.png'),
      );
    });

    testWidgets('Grid container with different cell sizes', (tester) async {
      final cellSizes = [30.0, 50.0, 70.0];
      
      for (final cellSize in cellSizes) {
        await tester.pumpWidget(
          TestWidgetBuilder.withLightTheme(
            SizedBox(
              width: 600,
              height: 400,
              child: GridWidget(
                dimensions: const GridDimensions(columns: 8, rows: 6),
                gridLineWidth: cellSize / 50, // Vary line width based on cell size
                backgroundColor: Colors.grey.shade50,
                highlightedCells: {
                  const Point(1, 1),
                  const Point(2, 2),
                  const Point(3, 3),
                },
                highlightColor: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(GridWidget),
          matchesGoldenFile('golden/widgets/grid_container_${cellSize.toInt()}.png'),
        );
      }
    });

    testWidgets('Resize controls appearance', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          Center(
            child: SizedBox(
              width: 300,
              height: 200,
              child: Stack(
                children: [
                  Container(
                    width: 200,
                    height: 100,
                    color: Colors.blue.withValues(alpha: 0.3),
                    child: const Center(
                      child: Text('Widget'),
                    ),
                  ),
                  // Show resize handles around the widget
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -4,
                    top: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(SizedBox),
        matchesGoldenFile('golden/widgets/resize_controls.png'),
      );
    });

    testWidgets('Different widget types visualization', (tester) async {
      final widgetTypes = [
        ('button', Icons.smart_button, Colors.blue),
        ('text_input', Icons.text_fields, Colors.green),
        ('label', Icons.label, Colors.orange),
        ('dropdown', Icons.arrow_drop_down, Colors.purple),
        ('checkbox', Icons.check_box, Colors.red),
        ('text_area', Icons.text_snippet, Colors.teal),
      ];

      for (final (widgetName, icon, color) in widgetTypes) {
        await tester.pumpWidget(
          TestWidgetBuilder.withLightTheme(
            Center(
              child: SizedBox(
                width: 200,
                height: 100,
                child: PlacedWidget(
                  placement: WidgetPlacement(
                    id: widgetName,
                    widgetName: widgetName,
                    column: 0,
                    row: 0,
                    width: 3,
                    height: 1,
                    properties: {'label': widgetName},
                  ),
                  isSelected: false,
                  showResizeHandles: false,
                  onDelete: () {},
                  onResizeStart: (_) {},
                  onResizeUpdate: (_, __) {},
                  onResizeEnd: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      border: Border.all(color: color),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color),
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(PlacedWidget),
          matchesGoldenFile('golden/widgets/widget_type_$widgetName.png'),
        );
      }
    });

    testWidgets('Dark theme widgets', (tester) async {
      
      // Grid in dark theme
      await tester.pumpWidget(
        TestWidgetBuilder.withDarkTheme(
          GridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
        ),
      );

      await expectLater(
        find.byType(GridWidget),
        matchesGoldenFile('golden/widgets/grid_dark_theme.png'),
      );

      // Toolbox in dark theme
      await tester.pumpWidget(
        TestWidgetBuilder.withDarkTheme(
          SizedBox(
            width: 300,
            height: 400,
            child: ToolboxWidget(
              toolbox: Toolbox(
                items: [
                  ToolboxItem(
              name: 'button',
              displayName: 'Button',
              defaultWidth: 2, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ToolboxWidget),
        matchesGoldenFile('golden/widgets/toolbox_dark_theme.png'),
      );
    });
  });
}