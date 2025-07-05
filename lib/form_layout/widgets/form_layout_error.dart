import 'package:flutter/material.dart';

/// Error boundary widget for the form layout
/// Catches and displays errors gracefully without losing work
///
/// Note: This widget only provides error UI for errors that have already been caught.
/// In production, you should combine this with proper error handling zones or
/// override FlutterError.onError to catch and display errors properly.
class FormLayoutError extends StatefulWidget {
  /// The child widget to protect
  final Widget child;

  /// Custom error widget builder
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  errorBuilder;

  /// Callback when an error is caught
  final void Function(Object error, StackTrace? stackTrace)? onError;

  /// Whether to show error details in debug mode
  final bool showDebugInfo;

  const FormLayoutError({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.showDebugInfo = true,
  });

  @override
  State<FormLayoutError> createState() => _FormLayoutErrorState();

  /// Helper method to trigger an error state programmatically
  /// This is mainly useful for testing
  static void triggerError(
    BuildContext context,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    final state = context.findAncestorStateOfType<_FormLayoutErrorState>();
    state?._handleError(error, stackTrace ?? StackTrace.current);
  }
}

class _FormLayoutErrorState extends State<FormLayoutError> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  void _handleError(Object error, StackTrace? stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
      _hasError = true;
    });
    widget.onError?.call(error, stackTrace);
  }

  void _recover() {
    setState(() {
      _error = null;
      _stackTrace = null;
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }

      return _buildDefaultErrorWidget(context);
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Oops! Something went wrong',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'An unexpected error occurred while using the form builder. '
                        'Don\'t worry, your work is safe. You can try to recover or restart.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.showDebugInfo &&
                          (_error != null || _stackTrace != null)) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Error Details:',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                _error.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                              if (_stackTrace != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Stack Trace:',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  child: SingleChildScrollView(
                                    child: SelectableText(
                                      _stackTrace.toString(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(fontFamily: 'monospace'),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // Copy error details to clipboard
                              // This would need clipboard plugin
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Error'),
                          ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            onPressed: _recover,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try to Recover'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to easily wrap widgets with error boundary
extension ErrorBoundaryExtension on Widget {
  Widget withErrorBoundary({
    Widget Function(BuildContext context, Object error, StackTrace? stackTrace)?
    errorBuilder,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool showDebugInfo = true,
  }) {
    return FormLayoutError(
      errorBuilder: errorBuilder,
      onError: onError,
      showDebugInfo: showDebugInfo,
      child: this,
    );
  }
}
