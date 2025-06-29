import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';

/// Custom matcher for widget placement at specific position
Matcher isAtPosition({required int row, required int column}) {
  return _WidgetPositionMatcher(row: row, column: column);
}

/// Custom matcher for widget with specific size
Matcher hasSize({required int width, required int height}) {
  return _WidgetSizeMatcher(width: width, height: height);
}

/// Custom matcher for widget within bounds
Matcher isWithinBounds({
  required int minRow,
  required int maxRow,
  required int minColumn,
  required int maxColumn,
}) {
  return _WidgetBoundsMatcher(
    minRow: minRow,
    maxRow: maxRow,
    minColumn: minColumn,
    maxColumn: maxColumn,
  );
}

/// Custom matcher for overlapping widgets
Matcher overlapsWidget(WidgetPlacement other) {
  return _WidgetOverlapMatcher(other);
}

/// Custom matcher for valid layout state
Matcher isValidLayoutState() {
  return const _ValidLayoutStateMatcher();
}

/// Custom matcher for accessible widget
Matcher isAccessible({
  String? label,
  String? hint,
  bool? enabled,
}) {
  return _AccessibilityMatcher(
    label: label,
    hint: hint,
    enabled: enabled,
  );
}

/// Custom matcher for widget with specific theme
Matcher hasTheme({
  Color? backgroundColor,
  Color? borderColor,
  BorderRadius? borderRadius,
}) {
  return _ThemeMatcher(
    backgroundColor: backgroundColor,
    borderColor: borderColor,
    borderRadius: borderRadius,
  );
}

// Implementation classes

class _WidgetPositionMatcher extends Matcher {
  final int row;
  final int column;

  const _WidgetPositionMatcher({required this.row, required this.column});

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! WidgetPlacement) return false;
    return item.row == row && item.column == column;
  }

  @override
  Description describe(Description description) {
    return description.add('widget at position ($row, $column)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! WidgetPlacement) {
      return mismatchDescription.add('is not a WidgetPlacement');
    }
    return mismatchDescription.add('is at position (${item.row}, ${item.column})');
  }
}

class _WidgetSizeMatcher extends Matcher {
  final int width;
  final int height;

  const _WidgetSizeMatcher({required this.width, required this.height});

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! WidgetPlacement) return false;
    return item.width == width && item.height == height;
  }

  @override
  Description describe(Description description) {
    return description.add('widget with size ${width}x$height');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! WidgetPlacement) {
      return mismatchDescription.add('is not a WidgetPlacement');
    }
    return mismatchDescription.add('has size ${item.width}x${item.height}');
  }
}

class _WidgetBoundsMatcher extends Matcher {
  final int minRow;
  final int maxRow;
  final int minColumn;
  final int maxColumn;

  const _WidgetBoundsMatcher({
    required this.minRow,
    required this.maxRow,
    required this.minColumn,
    required this.maxColumn,
  });

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! WidgetPlacement) return false;
    return item.row >= minRow &&
        item.row + item.height <= maxRow &&
        item.column >= minColumn &&
        item.column + item.width <= maxColumn;
  }

  @override
  Description describe(Description description) {
    return description.add(
        'widget within bounds [rows: $minRow-$maxRow, columns: $minColumn-$maxColumn]');
  }
}

class _WidgetOverlapMatcher extends Matcher {
  final WidgetPlacement other;

  const _WidgetOverlapMatcher(this.other);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! WidgetPlacement) return false;
    return item.overlaps(other);
  }

  @override
  Description describe(Description description) {
    return description.add('overlaps with widget ${other.id}');
  }
}

class _ValidLayoutStateMatcher extends Matcher {
  const _ValidLayoutStateMatcher();

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! LayoutState) return false;
    
    // Check for duplicate IDs
    final ids = item.widgets.map((w) => w.id).toList();
    if (ids.length != ids.toSet().length) {
      matchState['error'] = 'duplicate widget IDs';
      return false;
    }
    
    // Check for overlapping widgets
    for (int i = 0; i < item.widgets.length; i++) {
      for (int j = i + 1; j < item.widgets.length; j++) {
        if (item.widgets[i].overlaps(item.widgets[j])) {
          matchState['error'] = 
              'widgets ${item.widgets[i].id} and ${item.widgets[j].id} overlap';
          return false;
        }
      }
    }
    
    // Check all widgets fit in grid
    for (final widget in item.widgets) {
      if (!widget.fitsInGrid(item.dimensions)) {
        matchState['error'] = 'widget ${widget.id} does not fit in grid';
        return false;
      }
    }
    
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('valid layout state');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! LayoutState) {
      return mismatchDescription.add('is not a LayoutState');
    }
    if (matchState.containsKey('error')) {
      return mismatchDescription.add('has ${matchState['error']}');
    }
    return mismatchDescription;
  }
}

class _AccessibilityMatcher extends Matcher {
  final String? label;
  final String? hint;
  final bool? enabled;

  const _AccessibilityMatcher({this.label, this.hint, this.enabled});

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Semantics) return false;
    
    final properties = item.properties;
    
    if (label != null && properties.label != label) return false;
    if (hint != null && properties.hint != hint) return false;
    if (enabled != null && properties.enabled != enabled) return false;
    
    return true;
  }

  @override
  Description describe(Description description) {
    final parts = <String>[];
    if (label != null) parts.add('label: "$label"');
    if (hint != null) parts.add('hint: "$hint"');
    if (enabled != null) parts.add('enabled: $enabled');
    
    return description.add('accessible widget with ${parts.join(', ')}');
  }
}

class _ThemeMatcher extends Matcher {
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const _ThemeMatcher({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Container) return false;
    
    final decoration = item.decoration;
    if (decoration is! BoxDecoration) return false;
    
    if (backgroundColor != null && decoration.color != backgroundColor) {
      return false;
    }
    
    if (borderColor != null) {
      final border = decoration.border;
      if (border is! Border) return false;
      if (border.top.color != borderColor) return false;
    }
    
    if (borderRadius != null && decoration.borderRadius != borderRadius) {
      return false;
    }
    
    return true;
  }

  @override
  Description describe(Description description) {
    final parts = <String>[];
    if (backgroundColor != null) parts.add('backgroundColor: $backgroundColor');
    if (borderColor != null) parts.add('borderColor: $borderColor');
    if (borderRadius != null) parts.add('borderRadius: $borderRadius');
    
    return description.add('widget with theme ${parts.join(', ')}');
  }
}