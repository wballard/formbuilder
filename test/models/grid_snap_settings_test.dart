import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/grid_snap_settings.dart';

void main() {
  group('GridSnapSettings', () {
    test('should create default settings with snap to grid enabled', () {
      const settings = GridSnapSettings();

      expect(settings.snapToGrid, isTrue);
      expect(settings.snapToWidgets, isFalse);
      expect(settings.freePositioning, isFalse);
      expect(settings.magneticEdges, isFalse);
      expect(settings.subdivisions, equals(GridSubdivision.none));
      expect(settings.snapThreshold, equals(8.0));
    });

    test('should create custom settings', () {
      const settings = GridSnapSettings(
        snapToGrid: false,
        snapToWidgets: true,
        freePositioning: true,
        magneticEdges: true,
        subdivisions: GridSubdivision.half,
        snapThreshold: 16.0,
      );

      expect(settings.snapToGrid, isFalse);
      expect(settings.snapToWidgets, isTrue);
      expect(settings.freePositioning, isTrue);
      expect(settings.magneticEdges, isTrue);
      expect(settings.subdivisions, equals(GridSubdivision.half));
      expect(settings.snapThreshold, equals(16.0));
    });

    test('should support equality comparison', () {
      const settings1 = GridSnapSettings();
      const settings2 = GridSnapSettings();
      const settings3 = GridSnapSettings(snapToGrid: false);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('should support copyWith', () {
      const original = GridSnapSettings();
      final modified = original.copyWith(snapToWidgets: true);

      expect(modified.snapToGrid, isTrue);
      expect(modified.snapToWidgets, isTrue);
      expect(modified.freePositioning, isFalse);
    });

    test('should serialize to and from JSON', () {
      const settings = GridSnapSettings(
        snapToGrid: false,
        snapToWidgets: true,
        subdivisions: GridSubdivision.quarter,
      );

      final json = settings.toJson();
      final deserialized = GridSnapSettings.fromJson(json);

      expect(deserialized, equals(settings));
    });
  });

  group('GridSubdivision', () {
    test('should have correct subdivision values', () {
      expect(GridSubdivision.none.divisor, equals(1));
      expect(GridSubdivision.half.divisor, equals(2));
      expect(GridSubdivision.quarter.divisor, equals(4));
    });

    test('should serialize and deserialize correctly', () {
      expect(GridSubdivision.fromString('none'), equals(GridSubdivision.none));
      expect(GridSubdivision.fromString('half'), equals(GridSubdivision.half));
      expect(
        GridSubdivision.fromString('quarter'),
        equals(GridSubdivision.quarter),
      );
      expect(
        GridSubdivision.fromString('invalid'),
        equals(GridSubdivision.none),
      );
    });
  });
}
