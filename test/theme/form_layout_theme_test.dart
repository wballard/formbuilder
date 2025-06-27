import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

void main() {
  group('FormLayoutTheme', () {
    testWidgets('provides theme to descendants', (tester) async {
      const theme = FormLayoutTheme(
        gridLineColor: Colors.blue,
        gridBackgroundColor: Colors.white,
      );

      FormLayoutTheme? foundTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutThemeWidget(
            theme: theme,
            child: Builder(
              builder: (context) {
                foundTheme = FormLayoutTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(foundTheme, isNotNull);
      expect(foundTheme!.gridLineColor, Colors.blue);
      expect(foundTheme!.gridBackgroundColor, Colors.white);
    });

    testWidgets('falls back to default theme when not provided', (tester) async {
      FormLayoutTheme? foundTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              foundTheme = FormLayoutTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(foundTheme, isNotNull);
      expect(foundTheme!.gridLineColor, isA<Color>());
      expect(foundTheme!.gridBackgroundColor, isA<Color>());
    });

    test('creates theme from ThemeData', () {
      final materialTheme = ThemeData.light();
      final theme = FormLayoutTheme.fromThemeData(materialTheme);

      expect(theme.gridLineColor, isA<Color>());
      expect(theme.gridBackgroundColor, isA<Color>());
      expect(theme.selectionBorderColor, isA<Color>());
      expect(theme.dragHighlightColor, isA<Color>());
    });

    test('creates dark theme from dark ThemeData', () {
      final materialTheme = ThemeData.dark();
      final theme = FormLayoutTheme.fromThemeData(materialTheme);

      expect(theme.gridLineColor, isA<Color>());
      expect(theme.gridBackgroundColor, isA<Color>());
      expect(theme.selectionBorderColor, isA<Color>());
      expect(theme.dragHighlightColor, isA<Color>());
    });

    test('creates material design theme', () {
      final theme = FormLayoutTheme.material();

      expect(theme.gridLineColor, isA<Color>());
      expect(theme.gridBackgroundColor, Colors.white);
      expect(theme.selectionBorderColor, isA<Color>());
      expect(theme.labelStyle, isA<TextStyle>());
    });

    test('creates cupertino theme', () {
      final theme = FormLayoutTheme.cupertino();

      expect(theme.gridLineColor, isA<Color>());
      expect(theme.gridBackgroundColor, isA<Color>());
      expect(theme.selectionBorderColor, isA<Color>());
      expect(theme.labelStyle, isA<TextStyle>());
    });

    test('creates high contrast theme', () {
      final theme = FormLayoutTheme.highContrast();

      expect(theme.gridLineColor, Colors.black);
      expect(theme.gridBackgroundColor, Colors.white);
      expect(theme.selectionBorderColor, Colors.black);
      expect(theme.labelStyle, isA<TextStyle>());
    });

    test('copyWith creates new theme with updated properties', () {
      const original = FormLayoutTheme(
        gridLineColor: Colors.red,
        gridBackgroundColor: Colors.blue,
      );

      final updated = original.copyWith(
        gridLineColor: Colors.green,
      );

      expect(updated.gridLineColor, Colors.green);
      expect(updated.gridBackgroundColor, Colors.blue);
    });

    test('equality works correctly', () {
      const theme1 = FormLayoutTheme(
        gridLineColor: Colors.red,
        gridBackgroundColor: Colors.blue,
      );

      const theme2 = FormLayoutTheme(
        gridLineColor: Colors.red,
        gridBackgroundColor: Colors.blue,
      );

      const theme3 = FormLayoutTheme(
        gridLineColor: Colors.green,
        gridBackgroundColor: Colors.blue,
      );

      expect(theme1, equals(theme2));
      expect(theme1, isNot(equals(theme3)));
    });
  });
}