import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/error_display.dart';
import 'package:formbuilder/form_layout/models/validation_result.dart';

void main() {
  group('ErrorDisplay', () {
    testWidgets('show does nothing when result has no message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDisplay.show(
                      context,
                      const ValidationResult.success(),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('shows error snackbar with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDisplay.show(
                      context,
                      const ValidationResult.error('Test error message'),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(snackBar.backgroundColor, equals(theme.colorScheme.error));
      expect(snackBar.duration, equals(const Duration(seconds: 6)));
    });

    testWidgets('shows warning snackbar with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDisplay.show(
                      context,
                      const ValidationResult.warning('Test warning message'),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Test warning message'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      expect(find.text('Dismiss'), findsNothing);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(snackBar.backgroundColor, equals(theme.colorScheme.tertiary));
      expect(snackBar.duration, equals(const Duration(seconds: 4)));
    });

    testWidgets('shows info snackbar with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDisplay.show(
                      context,
                      const ValidationResult.info('Test info message'),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Test info message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(snackBar.backgroundColor, equals(theme.colorScheme.primary));
      expect(snackBar.duration, equals(const Duration(seconds: 4)));
    });

    testWidgets('calls onDismiss callback when dismissed', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDisplay.show(
                      context,
                      const ValidationResult.error('Test error message'),
                      onDismiss: () {
                        dismissed = true;
                      },
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('shows dialog when strategy is dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDisplay.show(
                      context,
                      const ValidationResult.error('Test error message'),
                      strategy: ErrorDisplayStrategy.dialog,
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  });

  group('InlineErrorDisplay', () {
    testWidgets('shows child only when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorDisplay(
              result: ValidationResult.success(),
              child: Text('Child'),
            ),
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('shows error border and icon for error result', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorDisplay(
              result: ValidationResult.error('Error message'),
              child: Text('Child'),
            ),
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Stack),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.border?.top.color,
        equals(
          Theme.of(tester.element(find.byType(Scaffold))).colorScheme.error,
        ),
      );
    });

    testWidgets('shows warning styling for warning result', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorDisplay(
              result: ValidationResult.warning('Warning message'),
              child: Text('Child'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Stack),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.border?.top.color,
        equals(
          Theme.of(tester.element(find.byType(Scaffold))).colorScheme.tertiary,
        ),
      );
    });

    testWidgets('shows tooltip with error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorDisplay(
              result: ValidationResult.error('Error message'),
              child: Text('Child'),
            ),
          ),
        ),
      );

      final icon = find.byIcon(Icons.error_outline);
      await tester.longPress(icon);
      await tester.pumpAndSettle();

      expect(find.text('Error message'), findsOneWidget);
    });
  });

  group('ErrorStatusBar', () {
    testWidgets('hides when no result', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStatusBar(result: ValidationResult.success()),
          ),
        ),
      );

      expect(find.byType(ErrorStatusBar), findsOneWidget);
      // When there's no error, the ErrorStatusBar should still render but be effectively hidden
      expect(find.text(''), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('shows error status bar with correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStatusBar(result: ValidationResult.error('Error message')),
          ),
        ),
      );

      expect(find.text('Error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      final errorStatusBar = find.byType(ErrorStatusBar);
      final material = tester.widget<Material>(
        find
            .descendant(of: errorStatusBar, matching: find.byType(Material))
            .first,
      );
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(material.color, equals(theme.colorScheme.errorContainer));
    });

    testWidgets('shows warning status bar with correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStatusBar(result: ValidationResult.warning('Warning message')),
          ),
        ),
      );

      expect(find.text('Warning message'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);

      final errorStatusBar = find.byType(ErrorStatusBar);
      final material = tester.widget<Material>(
        find
            .descendant(of: errorStatusBar, matching: find.byType(Material))
            .first,
      );
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(material.color, equals(theme.colorScheme.tertiaryContainer));
    });

    testWidgets('hides dismiss button when no callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStatusBar(result: ValidationResult.error('Error')),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('calls onDismiss when close button tapped', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStatusBar(
              result: const ValidationResult.error('Error'),
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('adapts colors for dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ErrorStatusBar(result: ValidationResult.error('Error')),
          ),
        ),
      );

      final errorStatusBar = find.byType(ErrorStatusBar);
      final material = tester.widget<Material>(
        find
            .descendant(of: errorStatusBar, matching: find.byType(Material))
            .first,
      );
      
      // In dark theme, the color should be darker
      expect(material.color, isNotNull);
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(material.color, equals(theme.colorScheme.errorContainer));
    });
  });
}