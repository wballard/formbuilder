import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('WidgetPlacement', () {
    test('creates valid instance with valid values', () {
      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TextInput',
        column: 2,
        row: 3,
        width: 2,
        height: 1,
      );
      
      expect(placement.id, equals('widget1'));
      expect(placement.widgetName, equals('TextInput'));
      expect(placement.column, equals(2));
      expect(placement.row, equals(3));
      expect(placement.width, equals(2));
      expect(placement.height, equals(1));
    });

    test('creates instance at origin', () {
      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'Button',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      
      expect(placement.column, equals(0));
      expect(placement.row, equals(0));
    });

    test('throws AssertionError when column is negative', () {
      expect(
        () => WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: -1,
          row: 0,
          width: 1,
          height: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when row is negative', () {
      expect(
        () => WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: -1,
          width: 1,
          height: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when width is less than 1', () {
      expect(
        () => WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 0,
          height: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when height is less than 1', () {
      expect(
        () => WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when id is empty', () {
      expect(
        () => WidgetPlacement(
          id: '',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when widgetName is empty', () {
      expect(
        () => WidgetPlacement(
          id: 'widget1',
          widgetName: '',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('bounds', () {
      test('calculates bounds correctly', () {
        final placement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 4,
          height: 2,
        );
        
        final bounds = placement.bounds;
        expect(bounds.left, equals(2));
        expect(bounds.top, equals(3));
        expect(bounds.width, equals(4));
        expect(bounds.height, equals(2));
        expect(bounds.right, equals(6));
        expect(bounds.bottom, equals(5));
      });

      test('calculates bounds for 1x1 widget', () {
        final placement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'Icon',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        
        final bounds = placement.bounds;
        expect(bounds.left, equals(0));
        expect(bounds.top, equals(0));
        expect(bounds.width, equals(1));
        expect(bounds.height, equals(1));
        expect(bounds.right, equals(1));
        expect(bounds.bottom, equals(1));
      });
    });

    group('fitsInGrid', () {
      test('fits when completely within grid', () {
        final placement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        );
        const dimensions = GridDimensions(columns: 4, rows: 4);
        
        expect(placement.fitsInGrid(dimensions), isTrue);
      });

      test('fits when filling entire grid', () {
        final placement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'Panel',
          column: 0,
          row: 0,
          width: 4,
          height: 4,
        );
        const dimensions = GridDimensions(columns: 4, rows: 4);
        
        expect(placement.fitsInGrid(dimensions), isTrue);
      });

      test('does not fit when extending beyond columns', () {
        final placement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 3,
          row: 0,
          width: 2,
          height: 1,
        );
        const dimensions = GridDimensions(columns: 4, rows: 4);
        
        expect(placement.fitsInGrid(dimensions), isFalse);
      });

      test('does not fit when extending beyond rows', () {
        final placement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 3,
          width: 1,
          height: 2,
        );
        const dimensions = GridDimensions(columns: 4, rows: 4);
        
        expect(placement.fitsInGrid(dimensions), isFalse);
      });

      test('does not fit when starting beyond grid', () {
        final placement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 4,
          row: 0,
          width: 1,
          height: 1,
        );
        const dimensions = GridDimensions(columns: 4, rows: 4);
        
        expect(placement.fitsInGrid(dimensions), isFalse);
      });
    });

    group('overlaps', () {
      test('overlaps when identical positions', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 2,
          width: 2,
          height: 2,
        );
        final placement2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 2,
          row: 2,
          width: 2,
          height: 2,
        );
        
        expect(placement1.overlaps(placement2), isTrue);
        expect(placement2.overlaps(placement1), isTrue);
      });

      test('overlaps when partially overlapping', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 1,
          row: 1,
          width: 3,
          height: 3,
        );
        final placement2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 3,
          row: 3,
          width: 2,
          height: 2,
        );
        
        expect(placement1.overlaps(placement2), isTrue);
        expect(placement2.overlaps(placement1), isTrue);
      });

      test('does not overlap when adjacent horizontally', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        );
        final placement2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 2,
          row: 0,
          width: 2,
          height: 2,
        );
        
        expect(placement1.overlaps(placement2), isFalse);
        expect(placement2.overlaps(placement1), isFalse);
      });

      test('does not overlap when adjacent vertically', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        );
        final placement2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 0,
          row: 2,
          width: 2,
          height: 2,
        );
        
        expect(placement1.overlaps(placement2), isFalse);
        expect(placement2.overlaps(placement1), isFalse);
      });

      test('does not overlap when completely separate', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        );
        final placement2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 5,
          row: 5,
          width: 2,
          height: 2,
        );
        
        expect(placement1.overlaps(placement2), isFalse);
        expect(placement2.overlaps(placement1), isFalse);
      });

      test('overlaps when one contains the other', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'Panel',
          column: 1,
          row: 1,
          width: 4,
          height: 4,
        );
        final placement2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 2,
          row: 2,
          width: 1,
          height: 1,
        );
        
        expect(placement1.overlaps(placement2), isTrue);
        expect(placement2.overlaps(placement1), isTrue);
      });
    });

    group('copyWith', () {
      test('copies with new id', () {
        final original = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        final copied = original.copyWith(id: 'widget2');
        
        expect(copied.id, equals('widget2'));
        expect(copied.widgetName, equals('TextInput'));
        expect(copied.column, equals(2));
        expect(copied.row, equals(3));
        expect(copied.width, equals(2));
        expect(copied.height, equals(1));
      });

      test('copies with new widgetName', () {
        final original = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        final copied = original.copyWith(widgetName: 'Button');
        
        expect(copied.id, equals('widget1'));
        expect(copied.widgetName, equals('Button'));
      });

      test('copies with new position', () {
        final original = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        final copied = original.copyWith(column: 5, row: 7);
        
        expect(copied.column, equals(5));
        expect(copied.row, equals(7));
      });

      test('copies with new size', () {
        final original = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        final copied = original.copyWith(width: 4, height: 3);
        
        expect(copied.width, equals(4));
        expect(copied.height, equals(3));
      });

      test('returns same values when no parameters provided', () {
        final original = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        final copied = original.copyWith();
        
        expect(copied.id, equals('widget1'));
        expect(copied.widgetName, equals('TextInput'));
        expect(copied.column, equals(2));
        expect(copied.row, equals(3));
        expect(copied.width, equals(2));
        expect(copied.height, equals(1));
      });

      test('validates new values in copyWith', () {
        final original = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        
        expect(
          () => original.copyWith(column: -1),
          throwsA(isA<AssertionError>()),
        );
        
        expect(
          () => original.copyWith(width: 0),
          throwsA(isA<AssertionError>()),
        );
        
        expect(
          () => original.copyWith(id: ''),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('equality', () {
      test('two instances with same values are equal', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        final placement2 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        
        expect(placement1, equals(placement2));
        expect(placement1.hashCode, equals(placement2.hashCode));
      });

      test('two instances with different ids are not equal', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        final placement2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        
        expect(placement1, isNot(equals(placement2)));
      });

      test('two instances with different positions are not equal', () {
        final placement1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        );
        final placement2 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 3,
          row: 3,
          width: 2,
          height: 1,
        );
        
        expect(placement1, isNot(equals(placement2)));
      });
    });

    test('toString returns readable representation', () {
      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TextInput',
        column: 2,
        row: 3,
        width: 2,
        height: 1,
      );
      final stringRep = placement.toString();
      
      expect(stringRep, contains('WidgetPlacement'));
      expect(stringRep, contains('widget1'));
      expect(stringRep, contains('TextInput'));
      expect(stringRep, contains('2'));
      expect(stringRep, contains('3'));
    });
  });
}