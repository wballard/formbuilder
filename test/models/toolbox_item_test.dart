import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  group('ToolboxItem', () {
    Widget testToolboxBuilder(BuildContext context) => Container();
    Widget testGridBuilder(BuildContext context, WidgetPlacement placement) => Container();

    test('creates valid instance with valid values', () {
      final item = ToolboxItem(
        name: 'text_input',
        displayName: 'Text Input',
        toolboxBuilder: testToolboxBuilder,
        gridBuilder: testGridBuilder,
        defaultWidth: 2,
        defaultHeight: 1,
      );
      
      expect(item.name, equals('text_input'));
      expect(item.displayName, equals('Text Input'));
      expect(item.toolboxBuilder, equals(testToolboxBuilder));
      expect(item.gridBuilder, equals(testGridBuilder));
      expect(item.defaultWidth, equals(2));
      expect(item.defaultHeight, equals(1));
    });

    test('creates instance with minimum dimensions', () {
      final item = ToolboxItem(
        name: 'icon',
        displayName: 'Icon',
        toolboxBuilder: testToolboxBuilder,
        gridBuilder: testGridBuilder,
        defaultWidth: 1,
        defaultHeight: 1,
      );
      
      expect(item.defaultWidth, equals(1));
      expect(item.defaultHeight, equals(1));
    });

    test('throws AssertionError when name is empty', () {
      expect(
        () => ToolboxItem(
          name: '',
          displayName: 'Text Input',
          toolboxBuilder: testToolboxBuilder,
          gridBuilder: testGridBuilder,
          defaultWidth: 2,
          defaultHeight: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when displayName is empty', () {
      expect(
        () => ToolboxItem(
          name: 'text_input',
          displayName: '',
          toolboxBuilder: testToolboxBuilder,
          gridBuilder: testGridBuilder,
          defaultWidth: 2,
          defaultHeight: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when defaultWidth is less than 1', () {
      expect(
        () => ToolboxItem(
          name: 'text_input',
          displayName: 'Text Input',
          toolboxBuilder: testToolboxBuilder,
          gridBuilder: testGridBuilder,
          defaultWidth: 0,
          defaultHeight: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when defaultHeight is less than 1', () {
      expect(
        () => ToolboxItem(
          name: 'text_input',
          displayName: 'Text Input',
          toolboxBuilder: testToolboxBuilder,
          gridBuilder: testGridBuilder,
          defaultWidth: 2,
          defaultHeight: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('equality', () {
      test('two instances with same values are equal', () {
        final item1 = ToolboxItem(
          name: 'text_input',
          displayName: 'Text Input',
          toolboxBuilder: testToolboxBuilder,
          gridBuilder: testGridBuilder,
          defaultWidth: 2,
          defaultHeight: 1,
        );
        final item2 = ToolboxItem(
          name: 'text_input',
          displayName: 'Text Input',
          toolboxBuilder: testToolboxBuilder,
          gridBuilder: testGridBuilder,
          defaultWidth: 2,
          defaultHeight: 1,
        );
        
        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('two instances with different names are not equal', () {
        final item1 = ToolboxItem(
          name: 'text_input',
          displayName: 'Text Input',
          toolboxBuilder: testToolboxBuilder,
          gridBuilder: testGridBuilder,
          defaultWidth: 2,
          defaultHeight: 1,
        );
        final item2 = ToolboxItem(
          name: 'button',
          displayName: 'Text Input',
          toolboxBuilder: testToolboxBuilder,
          gridBuilder: testGridBuilder,
          defaultWidth: 2,
          defaultHeight: 1,
        );
        
        expect(item1, isNot(equals(item2)));
      });
    });

    test('toString returns readable representation', () {
      final item = ToolboxItem(
        name: 'text_input',
        displayName: 'Text Input',
        toolboxBuilder: testToolboxBuilder,
        gridBuilder: testGridBuilder,
        defaultWidth: 2,
        defaultHeight: 1,
      );
      final stringRep = item.toString();
      
      expect(stringRep, contains('ToolboxItem'));
      expect(stringRep, contains('text_input'));
      expect(stringRep, contains('Text Input'));
    });
  });

  group('Toolbox', () {
    ToolboxItem createItem(String name, String displayName) {
      return ToolboxItem(
        name: name,
        displayName: displayName,
        toolboxBuilder: (context) => Container(),
        gridBuilder: (context, placement) => Container(),
        defaultWidth: 2,
        defaultHeight: 1,
      );
    }

    test('creates valid instance with empty items', () {
      final toolbox = Toolbox(items: []);
      
      expect(toolbox.items, isEmpty);
    });

    test('creates valid instance with unique items', () {
      final item1 = createItem('text_input', 'Text Input');
      final item2 = createItem('button', 'Button');
      
      final toolbox = Toolbox(items: [item1, item2]);
      
      expect(toolbox.items.length, equals(2));
      expect(toolbox.items[0], equals(item1));
      expect(toolbox.items[1], equals(item2));
    });

    test('throws ArgumentError when items have duplicate names', () {
      final item1 = createItem('text_input', 'Text Input');
      final item2 = createItem('text_input', 'Another Text Input');
      
      expect(
        () => Toolbox(items: [item1, item2]),
        throwsA(isA<ArgumentError>()),
      );
    });

    group('getItem', () {
      test('returns item when it exists', () {
        final item1 = createItem('text_input', 'Text Input');
        final item2 = createItem('button', 'Button');
        
        final toolbox = Toolbox(items: [item1, item2]);
        
        expect(toolbox.getItem('text_input'), equals(item1));
        expect(toolbox.getItem('button'), equals(item2));
      });

      test('returns null when item does not exist', () {
        final item = createItem('text_input', 'Text Input');
        final toolbox = Toolbox(items: [item]);
        
        expect(toolbox.getItem('nonexistent'), isNull);
      });
    });

    test('items list is immutable', () {
      final item = createItem('text_input', 'Text Input');
      final toolbox = Toolbox(items: [item]);
      
      expect(
        () => toolbox.items.add(createItem('button', 'Button')),
        throwsA(isA<UnsupportedError>()),
      );
    });

    group('predefined items', () {
      test('creates toolbox with predefined items', () {
        final toolbox = Toolbox.withDefaults();
        
        expect(toolbox.items.isNotEmpty, isTrue);
        
        // Check for some expected default items
        expect(toolbox.getItem('text_input'), isNotNull);
        expect(toolbox.getItem('button'), isNotNull);
        expect(toolbox.getItem('label'), isNotNull);
        expect(toolbox.getItem('checkbox'), isNotNull);
        
        // Verify all items have unique names
        final names = toolbox.items.map((item) => item.name).toSet();
        expect(names.length, equals(toolbox.items.length));
      });
    });
  });
}