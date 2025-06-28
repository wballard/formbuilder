import 'package:flutter/foundation.dart';

/// Severity levels for validation results
enum ValidationSeverity {
  /// Error - operation should not proceed
  error,

  /// Warning - operation can proceed but user should be aware
  warning,

  /// Info - informational message only
  info,
}

/// Result of a validation operation
@immutable
class ValidationResult {
  /// Whether the validation passed
  final bool isValid;

  /// Error/warning/info message if validation failed or has issues
  final String? message;

  /// Severity of the validation result
  final ValidationSeverity severity;

  /// Additional context data for the validation result
  final Map<String, dynamic>? context;

  const ValidationResult({
    required this.isValid,
    this.message,
    this.severity = ValidationSeverity.error,
    this.context,
  }) : assert(
         isValid || message != null,
         'Invalid results must have a message',
       );

  /// Creates a successful validation result
  const ValidationResult.success()
    : isValid = true,
      message = null,
      severity = ValidationSeverity.info,
      context = null;

  /// Creates an error validation result
  const ValidationResult.error(this.message, {this.context})
    : isValid = false,
      severity = ValidationSeverity.error;

  /// Creates a warning validation result
  const ValidationResult.warning(this.message, {this.context})
    : isValid = true,
      severity = ValidationSeverity.warning;

  /// Creates an info validation result
  const ValidationResult.info(this.message, {this.context})
    : isValid = true,
      severity = ValidationSeverity.info;

  /// Whether this result indicates an error
  bool get isError => !isValid && severity == ValidationSeverity.error;

  /// Whether this result indicates a warning
  bool get isWarning => severity == ValidationSeverity.warning;

  /// Whether this result has a message
  bool get hasMessage => message != null;

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, severity: $severity, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationResult &&
          runtimeType == other.runtimeType &&
          isValid == other.isValid &&
          message == other.message &&
          severity == other.severity &&
          mapEquals(context, other.context);

  @override
  int get hashCode =>
      isValid.hashCode ^
      message.hashCode ^
      severity.hashCode ^
      (context?.hashCode ?? 0);
}

/// Extension to combine multiple validation results
extension ValidationResultList on List<ValidationResult> {
  /// Combines multiple validation results into a single result
  ValidationResult combine() {
    if (isEmpty) return const ValidationResult.success();

    // Check if any are errors
    final errors = where((r) => r.isError).toList();
    if (errors.isNotEmpty) {
      final messages = errors
          .where((r) => r.message != null)
          .map((r) => r.message!)
          .join('\n');
      return ValidationResult.error(messages);
    }

    // Check for warnings
    final warnings = where((r) => r.isWarning).toList();
    if (warnings.isNotEmpty) {
      final messages = warnings
          .where((r) => r.message != null)
          .map((r) => r.message!)
          .join('\n');
      return ValidationResult.warning(messages);
    }

    // Check for info messages
    final infos = where((r) => r.hasMessage).toList();
    if (infos.isNotEmpty) {
      final messages = infos
          .where((r) => r.message != null)
          .map((r) => r.message!)
          .join('\n');
      return ValidationResult.info(messages);
    }

    return const ValidationResult.success();
  }
}
