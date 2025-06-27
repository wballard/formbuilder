import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('GridDimensions Serialization', () {
    test('should serialize to JSON correctly', () {
      const dimensions = GridDimensions(columns: 5, rows: 8);
      
      final json = dimensions.toJson();
      
      expect(json, {
        'columns': 5,
        'rows': 8,
      });
    });

    test('should deserialize from JSON correctly', () {
      const json = {
        'columns': 5,
        'rows': 8,
      };
      
      final dimensions = GridDimensions.fromJson(json);
      
      expect(dimensions.columns, 5);
      expect(dimensions.rows, 8);
    });

    test('should handle round-trip serialization', () {
      const original = GridDimensions(columns: 3, rows: 6);
      
      final json = original.toJson();
      final deserialized = GridDimensions.fromJson(json);
      
      expect(deserialized, equals(original));
    });

    test('should validate dimensions when deserializing', () {
      final invalidJson = {
        'columns': 0, // Invalid: below minimum
        'rows': 5,
      };
      
      expect(
        () => GridDimensions.fromJson(invalidJson),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle missing fields with validation', () {
      final incompleteJson = {
        'columns': 4,
        // rows missing
      };
      
      expect(
        () => GridDimensions.fromJson(incompleteJson),
        throwsA(isA<TypeError>()),
      );
    });

    test('should handle out-of-range values', () {
      final outOfRangeJson = {
        'columns': 15, // Above maximum
        'rows': 10,
      };
      
      expect(
        () => GridDimensions.fromJson(outOfRangeJson),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}