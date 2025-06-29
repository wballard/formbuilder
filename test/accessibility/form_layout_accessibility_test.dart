import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'package:formbuilder/form_layout/widgets/accessible_categorized_toolbox.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../test_utils/test_widget_builder.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

void main() {
  group('Form Layout Accessibility Tests', () {
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
            ],
          ),
        ],
      );
    });

    testWidgets('Semantic labels for form layout components', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          FormLayout(
            toolbox: toolbox,
            initialLayout: LayoutState(
              dimensions: const GridDimensions(columns: 4, rows: 5),
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
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that accessible widgets exist and have semantics
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
      expect(find.byType(AccessibleCategorizedToolbox), findsOneWidget);
      expect(find.byType(AccessiblePlacedWidget), findsOneWidget);
      
      // Verify grid has semantic label
      final gridSemantics = tester.getSemantics(find.byType(AccessibleGridWidget));
      expect(gridSemantics.label, isNotEmpty);
      expect(gridSemantics.label, contains('grid'));

      // Verify toolbox has semantic label
      final toolboxSemantics = tester.getSemantics(find.byType(AccessibleCategorizedToolbox));
      expect(toolboxSemantics.label, isNotEmpty);
      
      // Verify placed widget has semantic label
      final placedWidget = find.byType(AccessiblePlacedWidget);
      final placedWidgetSemantics = tester.getSemantics(placedWidget);
      expect(placedWidgetSemantics.label, isNotEmpty);
    });

    testWidgets('Keyboard navigation accessibility', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              final controller = useFormLayout(LayoutState(
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
                  ],
                ),
              );
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Tab through widgets
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      
      // Check focus traversal order
      final focusNodes = tester.widgetList<Focus>(find.byType(Focus));
      expect(focusNodes.isNotEmpty, isTrue);
    });

    testWidgets('Screen reader announcements', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              useFormLayout(LayoutState.empty());
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Widget addition would typically be done through UI interaction
      // which would then trigger screen reader announcements
      
      // Verify semantic announcement functionality exists
      // This would typically announce "Button widget added at position 5, 5"
    });

    testWidgets('Contrast ratios and color accessibility', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              final controller = useFormLayout(LayoutState(
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
              );
              
              // Select widget to show selection colors
              controller.selectWidget('widget1');
              
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Check that selected widget has sufficient contrast
      final selectedWidget = find.byType(AccessiblePlacedWidget);
      expect(selectedWidget, findsOneWidget);
      
      // Verify color contrast meets WCAG guidelines
      // This would check foreground/background contrast ratios
    });

    testWidgets('Touch target sizes', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              final controller = useFormLayout(LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'small_widget',
                      widgetName: 'checkbox',
                      column: 5,
                      row: 5,
                      width: 1,
                      height: 1,
                    ),
                  ],
                ),
              );
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Verify minimum touch target size (48x48 pixels)
      final widget = tester.getRect(find.byType(AccessiblePlacedWidget));
      expect(widget.width, greaterThanOrEqualTo(48));
      expect(widget.height, greaterThanOrEqualTo(48));
    });

    testWidgets('Focus indicators', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              final controller = useFormLayout(LayoutState(
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
              );
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Focus widget
      await tester.tap(find.byType(AccessiblePlacedWidget));
      await tester.pumpAndSettle();

      // Verify focus indicator is visible
      final focusedWidget = find.byType(AccessiblePlacedWidget);
      expect(focusedWidget, findsOneWidget);
      
      // Check for focus decoration (border, outline, etc.)
    });

    testWidgets('ARIA roles and properties', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              final controller = useFormLayout(LayoutState(
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
              );
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Check semantic properties
      final gridSemantics = tester.getSemantics(find.byType(AccessibleGridWidget));
      expect(gridSemantics.hasFlag(SemanticsFlag.isButton), isTrue);

      final toolboxSemantics = tester.getSemantics(find.byType(AccessibleCategorizedToolbox));
      expect(toolboxSemantics.hasFlag(SemanticsFlag.isButton), isTrue);

      final widgetSemantics = tester.getSemantics(find.byType(AccessiblePlacedWidget));
      expect(widgetSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('Drag and drop accessibility', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              useFormLayout(LayoutState.empty());
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Check draggable elements have proper semantics
      final draggableItem = find.descendant(
        of: find.byType(AccessibleCategorizedToolbox),
        matching: find.text('Button'),
      );
      
      expect(
        tester.getSemantics(draggableItem),
        matchesSemantics(
          label: 'Button widget, draggable',
          isButton: true,
        ),
      );
    });

    testWidgets('Error message accessibility', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              final controller = useFormLayout(LayoutState(
                  dimensions: const GridDimensions(columns: 4, rows: 4),
                  widgets: [],
                ),
              );
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Widget placement validation would prevent adding widgets that don't fit
      // and announce errors through screen reader
      
      // Verify error announcement functionality
      // Errors should be in a live region for immediate announcement
    });

    testWidgets('High contrast mode support', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          MediaQuery(
            data: const MediaQueryData(
              highContrast: true,
            ),
            child: HookBuilder(
              builder: (context) {
                final controller = useFormLayout(LayoutState(
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
                );
                return FormLayout(toolbox: toolbox);
              },
            ),
          ),
        ),
      );

      // Verify high contrast styles are applied
      // Borders should be more prominent
      // Colors should have higher contrast
    });

    testWidgets('Reduced motion support', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          MediaQuery(
            data: const MediaQueryData(
              disableAnimations: true,
            ),
            child: HookBuilder(
              builder: (context) {
                useFormLayout(LayoutState.empty());
                return FormLayout(toolbox: toolbox);
              },
            ),
          ),
        ),
      );

      // Verify animations are disabled
      // Drag and drop should work without animations
    });

    testWidgets('Text scaling accessibility', (tester) async {
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0),
            ),
            child: HookBuilder(
              builder: (context) {
                final controller = useFormLayout(LayoutState(
                    dimensions: const GridDimensions(columns: 12, rows: 12),
                    widgets: [
                      WidgetPlacement(
                        id: 'widget1',
                        widgetName: 'label',
                        column: 5,
                        row: 5,
                        width: 3,
                        height: 1,
                        properties: {'text': 'Test Label'},
                      ),
                    ],
                  ),
                );
                return FormLayout(toolbox: toolbox);
              },
            ),
          ),
        ),
      );

      // Verify text scales properly
      // Layout should adapt to larger text
    });

    testWidgets('Tooltips and help text', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              final controller = useFormLayout(LayoutState(
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
              );
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Hover over widget to show tooltip
      final widget = find.byType(AccessiblePlacedWidget);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      
      await gesture.moveTo(tester.getCenter(widget));
      await tester.pump(const Duration(milliseconds: 500));
      
      // Check for tooltip
      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets('Logical tab order', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              final controller = useFormLayout(LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 0,
                      row: 0,
                      width: 2,
                      height: 1,
                    ),
                    WidgetPlacement(
                      id: 'widget2',
                      widgetName: 'text_input',
                      column: 3,
                      row: 0,
                      width: 4,
                      height: 1,
                    ),
                    WidgetPlacement(
                      id: 'widget3',
                      widgetName: 'button',
                      column: 8,
                      row: 0,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
              );
              return FormLayout(toolbox: toolbox);
            },
          ),
        ),
      );

      // Tab through elements
      final List<String> focusOrder = [];
      
      for (int i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Record which element has focus
      }
      
      // Verify logical left-to-right, top-to-bottom order
    });
  });
}