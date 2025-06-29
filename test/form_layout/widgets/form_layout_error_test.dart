import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/form_layout_error.dart';

void main() {
  group('FormLayoutError', () {
    testWidgets('renders child normally when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FormLayoutError(child: Text('Normal child'))),
      );

      expect(find.text('Normal child'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('displays error UI when error is triggered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutError(
            child: Builder(
              builder: (context) {
                // Trigger error after build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FormLayoutError.triggerError(
                    context,
                    Exception('Test error'),
                  );
                });
                return const Text('Child widget');
              },
            ),
          ),
        ),
      );

      // Initially shows child
      expect(find.text('Child widget'), findsOneWidget);

      // After error is triggered
      await tester.pump();

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Try to Recover'), findsOneWidget);
    });

    testWidgets('shows error details in debug mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutError(
            showDebugInfo: true,
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FormLayoutError.triggerError(
                    context,
                    Exception('Debug test error'),
                  );
                });
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Error Details:'), findsOneWidget);
      expect(find.textContaining('Debug test error'), findsOneWidget);
      expect(find.text('Stack Trace:'), findsOneWidget);
    });

    testWidgets('hides error details when showDebugInfo is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutError(
            showDebugInfo: false,
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FormLayoutError.triggerError(
                    context,
                    Exception('Hidden error'),
                  );
                });
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Error Details:'), findsNothing);
      expect(find.textContaining('Hidden error'), findsNothing);
    });

    testWidgets('calls onError callback when error occurs', (tester) async {
      Object? capturedError;
      StackTrace? capturedStackTrace;

      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutError(
            onError: (error, stackTrace) {
              capturedError = error;
              capturedStackTrace = stackTrace;
            },
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FormLayoutError.triggerError(
                    context,
                    Exception('Callback test error'),
                    StackTrace.current,
                  );
                });
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('Callback test error'));
      expect(capturedStackTrace, isNotNull);
    });

    testWidgets('uses custom error builder when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutError(
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Text('Custom error: $error'));
            },
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FormLayoutError.triggerError(
                    context,
                    Exception('Custom builder error'),
                  );
                });
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('Custom error: Exception: Custom builder error'),
        findsOneWidget,
      );
      expect(find.text('Oops! Something went wrong'), findsNothing);
    });

    testWidgets('recover button resets error state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutError(
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FormLayoutError.triggerError(
                    context,
                    Exception('Test error'),
                  );
                });
                return const Text('Normal content');
              },
            ),
          ),
        ),
      );

      // Trigger error
      await tester.pump();
      expect(find.text('Oops! Something went wrong'), findsOneWidget);

      // Scroll to and tap recover button
      await tester.ensureVisible(find.text('Try to Recover'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Try to Recover'));
      await tester.pump();

      // Should show normal content again
      expect(find.text('Normal content'), findsOneWidget);
      expect(find.text('Oops! Something went wrong'), findsNothing);
    });

    testWidgets('error widget adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: FormLayoutError(
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FormLayoutError.triggerError(
                    context,
                    Exception('Dark theme error'),
                  );
                });
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.grey.shade900));
    });
  });

  group('ErrorBoundaryExtension', () {
    testWidgets('withErrorBoundary wraps widget correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Text('Test widget').withErrorBoundary()),
        );

      expect(find.byType(FormLayoutError), findsOneWidget);
      expect(find.text('Test widget'), findsOneWidget);
    });

    testWidgets('withErrorBoundary passes parameters correctly', (
      tester,
    ) async {
      var errorCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home:
              Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FormLayoutError.triggerError(
                      context,
                      Exception('Extension error'),
                    );
                  });
                  return const SizedBox();
                },
              ).withErrorBoundary(
                showDebugInfo: false,
                onError: (error, stackTrace) => errorCalled = true,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Custom error widget');
                },
              ),
        ),
      );

      await tester.pump();

      expect(find.text('Custom error widget'), findsOneWidget);
      expect(errorCalled, isTrue);
      expect(find.text('Error Details:'), findsNothing);
    });
  });
}
