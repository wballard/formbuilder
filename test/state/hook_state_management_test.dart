import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../test_utils/test_widget_builder.dart';

void main() {
  group('Hook State Management Tests', () {
    testWidgets('useFormLayout hook initialization', (tester) async {
      late FormLayoutController controller;
      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              return Text('State: ${controller.state.widgets.length} widgets');
            },
          ),
        ),
      );

      expect(controller, isNotNull);
      expect(controller.state, isNotNull);
      expect(controller.state.widgets.isEmpty, isTrue);
      expect(find.text('State: 0 widgets'), findsOneWidget);
    });

    testWidgets('useFormLayout with initial state', (tester) async {
      late FormLayoutController controller;
      final initialState = LayoutState(
        dimensions: const GridDimensions(columns: 10, rows: 10),
        widgets: [
          WidgetPlacement(
            id: 'initial',
            widgetName: 'button',
            column: 2,
            row: 2,
            width: 2,
            height: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(initialState);
              return Text('State: ${controller.state.widgets.length} widgets');
            },
          ),
        ),
      );

      expect(controller.state.widgets.length, equals(1));
      expect(controller.state.dimensions.columns, equals(10));
      expect(controller.state.dimensions.rows, equals(10));
      expect(find.text('State: 1 widgets'), findsOneWidget);
    });

    testWidgets('Hook preserves state across rebuilds', (tester) async {
      late FormLayoutController controller;
      int buildCount = 0;

      Widget buildWidget() {
        return TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              buildCount++;
              controller = useFormLayout(LayoutState.empty());
              return Column(
                children: [
                  Text('Build: $buildCount'),
                  Text('Widgets: ${controller.state.widgets.length}'),
                  ElevatedButton(
                    onPressed: () {
                      controller.addWidget(
                        WidgetPlacement(
                          id: 'widget_$buildCount',
                          widgetName: 'button',
                          column: buildCount,
                          row: 0,
                          width: 1,
                          height: 1,
                        ),
                      );
                    },
                    child: const Text('Add Widget'),
                  ),
                ],
              );
            },
          ),
        );
      }

      await tester.pumpWidget(buildWidget());
      expect(find.text('Build: 1'), findsOneWidget);
      expect(find.text('Widgets: 0'), findsOneWidget);

      // Add widget
      await tester.tap(find.text('Add Widget'));
      await tester.pump();
      expect(find.text('Build: 2'), findsOneWidget);
      expect(find.text('Widgets: 1'), findsOneWidget);

      // Force rebuild
      await tester.pumpWidget(buildWidget());
      expect(find.text('Build: 3'), findsOneWidget);
      expect(find.text('Widgets: 1'), findsOneWidget); // State preserved

      // Add another widget
      await tester.tap(find.text('Add Widget'));
      await tester.pump();
      expect(find.text('Widgets: 2'), findsOneWidget);
    });

    testWidgets('Multiple hooks in same widget', (tester) async {
      late FormLayoutController controller1;
      late FormLayoutController controller2;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller1 = useFormLayout(LayoutState.empty());
              controller2 = useFormLayout(LayoutState(
                  dimensions: const GridDimensions(columns: 6, rows: 6),
                  widgets: [],
                ),
              );
              
              return Column(
                children: [
                  Text('Controller1: ${controller1.state.dimensions.columns}x${controller1.state.dimensions.rows}'),
                  Text('Controller2: ${controller2.state.dimensions.columns}x${controller2.state.dimensions.rows}'),
                ],
              );
            },
          ),
        ),
      );

      expect(controller1, isNot(equals(controller2)));
      expect(controller1.state.dimensions.columns, equals(4));
      expect(controller2.state.dimensions.columns, equals(6));
      expect(find.text('Controller1: 4x4'), findsOneWidget);
      expect(find.text('Controller2: 6x6'), findsOneWidget);
    });

    testWidgets('Hook state updates trigger rebuilds', (tester) async {
      late FormLayoutController controller;
      int buildCount = 0;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              buildCount++;
              controller = useFormLayout(LayoutState.empty());
              
              return Column(
                children: [
                  Text('Build: $buildCount'),
                  Text('Widgets: ${controller.state.widgets.length}'),
                  Text('Can Undo: ${controller.canUndo}'),
                  Text('Can Redo: ${controller.canRedo}'),
                ],
              );
            },
          ),
        ),
      );

      expect(buildCount, equals(1));
      expect(find.text('Widgets: 0'), findsOneWidget);
      expect(find.text('Can Undo: false'), findsOneWidget);

      // Add widget - should trigger rebuild
      controller.addWidget(
        WidgetPlacement(
          id: 'widget1',
          widgetName: 'button',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        ),
      );
      await tester.pump();

      expect(buildCount, equals(2));
      expect(find.text('Widgets: 1'), findsOneWidget);
      expect(find.text('Can Undo: true'), findsOneWidget);

      // Undo - should trigger rebuild
      controller.undo();
      await tester.pump();

      expect(buildCount, equals(3));
      expect(find.text('Widgets: 0'), findsOneWidget);
      expect(find.text('Can Redo: true'), findsOneWidget);
    });

    testWidgets('Hook cleanup on disposal', (tester) async {
      late FormLayoutController controller;
      bool disposed = false;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              
              useEffect(() {
                return () {
                  disposed = true;
                };
              }, []);
              
              return Container();
            },
          ),
        ),
      );

      expect(disposed, isFalse);

      // Remove widget to trigger disposal
      await tester.pumpWidget(Container());

      expect(disposed, isTrue);
    });

    testWidgets('Hook with callbacks', (tester) async {
      late FormLayoutController controller;
      int callbackCount = 0;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              // Track state changes
              useEffect(() {
                void listener() => callbackCount++;
                controller.addListener(listener);
                return () => controller.removeListener(listener);
              }, [controller]);
              
              return Column(
                children: [
                  Text('Callbacks: $callbackCount'),
                  ElevatedButton(
                    onPressed: () {
                      controller.addWidget(
                        WidgetPlacement(
                          id: 'widget_$callbackCount',
                          widgetName: 'button',
                          column: callbackCount * 2,
                          row: 0,
                          width: 2,
                          height: 1,
                        ),
                      );
                    },
                    child: const Text('Add Widget'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(callbackCount, equals(0));

      // Add widget - should trigger callback
      await tester.tap(find.text('Add Widget'));
      await tester.pump();
      expect(callbackCount, equals(1));

      // Add another widget
      await tester.tap(find.text('Add Widget'));
      await tester.pump();
      expect(callbackCount, equals(2));
    });

    testWidgets('Hook memoization', (tester) async {
      late FormLayoutController controller;
      int memoCalcCount = 0;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              final memoizedValue = useMemoized(
                () {
                  memoCalcCount++;
                  return controller.state.widgets.length * 2;
                },
                [controller.state.widgets.length],
              );
              
              return Column(
                children: [
                  Text('Memo Calc Count: $memoCalcCount'),
                  Text('Memoized: $memoizedValue'),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Memo Calc Count: 1'), findsOneWidget);
      expect(find.text('Memoized: 0'), findsOneWidget);

      // Force rebuild without state change
      await tester.pump();
      expect(find.text('Memo Calc Count: 1'), findsOneWidget); // Should not recalculate
      expect(find.text('Memoized: 0'), findsOneWidget); // But memoized value same

      // Change state
      controller.addWidget(
        WidgetPlacement(
          id: 'widget1',
          widgetName: 'button',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        ),
      );
      await tester.pump();

      expect(find.text('Memoized: 2'), findsOneWidget); // Memoized value updated
    });

    testWidgets('Hook with async operations', (tester) async {
      late FormLayoutController controller;
      bool loadingComplete = false;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              
              useEffect(() {
                Future.delayed(const Duration(milliseconds: 100), () {
                  controller.addWidget(
                    WidgetPlacement(
                      id: 'async_widget',
                      widgetName: 'button',
                      column: 0,
                      row: 0,
                      width: 2,
                      height: 1,
                    ),
                  );
                  loadingComplete = true;
                });
                return null;
              }, []);
              
              return Text('Widgets: ${controller.state.widgets.length}');
            },
          ),
        ),
      );

      expect(find.text('Widgets: 0'), findsOneWidget);
      expect(loadingComplete, isFalse);

      // Wait for async operation
      await tester.pump(const Duration(milliseconds: 150));
      
      expect(find.text('Widgets: 1'), findsOneWidget);
      expect(loadingComplete, isTrue);
    });

    testWidgets('Hook error handling', (tester) async {
      late FormLayoutController controller;
      String? errorMessage;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          HookBuilder(
            builder: (context) {
              controller = useFormLayout(LayoutState.empty());
              
              return Column(
                children: [
                  if (errorMessage != null)
                    Text('Error: $errorMessage'),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        // Try to add invalid widget
                        controller.addWidget(
                          WidgetPlacement(
                            id: 'invalid',
                            widgetName: 'button',
                            column: -1, // Invalid column
                            row: 0,
                            width: 2,
                            height: 1,
                          ),
                        );
                      } catch (e) {
                        errorMessage = e.toString();
                      }
                    },
                    child: const Text('Add Invalid Widget'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Try to add invalid widget
      await tester.tap(find.text('Add Invalid Widget'));
      await tester.pump();

      // Should handle error gracefully
      expect(controller.state.widgets.length, equals(0));
    });

    testWidgets('Hook conditional usage', (tester) async {
      late FormLayoutController controller;
      bool useController = true;

      await tester.pumpWidget(
        TestWidgetBuilder.wrapWithMaterialApp(
          StatefulBuilder(
            builder: (context, setState) {
              return HookBuilder(
                builder: (context) {
                  // Conditional hook usage is not allowed
                  // This test verifies proper usage
                  controller = useFormLayout(LayoutState.empty());
                  
                  return Column(
                    children: [
                      Text('Active: $useController'),
                      Text('Widgets: ${controller.state.widgets.length}'),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            useController = !useController;
                          });
                        },
                        child: const Text('Toggle'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );

      expect(find.text('Active: true'), findsOneWidget);
      expect(find.text('Widgets: 0'), findsOneWidget);
      expect(controller, isNotNull);
    });
  });
}