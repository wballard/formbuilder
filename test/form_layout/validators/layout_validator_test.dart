import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/validators/layout_validator.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/validation_result.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  group('LayoutValidator', () {
    late LayoutState emptyState;
    late LayoutState stateWithWidgets;

    setUp(() {
      emptyState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: const [],
      );

      stateWithWidgets = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: [
          WidgetPlacement(
            id: 'widget1',
            widgetName: 'TextInput',
            column: 0,
            row: 0,
            width: 2,
            height: 2,
          ),
          WidgetPlacement(
            id: 'widget2',
            widgetName: 'Button',
            column: 2,
            row: 2,
            width: 2,
            height: 2,
          ),
        ],
      );
    });

    group('validateAddWidget', () {
      test('succeeds for valid placement in empty grid', () {
        final placement = WidgetPlacement(
          id: 'new-widget',
          widgetName: 'TextArea',
          column: 1,
          row: 1,
          width: 2,
          height: 2,
        );

        final result = LayoutValidator.validateAddWidget(emptyState, placement);

        expect(result.isValid, isTrue);
        expect(result.message, isNull);
      });

      test('fails when widget extends beyond grid columns', () {
        final placement = WidgetPlacement(
          id: 'new-widget',
          widgetName: 'TextInput',
          column: 3,
          row: 0,
          width: 2,
          height: 1,
        );

        final result = LayoutValidator.validateAddWidget(emptyState, placement);

        expect(result.isValid, isFalse);
        expect(result.severity, equals(ValidationSeverity.error));
        expect(
          result.message,
          contains('Widget would extend beyond grid boundary'),
        );
        expect(
          result.message,
          contains('column 5 but grid only has 4 columns'),
        );
        expect(result.context?['widgetEndColumn'], equals(5));
      });

      test('fails when widget extends beyond grid rows', () {
        final placement = WidgetPlacement(
          id: 'new-widget',
          widgetName: 'Button',
          column: 0,
          row: 3,
          width: 1,
          height: 2,
        );

        final result = LayoutValidator.validateAddWidget(emptyState, placement);

        expect(result.isValid, isFalse);
        expect(result.severity, equals(ValidationSeverity.error));
        expect(
          result.message,
          contains('Widget would extend beyond grid boundary'),
        );
        expect(result.message, contains('row 5 but grid only has 4 rows'));
        expect(result.context?['widgetEndRow'], equals(5));
      });

      test('fails when widget overlaps existing widget', () {
        final placement = WidgetPlacement(
          id: 'new-widget',
          widgetName: 'Checkbox',
          column: 1,
          row: 1,
          width: 2,
          height: 2,
        );

        final result = LayoutValidator.validateAddWidget(
          stateWithWidgets,
          placement,
        );

        expect(result.isValid, isFalse);
        expect(result.severity, equals(ValidationSeverity.error));
        expect(result.message, contains('Space is occupied by another widget'));
        expect(result.message, contains('Overlaps with widgets: 1, 2'));
        expect(result.context?['overlappingWidgets'], hasLength(2));
      });

      test('fails when widget ID already exists', () {
        final placement = WidgetPlacement(
          id: 'widget1',
          widgetName: 'Label',
          column: 2,
          row: 0,
          width: 1,
          height: 1,
        );

        final result = LayoutValidator.validateAddWidget(
          stateWithWidgets,
          placement,
        );

        expect(result.isValid, isFalse);
        expect(result.severity, equals(ValidationSeverity.error));
        expect(
          result.message,
          contains('A widget with ID "widget1" already exists'),
        );
      });

      test('reports multiple overlapping widgets', () {
        final placement = WidgetPlacement(
          id: 'new-widget',
          widgetName: 'Container',
          column: 0,
          row: 0,
          width: 4,
          height: 4,
        );

        final result = LayoutValidator.validateAddWidget(
          stateWithWidgets,
          placement,
        );

        expect(result.isValid, isFalse);
        expect(result.message, contains('Overlaps with widgets: 1, 2'));
      });
    });

    group('validateMoveWidget', () {
      test('succeeds for valid move', () {
        final result = LayoutValidator.validateMoveWidget(
          stateWithWidgets,
          'widget1',
          const Point(2, 0),
        );

        expect(result.isValid, isTrue);
      });

      test('fails when widget not found', () {
        final result = LayoutValidator.validateMoveWidget(
          stateWithWidgets,
          'non-existent',
          const Point(0, 0),
        );

        expect(result.isValid, isFalse);
        expect(
          result.message,
          contains('Widget with ID "non-existent" not found'),
        );
      });

      test('fails when new position extends beyond grid', () {
        final result = LayoutValidator.validateMoveWidget(
          stateWithWidgets,
          'widget1',
          const Point(3, 3),
        );

        expect(result.isValid, isFalse);
        expect(
          result.message,
          contains('Widget would extend beyond grid boundary'),
        );
      });

      test('fails when new position overlaps another widget', () {
        final result = LayoutValidator.validateMoveWidget(
          stateWithWidgets,
          'widget1',
          const Point(2, 2),
        );

        expect(result.isValid, isFalse);
        expect(
          result.message,
          contains('New position would overlap with existing widgets'),
        );
      });

      test('allows moving to same position', () {
        final result = LayoutValidator.validateMoveWidget(
          stateWithWidgets,
          'widget1',
          const Point(0, 0),
        );

        expect(result.isValid, isTrue);
      });
    });

    group('validateResizeWidget', () {
      test('succeeds for valid resize', () {
        final result = LayoutValidator.validateResizeWidget(
          stateWithWidgets,
          'widget1',
          const Size(1, 1),
        );

        expect(result.isValid, isTrue);
      });

      test('fails when widget not found', () {
        final result = LayoutValidator.validateResizeWidget(
          stateWithWidgets,
          'non-existent',
          const Size(2, 2),
        );

        expect(result.isValid, isFalse);
        expect(
          result.message,
          contains('Widget with ID "non-existent" not found'),
        );
      });

      test('fails when size is less than 1x1', () {
        final result = LayoutValidator.validateResizeWidget(
          stateWithWidgets,
          'widget1',
          const Size(0, 1),
        );

        expect(result.isValid, isFalse);
        expect(result.message, contains('Widget size must be at least 1x1'));
      });

      test('fails when new size extends beyond grid', () {
        final result = LayoutValidator.validateResizeWidget(
          stateWithWidgets,
          'widget1',
          const Size(5, 2),
        );

        expect(result.isValid, isFalse);
        expect(
          result.message,
          contains('Widget would extend beyond grid boundary'),
        );
      });

      test('fails when new size overlaps another widget', () {
        final result = LayoutValidator.validateResizeWidget(
          stateWithWidgets,
          'widget1',
          const Size(3, 3),
        );

        expect(result.isValid, isFalse);
        expect(
          result.message,
          contains('New size would overlap with existing widgets'),
        );
      });
    });

    group('validateResizeGrid', () {
      test('succeeds when no widgets are affected', () {
        const newDimensions = GridDimensions(columns: 5, rows: 5);

        final result = LayoutValidator.validateResizeGrid(
          stateWithWidgets,
          newDimensions,
        );

        expect(result.isValid, isTrue);
        expect(result.message, isNull);
      });

      test('warns when widgets would be removed', () {
        const newDimensions = GridDimensions(columns: 3, rows: 3);

        final result = LayoutValidator.validateResizeGrid(
          stateWithWidgets,
          newDimensions,
        );

        expect(result.isValid, isTrue);
        expect(result.severity, equals(ValidationSeverity.warning));
        expect(
          result.message,
          contains('Resizing the grid will remove 1 widget'),
        );
        expect(result.message, contains('Widget 2 at (2, 2)'));
        expect(result.context?['affectedWidgets'], hasLength(1));
      });

      test('warns about multiple widgets being removed', () {
        const newDimensions = GridDimensions(columns: 2, rows: 2);

        final result = LayoutValidator.validateResizeGrid(
          stateWithWidgets,
          newDimensions,
        );

        expect(result.isValid, isTrue);
        expect(result.severity, equals(ValidationSeverity.warning));
        expect(
          result.message,
          contains('Resizing the grid will remove 1 widget'),
        );
        expect(result.context?['affectedWidgets'], hasLength(1));
      });
    });

    group('validateRemoveWidget', () {
      test('succeeds when widget exists', () {
        final result = LayoutValidator.validateRemoveWidget(
          stateWithWidgets,
          'widget1',
        );

        expect(result.isValid, isTrue);
      });

      test('fails when widget not found', () {
        final result = LayoutValidator.validateRemoveWidget(
          stateWithWidgets,
          'non-existent',
        );

        expect(result.isValid, isFalse);
        expect(
          result.message,
          contains('Widget with ID "non-existent" not found'),
        );
      });
    });

    group('validateBounds', () {
      test('succeeds for valid bounds', () {
        final placement = WidgetPlacement(
          id: 'test',
          widgetName: 'TestWidget',
          column: 0,
          row: 0,
          width: 2,
          height: 2,
        );
        const dimensions = GridDimensions(columns: 4, rows: 4);

        final result = LayoutValidator.validateBounds(placement, dimensions);

        expect(result.isValid, isTrue);
      });

      test('fails for negative position', () {
        // This test verifies the assertion in WidgetPlacement constructor
        expect(
          () => WidgetPlacement(
            id: 'test',
            widgetName: 'TestWidget',
            column: -1,
            row: 0,
            width: 1,
            height: 1,
          ),
          throwsAssertionError,
        );
      });

      test('fails when widget extends beyond grid', () {
        final placement = WidgetPlacement(
          id: 'test',
          widgetName: 'TestWidget',
          column: 3,
          row: 3,
          width: 2,
          height: 2,
        );
        const dimensions = GridDimensions(columns: 4, rows: 4);

        final result = LayoutValidator.validateBounds(placement, dimensions);

        expect(result.isValid, isFalse);
        expect(
          result.message,
          contains('Widget extends beyond grid boundaries'),
        );
      });
    });

    group('validateNoOverlap', () {
      test('succeeds when widgets do not overlap', () {
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
          row: 2,
          width: 2,
          height: 2,
        );

        final result = LayoutValidator.validateNoOverlap(widget1, widget2);

        expect(result.isValid, isTrue);
      });

      test('fails when widgets overlap', () {
        final widget1 = WidgetPlacement(
          id: 'widget1',
          widgetName: 'TextArea',
          column: 0,
          row: 0,
          width: 3,
          height: 3,
        );
        final widget2 = WidgetPlacement(
          id: 'widget2',
          widgetName: 'Checkbox',
          column: 2,
          row: 2,
          width: 2,
          height: 2,
        );

        final result = LayoutValidator.validateNoOverlap(widget1, widget2);

        expect(result.isValid, isFalse);
        expect(result.message, contains('Widgets overlap each other'));
      });
    });
  });
}
