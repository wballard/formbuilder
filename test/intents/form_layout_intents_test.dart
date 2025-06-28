import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('FormLayout Intents', () {
    late ToolboxItem testItem;

    setUp(() {
      testItem = ToolboxItem(
        name: 'test_widget',
        displayName: 'Test Widget',
        toolboxBuilder: (context) => Container(),
        gridBuilder: (context, placement) => Container(),
        defaultWidth: 2,
        defaultHeight: 1,
      );
    });

    group('AddWidgetIntent', () {
      test('creates intent with required properties', () {
        const position = Point(1, 2);
        final intent = AddWidgetIntent(item: testItem, position: position);

        expect(intent.item, equals(testItem));
        expect(intent.position, equals(position));
      });
    });

    group('RemoveWidgetIntent', () {
      test('creates intent with widget ID', () {
        const widgetId = 'widget123';
        const intent = RemoveWidgetIntent(widgetId: widgetId);

        expect(intent.widgetId, equals(widgetId));
      });
    });

    group('MoveWidgetIntent', () {
      test('creates intent with widget ID and new position', () {
        const widgetId = 'widget123';
        const newPosition = Point(3, 4);
        const intent = MoveWidgetIntent(
          widgetId: widgetId,
          newPosition: newPosition,
        );

        expect(intent.widgetId, equals(widgetId));
        expect(intent.newPosition, equals(newPosition));
      });
    });

    group('ResizeWidgetIntent', () {
      test('creates intent with widget ID and new size', () {
        const widgetId = 'widget123';
        const newSize = Size(3, 2);
        const intent = ResizeWidgetIntent(widgetId: widgetId, newSize: newSize);

        expect(intent.widgetId, equals(widgetId));
        expect(intent.newSize, equals(newSize));
      });
    });

    group('SelectWidgetIntent', () {
      test('creates intent with widget ID', () {
        const widgetId = 'widget123';
        const intent = SelectWidgetIntent(widgetId: widgetId);

        expect(intent.widgetId, equals(widgetId));
      });

      test('creates intent with null to deselect', () {
        const intent = SelectWidgetIntent();

        expect(intent.widgetId, isNull);
      });
    });

    group('ResizeGridIntent', () {
      test('creates intent with new dimensions', () {
        const newDimensions = GridDimensions(columns: 6, rows: 8);
        const intent = ResizeGridIntent(newDimensions: newDimensions);

        expect(intent.newDimensions, equals(newDimensions));
      });
    });

    group('UndoIntent', () {
      test('creates intent without parameters', () {
        const intent = UndoIntent();

        expect(intent, isA<UndoIntent>());
      });
    });

    group('RedoIntent', () {
      test('creates intent without parameters', () {
        const intent = RedoIntent();

        expect(intent, isA<RedoIntent>());
      });
    });

    group('TogglePreviewModeIntent', () {
      test('creates intent without parameters', () {
        const intent = TogglePreviewModeIntent();

        expect(intent, isA<TogglePreviewModeIntent>());
      });
    });

    group('DuplicateWidgetIntent', () {
      test('creates intent with widget ID', () {
        const widgetId = 'widget123';
        const intent = DuplicateWidgetIntent(widgetId: widgetId);

        expect(intent.widgetId, equals(widgetId));
      });
    });

    group('StartDraggingIntent', () {
      test('creates intent with widget ID', () {
        const widgetId = 'widget123';
        const intent = StartDraggingIntent(widgetId: widgetId);

        expect(intent.widgetId, equals(widgetId));
      });
    });

    group('StopDraggingIntent', () {
      test('creates intent with widget ID', () {
        const widgetId = 'widget123';
        const intent = StopDraggingIntent(widgetId: widgetId);

        expect(intent.widgetId, equals(widgetId));
      });
    });

    group('StartResizingIntent', () {
      test('creates intent with widget ID', () {
        const widgetId = 'widget123';
        const intent = StartResizingIntent(widgetId: widgetId);

        expect(intent.widgetId, equals(widgetId));
      });
    });

    group('StopResizingIntent', () {
      test('creates intent with widget ID', () {
        const widgetId = 'widget123';
        const intent = StopResizingIntent(widgetId: widgetId);

        expect(intent.widgetId, equals(widgetId));
      });
    });

    group('ClearHistoryIntent', () {
      test('creates intent without parameters', () {
        const intent = ClearHistoryIntent();

        expect(intent, isA<ClearHistoryIntent>());
      });
    });
  });
}
