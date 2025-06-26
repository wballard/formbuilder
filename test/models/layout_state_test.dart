import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'dart:math';

void main() {
  group('LayoutState', () {
    group('construction', () {
      test('creates valid instance with empty widgets', () {
        const dimensions = GridDimensions(columns: 4, rows: 4);
        final state = LayoutState(
          dimensions: dimensions,
          widgets: [],
        );
        
        expect(state.dimensions, equals(dimensions));
        expect(state.widgets, isEmpty);
      });

      test('creates valid instance with non-overlapping widgets', () {
        const dimensions = GridDimensions(columns: 4, rows: 4);
        final widget1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final widget2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 2,
          row: 0,
          width: 2,
          height: 1,
        );
        
        final state = LayoutState(
          dimensions: dimensions,
          widgets: [widget1, widget2],
        );
        
        expect(state.dimensions, equals(dimensions));
        expect(state.widgets.length, equals(2));
      });

      test('throws ArgumentError when widgets overlap', () {
        const dimensions = GridDimensions(columns: 4, rows: 4);
        final widget1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        );
        final widget2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 1,
          row: 1,
          width: 2,
          height: 2,
        );
        
        expect(
          () => LayoutState(
            dimensions: dimensions,
            widgets: [widget1, widget2],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError when widget is outside grid', () {
        const dimensions = GridDimensions(columns: 4, rows: 4);
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 3,
          row: 0,
          width: 2,
          height: 1,
        );
        
        expect(
          () => LayoutState(
            dimensions: dimensions,
            widgets: [widget],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('empty factory creates 4x4 grid with no widgets', () {
        final state = LayoutState.empty();
        
        expect(state.dimensions.columns, equals(4));
        expect(state.dimensions.rows, equals(4));
        expect(state.widgets, isEmpty);
      });
    });

    group('canAddWidget', () {
      test('returns true when widget fits and does not overlap', () {
        final state = LayoutState.empty();
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        
        expect(state.canAddWidget(widget), isTrue);
      });

      test('returns false when widget does not fit in grid', () {
        final state = LayoutState.empty();
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 3,
          row: 0,
          width: 2,
          height: 1,
        );
        
        expect(state.canAddWidget(widget), isFalse);
      });

      test('returns false when widget overlaps existing widget', () {
        final existingWidget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 1,
          row: 1,
          width: 2,
          height: 2,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [existingWidget],
        );
        
        final newWidget = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 2,
          row: 2,
          width: 2,
          height: 2,
        );
        
        expect(state.canAddWidget(newWidget), isFalse);
      });

      test('returns false when widget with same id already exists', () {
        final existingWidget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [existingWidget],
        );
        
        final newWidget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'Button',
          column: 2,
          row: 2,
          width: 1,
          height: 1,
        );
        
        expect(state.canAddWidget(newWidget), isFalse);
      });
    });

    group('addWidget', () {
      test('adds widget when valid', () {
        final state = LayoutState.empty();
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        
        final newState = state.addWidget(widget);
        
        expect(newState.widgets.length, equals(1));
        expect(newState.widgets.first, equals(widget));
        expect(identical(state, newState), isFalse);
      });

      test('throws ArgumentError when widget cannot be added', () {
        final state = LayoutState.empty();
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 3,
          row: 0,
          width: 2,
          height: 1,
        );
        
        expect(
          () => state.addWidget(widget),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('removeWidget', () {
      test('removes widget when it exists', () {
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [widget],
        );
        
        final newState = state.removeWidget('widget1');
        
        expect(newState.widgets, isEmpty);
        expect(identical(state, newState), isFalse);
      });

      test('returns same state when widget does not exist', () {
        final state = LayoutState.empty();
        final newState = state.removeWidget('nonexistent');
        
        expect(identical(state, newState), isTrue);
      });
    });

    group('updateWidget', () {
      test('updates widget when new placement is valid', () {
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [widget],
        );
        
        final newPlacement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 2,
          row: 2,
          width: 2,
          height: 1,
        );
        
        final newState = state.updateWidget('widget1', newPlacement);
        
        expect(newState.widgets.length, equals(1));
        expect(newState.widgets.first, equals(newPlacement));
      });

      test('throws ArgumentError when widget does not exist', () {
        final state = LayoutState.empty();
        final newPlacement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        
        expect(
          () => state.updateWidget('widget1', newPlacement),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError when new placement is invalid', () {
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [widget],
        );
        
        final newPlacement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 3,
          row: 0,
          width: 2,
          height: 1,
        );
        
        expect(
          () => state.updateWidget('widget1', newPlacement),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('allows updating widget to overlap its current position', () {
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [widget],
        );
        
        final newPlacement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 1,
          row: 0,
          width: 2,
          height: 2,
        );
        
        final newState = state.updateWidget('widget1', newPlacement);
        expect(newState.widgets.first, equals(newPlacement));
      });
    });

    group('getWidget', () {
      test('returns widget when it exists', () {
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [widget],
        );
        
        expect(state.getWidget('widget1'), equals(widget));
      });

      test('returns null when widget does not exist', () {
        final state = LayoutState.empty();
        expect(state.getWidget('nonexistent'), isNull);
      });
    });

    group('resizeGrid', () {
      test('resizes grid when all widgets fit', () {
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [widget],
        );
        
        const newDimensions = GridDimensions(columns: 6, rows: 6);
        final newState = state.resizeGrid(newDimensions);
        
        expect(newState.dimensions, equals(newDimensions));
        expect(newState.widgets.length, equals(1));
      });

      test('removes widgets that do not fit in smaller grid', () {
        final widget1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final widget2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 2,
          row: 2,
          width: 2,
          height: 2,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [widget1, widget2],
        );
        
        const newDimensions = GridDimensions(columns: 3, rows: 3);
        final newState = state.resizeGrid(newDimensions);
        
        expect(newState.dimensions, equals(newDimensions));
        expect(newState.widgets.length, equals(1));
        expect(newState.widgets.first, equals(widget1));
      });
    });

    group('getWidgetsInArea', () {
      test('returns widgets that intersect with area', () {
        final widget1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        );
        final widget2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 2,
          row: 0,
          width: 2,
          height: 2,
        );
        final widget3 = WidgetPlacement(
          id: 'widget3',
          widgetName: 'Label',
          column: 4,
          row: 0,
          width: 1,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 5, rows: 4),
          widgets: [widget1, widget2, widget3],
        );
        
        final area = Rectangle(0, 0, 3, 3);
        final widgetsInArea = state.getWidgetsInArea(area);
        
        expect(widgetsInArea.length, equals(2));
        expect(widgetsInArea, contains(widget1));
        expect(widgetsInArea, contains(widget2));
        expect(widgetsInArea, isNot(contains(widget3)));
      });

      test('returns empty list when no widgets in area', () {
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 4),
          widgets: [widget],
        );
        
        final area = Rectangle(2, 2, 2, 2);
        final widgetsInArea = state.getWidgetsInArea(area);
        
        expect(widgetsInArea, isEmpty);
      });
    });

    group('serialization', () {
      test('toJson creates correct JSON representation', () {
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final state = LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 6),
          widgets: [widget],
        );
        
        final json = state.toJson();
        
        expect(json['dimensions'], isNotNull);
        expect(json['dimensions']['columns'], equals(4));
        expect(json['dimensions']['rows'], equals(6));
        expect(json['widgets'], isList);
        expect((json['widgets'] as List).length, equals(1));
      });

      test('fromJson creates correct instance', () {
        final json = {
          'dimensions': {
            'columns': 4,
            'rows': 6,
          },
          'widgets': [
            {
              'id': 'widget1',
              'widgetName': 'TextInput',
              'column': 0,
              'row': 0,
              'width': 2,
              'height': 1,
            },
          ],
        };
        
        final state = LayoutState.fromJson(json);
        
        expect(state.dimensions.columns, equals(4));
        expect(state.dimensions.rows, equals(6));
        expect(state.widgets.length, equals(1));
        expect(state.widgets.first.id, equals('widget1'));
      });

      test('toJson and fromJson are symmetric', () {
        final widget1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        final widget2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Button',
          column: 2,
          row: 2,
          width: 1,
          height: 1,
        );
        final original = LayoutState(
          dimensions: const GridDimensions(columns: 6, rows: 8),
          widgets: [widget1, widget2],
        );
        
        final json = original.toJson();
        final restored = LayoutState.fromJson(json);
        
        expect(restored.dimensions, equals(original.dimensions));
        expect(restored.widgets.length, equals(original.widgets.length));
        for (int i = 0; i < restored.widgets.length; i++) {
          expect(restored.widgets[i], equals(original.widgets[i]));
        }
      });
    });

    group('copyWith', () {
      test('copies with new dimensions', () {
        final state = LayoutState.empty();
        const newDimensions = GridDimensions(columns: 6, rows: 8);
        
        final newState = state.copyWith(dimensions: newDimensions);
        
        expect(newState.dimensions, equals(newDimensions));
        expect(newState.widgets, equals(state.widgets));
      });

      test('copies with new widgets', () {
        final state = LayoutState.empty();
        final widget = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextInput',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
        );
        
        final newState = state.copyWith(widgets: [widget]);
        
        expect(newState.dimensions, equals(state.dimensions));
        expect(newState.widgets.length, equals(1));
        expect(newState.widgets.first, equals(widget));
      });

      test('returns same instance when no changes', () {
        final state = LayoutState.empty();
        final newState = state.copyWith();
        
        expect(identical(state, newState), isTrue);
      });
    });
  });
}