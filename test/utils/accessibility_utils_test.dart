import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:formbuilder/form_layout/utils/accessibility_utils.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  group('AccessibilityUtils', () {
    test('should create semantic label for widget placement', () {
      final placement = WidgetPlacement(
        id: 'test-1',
        widgetName: 'Text Field',
        column: 2,
        row: 3,
        width: 2,
        height: 1,
      );
      
      final label = AccessibilityUtils.getWidgetSemanticLabel(placement);
      expect(label, 'Text Field widget at column 3, row 4. Size: 2 by 1 cells');
    });

    test('should create semantic hint for selected widget', () {
      final hint = AccessibilityUtils.getWidgetSemanticHint(true);
      expect(hint, 'Double tap to deselect. Use arrow keys to move. Press Delete to remove.');
    });

    test('should create semantic hint for unselected widget', () {
      final hint = AccessibilityUtils.getWidgetSemanticHint(false);
      expect(hint, 'Double tap to select');
    });

    test('should create semantic label for grid cell', () {
      final label = AccessibilityUtils.getGridCellLabel(0, 0);
      expect(label, 'Grid cell at column 1, row 1');
      
      final label2 = AccessibilityUtils.getGridCellLabel(3, 2);
      expect(label2, 'Grid cell at column 4, row 3');
    });

    test('should create semantic label for toolbox item', () {
      final label = AccessibilityUtils.getToolboxItemLabel('Button', 2, 1);
      expect(label, 'Button. Default size: 2 by 1 cells. Double tap to place on grid.');
    });

    group('Color contrast', () {
      test('should calculate correct contrast ratio', () {
        // Black on white should have ratio of 21:1
        expect(
          AccessibilityUtils.meetsContrastRatio(Colors.black, Colors.white),
          true,
        );
        
        // White on white should have ratio of 1:1
        expect(
          AccessibilityUtils.meetsContrastRatio(Colors.white, Colors.white),
          false,
        );
      });

      test('should meet WCAG AA standards for normal text', () {
        // 4.5:1 minimum for normal text
        expect(
          AccessibilityUtils.meetsContrastRatio(
            const Color(0xFF595959), // Gray
            Colors.white,
          ),
          true,
        );
        
        expect(
          AccessibilityUtils.meetsContrastRatio(
            const Color(0xFF969696), // Light gray
            Colors.white,
          ),
          false,
        );
      });

      test('should meet WCAG AA standards for large text', () {
        // 3:1 minimum for large text
        expect(
          AccessibilityUtils.meetsContrastRatio(
            const Color(0xFF7A7A7A), // Medium gray
            Colors.white,
            isLargeText: true,
          ),
          true,
        );
      });
    });
  });

  group('AccessibleTouchTarget', () {
    testWidgets('should enforce minimum touch target size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTouchTarget(
              child: Icon(Icons.close, size: 16),
            ),
          ),
        ),
      );

      final touchTarget = tester.getSize(find.byType(AccessibleTouchTarget));
      expect(touchTarget.width, greaterThanOrEqualTo(AccessibilityUtils.minTouchTargetSize));
      expect(touchTarget.height, greaterThanOrEqualTo(AccessibilityUtils.minTouchTargetSize));
    });

    testWidgets('should apply semantic properties', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleTouchTarget(
              onTap: () => tapped = true,
              semanticLabel: 'Test button',
              semanticHint: 'Tap to test',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AccessibleTouchTarget));
      expect(semantics.label, 'Test button');
      expect(semantics.hint, 'Tap to test');
      expect(semantics.hasFlag(SemanticsFlag.isButton), true);

      await tester.tap(find.byType(AccessibleTouchTarget));
      expect(tapped, true);
    });
  });

  group('AccessibleFocusIndicator', () {
    testWidgets('should show focus indicator when focused', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleFocusIndicator(
              isFocused: true,
              child: Text('Focused'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AccessibleFocusIndicator),
          matching: find.byType(Container),
        ),
      );
      
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.width, AccessibilityUtils.focusIndicatorWidth);
    });

    testWidgets('should not show focus indicator when not focused', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleFocusIndicator(
              isFocused: false,
              child: Text('Not focused'),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(AccessibleFocusIndicator),
          matching: find.byType(Container),
        ),
        findsNothing,
      );
    });
  });
}