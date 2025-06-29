import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

/// A utility class for building widgets in tests with common configurations
class TestWidgetBuilder {
  /// Wraps a widget with MaterialApp and necessary dependencies for testing
  static Widget wrapWithMaterialApp(
    Widget child, {
    ThemeData? theme,
    FormLayoutTheme? formLayoutTheme,
    Size? screenSize,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Builder(
        builder: (context) {
          Widget wrappedChild = child;
          
          // Apply FormLayoutTheme if provided
          if (formLayoutTheme != null) {
            wrappedChild = _FormLayoutThemeProvider(
              theme: formLayoutTheme,
              child: wrappedChild,
            );
          }
          
          // Apply screen size constraints if provided
          if (screenSize != null) {
            wrappedChild = MediaQuery(
              data: MediaQuery.of(context).copyWith(size: screenSize),
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: wrappedChild,
              ),
            );
          }
          
          return Scaffold(body: wrappedChild);
        },
      ),
    );
  }

  /// Creates a test widget with a specific screen size
  static Widget withScreenSize(Widget child, Size size) {
    return wrapWithMaterialApp(child, screenSize: size);
  }

  /// Creates a test widget with dark theme
  static Widget withDarkTheme(Widget child) {
    return wrapWithMaterialApp(
      child,
      theme: ThemeData.dark(),
      formLayoutTheme: FormLayoutTheme.fromThemeData(ThemeData.dark()),
    );
  }

  /// Creates a test widget with light theme
  static Widget withLightTheme(Widget child) {
    return wrapWithMaterialApp(
      child,
      theme: ThemeData.light(),
      formLayoutTheme: FormLayoutTheme.fromThemeData(ThemeData.light()),
    );
  }

  /// Creates a test widget with custom theme
  static Widget withCustomTheme(
    Widget child, {
    required ThemeData theme,
    FormLayoutTheme? formLayoutTheme,
  }) {
    return wrapWithMaterialApp(
      child,
      theme: theme,
      formLayoutTheme: formLayoutTheme ?? FormLayoutTheme.fromThemeData(theme),
    );
  }

  /// Pumps a widget and settles all animations
  static Future<void> pumpWidgetAndSettle(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration ?? const Duration());
  }

  /// Pumps a widget with a specific screen size
  static Future<void> pumpWithScreenSize(
    WidgetTester tester,
    Widget widget,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    await pumpWidgetAndSettle(tester, withScreenSize(widget, size));
  }
}

/// InheritedWidget to provide FormLayoutTheme to descendants
class _FormLayoutThemeProvider extends InheritedWidget {
  final FormLayoutTheme theme;

  const _FormLayoutThemeProvider({
    required this.theme,
    required super.child,
  });

  @override
  bool updateShouldNotify(_FormLayoutThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }

  static _FormLayoutThemeProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FormLayoutThemeProvider>();
  }
}