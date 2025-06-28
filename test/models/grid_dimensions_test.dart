import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('GridDimensions', () {
    test('creates valid instance with valid values', () {
      const dimensions = GridDimensions(columns: 4, rows: 6);
      expect(dimensions.columns, equals(4));
      expect(dimensions.rows, equals(6));
    });

    test('creates instance with minimum values', () {
      const dimensions = GridDimensions(columns: 1, rows: 1);
      expect(dimensions.columns, equals(1));
      expect(dimensions.rows, equals(1));
    });

    test('creates instance with maximum values', () {
      const dimensions = GridDimensions(columns: 12, rows: 20);
      expect(dimensions.columns, equals(12));
      expect(dimensions.rows, equals(20));
    });

    test('throws AssertionError when columns is less than 1', () {
      expect(
        () => GridDimensions(columns: 0, rows: 5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when columns is greater than 12', () {
      expect(
        () => GridDimensions(columns: 13, rows: 5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when rows is less than 1', () {
      expect(
        () => GridDimensions(columns: 4, rows: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when rows is greater than 20', () {
      expect(
        () => GridDimensions(columns: 4, rows: 21),
        throwsA(isA<AssertionError>()),
      );
    });

    group('copyWith', () {
      test('copies with new columns value', () {
        const original = GridDimensions(columns: 4, rows: 6);
        final copied = original.copyWith(columns: 8);

        expect(copied.columns, equals(8));
        expect(copied.rows, equals(6));
        expect(identical(original, copied), isFalse);
      });

      test('copies with new rows value', () {
        const original = GridDimensions(columns: 4, rows: 6);
        final copied = original.copyWith(rows: 10);

        expect(copied.columns, equals(4));
        expect(copied.rows, equals(10));
        expect(identical(original, copied), isFalse);
      });

      test('copies with both values changed', () {
        const original = GridDimensions(columns: 4, rows: 6);
        final copied = original.copyWith(columns: 6, rows: 8);

        expect(copied.columns, equals(6));
        expect(copied.rows, equals(8));
        expect(identical(original, copied), isFalse);
      });

      test('returns same values when no parameters provided', () {
        const original = GridDimensions(columns: 4, rows: 6);
        final copied = original.copyWith();

        expect(copied.columns, equals(4));
        expect(copied.rows, equals(6));
      });

      test('validates new values in copyWith', () {
        const original = GridDimensions(columns: 4, rows: 6);

        expect(
          () => original.copyWith(columns: 0),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => original.copyWith(rows: 25),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('equality', () {
      test('two instances with same values are equal', () {
        const dimensions1 = GridDimensions(columns: 4, rows: 6);
        const dimensions2 = GridDimensions(columns: 4, rows: 6);

        expect(dimensions1, equals(dimensions2));
        expect(dimensions1.hashCode, equals(dimensions2.hashCode));
      });

      test('two instances with different columns are not equal', () {
        const dimensions1 = GridDimensions(columns: 4, rows: 6);
        const dimensions2 = GridDimensions(columns: 5, rows: 6);

        expect(dimensions1, isNot(equals(dimensions2)));
      });

      test('two instances with different rows are not equal', () {
        const dimensions1 = GridDimensions(columns: 4, rows: 6);
        const dimensions2 = GridDimensions(columns: 4, rows: 7);

        expect(dimensions1, isNot(equals(dimensions2)));
      });
    });

    test('toString returns readable representation', () {
      const dimensions = GridDimensions(columns: 4, rows: 6);
      final stringRep = dimensions.toString();

      expect(stringRep, contains('GridDimensions'));
      expect(stringRep, contains('4'));
      expect(stringRep, contains('6'));
    });
  });
}
