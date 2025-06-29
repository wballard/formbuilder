import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/widgets/form_layout_action_dispatcher.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';

LayoutState _createInitialState() {
  return LayoutState(
    dimensions: GridDimensions(columns: 4, rows: 5),
    widgets: [],
  );
}

void main() {
  group('FormLayoutActionDispatcher', () {

    late ToolboxItem testItem;

    setUp(() {
      testItem = ToolboxItem(
        name: 'test_widget',
        displayName: 'Test Widget',
        toolboxBuilder: (context) => Container(),
        gridBuilder: (context, placement) => const Icon(Icons.widgets),
        defaultWidth: 2,
        defaultHeight: 1,
      );
    });

    testWidgets('provides actions to descendants', (tester) async {
        late FormLayoutController controller;
        
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());

              return FormLayoutActionDispatcher(
                controller: controller,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        Actions.maybeInvoke<AddWidgetIntent>(
                          context,
                          AddWidgetIntent(
                            item: testItem,
                            position: const Point(1, 2),
                          ),
                        );
                      },
                      child: const Text('Add Widget'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(controller.state.widgets.length, 0);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(controller.state.widgets.length, 1);
      final widget = controller.state.widgets.first;
      expect(widget.widgetName, 'test_widget');
      expect(widget.column, 1);
      expect(widget.row, 2);
    });

    testWidgets('context extension methods work correctly', (tester) async {
        late FormLayoutController controller;
        
      bool invoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());

              return FormLayoutActionDispatcher(
                controller: controller,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        invoked = context.maybeInvokeIntent(
                          RemoveWidgetIntent(widgetId: 'test_widget_id'),
                        );
                      },
                      child: const Text('Remove Widget'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      // Add a widget for testing
      controller.addWidget(
        WidgetPlacement(
          id: 'test_widget_id',
          widgetName: 'test_widget',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        ),
      );
      await tester.pump();

      expect(controller.state.widgets.length, 1);
      expect(invoked, false);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(controller.state.widgets.length, 0);
      expect(invoked, true);
    });

    testWidgets('FormLayoutIntentInvoker mixin provides convenience methods', (tester) async {
      late FormLayoutController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());

              return FormLayoutActionDispatcher(
                controller: controller,
                child: _TestWidget(),
              );
            },
          ),
        ),
      );

      expect(controller.state.widgets.length, 0);

      // Test add widget
      await tester.tap(find.byKey(const Key('add_button')));
      await tester.pump();
      expect(controller.state.widgets.length, 1);

      // Test select widget
      expect(controller.selectedWidgetId, isNull);
      await tester.tap(find.byKey(const Key('select_button')));
      await tester.pump();
      expect(controller.selectedWidgetId, isNotNull);

      // Test move widget
      final widgetBefore = controller.state.widgets.first;
      expect(widgetBefore.column, 1);
      expect(widgetBefore.row, 2);
      await tester.tap(find.byKey(const Key('move_button')));
      await tester.pump();
      final widgetAfter = controller.state.widgets.first;
      expect(widgetAfter.column, 2);
      expect(widgetAfter.row, 3);

      // Test remove widget
      await tester.tap(find.byKey(const Key('remove_button')));
      await tester.pump();
      expect(controller.state.widgets.length, 0);
    });

    testWidgets('all actions are available through dispatcher', (tester) async {
        late FormLayoutController controller;
        
      final invokedIntents = <Type>[];

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useFormLayout(_createInitialState());

              return FormLayoutActionDispatcher(
                controller: controller,
                child: Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        ElevatedButton(
                          key: const Key('undo'),
                          onPressed: () {
                            final result = Actions.maybeInvoke<UndoIntent>(
                              context,
                              const UndoIntent(),
                            );
                            if (result != null) {
                              invokedIntents.add(UndoIntent);
                            }
                          },
                          child: const Text('Undo'),
                        ),
                        ElevatedButton(
                          key: const Key('toggle_preview'),
                          onPressed: () {
                            final result =
                                Actions.maybeInvoke<TogglePreviewModeIntent>(
                                  context,
                                  const TogglePreviewModeIntent(),
                                );
                            if (result != null) {
                              invokedIntents.add(TogglePreviewModeIntent);
                            }
                          },
                          child: const Text('Toggle Preview'),
                        ),
                        ElevatedButton(
                          key: const Key('resize_grid'),
                          onPressed: () {
                            final result =
                                Actions.maybeInvoke<ResizeGridIntent>(
                                  context,
                                  const ResizeGridIntent(
                                    newDimensions: GridDimensions(
                                      columns: 6,
                                      rows: 8,
                                    ),
                                  ),
                                );
                            if (result != null) {
                              invokedIntents.add(ResizeGridIntent);
                            }
                          },
                          child: const Text('Resize Grid'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      // Prepare state for testing - add widget after initial build
      controller.addWidget(
        WidgetPlacement(
          id: 'test_widget',
          widgetName: 'test_widget',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        ),
      );
      await tester.pump();

      // Test undo action
      await tester.tap(find.byKey(const Key('undo')));
      await tester.pump();
      expect(invokedIntents.contains(UndoIntent), true);

      // Test toggle preview action
      await tester.tap(find.byKey(const Key('toggle_preview')));
      await tester.pump();
      expect(invokedIntents.contains(TogglePreviewModeIntent), true);

      // Test resize grid action
      await tester.tap(find.byKey(const Key('resize_grid')));
      await tester.pump();
      expect(invokedIntents.contains(ResizeGridIntent), true);
    });
  });
}

// Test widget that uses the FormLayoutIntentInvoker mixin
class _TestWidget extends StatefulWidget {
  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> with FormLayoutIntentInvoker {
  @override
  Widget build(BuildContext context) {
    final testItem = ToolboxItem(
      name: 'test_widget',
      displayName: 'Test Widget',
      toolboxBuilder: (context) => Container(),
      gridBuilder: (context, placement) => const Icon(Icons.widgets),
      defaultWidth: 2,
      defaultHeight: 1,
    );

    return Column(
      children: [
        ElevatedButton(
          key: const Key('add_button'),
          onPressed: () {
            addWidget(testItem, const Point(1, 2));
          },
          child: const Text('Add'),
        ),
        ElevatedButton(
          key: const Key('select_button'),
          onPressed: () {
            // Select the first widget if any exist
            final context = this.context;
            final ancestorContext = context
                .findAncestorWidgetOfExactType<FormLayoutActionDispatcher>()!
                .controller;
            if (ancestorContext.state.widgets.isNotEmpty) {
              selectWidget(ancestorContext.state.widgets.first.id);
            }
          },
          child: const Text('Select'),
        ),
        ElevatedButton(
          key: const Key('move_button'),
          onPressed: () {
            // Move the first widget if any exist
            final context = this.context;
            final ancestorContext = context
                .findAncestorWidgetOfExactType<FormLayoutActionDispatcher>()!
                .controller;
            if (ancestorContext.state.widgets.isNotEmpty) {
              moveWidget(
                ancestorContext.state.widgets.first.id,
                const Point(2, 3),
              );
            }
          },
          child: const Text('Move'),
        ),
        ElevatedButton(
          key: const Key('remove_button'),
          onPressed: () {
            // Remove the first widget if any exist
            final context = this.context;
            final ancestorContext = context
                .findAncestorWidgetOfExactType<FormLayoutActionDispatcher>()!
                .controller;
            if (ancestorContext.state.widgets.isNotEmpty) {
              removeWidget(ancestorContext.state.widgets.first.id);
            }
          },
          child: const Text('Remove'),
        ),
      ],
    );
  }
}
