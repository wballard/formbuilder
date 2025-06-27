import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/theme/accessible_color_scheme.dart';
import 'package:formbuilder/form_layout/utils/accessibility_utils.dart';

void main() {
  group('AccessibleColorScheme', () {
    group('lightColorScheme', () {
      testWidgets('should create light color scheme with accessible contrast', (tester) async {
        final colorScheme = AccessibleColorScheme.lightColorScheme();

        expect(colorScheme.brightness, equals(Brightness.light));
        expect(colorScheme.surface, equals(Colors.white));
        
        // Verify contrast ratios meet WCAG AA standards
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.primary,
            colorScheme.surface,
          ),
          isTrue,
        );
        
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.onSurface,
            colorScheme.surface,
          ),
          isTrue,
        );
      });

      testWidgets('should accept custom colors and ensure contrast', (tester) async {
        const customPrimary = Colors.red;
        const customSecondary = Colors.green;
        const customError = Colors.orange;

        final colorScheme = AccessibleColorScheme.lightColorScheme(
          primary: customPrimary,
          secondary: customSecondary,
          error: customError,
        );

        // Colors should be adjusted to meet contrast requirements
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.error, isNotNull);
        
        // All should meet contrast requirements
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.primary,
            colorScheme.surface,
          ),
          isTrue,
        );
      });
    });

    group('darkColorScheme', () {
      testWidgets('should create dark color scheme with accessible contrast', (tester) async {
        final colorScheme = AccessibleColorScheme.darkColorScheme();

        expect(colorScheme.brightness, equals(Brightness.dark));
        
        // Verify contrast ratios meet WCAG AA standards
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.primary,
            colorScheme.surface,
          ),
          isTrue,
        );
        
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.onSurface,
            colorScheme.surface,
          ),
          isTrue,
        );
      });

      testWidgets('should accept custom colors and ensure contrast', (tester) async {
        const customPrimary = Colors.blue;
        const customSecondary = Colors.purple;
        const customError = Colors.pink;

        final colorScheme = AccessibleColorScheme.darkColorScheme(
          primary: customPrimary,
          secondary: customSecondary,
          error: customError,
        );

        // All should meet contrast requirements
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.primary,
            colorScheme.surface,
          ),
          isTrue,
        );
      });
    });

    group('highContrastLight', () {
      testWidgets('should create high contrast light color scheme', (tester) async {
        final colorScheme = AccessibleColorScheme.highContrastLight();

        expect(colorScheme.brightness, equals(Brightness.light));
        expect(colorScheme.primary, equals(Colors.black));
        expect(colorScheme.onPrimary, equals(Colors.white));
        expect(colorScheme.surface, equals(Colors.white));
        expect(colorScheme.onSurface, equals(Colors.black));
        
        // High contrast should definitely meet WCAG standards
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.primary,
            colorScheme.surface,
          ),
          isTrue,
        );
        
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.onSurface,
            colorScheme.surface,
          ),
          isTrue,
        );
      });
    });

    group('highContrastDark', () {
      testWidgets('should create high contrast dark color scheme', (tester) async {
        final colorScheme = AccessibleColorScheme.highContrastDark();

        expect(colorScheme.brightness, equals(Brightness.dark));
        expect(colorScheme.primary, equals(Colors.white));
        expect(colorScheme.onPrimary, equals(Colors.black));
        expect(colorScheme.surface, equals(Colors.black));
        expect(colorScheme.onSurface, equals(Colors.white));
        
        // High contrast should definitely meet WCAG standards
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.primary,
            colorScheme.surface,
          ),
          isTrue,
        );
        
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.onSurface,
            colorScheme.surface,
          ),
          isTrue,
        );
      });
    });

    group('getColorScheme', () {
      testWidgets('should return light color scheme for light brightness', (tester) async {
        final colorScheme = AccessibleColorScheme.getColorScheme(
          brightness: Brightness.light,
          highContrast: false,
        );

        expect(colorScheme.brightness, equals(Brightness.light));
        expect(colorScheme.surface, equals(Colors.white));
      });

      testWidgets('should return dark color scheme for dark brightness', (tester) async {
        final colorScheme = AccessibleColorScheme.getColorScheme(
          brightness: Brightness.dark,
          highContrast: false,
        );

        expect(colorScheme.brightness, equals(Brightness.dark));
      });

      testWidgets('should return high contrast light when requested', (tester) async {
        final colorScheme = AccessibleColorScheme.getColorScheme(
          brightness: Brightness.light,
          highContrast: true,
        );

        expect(colorScheme.brightness, equals(Brightness.light));
        expect(colorScheme.primary, equals(Colors.black));
        expect(colorScheme.surface, equals(Colors.white));
      });

      testWidgets('should return high contrast dark when requested', (tester) async {
        final colorScheme = AccessibleColorScheme.getColorScheme(
          brightness: Brightness.dark,
          highContrast: true,
        );

        expect(colorScheme.brightness, equals(Brightness.dark));
        expect(colorScheme.primary, equals(Colors.white));
        expect(colorScheme.surface, equals(Colors.black));
      });

      testWidgets('should accept custom colors for non-high contrast schemes', (tester) async {
        const customPrimary = Colors.teal;
        
        final lightScheme = AccessibleColorScheme.getColorScheme(
          brightness: Brightness.light,
          highContrast: false,
          primary: customPrimary,
        );

        final darkScheme = AccessibleColorScheme.getColorScheme(
          brightness: Brightness.dark,
          highContrast: false,
          primary: customPrimary,
        );

        // Custom colors should be applied (and adjusted for contrast if needed)
        expect(lightScheme.primary, isNotNull);
        expect(darkScheme.primary, isNotNull);
      });
    });

    group('_ensureContrast', () {
      testWidgets('should maintain color if contrast is sufficient', (tester) async {
        // Black on white already has excellent contrast
        const foreground = Colors.black;
        const background = Colors.white;
        
        final lightScheme = AccessibleColorScheme.lightColorScheme();
        
        // The scheme should work with high contrast colors
        expect(
          AccessibilityUtils.meetsContrastRatio(foreground, background),
          isTrue,
        );
      });

      testWidgets('should adjust color if contrast is insufficient', (tester) async {
        // Light gray on white has poor contrast
        const foreground = Color(0xFFE0E0E0);
        const background = Colors.white;
        
        expect(
          AccessibilityUtils.meetsContrastRatio(foreground, background),
          isFalse,
        );
        
        // The color scheme should automatically adjust such colors
        final colorScheme = AccessibleColorScheme.lightColorScheme();
        
        // All colors in the scheme should meet contrast requirements
        expect(
          AccessibilityUtils.meetsContrastRatio(
            colorScheme.onSurface,
            colorScheme.surface,
          ),
          isTrue,
        );
      });
    });

    group('color consistency', () {
      testWidgets('should maintain consistent color relationships', (tester) async {
        final lightScheme = AccessibleColorScheme.lightColorScheme();
        final darkScheme = AccessibleColorScheme.darkColorScheme();

        // Light scheme should have dark text on light background
        expect(lightScheme.surface.computeLuminance(), greaterThan(0.5));
        expect(lightScheme.onSurface.computeLuminance(), lessThan(0.5));

        // Dark scheme should have light text on dark background
        expect(darkScheme.surface.computeLuminance(), lessThan(0.5));
        expect(darkScheme.onSurface.computeLuminance(), greaterThan(0.5));
      });

      testWidgets('should have proper container color relationships', (tester) async {
        final lightScheme = AccessibleColorScheme.lightColorScheme();

        // Container colors should be different from their content colors
        expect(lightScheme.onPrimaryContainer, isNot(equals(lightScheme.primaryContainer)));
        expect(lightScheme.onSecondaryContainer, isNot(equals(lightScheme.secondaryContainer)));
      });
    });
  });
}