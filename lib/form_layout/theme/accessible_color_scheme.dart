import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/utils/accessibility_utils.dart';

/// Provides accessible color schemes that meet WCAG AA standards
class AccessibleColorScheme {
  AccessibleColorScheme._();

  /// Create a light color scheme with accessible contrast ratios
  static ColorScheme lightColorScheme({
    Color? primary,
    Color? secondary,
    Color? error,
  }) {
    // Ensure primary color has sufficient contrast with white
    final effectivePrimary = primary ?? Colors.blue.shade700;
    final primaryColor = _ensureContrast(effectivePrimary, Colors.white, 4.5);

    // Ensure secondary color has sufficient contrast
    final effectiveSecondary = secondary ?? Colors.teal.shade700;
    final secondaryColor = _ensureContrast(
      effectiveSecondary,
      Colors.white,
      4.5,
    );

    // Ensure error color has sufficient contrast
    final effectiveError = error ?? Colors.red.shade700;
    final errorColor = _ensureContrast(effectiveError, Colors.white, 4.5);

    return ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryColor.withValues(alpha: 0.12),
      onPrimaryContainer: primaryColor,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: secondaryColor.withValues(alpha: 0.12),
      onSecondaryContainer: secondaryColor,
      error: errorColor,
      onError: Colors.white,
      errorContainer: errorColor.withValues(alpha: 0.12),
      onErrorContainer: errorColor,
      surface: Colors.white,
      onSurface: Colors.grey.shade900,
      surfaceContainerHighest: Colors.grey.shade100,
      onSurfaceVariant: Colors.grey.shade700,
      outline: Colors.grey.shade600,
      outlineVariant: Colors.grey.shade400,
    );
  }

  /// Create a dark color scheme with accessible contrast ratios
  static ColorScheme darkColorScheme({
    Color? primary,
    Color? secondary,
    Color? error,
  }) {
    // Ensure primary color has sufficient contrast with dark background
    final effectivePrimary = primary ?? Colors.blue.shade300;
    final primaryColor = _ensureContrast(
      effectivePrimary,
      Colors.grey.shade900,
      4.5,
    );

    // Ensure secondary color has sufficient contrast
    final effectiveSecondary = secondary ?? Colors.teal.shade300;
    final secondaryColor = _ensureContrast(
      effectiveSecondary,
      Colors.grey.shade900,
      4.5,
    );

    // Ensure error color has sufficient contrast
    final effectiveError = error ?? Colors.red.shade300;
    final errorColor = _ensureContrast(
      effectiveError,
      Colors.grey.shade900,
      4.5,
    );

    return ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.black,
      primaryContainer: primaryColor.withValues(alpha: 0.15),
      onPrimaryContainer: primaryColor,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      secondaryContainer: secondaryColor.withValues(alpha: 0.15),
      onSecondaryContainer: secondaryColor,
      error: errorColor,
      onError: Colors.black,
      errorContainer: errorColor.withValues(alpha: 0.15),
      onErrorContainer: errorColor,
      surface: Colors.grey.shade900,
      onSurface: Colors.grey.shade100,
      surfaceContainerHighest: Colors.grey.shade800,
      onSurfaceVariant: Colors.grey.shade300,
      outline: Colors.grey.shade400,
      outlineVariant: Colors.grey.shade600,
    );
  }

  /// Create a high contrast light color scheme
  static ColorScheme highContrastLight() {
    return const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E0E0),
      onPrimaryContainer: Colors.black,
      secondary: Color(0xFF004D40), // Dark teal
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE0F2F1),
      onSecondaryContainer: Color(0xFF004D40),
      error: Color(0xFFB71C1C), // Dark red
      onError: Colors.white,
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFB71C1C),
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceContainerHighest: Color(0xFFF5F5F5),
      onSurfaceVariant: Color(0xFF212121),
      outline: Colors.black,
      outlineVariant: Color(0xFF616161),
    );
  }

  /// Create a high contrast dark color scheme
  static ColorScheme highContrastDark() {
    return const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF424242),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFF80CBC4), // Light teal
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF004D40),
      onSecondaryContainer: Color(0xFF80CBC4),
      error: Color(0xFFEF9A9A), // Light red
      onError: Colors.black,
      errorContainer: Color(0xFF5D0909),
      onErrorContainer: Color(0xFFEF9A9A),
      surface: Colors.black,
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF212121),
      onSurfaceVariant: Color(0xFFE0E0E0),
      outline: Colors.white,
      outlineVariant: Color(0xFF9E9E9E),
    );
  }

  /// Ensure a color has sufficient contrast against a background
  static Color _ensureContrast(
    Color foreground,
    Color background,
    double minRatio,
  ) {
    if (AccessibilityUtils.meetsContrastRatio(foreground, background)) {
      return foreground;
    }

    // If contrast is insufficient, darken or lighten the color
    final isDarkBackground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark;

    HSLColor hsl = HSLColor.fromColor(foreground);
    const step = 0.05;

    // Adjust lightness until we meet contrast requirements
    while (!AccessibilityUtils.meetsContrastRatio(hsl.toColor(), background)) {
      if (isDarkBackground) {
        // Lighten the color for dark backgrounds
        hsl = hsl.withLightness((hsl.lightness + step).clamp(0.0, 1.0));
        if (hsl.lightness >= 1.0) break;
      } else {
        // Darken the color for light backgrounds
        hsl = hsl.withLightness((hsl.lightness - step).clamp(0.0, 1.0));
        if (hsl.lightness <= 0.0) break;
      }
    }

    return hsl.toColor();
  }

  /// Get a color scheme based on brightness and contrast preference
  static ColorScheme getColorScheme({
    required Brightness brightness,
    bool highContrast = false,
    Color? primary,
    Color? secondary,
    Color? error,
  }) {
    if (highContrast) {
      return brightness == Brightness.light
          ? highContrastLight()
          : highContrastDark();
    } else {
      return brightness == Brightness.light
          ? lightColorScheme(
              primary: primary,
              secondary: secondary,
              error: error,
            )
          : darkColorScheme(
              primary: primary,
              secondary: secondary,
              error: error,
            );
    }
  }
}
