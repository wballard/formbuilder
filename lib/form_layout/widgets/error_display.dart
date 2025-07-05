import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/validation_result.dart';

/// Different strategies for displaying errors
enum ErrorDisplayStrategy {
  /// Show as a SnackBar
  snackBar,

  /// Show inline near the error location
  inline,

  /// Show in a status bar
  statusBar,

  /// Show in a dialog
  dialog,
}

/// Displays validation errors and messages
class ErrorDisplay {
  /// Shows a validation result using the specified strategy
  static void show(
    BuildContext context,
    ValidationResult result, {
    ErrorDisplayStrategy strategy = ErrorDisplayStrategy.snackBar,
    VoidCallback? onDismiss,
  }) {
    if (!result.hasMessage) return;

    switch (strategy) {
      case ErrorDisplayStrategy.snackBar:
        _showSnackBar(context, result, onDismiss);
        break;
      case ErrorDisplayStrategy.dialog:
        _showDialog(context, result, onDismiss);
        break;
      case ErrorDisplayStrategy.inline:
        // Inline display is handled by widgets themselves
        break;
      case ErrorDisplayStrategy.statusBar:
        // Status bar is handled by a persistent widget
        break;
    }
  }

  static void _showSnackBar(
    BuildContext context,
    ValidationResult result,
    VoidCallback? onDismiss,
  ) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (result.severity) {
      case ValidationSeverity.error:
        backgroundColor = theme.colorScheme.error;
        textColor = theme.colorScheme.onError;
        icon = Icons.error_outline;
        break;
      case ValidationSeverity.warning:
        backgroundColor = theme.colorScheme.tertiary;
        textColor = theme.colorScheme.onTertiary;
        icon = Icons.warning_amber_outlined;
        break;
      case ValidationSeverity.info:
        backgroundColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onPrimary;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(result.message!, style: TextStyle(color: textColor)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        action: result.severity == ValidationSeverity.error
            ? SnackBarAction(
                label: 'Dismiss',
                textColor: textColor,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onDismiss?.call();
                },
              )
            : null,
        duration: Duration(
          seconds: result.severity == ValidationSeverity.error ? 6 : 4,
        ),
      ),
    );
  }

  static void _showDialog(
    BuildContext context,
    ValidationResult result,
    VoidCallback? onDismiss,
  ) {
    final theme = Theme.of(context);

    IconData icon;
    Color iconColor;
    String title;

    switch (result.severity) {
      case ValidationSeverity.error:
        icon = Icons.error_outline;
        iconColor = theme.colorScheme.error;
        title = 'Error';
        break;
      case ValidationSeverity.warning:
        icon = Icons.warning_amber_outlined;
        iconColor = theme.colorScheme.tertiary;
        title = 'Warning';
        break;
      case ValidationSeverity.info:
        icon = Icons.info_outline;
        iconColor = theme.colorScheme.primary;
        title = 'Information';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: iconColor, size: 48),
        title: Text(title),
        content: Text(result.message!),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Widget that displays validation errors inline
class InlineErrorDisplay extends StatelessWidget {
  final ValidationResult? result;
  final Widget child;

  const InlineErrorDisplay({super.key, this.result, required this.child});

  @override
  Widget build(BuildContext context) {
    if (result == null || !result!.hasMessage) {
      return child;
    }

    final theme = Theme.of(context);

    Color borderColor;
    Color backgroundColor;
    IconData icon;

    switch (result!.severity) {
      case ValidationSeverity.error:
        borderColor = theme.colorScheme.error;
        backgroundColor = theme.colorScheme.error.withValues(alpha: 0.1);
        icon = Icons.error_outline;
        break;
      case ValidationSeverity.warning:
        borderColor = theme.colorScheme.tertiary;
        backgroundColor = theme.colorScheme.tertiary.withValues(alpha: 0.1);
        icon = Icons.warning_amber_outlined;
        break;
      case ValidationSeverity.info:
        borderColor = theme.colorScheme.primary;
        backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
        icon = Icons.info_outline;
        break;
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(4),
            color: backgroundColor,
          ),
          child: child,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Tooltip(
            message: result!.message!,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: borderColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: result!.severity == ValidationSeverity.error
                    ? theme.colorScheme.onError
                    : result!.severity == ValidationSeverity.warning
                    ? theme.colorScheme.onTertiary
                    : theme.colorScheme.onPrimary,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Status bar for persistent error messages
class ErrorStatusBar extends StatelessWidget {
  final ValidationResult? result;
  final VoidCallback? onDismiss;

  const ErrorStatusBar({super.key, this.result, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (result == null || !result!.hasMessage) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (result!.severity) {
      case ValidationSeverity.error:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        icon = Icons.error_outline;
        break;
      case ValidationSeverity.warning:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        icon = Icons.warning_amber_outlined;
        break;
      case ValidationSeverity.info:
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        icon = Icons.info_outline;
        break;
    }

    return Material(
      color: backgroundColor,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result!.message!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close, color: textColor, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
