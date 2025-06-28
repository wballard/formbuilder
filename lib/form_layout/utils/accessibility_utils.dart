import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'dart:math';

/// Utilities for accessibility support in the form builder
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Minimum touch target size for accessibility (WCAG guideline)
  static const double minTouchTargetSize = 44.0;

  /// High contrast focus indicator width
  static const double focusIndicatorWidth = 3.0;

  /// Create a semantic label for a placed widget
  static String getWidgetSemanticLabel(WidgetPlacement placement) {
    return '${placement.widgetName} widget at column ${placement.column + 1}, row ${placement.row + 1}. '
        'Size: ${placement.width} by ${placement.height} cells';
  }

  /// Create a semantic hint for a placed widget
  static String getWidgetSemanticHint(bool isSelected) {
    if (isSelected) {
      return 'Double tap to deselect. Use arrow keys to move. Press Delete to remove.';
    }
    return 'Double tap to select';
  }

  /// Create a semantic label for a grid cell
  static String getGridCellLabel(int column, int row) {
    return 'Grid cell at column ${column + 1}, row ${row + 1}';
  }

  /// Create a semantic label for a toolbox item
  static String getToolboxItemLabel(
    String itemName,
    int defaultWidth,
    int defaultHeight,
  ) {
    return '$itemName. Default size: $defaultWidth by $defaultHeight cells. Double tap to place on grid.';
  }

  /// Announce a status change using Semantics
  static void announceStatus(BuildContext context, String message) {
    SemanticsService.announce(message, Directionality.of(context));
  }

  /// Check if color contrast meets WCAG AA standards
  static bool meetsContrastRatio(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final double ratio = _calculateContrastRatio(foreground, background);
    return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// Calculate contrast ratio between two colors
  static double _calculateContrastRatio(Color color1, Color color2) {
    final lum1 = _relativeLuminance(color1);
    final lum2 = _relativeLuminance(color2);
    final bright = max(lum1, lum2);
    final dark = min(lum1, lum2);
    return (bright + 0.05) / (dark + 0.05);
  }

  /// Calculate relative luminance of a color
  static double _relativeLuminance(Color color) {
    final r = _toLinearRGB(color.r);
    final g = _toLinearRGB(color.g);
    final b = _toLinearRGB(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Convert sRGB to linear RGB
  static double _toLinearRGB(double value) {
    return value <= 0.03928
        ? value / 12.92
        : pow((value + 0.055) / 1.055, 2.4).toDouble();
  }
}

/// A widget that ensures minimum touch target size for accessibility
class AccessibleTouchTarget extends StatelessWidget {
  /// The child widget
  final Widget child;

  /// The tap callback
  final VoidCallback? onTap;

  /// Minimum size for the touch target
  final double minSize;

  /// Semantic label
  final String? semanticLabel;

  /// Semantic hint
  final String? semanticHint;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize = AccessibilityUtils.minTouchTargetSize,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// A focus indicator that meets accessibility standards
class AccessibleFocusIndicator extends StatelessWidget {
  /// Whether the widget is focused
  final bool isFocused;

  /// The child widget
  final Widget child;

  /// Focus indicator color
  final Color? focusColor;

  /// Border radius
  final BorderRadius? borderRadius;

  const AccessibleFocusIndicator({
    super.key,
    required this.isFocused,
    required this.child,
    this.focusColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveFocusColor = focusColor ?? theme.colorScheme.primary;

    if (!isFocused) {
      return child;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: effectiveFocusColor,
          width: AccessibilityUtils.focusIndicatorWidth,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

/// Skip link for keyboard navigation
class SkipLink extends StatelessWidget {
  /// The label for the skip link
  final String label;

  /// The callback when activated
  final VoidCallback onSkip;

  /// The child widget
  final Widget child;

  const SkipLink({
    super.key,
    required this.label,
    required this.onSkip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSkip,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  label,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
