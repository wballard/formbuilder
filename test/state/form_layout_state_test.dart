import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import '../test_utils/test_widget_builder.dart';
import '../test_utils/state_assertions.dart';
import '../test_utils/test_data_generators.dart';

void main() {
  group('Form Layout State Management Tests', () {
    testWidgets('Initial state', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              return Container();
            },
          ),
        ),
      );

      expect(controller.state, isNotNull);
      expect(controller.state.widgets, isEmpty);
      expect(controller.state.dimensions.columns, equals(12));
      expect(controller.state.dimensions.rows, equals(12));
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);
      expect(controller.isPreviewMode, isFalse);
      expect((controller.selectedWidgetId != null ? [controller.selectedWidgetId!] : []), isEmpty);
    });

    testWidgets('Add widget state changes', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              return Container();
            },
          ),
        ),
      );

      final widget = WidgetPlacement(
        id: 'widget1',
        widgetName: 'button',
        column: 5,
        row: 5,
        width: 2,
        height: 1,
      );

      controller.addWidget(widget);
      await tester.pump();

      expect(controller.state.widgets.length, equals(1));
      expect(controller.state.getWidget('widget1'), equals(widget));
      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);
    });

    testWidgets('Remove widget state changes', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState(
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
              return Container();
            },
          ),
        ),
      );

      expect(controller.state.widgets.length, equals(1));

      controller.removeWidget('widget1');
      await tester.pump();

      expect(controller.state.widgets.length, equals(0));
      expect(controller.state.getWidget('widget1'), isNull);
      expect(controller.canUndo, isTrue);
    });

    testWidgets('Update widget state changes', (tester) async {
        late FormLayoutController controller;
        

      final initialWidget = WidgetPlacement(
        id: 'widget1',
        widgetName: 'button',
        column: 2,
        row: 2,
        width: 2,
        height: 1,
      );

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [initialWidget],
                ),
              );
              return Container();
            },
          ),
        ),
      );

      final updatedWidget = initialWidget.copyWith(column: 5, row: 5);
      controller.updateWidget(updatedWidget.id, updatedWidget);
      await tester.pump();

      expect(controller.state.widgets.length, equals(1));
      final widget = controller.state.getWidget('widget1')!;
      expect(widget.column, equals(5));
      expect(widget.row, equals(5));
      expect(controller.canUndo, isTrue);
    });

    testWidgets('Selection state management', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState(
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
              return Container();
            },
          ),
        ),
      );

      // Single selection
      controller.selectWidget('widget1');
      await tester.pump();
      expect((controller.selectedWidgetId != null ? [controller.selectedWidgetId!] : []), equals(['widget1']));

      // Replace selection
      controller.selectWidget('widget2');
      await tester.pump();
      expect((controller.selectedWidgetId != null ? [controller.selectedWidgetId!] : []), equals(['widget2']));

      // Multi-selection
      controller.selectWidget('widget1');
      await tester.pump();
      expect((controller.selectedWidgetId != null ? [controller.selectedWidgetId!] : []).toSet(), equals({'widget1', 'widget2'}));

      // Clear selection
      controller.selectWidget(null);
      await tester.pump();
      expect((controller.selectedWidgetId != null ? [controller.selectedWidgetId!] : []), isEmpty);
    });

    testWidgets('Batch operations state changes', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              return Container();
            },
          ),
        ),
      );

      // Add multiple widgets
      final widgets = [
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
          widgetName: 'button',
          column: 3,
          row: 0,
          width: 2,
          height: 1,
        ),
        WidgetPlacement(
          id: 'widget3',
          widgetName: 'button',
          column: 6,
          row: 0,
          width: 2,
          height: 1,
        ),
      ];

      for (final widget in widgets) controller.addWidget(widget);
      await tester.pump();

      expect(controller.state.widgets.length, equals(3));
      expect(controller.canUndo, isTrue);

      // Remove multiple widgets
      for (final id in ['widget1', 'widget3']) controller.removeWidget(id);
      await tester.pump();

      expect(controller.state.widgets.length, equals(1));
      expect(controller.state.getWidget('widget2'), isNotNull);
      expect(controller.state.getWidget('widget1'), isNull);
      expect(controller.state.getWidget('widget3'), isNull);
    });

    testWidgets('Grid dimension state changes', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'widget1',
                      widgetName: 'button',
                      column: 10,
                      row: 10,
                      width: 2,
                      height: 2,
                    ),
                  ],
                ),
              );
              return Container();
            },
          ),
        ),
      );

      // Resize grid smaller
      controller.resizeGrid(const GridDimensions(columns: 10, rows: 10));
      await tester.pump();

      expect(controller.state.dimensions.columns, equals(10));
      expect(controller.state.dimensions.rows, equals(10));

      // Widget should be adjusted to fit
      final widget = controller.state.getWidget('widget1')!;
      expect(widget.column + widget.width, lessThanOrEqualTo(10));
      expect(widget.row + widget.height, lessThanOrEqualTo(10));
    });

    testWidgets('Preview mode state', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              return Container();
            },
          ),
        ),
      );

      expect(controller.isPreviewMode, isFalse);

      controller.togglePreviewMode();
      await tester.pump();
      expect(controller.isPreviewMode, isTrue);

      controller.togglePreviewMode();
      await tester.pump();
      expect(controller.isPreviewMode, isFalse);
    });

    testWidgets('State persistence across rebuilds', (tester) async {
        late FormLayoutController controller;
        

      int buildCount = 0;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              buildCount++;
              controller = useFormLayout(LayoutState.empty());
              
              if (buildCount == 1) {
                // Add widget on first build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.addWidget(
                    WidgetPlacement(
                      id: 'persistent',
                      widgetName: 'button',
                      column: 5,
                      row: 5,
                      width: 2,
                      height: 1,
                    ),
                  );
                });
              }
              
              return Text('Build $buildCount');
            },
          ),
        ),
      );

      await tester.pump(); // Process post-frame callback
      expect(controller.state.widgets.length, equals(1));

      // Trigger rebuild
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              buildCount++;
              controller = useFormLayout(LayoutState.empty());
              return Text('Build $buildCount');
            },
          ),
        ),
      );

      // State should persist
      expect(controller.state.widgets.length, equals(1));
      expect(controller.state.getWidget('persistent'), isNotNull);
    });

    testWidgets('State validation', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState(
                  dimensions: const GridDimensions(columns: 6, rows: 6),
                  widgets: [],
                ),
              );
              return Container();
            },
          ),
        ),
      );

      // Try to add overlapping widgets
      controller.addWidget(
        WidgetPlacement(
          id: 'widget1',
          widgetName: 'button',
          column: 2,
          row: 2,
          width: 3,
          height: 3,
        ),
      );
      await tester.pump();

      // This should fail due to overlap
      final overlappingWidget = WidgetPlacement(
        id: 'widget2',
        widgetName: 'button',
        column: 3,
        row: 3,
        width: 2,
        height: 2,
      );

      final canAdd = controller.state.canAddWidget(overlappingWidget);
      expect(canAdd, isFalse);

      // Try to add widget outside grid
      final outsideWidget = WidgetPlacement(
        id: 'widget3',
        widgetName: 'button',
        column: 5,
        row: 5,
        width: 3,
        height: 3,
      );

      expect(controller.state.canAddWidget(outsideWidget), isFalse);
    });

    testWidgets('Complex state transitions', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              return Container();
            },
          ),
        ),
      );

      // Generate complex layout
      final layout = TestDataGenerators.randomLayout(
        widgetCount: 5,
        dimensions: const GridDimensions(columns: 12, rows: 12),
      );

      // Add all widgets
      for (final widget in layout.widgets) controller.addWidget(widget);
      await tester.pump();

      StateAssertions.assertStateConsistency(controller.state);
      
      // Select multiple widgets
      controller.selectWidget(layout.widgets[0].id);
      controller.selectWidget(layout.widgets[1].id);
      controller.selectWidget(layout.widgets[2].id);
      await tester.pump();

      expect((controller.selectedWidgetId != null ? [controller.selectedWidgetId!] : []).length, equals(3));

      // Delete selected widgets
      if (controller.selectedWidgetId != null) controller.removeWidget(controller.selectedWidgetId!);
      await tester.pump();

      expect(controller.state.widgets.length, equals(2));
      expect((controller.selectedWidgetId != null ? [controller.selectedWidgetId!] : []), isEmpty);

      // Undo deletion
      controller.undo();
      await tester.pump();

      expect(controller.state.widgets.length, equals(5));
      StateAssertions.assertStateConsistency(controller.state);
    });

    testWidgets('State immutability', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              return Container();
            },
          ),
        ),
      );

      final initialState = controller.state;
      final widget = WidgetPlacement(
        id: 'widget1',
        widgetName: 'button',
        column: 5,
        row: 5,
        width: 2,
        height: 1,
      );

      controller.addWidget(widget);
      await tester.pump();

      final newState = controller.state;
      
      // States should be different objects
      expect(identical(initialState, newState), isFalse);
      
      // Initial state should remain unchanged
      expect(initialState.widgets.length, equals(0));
      expect(newState.widgets.length, equals(1));
    });

    testWidgets('Error recovery in state management', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                  widgets: [
                    WidgetPlacement(
                      id: 'existing',
                      widgetName: 'button',
                      column: 5,
                      row: 5,
                      width: 2,
                      height: 1,
                    ),
                  ],
                ),
              );
              return Container();
            },
          ),
        ),
      );

      final stateBefore = controller.state;

      // Try to add widget with duplicate ID
      try {
        controller.addWidget(
          WidgetPlacement(
            id: 'existing', // Duplicate ID
            widgetName: 'text_input',
            column: 0,
            row: 0,
            width: 4,
            height: 1,
          ),
        );
      } catch (e) {
        // Error expected
      }

      await tester.pump();

      // State should remain valid
      expect(controller.state.widgets.length, equals(1));
      StateAssertions.assertStateConsistency(controller.state);
    });
  });
}