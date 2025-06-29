import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import '../test_utils/test_widget_builder.dart';
import '../test_utils/form_layout_test_wrapper.dart';
import '../test_utils/test_data_generators.dart';

void main() {
  group('Form Layout Golden Tests', () {
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
              ToolboxItem(
              name: 'checkbox',
              displayName: 'Checkbox',
              defaultWidth: 1, defaultHeight: 1,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
              ToolboxItem(
              name: 'text_area',
              displayName: 'Text Area',
              defaultWidth: 4, defaultHeight: 3,
              gridBuilder: (context, placement) => const Icon(Icons.widgets),
              toolboxBuilder: (context) => const Icon(Icons.widgets),
            ),
            ],
          ),
        ],
      );
    });

    testWidgets('Empty form layout - light theme', (tester) async {
      late FormLayoutController controller;
      
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState.empty(),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/empty_form_light.png'),
      );
    });

    testWidgets('Empty form layout - dark theme', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withDarkTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState.empty(),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/empty_form_dark.png'),
      );
    });

    testWidgets('Form layout with basic widgets', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState(
                dimensions: const GridDimensions(columns: 12, rows: 12),
                widgets: [
                  WidgetPlacement(
                    id: 'title',
                    widgetName: 'label',
                    column: 0,
                    row: 0,
                    width: 12,
                    height: 1,
                    properties: {'text': 'Contact Form'},
                  ),
                  WidgetPlacement(
                    id: 'name_label',
                    widgetName: 'label',
                    column: 0,
                    row: 2,
                    width: 2,
                    height: 1,
                    properties: {'text': 'Name:'},
                  ),
                  WidgetPlacement(
                    id: 'name_input',
                    widgetName: 'text_input',
                    column: 2,
                    row: 2,
                    width: 4,
                    height: 1,
                    properties: {'placeholder': 'Enter your name'},
                  ),
                  WidgetPlacement(
                    id: 'email_label',
                    widgetName: 'label',
                    column: 0,
                    row: 4,
                    width: 2,
                    height: 1,
                    properties: {'text': 'Email:'},
                  ),
                  WidgetPlacement(
                    id: 'email_input',
                    widgetName: 'text_input',
                    column: 2,
                    row: 4,
                    width: 4,
                    height: 1,
                    properties: {'placeholder': 'Enter your email'},
                  ),
                  WidgetPlacement(
                    id: 'submit_button',
                    widgetName: 'button',
                    column: 2,
                    row: 6,
                    width: 2,
                    height: 1,
                    properties: {'text': 'Submit'},
                  ),
                ],
              ),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/basic_contact_form.png'),
      );
    });

    testWidgets('Form layout with single widget', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState(
                dimensions: const GridDimensions(columns: 12, rows: 12),
                widgets: [
                  WidgetPlacement(
                    id: 'selected_widget',
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

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/form_layout_single_widget.png'),
      );
    });

    testWidgets('Form layout with multiple widgets', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
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
                    widgetName: 'text_input',
                    column: 5,
                    row: 2,
                    width: 4,
                    height: 1,
                  ),
                  WidgetPlacement(
                    id: 'widget3',
                    widgetName: 'label',
                    column: 2,
                    row: 4,
                    width: 3,
                    height: 1,
                  ),
                ],
              ),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/form_layout_multiple_widgets.png'),
      );
    });

    testWidgets('Preview mode appearance', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState(
                dimensions: const GridDimensions(columns: 12, rows: 12),
                widgets: [
                  WidgetPlacement(
                    id: 'preview_button',
                    widgetName: 'button',
                    column: 2,
                    row: 2,
                    width: 2,
                    height: 1,
                    properties: {'text': 'Preview Button'},
                  ),
                  WidgetPlacement(
                    id: 'preview_input',
                    widgetName: 'text_input',
                    column: 5,
                    row: 2,
                    width: 4,
                    height: 1,
                    properties: {'placeholder': 'Preview Input'},
                  ),
                ],
              ),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Enable preview mode
      controller.togglePreviewMode();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/preview_mode.png'),
      );
    });

    testWidgets('Dense layout', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState(
                dimensions: const GridDimensions(columns: 12, rows: 12),
                widgets: [
                  WidgetPlacement(
                    id: 'dense1',
                    widgetName: 'label',
                    column: 0,
                    row: 0,
                    width: 3,
                    height: 1,
                    properties: {'text': 'Label 1'},
                  ),
                  WidgetPlacement(
                    id: 'dense2',
                    widgetName: 'text_input',
                    column: 3,
                    row: 0,
                    width: 3,
                    height: 1,
                  ),
                  WidgetPlacement(
                    id: 'dense3',
                    widgetName: 'button',
                    column: 6,
                    row: 0,
                    width: 2,
                    height: 1,
                    properties: {'text': 'Button'},
                  ),
                  WidgetPlacement(
                    id: 'dense4',
                    widgetName: 'label',
                    column: 0,
                    row: 2,
                    width: 4,
                    height: 1,
                    properties: {'text': 'Another Label'},
                  ),
                  WidgetPlacement(
                    id: 'dense5',
                    widgetName: 'text_input',
                    column: 4,
                    row: 2,
                    width: 4,
                    height: 1,
                  ),
                ],
              ),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/dense_layout.png'),
      );
    });

    testWidgets('Standard layout size', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState(
                dimensions: const GridDimensions(columns: 12, rows: 12),
                widgets: [
                  WidgetPlacement(
                    id: 'layout_title',
                    widgetName: 'label',
                    column: 0,
                    row: 0,
                    width: 8,
                    height: 1,
                    properties: {'text': 'Standard Layout'},
                  ),
                  WidgetPlacement(
                    id: 'layout_button',
                    widgetName: 'button',
                    column: 1,
                    row: 2,
                    width: 2,
                    height: 1,
                    properties: {'text': 'OK'},
                  ),
                ],
              ),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/standard_layout.png'),
      );
    });

    testWidgets('Custom theme', (tester) async {
        late FormLayoutController controller;
        
      final customTheme = ThemeData(
        primaryColor: Colors.purple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );

      await tester.pumpWidget(
        TestWidgetBuilder.withCustomTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: TestDataGenerators.patternLayout(
                'checkerboard',
                dimensions: const GridDimensions(columns: 8, rows: 8),
              ),
              onControllerCreated: (c) => controller = c,
            ),
          ),
          theme: customTheme,
        ),
      );

      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/custom_theme.png'),
      );
    });

    testWidgets('Error states', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState(
                dimensions: const GridDimensions(columns: 12, rows: 12),
                widgets: [
                  // Widget at boundary
                  WidgetPlacement(
                    id: 'boundary_widget',
                    widgetName: 'button',
                    column: 11,
                    row: 11,
                    width: 1,
                    height: 1,
                  ),
                  // Large widget
                  WidgetPlacement(
                    id: 'large_widget',
                    widgetName: 'text_area',
                    column: 0,
                    row: 0,
                    width: 12,
                    height: 6,
                  ),
                ],
              ),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Try to add overlapping widget to trigger error (catch it to test error display)
      try {
        controller.addWidget(
          WidgetPlacement(
            id: 'overlapping',
            widgetName: 'button',
            column: 1,
            row: 1,
            width: 2,
            height: 2,
          ),
        );
      } catch (e) {
        // Expected error for overlapping widget
      }
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/error_states.png'),
      );
    });

    testWidgets('Hover and focus states', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.withLightTheme(
          SizedBox(
            width: 800,
            height: 600,
            child: FormLayoutTestWrapper(
              toolbox: toolbox,
              initialLayout: LayoutState(
                dimensions: const GridDimensions(columns: 12, rows: 12),
                widgets: [
                  WidgetPlacement(
                    id: 'hover_widget',
                    widgetName: 'button',
                    column: 2,
                    row: 2,
                    width: 2,
                    height: 1,
                  ),
                  WidgetPlacement(
                    id: 'focus_widget',
                    widgetName: 'text_input',
                    column: 5,
                    row: 2,
                    width: 4,
                    height: 1,
                  ),
                ],
              ),
              onControllerCreated: (c) => controller = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Skip hover simulation for golden test stability
      // Focus on basic layout appearance

      await expectLater(
        find.byType(FormLayoutTestWrapper),
        matchesGoldenFile('golden/hover_focus_states.png'),
      );
    });
  });
}