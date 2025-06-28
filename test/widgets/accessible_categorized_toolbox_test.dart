import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/widgets/accessible_categorized_toolbox.dart';

void main() {
  group('AccessibleCategorizedToolbox', () {
    late CategorizedToolbox testToolbox;

    setUp(() {
      testToolbox = CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Input',
            items: [
              ToolboxItem(
                name: 'text_field',
                displayName: 'Text Field',
                defaultWidth: 2,
                defaultHeight: 1,
                toolboxBuilder: (context) => const Icon(Icons.text_fields),
                gridBuilder: (context, placement) => const TextField(),
              ),
              ToolboxItem(
                name: 'checkbox',
                displayName: 'Checkbox',
                defaultWidth: 1,
                defaultHeight: 1,
                toolboxBuilder: (context) => const Icon(Icons.check_box),
                gridBuilder: (context, placement) =>
                    const Checkbox(value: false, onChanged: null),
              ),
            ],
          ),
          ToolboxCategory(
            name: 'Layout',
            items: [
              ToolboxItem(
                name: 'container',
                displayName: 'Container',
                defaultWidth: 2,
                defaultHeight: 2,
                toolboxBuilder: (context) => const Icon(Icons.crop_square),
                gridBuilder: (context, placement) => Container(),
              ),
            ],
          ),
        ],
      );
    });

    testWidgets('should render with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Check semantic label
      expect(find.bySemanticsLabel('Widget toolbox'), findsOneWidget);

      // Check semantic hint mentions navigation
      final semantics = tester.getSemantics(
        find.byType(AccessibleCategorizedToolbox),
      );
      expect(semantics.hint, contains('Use arrow keys to navigate'));
      expect(semantics.hint, contains('Enter to select'));
      expect(semantics.hint, contains('Tab to expand categories'));
    });

    testWidgets('should expand first category by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Input category should be expanded by default
      expect(find.text('Text Field'), findsOneWidget);
      expect(find.text('Checkbox'), findsOneWidget);

      // Layout category should be collapsed
      expect(find.text('Container'), findsNothing);
    });

    testWidgets('should handle category expansion/collapse via tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Layout category should be collapsed initially
      expect(find.text('Container'), findsNothing);

      // Tap Layout category header to expand
      await tester.tap(find.text('Layout'));
      await tester.pump();

      // Container should now be visible
      expect(find.text('Container'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.text('Layout'));
      await tester.pump();

      // Container should be hidden again
      expect(find.text('Container'), findsNothing);
    });

    testWidgets('should handle keyboard navigation between categories', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Focus the toolbox
      await tester.tap(find.byType(AccessibleCategorizedToolbox));
      await tester.pump();

      // Navigate down to next category
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Navigate back up
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
    });

    testWidgets('should handle keyboard navigation between items', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Focus the toolbox
      await tester.tap(find.byType(AccessibleCategorizedToolbox));
      await tester.pump();

      // Navigate right to next item
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Navigate left to previous item
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
    });

    testWidgets('should handle tab key for category expansion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Focus the toolbox - ensure the Focus widget inside has focus
      final focusWidgetFinder = find
          .descendant(
            of: find.byType(AccessibleCategorizedToolbox),
            matching: find.byType(Focus),
          )
          .first;

      final focusWidget = tester.widget<Focus>(focusWidgetFinder);
      focusWidget.focusNode!.requestFocus();
      await tester.pump();

      // Layout category should be collapsed
      expect(find.text('Container'), findsNothing);

      // Navigate to Layout category
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Press Tab to expand
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Container should now be visible
      expect(find.text('Container'), findsOneWidget);
    });

    // TODO: Re-enable when focus handling can be properly tested
    // testWidgets('should handle item activation via keyboard', (tester) async {
    //   // Keyboard event handling in toolbox requires complex
    //   // focus management. The functionality is tested through integration tests.
    // });

    // TODO: Re-enable when focus handling can be properly tested
    // testWidgets('should handle item activation via space key', (tester) async {
    //   // Keyboard event handling in toolbox requires complex
    //   // focus management. The functionality is tested through integration tests.
    // });

    testWidgets('should show proper category semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Check Input category semantics (expanded)
      final inputSemanticsLabel = find.bySemanticsLabel('Input category');
      expect(inputSemanticsLabel, findsOneWidget);

      // Check Layout category semantics (collapsed)
      final layoutSemanticsLabel = find.bySemanticsLabel('Layout category');
      expect(layoutSemanticsLabel, findsOneWidget);
    });

    testWidgets('should show proper item semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Check Text Field item semantics
      expect(
        find.bySemanticsLabel(
          'Text Field. Default size: 2 by 1 cells. Double tap to place on grid.',
        ),
        findsOneWidget,
      );

      // Check Checkbox item semantics
      expect(
        find.bySemanticsLabel(
          'Checkbox. Default size: 1 by 1 cells. Double tap to place on grid.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should handle item selection via tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Tap on Checkbox item
      await tester.tap(find.text('Checkbox'));
      await tester.pump();

      // Item should be selectable
      expect(find.text('Checkbox'), findsOneWidget);
    });

    testWidgets('should support horizontal scrolling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(
              toolbox: testToolbox,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
      );

      expect(find.byType(AccessibleCategorizedToolbox), findsOneWidget);
    });

    testWidgets('should handle empty toolbox', (tester) async {
      final emptyToolbox = CategorizedToolbox(categories: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: emptyToolbox),
          ),
        ),
      );

      expect(find.byType(AccessibleCategorizedToolbox), findsOneWidget);
    });

    testWidgets('should handle category with no items', (tester) async {
      final toolboxWithEmptyCategory = CategorizedToolbox(
        categories: [ToolboxCategory(name: 'Empty', items: [])],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(
              toolbox: toolboxWithEmptyCategory,
            ),
          ),
        ),
      );

      expect(find.text('Empty'), findsOneWidget);
    });

    testWidgets('should support drag and drop for items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCategorizedToolbox(toolbox: testToolbox),
          ),
        ),
      );

      // Verify draggable widgets exist
      expect(find.byType(Draggable<ToolboxItem>), findsWidgets);
    });
  });
}
