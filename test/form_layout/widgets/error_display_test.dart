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
      expect(find.text('Dismiss'), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, equals(Colors.red.shade600));
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
                      const ValidationResult.warning('Test warning'),
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
      expect(find.text('Test warning'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      expect(find.text('Dismiss'), findsNothing);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, equals(Colors.orange.shade600));
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
                      const ValidationResult.info('Test info'),
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
      expect(find.text('Test info'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, equals(Colors.blue.shade600));
    });

    testWidgets('calls onDismiss callback when dismissed', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorDisplay.show(
                      context,
                      const ValidationResult.error('Test error'),
                      onDismiss: () => dismissed = true,
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
                      const ValidationResult.error('Dialog error'),
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
      expect(find.text('Dialog error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  });

  group('InlineErrorDisplay', () {
    testWidgets('shows child only when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorDisplay(result: null, child: Text('Child')),
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('shows error border and icon for error result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InlineErrorDisplay(
              result: const ValidationResult.error('Error message'),
              child: const Text('Child'),
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
      expect(decoration.border?.top.color, equals(Colors.orange));
    });

    testWidgets('shows tooltip with error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineErrorDisplay(
              result: ValidationResult.error('Detailed error message'),
              child: Text('Child'),
            ),
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, equals('Detailed error message'));
    });
  });

  group('ErrorStatusBar', () {
    testWidgets('hides when no result', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ErrorStatusBar(result: null))),
      );

      expect(find.byType(ErrorStatusBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ErrorStatusBar),
          matching: find.byType(Material),
        ),
        findsNothing,
      );
    });

    testWidgets('shows error status bar with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStatusBar(
              result: const ValidationResult.error('Error status'),
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Error status'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      final errorStatusBar = find.byType(ErrorStatusBar);
      final material = tester.widget<Material>(
        find
            .descendant(of: errorStatusBar, matching: find.byType(Material))
            .first,
      );
      expect(material.color, equals(Colors.red.shade100));
    });

    testWidgets('shows warning status bar with correct styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStatusBar(
              result: const ValidationResult.warning('Warning status'),
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Warning status'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);

      final errorStatusBar = find.byType(ErrorStatusBar);
      final material = tester.widget<Material>(
        find
            .descendant(of: errorStatusBar, matching: find.byType(Material))
            .first,
      );
      expect(material.color, equals(Colors.orange.shade100));
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
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStatusBar(
              result: const ValidationResult.error('Error'),
              onDismiss: () => dismissed = true,
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
          home: Scaffold(
            body: ErrorStatusBar(result: const ValidationResult.error('Error')),
          ),
        ),
      );

      final errorStatusBar = find.byType(ErrorStatusBar);
      final material = tester.widget<Material>(
        find
            .descendant(of: errorStatusBar, matching: find.byType(Material))
            .first,
      );
      expect(material.color, equals(Colors.red.shade900));
    });
  });
}
