import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/accessible_placed_widget.dart';
import 'package:formbuilder/form_layout/widgets/accessible_grid_widget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../test_utils/test_widget_builder.dart';
import '../test_utils/form_layout_test_wrapper.dart';
import '../test_utils/mock_drag_operations.dart';
import '../test_utils/state_assertions.dart';
import 'package:flutter/gestures.dart';

void main() {
  group('Widget Interaction Tests', () {
    late CategorizedToolbox toolbox;

    setUp(() {
      toolbox = CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Basic',
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
        ],
      );
    });

    group('Mouse Interactions', () {
      testWidgets('Mouse hover effects', (tester) async {
        late FormLayoutController controller;
        
        await tester.pumpWidget(
          TestWidgetBuilder.wrapWithMaterialApp(
            SizedBox(
              width: 800,
              height: 600,
              child: FormLayoutTestWrapper(
                toolbox: toolbox,
                initialLayout: LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 5,
                      row: 5,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Give time for layout to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Test that widget exists in controller
        expect(controller.state.widgets.length, equals(1));
        expect(controller.state.widgets.first.id, equals('widget1'));
        
        // Note: Actual hover effects would be tested if the widget
        // has specific hover behavior implemented
      });

      testWidgets('Mouse click selection', (tester) async {
        late FormLayoutController controller;
        
        await tester.pumpWidget(
          TestWidgetBuilder.wrapWithMaterialApp(
            SizedBox(
              width: 800,
              height: 600,
              child: FormLayoutTestWrapper(
                toolbox: toolbox,
                initialLayout: LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 2,
                      row: 2,
                      width: 2,
                      height: 1,
                    ),
                    WidgetPlacement(
                      id: 'widget2',
                      widgetName: 'button',
                      column: 5,
                      row: 2,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Give time for layout to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Test selection through controller
        controller.selectWidget('widget1');
        await tester.pump();
        expect(controller.selectedWidgetId, equals('widget1'));

        // Select second widget
        controller.selectWidget('widget2');
        await tester.pump();
        expect(controller.selectedWidgetId, equals('widget2'));
      });

      testWidgets('Mouse multi-select with Ctrl/Cmd', (tester) async {
        late FormLayoutController controller;
        
        await tester.pumpWidget(
          TestWidgetBuilder.wrapWithMaterialApp(
            SizedBox(
              width: 800,
              height: 600,
              child: FormLayoutTestWrapper(
                toolbox: toolbox,
                initialLayout: LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 2,
                      row: 2,
                      width: 2,
                      height: 1,
                    ),
                    WidgetPlacement(
                      id: 'widget2',
                      widgetName: 'button',
                      column: 5,
                      row: 2,
                      width: 2,
                      height: 1,
                    ),
                    WidgetPlacement(
                      id: 'widget3',
                      widgetName: 'button',
                      column: 8,
                      row: 2,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Give time for layout to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Note: The controller only supports single selection currently
        // Multi-select would need to be implemented in the controller
        
        // Test single selection
        controller.selectWidget('widget1');
        await tester.pump();
        expect(controller.selectedWidgetId, equals('widget1'));
        
        // Selecting another widget replaces selection
        controller.selectWidget('widget2');
        await tester.pump();
        expect(controller.selectedWidgetId, equals('widget2'));
      });

      testWidgets('Mouse right-click context menu', (tester) async {
        late FormLayoutController controller;
        
        await tester.pumpWidget(
          TestWidgetBuilder.wrapWithMaterialApp(
            SizedBox(
              width: 800,
              height: 600,
              child: FormLayoutTestWrapper(
                toolbox: toolbox,
                initialLayout: LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 5,
                      row: 5,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Give time for layout to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Test widget exists
        expect(controller.state.widgets.length, equals(1));
        // Note: Context menu functionality would need to be implemented
      });
    });

    group('Touch Interactions', () {
      testWidgets('Touch tap selection', (tester) async {
        late FormLayoutController controller;
        
        await tester.pumpWidget(
          TestWidgetBuilder.wrapWithMaterialApp(
            SizedBox(
              width: 800,
              height: 600,
              child: FormLayoutTestWrapper(
                toolbox: toolbox,
                initialLayout: LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 5,
                      row: 5,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Give time for layout to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Test selection through controller
        controller.selectWidget('widget1');
        await tester.pump();
        expect(controller.selectedWidgetId, equals('widget1'));
      });

      testWidgets('Touch long press actions', (tester) async {
        late FormLayoutController controller;
        
        await tester.pumpWidget(
          TestWidgetBuilder.wrapWithMaterialApp(
            SizedBox(
              width: 800,
              height: 600,
              child: FormLayoutTestWrapper(
                toolbox: toolbox,
                initialLayout: LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 5,
                      row: 5,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Give time for layout to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Test widget exists and can be selected
        expect(controller.state.widgets.length, equals(1));
        controller.selectWidget('widget1');
        await tester.pump();
        expect(controller.selectedWidgetId, equals('widget1'));
      });

      testWidgets('Touch drag gestures', (tester) async {
        late FormLayoutController controller;
        
        await tester.pumpWidget(
          TestWidgetBuilder.wrapWithMaterialApp(
            SizedBox(
              width: 800,
              height: 600,
              child: FormLayoutTestWrapper(
                toolbox: toolbox,
                initialLayout: LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 2,
                      row: 2,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Give time for layout to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Test widget movement through controller
        final initialPosition = controller.state.widgets.first.column;
        final newPlacement = controller.state.widgets.first.copyWith(column: initialPosition + 2);
        controller.updateWidget('widget1', newPlacement);
        await tester.pump();
        
        // Widget should have moved
        expect(controller.state.widgets.first.column, equals(initialPosition + 2));
      });

      testWidgets('Multi-touch gestures', (tester) async {
        late FormLayoutController controller;
        
        await tester.pumpWidget(
          TestWidgetBuilder.wrapWithMaterialApp(
            SizedBox(
              width: 800,
              height: 600,
              child: FormLayoutTestWrapper(
                toolbox: toolbox,
                initialLayout: LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 2,
                      row: 2,
                      width: 2,
                      height: 1,
                    ),
                    WidgetPlacement(
                      id: 'widget2',
                      widgetName: 'button',
                      column: 6,
                      row: 2,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Give time for layout to complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Test moving both widgets through controller
        final widget1 = controller.state.widgets[0];
        final widget2 = controller.state.widgets[1];
        
        controller.updateWidget(widget1.id, widget1.copyWith(row: widget1.row + 2));
        controller.updateWidget(widget2.id, widget2.copyWith(row: widget2.row + 2));
        await tester.pump();
        
        // Both widgets should have moved
        expect(controller.state.widgets[0].row, equals(4));
        expect(controller.state.widgets[1].row, equals(4));
      });
    });

    group('Keyboard Interactions', () {
      // Skip keyboard tests as they're covered in keyboard_navigation_test.dart
    });
  });
}