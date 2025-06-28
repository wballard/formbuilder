import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  group('WidgetPlacement Serialization', () {
    test('should serialize basic placement to JSON correctly', () {
      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'button',
        column: 2,
        row: 3,
        width: 2,
        height: 1,
      );

      final json = placement.toJson();

      expect(json, {
        'id': 'widget1',
        'widgetName': 'button',
        'column': 2,
        'row': 3,
        'width': 2,
        'height': 1,
        'properties': <String, dynamic>{},
      });
    });

    test('should serialize placement with properties to JSON correctly', () {
      final placement = WidgetPlacement(
        id: 'widget1',
        widgetName: 'button',
        column: 2,
        row: 3,
        width: 2,
        height: 1,
        properties: {
          'text': 'Click me',
          'color': '#FF0000',
          'enabled': true,
          'fontSize': 16,
        },
      );

      final json = placement.toJson();

      expect(json, {
        'id': 'widget1',
        'widgetName': 'button',
        'column': 2,
        'row': 3,
        'width': 2,
        'height': 1,
        'properties': {
          'text': 'Click me',
          'color': '#FF0000',
          'enabled': true,
          'fontSize': 16,
        },
      });
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'widget1',
        'widgetName': 'button',
        'column': 2,
        'row': 3,
        'width': 2,
        'height': 1,
        'properties': {'text': 'Click me', 'color': '#FF0000'},
      };

      final placement = WidgetPlacement.fromJson(json);

      expect(placement.id, 'widget1');
      expect(placement.widgetName, 'button');
      expect(placement.column, 2);
      expect(placement.row, 3);
      expect(placement.width, 2);
      expect(placement.height, 1);
      expect(placement.properties['text'], 'Click me');
      expect(placement.properties['color'], '#FF0000');
    });

    test('should handle round-trip serialization', () {
      final original = WidgetPlacement(
        id: 'widget1',
        widgetName: 'textfield',
        column: 0,
        row: 0,
        width: 3,
        height: 1,
        properties: {
          'placeholder': 'Enter text',
          'maxLength': 100,
          'required': true,
        },
      );

      final json = original.toJson();
      final deserialized = WidgetPlacement.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('should handle missing properties field', () {
      final json = {
        'id': 'widget1',
        'widgetName': 'button',
        'column': 2,
        'row': 3,
        'width': 2,
        'height': 1,
        // properties missing
      };

      final placement = WidgetPlacement.fromJson(json);

      expect(placement.properties, isEmpty);
    });

    test('should validate required fields when deserializing', () {
      final invalidJson = {
        'id': 'widget1',
        // widgetName missing
        'column': 2,
        'row': 3,
        'width': 2,
        'height': 1,
      };

      expect(
        () => WidgetPlacement.fromJson(invalidJson),
        throwsA(isA<TypeError>()),
      );
    });

    test('should validate placement constraints', () {
      final invalidJson = {
        'id': 'widget1',
        'widgetName': 'button',
        'column': -1, // Invalid: negative
        'row': 3,
        'width': 2,
        'height': 1,
      };

      expect(
        () => WidgetPlacement.fromJson(invalidJson),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should handle null properties gracefully', () {
      final json = {
        'id': 'widget1',
        'widgetName': 'button',
        'column': 2,
        'row': 3,
        'width': 2,
        'height': 1,
        'properties': null,
      };

      final placement = WidgetPlacement.fromJson(json);

      expect(placement.properties, isEmpty);
    });
  });
}
