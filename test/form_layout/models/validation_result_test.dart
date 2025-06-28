import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/validation_result.dart';

void main() {
  group('ValidationResult', () {
    group('factory constructors', () {
      test('success creates valid result with no message', () {
        const result = ValidationResult.success();

        expect(result.isValid, isTrue);
        expect(result.message, isNull);
        expect(result.severity, equals(ValidationSeverity.info));
        expect(result.context, isNull);
        expect(result.hasMessage, isFalse);
      });

      test('error creates invalid result with error severity', () {
        const result = ValidationResult.error(
          'Test error',
          context: {'key': 'value'},
        );

        expect(result.isValid, isFalse);
        expect(result.message, equals('Test error'));
        expect(result.severity, equals(ValidationSeverity.error));
        expect(result.context, equals({'key': 'value'}));
        expect(result.isError, isTrue);
        expect(result.hasMessage, isTrue);
      });

      test('warning creates valid result with warning severity', () {
        const result = ValidationResult.warning(
          'Test warning',
          context: {'count': 3},
        );

        expect(result.isValid, isTrue);
        expect(result.message, equals('Test warning'));
        expect(result.severity, equals(ValidationSeverity.warning));
        expect(result.context, equals({'count': 3}));
        expect(result.isWarning, isTrue);
        expect(result.hasMessage, isTrue);
      });

      test('info creates valid result with info severity', () {
        const result = ValidationResult.info(
          'Test info',
          context: {'data': 'test'},
        );

        expect(result.isValid, isTrue);
        expect(result.message, equals('Test info'));
        expect(result.severity, equals(ValidationSeverity.info));
        expect(result.context, equals({'data': 'test'}));
        expect(result.hasMessage, isTrue);
      });
    });

    group('properties', () {
      test('isError returns true only for invalid error results', () {
        const errorResult = ValidationResult.error('Error');
        const warningResult = ValidationResult.warning('Warning');
        const infoResult = ValidationResult.info('Info');
        const successResult = ValidationResult.success();

        expect(errorResult.isError, isTrue);
        expect(warningResult.isError, isFalse);
        expect(infoResult.isError, isFalse);
        expect(successResult.isError, isFalse);
      });

      test('isWarning returns true only for warning results', () {
        const errorResult = ValidationResult.error('Error');
        const warningResult = ValidationResult.warning('Warning');
        const infoResult = ValidationResult.info('Info');
        const successResult = ValidationResult.success();

        expect(errorResult.isWarning, isFalse);
        expect(warningResult.isWarning, isTrue);
        expect(infoResult.isWarning, isFalse);
        expect(successResult.isWarning, isFalse);
      });
    });

    group('equality and hashCode', () {
      test('equal results have same hashCode', () {
        const result1 = ValidationResult.error('Same error');
        const result2 = ValidationResult.error('Same error');

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('different results are not equal', () {
        const result1 = ValidationResult.error('Error 1');
        const result2 = ValidationResult.error('Error 2');
        const result3 = ValidationResult.warning('Error 1');

        expect(result1, isNot(equals(result2)));
        expect(result1, isNot(equals(result3)));
      });

      test('results with different contexts are not equal', () {
        const result1 = ValidationResult.error('Error', context: {'a': 1});
        const result2 = ValidationResult.error('Error', context: {'a': 2});

        expect(result1, isNot(equals(result2)));
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        const result = ValidationResult.error('Test error');

        expect(
          result.toString(),
          equals(
            'ValidationResult(isValid: false, severity: ValidationSeverity.error, message: Test error)',
          ),
        );
      });
    });
  });

  group('ValidationResultList extension', () {
    test('combine returns success for empty list', () {
      final result = <ValidationResult>[].combine();

      expect(result.isValid, isTrue);
      expect(result.message, isNull);
    });

    test('combine returns single error when errors present', () {
      final results = [
        const ValidationResult.success(),
        const ValidationResult.error('Error 1'),
        const ValidationResult.warning('Warning 1'),
        const ValidationResult.error('Error 2'),
      ];

      final combined = results.combine();

      expect(combined.isValid, isFalse);
      expect(combined.severity, equals(ValidationSeverity.error));
      expect(combined.message, equals('Error 1\nError 2'));
    });

    test('combine returns warnings when no errors', () {
      final results = [
        const ValidationResult.success(),
        const ValidationResult.warning('Warning 1'),
        const ValidationResult.info('Info 1'),
        const ValidationResult.warning('Warning 2'),
      ];

      final combined = results.combine();

      expect(combined.isValid, isTrue);
      expect(combined.severity, equals(ValidationSeverity.warning));
      expect(combined.message, equals('Warning 1\nWarning 2'));
    });

    test('combine returns info when no errors or warnings', () {
      final results = [
        const ValidationResult.success(),
        const ValidationResult.info('Info 1'),
        const ValidationResult.info('Info 2'),
      ];

      final combined = results.combine();

      expect(combined.isValid, isTrue);
      expect(combined.severity, equals(ValidationSeverity.info));
      expect(combined.message, equals('Info 1\nInfo 2'));
    });

    test('combine returns success when all are success', () {
      final results = [
        const ValidationResult.success(),
        const ValidationResult.success(),
        const ValidationResult.success(),
      ];

      final combined = results.combine();

      expect(combined.isValid, isTrue);
      expect(combined.message, isNull);
    });
  });
}
