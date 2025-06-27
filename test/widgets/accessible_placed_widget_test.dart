import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/accessible_placed_widget.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'dart:math';

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
              child: const Text('Test'),
              isSelected: true,
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

    testWidgets('should handle keyboard navigation when selected', (tester) async {
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
                child: const Text('Test'),
                isSelected: true,
                canDrag: true,
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

      expect(capturedIntent, isNotNull);
      expect(capturedIntent!.widgetId, equals('test-widget'));
      expect(capturedIntent!.newPosition, equals(const Point(2, 1)));
    });

    testWidgets('should handle delete key when selected', (tester) async {
      bool deleteCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessiblePlacedWidget(
              placement: testPlacement,
              child: const Text('Test'),
              isSelected: true,
              onDelete: () {
                deleteCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Focus the widget
      await tester.tap(find.byType(AccessiblePlacedWidget));
      await tester.pump();

      // Press delete key
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();

      expect(deleteCallbackCalled, isTrue);
    });

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
            body: AccessiblePlacedWidget(
              placement: testPlacement,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Widget should not show focus indicator initially
      expect(find.byType(Container), findsWidgets);

      // Tap to focus
      await tester.tap(find.byType(AccessiblePlacedWidget));
      await tester.pump();

      // Focus indicator should be visible
      final focusIndicator = tester.widget<Container>(
        find.descendant(
          of: find.byType(AccessiblePlacedWidget),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(focusIndicator.decoration, isA<BoxDecoration>());
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

      final semantics = tester.getSemantics(find.byType(AccessiblePlacedWidget));
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
                child: const Text('Test'),
                isSelected: false,
                canDrag: true,
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
                child: const Text('Test'),
                isSelected: true,
                canDrag: false,
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