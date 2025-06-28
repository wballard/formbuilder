import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  group('LayoutState Enhanced Serialization', () {
    test('should serialize with version and metadata', () {
      final layout = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 3),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'button',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
            properties: {'text': 'Click me'},
          ),
        ],
      );

      final json = layout.toJson();

      expect(json['version'], isA<String>());
      expect(json['timestamp'], isA<String>());
      expect(json['dimensions'], isA<Map<String, dynamic>>());
      expect(json['widgets'], isA<List>());
      expect((json['widgets'] as List).length, 1);
    });

    test('should deserialize with version compatibility', () {
      final json = {
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'dimensions': {'columns': 4, 'rows': 3},
        'widgets': [
          {
            'id': 'widget1',
            'widgetName': 'button',
            'column': 0,
            'row': 0,
            'width': 2,
            'height': 1,
            'properties': {'text': 'Click me'},
          },
        ],
      };

      final layout = LayoutState.fromJson(json);

      expect(layout.dimensions.columns, 4);
      expect(layout.dimensions.rows, 3);
      expect(layout.widgets.length, 1);
      expect(layout.widgets.first.id, 'widget1');
      expect(layout.widgets.first.properties['text'], 'Click me');
    });

    test('should handle missing version gracefully', () {
      final json = {
        // version missing - should assume legacy format
        'dimensions': {'columns': 4, 'rows': 3},
        'widgets': [
          {
            'id': 'widget1',
            'widgetName': 'button',
            'column': 0,
            'row': 0,
            'width': 2,
            'height': 1,
            'properties': {},
          },
        ],
      };

      final layout = LayoutState.fromJson(json);

      expect(layout.dimensions.columns, 4);
      expect(layout.widgets.length, 1);
    });

    test('should handle legacy format without properties', () {
      final json = {
        'dimensions': {'columns': 4, 'rows': 3},
        'widgets': [
          {
            'id': 'widget1',
            'widgetName': 'button',
            'column': 0,
            'row': 0,
            'width': 2,
            'height': 1,
            // properties missing in legacy format
          },
        ],
      };

      final layout = LayoutState.fromJson(json);

      expect(layout.widgets.first.properties, isEmpty);
    });

    test('should support unknown future version gracefully', () {
      final json = {
        'version': '2.0.0', // Future version
        'timestamp': DateTime.now().toIso8601String(),
        'dimensions': {'columns': 4, 'rows': 3},
        'widgets': [
          {
            'id': 'widget1',
            'widgetName': 'button',
            'column': 0,
            'row': 0,
            'width': 2,
            'height': 1,
            'properties': {'text': 'Click me'},
          },
        ],
        'unknownField': 'should be ignored',
      };

      // Should not throw even with unknown version/fields
      expect(() => LayoutState.fromJson(json), isNot(throwsA(anything)));

      final layout = LayoutState.fromJson(json);
      expect(layout.widgets.length, 1);
    });

    test('should include metadata in serialized format', () {
      final layout = LayoutState(
        dimensions: const GridDimensions(columns: 2, rows: 2),
        widgets: [],
      );

      final json = layout.toJson();

      // Should have metadata
      expect(json.containsKey('version'), true);
      expect(json.containsKey('timestamp'), true);
      expect(json.containsKey('metadata'), true);

      final metadata = json['metadata'] as Map<String, dynamic>;
      expect(metadata['widgetCount'], 0);
      expect(metadata['gridSize'], 4); // 2x2 grid
    });

    test('should round-trip with metadata preserved', () {
      final original = LayoutState(
        dimensions: const GridDimensions(columns: 3, rows: 2),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'button',
            column: 0,
            row: 0,
            width: 1,
            height: 1,
            properties: {'text': 'Button'},
          ),
        ],
      );

      final json = original.toJson();
      final deserialized = LayoutState.fromJson(json);

      expect(deserialized.dimensions, original.dimensions);
      expect(deserialized.widgets.length, original.widgets.length);
      expect(deserialized.widgets.first.properties['text'], 'Button');
    });
  });
}
