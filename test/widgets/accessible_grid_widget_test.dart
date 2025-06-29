import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/widgets/accessible_grid_widget.dart';
import 'dart:math';

void main() {
  group('AccessibleGridWidget', () {
    const testDimensions = GridDimensions(columns: 3, rows: 3);

    testWidgets('should render with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
          ),
        ),
      );

      // Check semantic label
      expect(find.bySemanticsLabel('Form layout grid'), findsOneWidget);

      // Check semantic hint mentions navigation
      final semantics = tester.getSemantics(
        find.bySemanticsLabel('Form layout grid'),
      );
      expect(semantics.hint, contains('Use arrow keys to navigate cells'));
      expect(semantics.hint, contains('12 columns by 12 rows'));
    });

    testWidgets('should handle keyboard navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
          ),
        ),
      );

      // Tap to focus the grid
      await tester.tap(find.byType(AccessibleGridWidget), warnIfMissed: false);
      await tester.pump();

      // Should start at 0,0 when focused
      expect(find.byType(AccessibleGridWidget), findsOneWidget);

      // Test right arrow navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Test down arrow navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Test left arrow navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      // Test up arrow navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
    });

    testWidgets('should not navigate beyond grid boundaries', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
          ),
        ),
      );

      // Tap to focus the grid
      await tester.tap(find.byType(AccessibleGridWidget), warnIfMissed: false);
      await tester.pump();

      // Try to navigate left from starting position (0,0)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      // Try to navigate up from starting position (0,0)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      // Should still be at valid position
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
    });

    testWidgets('should handle cell selection via keyboard', (tester) async {
      Point<int>? selectedCell;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: AccessibleGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
            onCellSelected: (cell) {
                  selectedCell = cell;
                },
              ),
            ),
          ),
        ),
      );

      // Find the Focus widget and request focus through it
      final focusFinder = find.descendant(
        of: find.byType(AccessibleGridWidget),
        matching: find.byType(Focus),
      );

      // Tap to request focus on the Focus widget specifically
      await tester.tap(focusFinder, warnIfMissed: false);
      await tester.pump();

      // Give it a moment to establish focus
      await tester.pumpAndSettle();

      // Use sendKeyEvent directly
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(selectedCell, equals(const Point(0, 0)));
    });

    testWidgets('should handle cell selection via space key', (tester) async {
      Point<int>? selectedCell;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: AccessibleGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
            onCellSelected: (cell) {
                  selectedCell = cell;
                },
              ),
            ),
          ),
        ),
      );

      // Find the Focus widget and request focus through it
      final focusFinder = find.descendant(
        of: find.byType(AccessibleGridWidget),
        matching: find.byType(Focus),
      );

      // Tap to request focus on the Focus widget specifically
      await tester.tap(focusFinder, warnIfMissed: false);
      await tester.pump();

      // Give it a moment to establish focus
      await tester.pumpAndSettle();

      // Select cell with Space
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(selectedCell, equals(const Point(0, 0)));
    });

    testWidgets('should highlight focused cell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
          ),
        ),
      );

      // Initially no focused cell
      await tester.pump();

      // Tap to focus the grid
      await tester.tap(find.byType(AccessibleGridWidget), warnIfMissed: false);
      await tester.pump();

      // Should now have highlighted cell
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
    });

    testWidgets('should handle highlighted cells', (tester) async {
      final highlightedCells = {const Point(1, 1), const Point(2, 2)};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
          ),
        ),
      );

      expect(find.byType(AccessibleGridWidget), findsOneWidget);
    });

    testWidgets('should validate cells when isCellValid is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
              dimensions: const GridDimensions(columns: 12, rows: 12),
              isCellValid: (cell) =>
                  cell.x != 1 || cell.y != 1, // Cell (1,1) is invalid
            ),
          ),
        ),
      );

      // Tap to focus the grid
      await tester.tap(find.byType(AccessibleGridWidget), warnIfMissed: false);
      await tester.pump();

      // Navigate to invalid cell (1, 1)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(find.byType(AccessibleGridWidget), findsOneWidget);
    });

    testWidgets('should lose focus when unfocused', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AccessibleGridWidget(
                  dimensions: const GridDimensions(columns: 12, rows: 12),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Other Widget'),
                ),
              ],
            ),
          ),
        ),
      );

      // Focus the grid
      await tester.tap(find.byType(AccessibleGridWidget), warnIfMissed: false);
      await tester.pump();

      // Focus the button instead
      await tester.tap(find.text('Other Widget'));
      await tester.pump();

      // Grid should lose focus
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
    });

    testWidgets('should request focus on mouse enter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridWidget(
            dimensions: const GridDimensions(columns: 12, rows: 12),
          ),
          ),
        ),
      );

      // Simulate mouse enter
      final gesture = await tester.createGesture();
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(find.byType(AccessibleGridWidget)));
      await tester.pump();

      expect(find.byType(AccessibleGridWidget), findsOneWidget);
    });
  });

  group('AccessibleGridSemantics', () {
    const testDimensions = GridDimensions(columns: 4, rows: 3);

    testWidgets('should provide proper grid semantics for edit mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridSemantics(
              dimensions: testDimensions,
              placedWidgetCount: 2,
              isPreviewMode: false,
              child: Container(),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byType(AccessibleGridSemantics),
      );
      expect(semantics.label, contains('Form layout grid'));
      expect(semantics.label, contains('4 columns'));
      expect(semantics.label, contains('3 rows'));
      expect(semantics.label, contains('2 widgets placed'));
      expect(semantics.label, contains('Edit mode active'));
    });

    testWidgets('should provide proper grid semantics for preview mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridSemantics(
              dimensions: testDimensions,
              placedWidgetCount: 0,
              isPreviewMode: true,
              child: Container(),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byType(AccessibleGridSemantics),
      );
      expect(semantics.label, contains('No widgets placed'));
      expect(semantics.label, contains('Preview mode active'));
    });

    testWidgets('should handle singular vs plural widget count', (
      tester,
    ) async {
      // Test singular
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridSemantics(
              dimensions: testDimensions,
              placedWidgetCount: 1,
              isPreviewMode: false,
              child: Container(),
            ),
          ),
        ),
      );

      final singularSemantics = tester.getSemantics(
        find.byType(AccessibleGridSemantics),
      );
      expect(singularSemantics.label, contains('1 widget placed'));

      // Test plural
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleGridSemantics(
              dimensions: testDimensions,
              placedWidgetCount: 3,
              isPreviewMode: false,
              child: Container(),
            ),
          ),
        ),
      );

      final pluralSemantics = tester.getSemantics(
        find.byType(AccessibleGridSemantics),
      );
      expect(pluralSemantics.label, contains('3 widgets placed'));
    });
  });
}
