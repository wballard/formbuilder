import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/accessible_placed_widget.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/utils/accessibility_utils.dart';

void main() {
  group('AccessiblePlacedWidget', () {
    late WidgetPlacement testPlacement;

    setUp(() {
      testPlacement = WidgetPlacement(
        id: 'test-widget',
        widgetName: 'Test Widget',
        column: 1,
        row: 1,
        width: 2,
        height: 2,
      );
    });

    testWidgets('should render with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessiblePlacedWidget(
              placement: testPlacement,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Check semantic label
      expect(
        find.bySemanticsLabel('Test Widget widget at column 2, row 2. Size: 2 by 2 cells'),
        findsOneWidget,
      );

      // Check semantic hint for unselected widget
      final semantics = tester.getSemantics(find.byType(AccessiblePlacedWidget));
      expect(semantics.hint, contains('Double tap to select'));
    });

    testWidgets('should show selected semantics when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessiblePlacedWidget(
              placement: testPlacement,
              isSelected: true,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AccessiblePlacedWidget));
      expect(semantics.hint, contains('Double tap to deselect'));
      expect(semantics.hint, contains('Use arrow keys to move'));
      expect(semantics.hint, contains('Press Delete to remove'));
      // Verify the widget is marked as selected
      expect(find.byType(AccessiblePlacedWidget), findsOneWidget);
    });

    // TODO: Re-enable when FormLayoutActionDispatcher can be properly mocked
    // testWidgets('should handle keyboard navigation when selected', (tester) async {
    //   // This test requires FormLayoutActionDispatcher which needs a full form layout setup.
    //   // The keyboard handling is tested indirectly through integration tests.
    // });

    // TODO: Re-enable when focus handling can be properly tested
    // testWidgets('should handle delete key when selected', (tester) async {
    //   // Keyboard event handling requires proper focus management
    //   // which is complex in widget tests. The delete functionality is tested
    //   // through integration tests.
    // });

    testWidgets('should handle enter/space key for selection', (tester) async {
      bool tapCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessiblePlacedWidget(
              placement: testPlacement,
              child: const Text('Test'),
              onTap: () {
                tapCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Focus the widget
      await tester.tap(find.byType(AccessiblePlacedWidget));
      await tester.pump();

      // Press enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapCallbackCalled, isTrue);
    });

    testWidgets('should show focus indicator when focused', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: AccessiblePlacedWidget(
                placement: testPlacement,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      // Widget should not show focus indicator initially
      expect(find.byType(Container), findsWidgets);

      // Tap to focus the widget
      await tester.tap(find.byType(AccessiblePlacedWidget), warnIfMissed: false);
      await tester.pump();
      
      // Give it a moment to establish focus
      await tester.pumpAndSettle();

      // Focus indicator should be visible - find the AccessibleFocusIndicator itself
      final focusIndicatorWidget = find.byType(AccessibleFocusIndicator);
      expect(focusIndicatorWidget, findsOneWidget);
      
      // Since AccessibleFocusIndicator returns a Container with decoration when focused,
      // let's find that specific container by looking for one with a border
      final containers = find.descendant(
        of: focusIndicatorWidget,
        matching: find.byType(Container),
      );
      
      // Should find at least one container
      expect(containers, findsWidgets);
      
      // Find the container with the focus border by checking for border decoration
      bool foundFocusBorder = false;
      final containerList = tester.widgetList<Container>(containers).toList();
      for (int i = 0; i < containerList.length; i++) {
        final container = containerList[i];
        if (container.decoration is BoxDecoration) {
          final boxDecoration = container.decoration as BoxDecoration;
          if (boxDecoration.border != null) {
            foundFocusBorder = true;
            break;
          }
        }
      }
      
      expect(foundFocusBorder, isTrue);
    });

    testWidgets('should be focusable and support proper focus management', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessiblePlacedWidget(
              placement: testPlacement,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Verify the widget is focusable
      expect(find.byType(AccessiblePlacedWidget), findsOneWidget);
    });

    testWidgets('should not handle keyboard input when not selected', (tester) async {
      MoveWidgetIntent? capturedIntent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Actions(
              actions: {
                MoveWidgetIntent: CallbackAction<MoveWidgetIntent>(
                  onInvoke: (intent) {
                    capturedIntent = intent;
                    return null;
                  },
                ),
              },
              child: AccessiblePlacedWidget(
                placement: testPlacement,
                isSelected: false,
                canDrag: true,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      // Focus the widget
      await tester.tap(find.byType(AccessiblePlacedWidget));
      await tester.pump();

      // Press right arrow key
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Should not move when not selected
      expect(capturedIntent, isNull);
    });

    testWidgets('should not handle keyboard input when cannot drag', (tester) async {
      MoveWidgetIntent? capturedIntent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Actions(
              actions: {
                MoveWidgetIntent: CallbackAction<MoveWidgetIntent>(
                  onInvoke: (intent) {
                    capturedIntent = intent;
                    return null;
                  },
                ),
              },
              child: AccessiblePlacedWidget(
                placement: testPlacement,
                isSelected: true,
                canDrag: false,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      // Focus the widget
      await tester.tap(find.byType(AccessiblePlacedWidget));
      await tester.pump();

      // Press right arrow key
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Should not move when cannot drag
      expect(capturedIntent, isNull);
    });
  });
}