import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormLayoutTheme {
  const FormLayoutTheme({
    this.gridLineColor = const Color(0xFFE0E0E0),
    this.gridBackgroundColor = Colors.white,
    this.selectionBorderColor = const Color(0xFF2196F3),
    this.dragHighlightColor = const Color(0x4D2196F3),
    this.invalidDropColor = const Color(0x4DF44336),
    this.toolboxBackgroundColor = const Color(0xFFF5F5F5),
    this.labelStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF424242),
    ),
    this.widgetBorderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.elevations = 2.0,
    this.defaultPadding = const EdgeInsets.all(8.0),
  });

  final Color gridLineColor;
  final Color gridBackgroundColor;
  final Color selectionBorderColor;
  final Color dragHighlightColor;
  final Color invalidDropColor;
  final Color toolboxBackgroundColor;
  final TextStyle labelStyle;
  final BorderRadius widgetBorderRadius;
  final double elevations;
  final EdgeInsets defaultPadding;

  static FormLayoutTheme of(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<_FormLayoutThemeInheritedWidget>();
    if (theme != null) {
      return theme.theme;
    }

    // Fall back to creating from Material theme
    final materialTheme = Theme.of(context);
    return FormLayoutTheme.fromThemeData(materialTheme);
  }

  static FormLayoutTheme fromThemeData(ThemeData themeData) {
    final isDark = themeData.brightness == Brightness.dark;
    final colorScheme = themeData.colorScheme;

    return FormLayoutTheme(
      gridLineColor: isDark ? Colors.grey[600]! : Colors.grey[300]!,
      gridBackgroundColor: colorScheme.surface,
      selectionBorderColor: colorScheme.primary,
      dragHighlightColor: colorScheme.primary.withValues(alpha: 0.3),
      invalidDropColor: colorScheme.error.withValues(alpha: 0.3),
      toolboxBackgroundColor: colorScheme.surface,
      labelStyle: themeData.textTheme.bodyMedium ?? const TextStyle(),
      widgetBorderRadius: const BorderRadius.all(Radius.circular(4.0)),
      elevations: 2.0,
      defaultPadding: const EdgeInsets.all(8.0),
    );
  }

  static FormLayoutTheme material() {
    return const FormLayoutTheme(
      gridLineColor: Color(0xFFE0E0E0),
      gridBackgroundColor: Colors.white,
      selectionBorderColor: Color(0xFF2196F3),
      dragHighlightColor: Color(0x4D2196F3),
      invalidDropColor: Color(0x4DF44336),
      toolboxBackgroundColor: Color(0xFFF5F5F5),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF424242),
      ),
      widgetBorderRadius: BorderRadius.all(Radius.circular(4.0)),
      elevations: 2.0,
      defaultPadding: EdgeInsets.all(8.0),
    );
  }

  static FormLayoutTheme cupertino() {
    return const FormLayoutTheme(
      gridLineColor: Color(0xFFE5E5EA),
      gridBackgroundColor: CupertinoColors.systemBackground,
      selectionBorderColor: CupertinoColors.systemBlue,
      dragHighlightColor: Color(0x4D007AFF),
      invalidDropColor: Color(0x4DFF3B30),
      toolboxBackgroundColor: Color(0xFFF2F2F7),
      labelStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.label,
      ),
      widgetBorderRadius: BorderRadius.all(Radius.circular(8.0)),
      elevations: 0.0,
      defaultPadding: EdgeInsets.all(12.0),
    );
  }

  static FormLayoutTheme highContrast() {
    return const FormLayoutTheme(
      gridLineColor: Colors.black,
      gridBackgroundColor: Colors.white,
      selectionBorderColor: Colors.black,
      dragHighlightColor: Color(0x80000000),
      invalidDropColor: Color(0x80FF0000),
      toolboxBackgroundColor: Color(0xFFF0F0F0),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      widgetBorderRadius: BorderRadius.all(Radius.circular(2.0)),
      elevations: 4.0,
      defaultPadding: EdgeInsets.all(12.0),
    );
  }

  FormLayoutTheme copyWith({
    Color? gridLineColor,
    Color? gridBackgroundColor,
    Color? selectionBorderColor,
    Color? dragHighlightColor,
    Color? invalidDropColor,
    Color? toolboxBackgroundColor,
    TextStyle? labelStyle,
    BorderRadius? widgetBorderRadius,
    double? elevations,
    EdgeInsets? defaultPadding,
  }) {
    return FormLayoutTheme(
      gridLineColor: gridLineColor ?? this.gridLineColor,
      gridBackgroundColor: gridBackgroundColor ?? this.gridBackgroundColor,
      selectionBorderColor: selectionBorderColor ?? this.selectionBorderColor,
      dragHighlightColor: dragHighlightColor ?? this.dragHighlightColor,
      invalidDropColor: invalidDropColor ?? this.invalidDropColor,
      toolboxBackgroundColor:
          toolboxBackgroundColor ?? this.toolboxBackgroundColor,
      labelStyle: labelStyle ?? this.labelStyle,
      widgetBorderRadius: widgetBorderRadius ?? this.widgetBorderRadius,
      elevations: elevations ?? this.elevations,
      defaultPadding: defaultPadding ?? this.defaultPadding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FormLayoutTheme &&
        other.gridLineColor == gridLineColor &&
        other.gridBackgroundColor == gridBackgroundColor &&
        other.selectionBorderColor == selectionBorderColor &&
        other.dragHighlightColor == dragHighlightColor &&
        other.invalidDropColor == invalidDropColor &&
        other.toolboxBackgroundColor == toolboxBackgroundColor &&
        other.labelStyle == labelStyle &&
        other.widgetBorderRadius == widgetBorderRadius &&
        other.elevations == elevations &&
        other.defaultPadding == defaultPadding;
  }

  @override
  int get hashCode {
    return Object.hash(
      gridLineColor,
      gridBackgroundColor,
      selectionBorderColor,
      dragHighlightColor,
      invalidDropColor,
      toolboxBackgroundColor,
      labelStyle,
      widgetBorderRadius,
      elevations,
      defaultPadding,
    );
  }
}

class _FormLayoutThemeInheritedWidget extends InheritedWidget {
  const _FormLayoutThemeInheritedWidget({
    required this.theme,
    required super.child,
  });

  final FormLayoutTheme theme;

  @override
  bool updateShouldNotify(_FormLayoutThemeInheritedWidget oldWidget) {
    return theme != oldWidget.theme;
  }
}

class FormLayoutThemeWidget extends StatelessWidget {
  const FormLayoutThemeWidget({
    super.key,
    required this.theme,
    required this.child,
  });

  final FormLayoutTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _FormLayoutThemeInheritedWidget(theme: theme, child: child);
  }
}
