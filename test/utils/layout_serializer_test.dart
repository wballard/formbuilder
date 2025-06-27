import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/utils/layout_serializer.dart';

void main() {
  group('LayoutSerializer', () {
    late LayoutState testLayout;

    setUp(() {
      testLayout = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 3),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'button',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
            properties: {'text': 'Click me', 'color': '#FF0000'},
          ),
          WidgetPlacement(
            id: 'widget2',
            widgetName: 'textfield',
            column: 2,
            row: 1,
            width: 2,
            height: 1,
            properties: {'placeholder': 'Enter text'},
          ),
        ],
      );
    });

    test('should serialize layout to JSON string', () {
      final jsonString = LayoutSerializer.toJsonString(testLayout);
      
      expect(jsonString, isA<String>());
      expect(jsonString.isNotEmpty, true);
      expect(jsonString.contains('"version"'), true);
      expect(jsonString.contains('"widgets"'), true);
      expect(jsonString.contains('"dimensions"'), true);
    });

    test('should deserialize layout from JSON string', () {
      final jsonString = LayoutSerializer.toJsonString(testLayout);
      final deserializedLayout = LayoutSerializer.fromJsonString(jsonString);
      
      expect(deserializedLayout, isNotNull);
      expect(deserializedLayout!.dimensions.columns, testLayout.dimensions.columns);
      expect(deserializedLayout.dimensions.rows, testLayout.dimensions.rows);
      expect(deserializedLayout.widgets.length, testLayout.widgets.length);
      expect(deserializedLayout.widgets.first.id, 'widget1');
      expect(deserializedLayout.widgets.first.properties['text'], 'Click me');
    });

    test('should handle round-trip serialization correctly', () {
      final jsonString = LayoutSerializer.toJsonString(testLayout);
      final deserializedLayout = LayoutSerializer.fromJsonString(jsonString);
      
      expect(deserializedLayout, isNotNull);
      expect(deserializedLayout!.dimensions, equals(testLayout.dimensions));
      expect(deserializedLayout.widgets.length, equals(testLayout.widgets.length));
      
      for (int i = 0; i < testLayout.widgets.length; i++) {
        expect(deserializedLayout.widgets[i], equals(testLayout.widgets[i]));
      }
    });

    test('should return null for invalid JSON string', () {
      const invalidJson = '{"invalid": json}';
      final result = LayoutSerializer.fromJsonString(invalidJson);
      
      expect(result, isNull);
    });

    test('should return null for empty JSON string', () {
      const emptyJson = '';
      final result = LayoutSerializer.fromJsonString(emptyJson);
      
      expect(result, isNull);
    });

    test('should return null for malformed JSON', () {
      const malformedJson = '{"widgets": [}';
      final result = LayoutSerializer.fromJsonString(malformedJson);
      
      expect(result, isNull);
    });

    test('should handle missing required fields gracefully', () {
      const incompleteJson = '{"version": "1.0.0"}'; // Missing dimensions and widgets
      final result = LayoutSerializer.fromJsonString(incompleteJson);
      
      expect(result, isNull);
    });

    test('should validate data integrity before import', () {
      // Create layout with overlapping widgets (invalid)
      final invalidLayout = {
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
            'properties': {},
          },
          {
            'id': 'widget2', 
            'widgetName': 'button',
            'column': 1, // Overlaps with widget1
            'row': 0,
            'width': 2,
            'height': 1,
            'properties': {},
          },
        ],
      };
      
      final jsonString = '$invalidLayout';
      final result = LayoutSerializer.fromJsonString(jsonString);
      
      expect(result, isNull); // Should return null due to validation failure
    });

    test('should handle large layouts efficiently', () {
      // Create a large layout with many widgets
      final widgets = List.generate(100, (index) {
        final row = index ~/ 10;
        final col = index % 10;
        return WidgetPlacement(
          id: 'widget_$index',
          widgetName: 'button',
          column: col,
          row: row,
          width: 1,
          height: 1,
          properties: {'index': index},
        );
      });
      
      final largeLayout = LayoutState(
        dimensions: const GridDimensions(columns: 10, rows: 10),
        widgets: widgets,
      );
      
      final startTime = DateTime.now();
      final jsonString = LayoutSerializer.toJsonString(largeLayout);
      final deserializedLayout = LayoutSerializer.fromJsonString(jsonString);
      final endTime = DateTime.now();
      
      final duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, lessThan(1000)); // Should complete in under 1 second
      expect(deserializedLayout, isNotNull);
      expect(deserializedLayout!.widgets.length, 100);
    });

    test('should preserve custom properties during serialization', () {
      final complexProperties = {
        'text': 'Button Text',
        'color': '#FF0000', 
        'enabled': true,
        'fontSize': 16,
        'padding': {'top': 8, 'left': 12, 'bottom': 8, 'right': 12},
        'actions': ['click', 'hover'],
      };
      
      final widget = WidgetPlacement(
        id: 'complex_widget',
        widgetName: 'button',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
        properties: complexProperties,
      );
      
      final layout = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 3),
        widgets: [widget],
      );
      
      final jsonString = LayoutSerializer.toJsonString(layout);
      final deserializedLayout = LayoutSerializer.fromJsonString(jsonString);
      
      expect(deserializedLayout, isNotNull);
      final deserializedWidget = deserializedLayout!.widgets.first;
      expect(deserializedWidget.properties['text'], 'Button Text');
      expect(deserializedWidget.properties['enabled'], true);
      expect(deserializedWidget.properties['fontSize'], 16);
      expect(deserializedWidget.properties['padding']['top'], 8);
      expect(deserializedWidget.properties['actions'], ['click', 'hover']);
    });

    test('should handle legacy format gracefully', () {
      const legacyJson = '''
      {
        "dimensions": {
          "columns": 4,
          "rows": 3
        },
        "widgets": [
          {
            "id": "widget1",
            "widgetName": "button",
            "column": 0,
            "row": 0,
            "width": 2,
            "height": 1
          }
        ]
      }
      ''';
      
      final layout = LayoutSerializer.fromJsonString(legacyJson);
      
      expect(layout, isNotNull);
      expect(layout!.widgets.length, 1);
      expect(layout.widgets.first.properties, isEmpty); // Should have empty properties
    });

    test('should export layout with export metadata', () {
      final exportedData = LayoutSerializer.exportLayout(testLayout);
      
      expect(exportedData, isA<Map<String, dynamic>>());
      expect(exportedData.containsKey('exportMetadata'), true);
      
      final exportMetadata = exportedData['exportMetadata'] as Map<String, dynamic>;
      expect(exportMetadata['exportedAt'], isA<String>());
      expect(exportMetadata['exportVersion'], '1.0.0');
      expect(exportMetadata['description'], contains('Form Builder'));
      
      // Should contain all the original layout data
      expect(exportedData.containsKey('version'), true);
      expect(exportedData.containsKey('dimensions'), true);
      expect(exportedData.containsKey('widgets'), true);
    });

    test('should import layout and remove export metadata', () {
      final exportedData = LayoutSerializer.exportLayout(testLayout);
      final importedLayout = LayoutSerializer.importLayout(exportedData);
      
      expect(importedLayout, isNotNull);
      expect(importedLayout!.dimensions, equals(testLayout.dimensions));
      expect(importedLayout.widgets.length, equals(testLayout.widgets.length));
      
      // Verify the imported layout matches the original
      for (int i = 0; i < testLayout.widgets.length; i++) {
        expect(importedLayout.widgets[i], equals(testLayout.widgets[i]));
      }
    });

    test('should handle round-trip export/import correctly', () {
      final exportedData = LayoutSerializer.exportLayout(testLayout);
      final importedLayout = LayoutSerializer.importLayout(exportedData);
      
      expect(importedLayout, isNotNull);
      expect(importedLayout!.dimensions, equals(testLayout.dimensions));
      expect(importedLayout.widgets, equals(testLayout.widgets));
    });

    test('should return null for invalid import data', () {
      final invalidData = {
        'exportMetadata': {'exportedAt': DateTime.now().toIso8601String()},
        'invalid': 'data'
      };
      
      final result = LayoutSerializer.importLayout(invalidData);
      expect(result, isNull);
    });

    test('should get version from JSON string', () {
      final jsonString = LayoutSerializer.toJsonString(testLayout);
      final version = LayoutSerializer.getVersion(jsonString);
      
      expect(version, isNotNull);
      expect(version, '1.0.0');
    });

    test('should return null version for invalid JSON', () {
      const invalidJson = '{invalid json}';
      final version = LayoutSerializer.getVersion(invalidJson);
      
      expect(version, isNull);
    });

    test('should validate layout correctly', () {
      final jsonString = LayoutSerializer.toJsonString(testLayout);
      final isValid = LayoutSerializer.isValidLayout(jsonString);
      
      expect(isValid, true);
    });

    test('should reject invalid layout', () {
      const invalidJson = '{"invalid": "layout"}';
      final isValid = LayoutSerializer.isValidLayout(invalidJson);
      
      expect(isValid, false);
    });

    test('should get layout statistics', () {
      final jsonString = LayoutSerializer.toJsonString(testLayout);
      final stats = LayoutSerializer.getLayoutStats(jsonString);
      
      expect(stats, isNotNull);
      expect(stats!['version'], '1.0.0');
      expect(stats['widgetCount'], testLayout.widgets.length);
      expect(stats['gridSize'], 12); // 4 columns * 3 rows
      expect(stats.containsKey('timestamp'), true);
      expect(stats.containsKey('totalArea'), true);
    });

    test('should return null stats for invalid JSON', () {
      const invalidJson = '{invalid}';
      final stats = LayoutSerializer.getLayoutStats(invalidJson);
      
      expect(stats, isNull);
    });

    test('should migrate layout successfully', () {
      final jsonString = LayoutSerializer.toJsonString(testLayout);
      final migratedLayout = LayoutSerializer.migrateLayout(jsonString, '1.0.0');
      
      expect(migratedLayout, isNotNull);
      expect(migratedLayout!.dimensions, equals(testLayout.dimensions));
      expect(migratedLayout.widgets, equals(testLayout.widgets));
    });

    test('should return null for failed migration', () {
      const invalidJson = '{invalid}';
      final migratedLayout = LayoutSerializer.migrateLayout(invalidJson, '1.0.0');
      
      expect(migratedLayout, isNull);
    });
  });
}