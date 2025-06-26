import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/utils/commands.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('FormLayoutCommand', () {
    late LayoutState initialState;
    late WidgetPlacement testWidget;

    setUp(() {
      initialState = LayoutState.empty();
      testWidget = WidgetPlacement(
        id: 'widget1',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
    });

    group('AddWidgetCommand', () {
      test('executes add widget operation', () {
        final command = AddWidgetCommand(testWidget);
        final result = command.execute(initialState);
        
        expect(result.widgets, contains(testWidget));
        expect(result.widgets.length, equals(1));
      });

      test('undoes add widget operation', () {
        final command = AddWidgetCommand(testWidget);
        final afterAdd = command.execute(initialState);
        final afterUndo = command.undo(afterAdd);
        
        expect(afterUndo.widgets, isEmpty);
        expect(afterUndo, equals(initialState));
      });

      test('stores widget placement correctly', () {
        final command = AddWidgetCommand(testWidget);
        expect(command.placement, equals(testWidget));
      });
    });

    group('RemoveWidgetCommand', () {
      test('executes remove widget operation', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final command = RemoveWidgetCommand('widget1', testWidget);
        final result = command.execute(stateWithWidget);
        
        expect(result.widgets, isEmpty);
        expect(result.getWidget('widget1'), isNull);
      });

      test('undoes remove widget operation', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final command = RemoveWidgetCommand('widget1', testWidget);
        final afterRemove = command.execute(stateWithWidget);
        final afterUndo = command.undo(afterRemove);
        
        expect(afterUndo.widgets, contains(testWidget));
        expect(afterUndo.getWidget('widget1'), equals(testWidget));
      });

      test('stores widget data correctly', () {
        final command = RemoveWidgetCommand('widget1', testWidget);
        expect(command.widgetId, equals('widget1'));
        expect(command.removedWidget, equals(testWidget));
      });
    });

    group('MoveWidgetCommand', () {
      test('executes move widget operation', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final newPlacement = testWidget.copyWith(column: 2, row: 2);
        final command = MoveWidgetCommand('widget1', testWidget, newPlacement);
        final result = command.execute(stateWithWidget);
        
        final movedWidget = result.getWidget('widget1');
        expect(movedWidget?.column, equals(2));
        expect(movedWidget?.row, equals(2));
      });

      test('undoes move widget operation', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final newPlacement = testWidget.copyWith(column: 2, row: 2);
        final command = MoveWidgetCommand('widget1', testWidget, newPlacement);
        final afterMove = command.execute(stateWithWidget);
        final afterUndo = command.undo(afterMove);
        
        final restoredWidget = afterUndo.getWidget('widget1');
        expect(restoredWidget?.column, equals(0));
        expect(restoredWidget?.row, equals(0));
      });

      test('stores movement data correctly', () {
        final newPlacement = testWidget.copyWith(column: 2, row: 2);
        final command = MoveWidgetCommand('widget1', testWidget, newPlacement);
        expect(command.widgetId, equals('widget1'));
        expect(command.oldPlacement, equals(testWidget));
        expect(command.newPlacement, equals(newPlacement));
      });
    });

    group('ResizeWidgetCommand', () {
      test('executes resize widget operation', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final newPlacement = testWidget.copyWith(width: 2, height: 2);
        final command = ResizeWidgetCommand('widget1', testWidget, newPlacement);
        final result = command.execute(stateWithWidget);
        
        final resizedWidget = result.getWidget('widget1');
        expect(resizedWidget?.width, equals(2));
        expect(resizedWidget?.height, equals(2));
      });

      test('undoes resize widget operation', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final newPlacement = testWidget.copyWith(width: 2, height: 2);
        final command = ResizeWidgetCommand('widget1', testWidget, newPlacement);
        final afterResize = command.execute(stateWithWidget);
        final afterUndo = command.undo(afterResize);
        
        final restoredWidget = afterUndo.getWidget('widget1');
        expect(restoredWidget?.width, equals(1));
        expect(restoredWidget?.height, equals(1));
      });

      test('stores resize data correctly', () {
        final newPlacement = testWidget.copyWith(width: 2, height: 2);
        final command = ResizeWidgetCommand('widget1', testWidget, newPlacement);
        expect(command.widgetId, equals('widget1'));
        expect(command.oldPlacement, equals(testWidget));
        expect(command.newPlacement, equals(newPlacement));
      });
    });

    group('ResizeGridCommand', () {
      test('executes resize grid operation', () {
        const newDimensions = GridDimensions(columns: 6, rows: 6);
        final command = ResizeGridCommand(initialState.dimensions, newDimensions);
        final result = command.execute(initialState);
        
        expect(result.dimensions, equals(newDimensions));
      });

      test('undoes resize grid operation', () {
        const newDimensions = GridDimensions(columns: 6, rows: 6);
        final command = ResizeGridCommand(initialState.dimensions, newDimensions);
        final afterResize = command.execute(initialState);
        final afterUndo = command.undo(afterResize);
        
        expect(afterUndo.dimensions, equals(initialState.dimensions));
      });

      test('stores grid resize data correctly', () {
        const newDimensions = GridDimensions(columns: 6, rows: 6);
        final command = ResizeGridCommand(initialState.dimensions, newDimensions);
        expect(command.oldDimensions, equals(initialState.dimensions));
        expect(command.newDimensions, equals(newDimensions));
      });
    });

    group('UpdateWidgetCommand', () {
      test('executes update widget operation', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final updatedPlacement = testWidget.copyWith(
          column: 1,
          row: 1,
          width: 2,
          height: 2,
        );
        final command = UpdateWidgetCommand('widget1', testWidget, updatedPlacement);
        final result = command.execute(stateWithWidget);
        
        final updatedWidget = result.getWidget('widget1');
        expect(updatedWidget?.column, equals(1));
        expect(updatedWidget?.row, equals(1));
        expect(updatedWidget?.width, equals(2));
        expect(updatedWidget?.height, equals(2));
      });

      test('undoes update widget operation', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final updatedPlacement = testWidget.copyWith(
          column: 1,
          row: 1,
          width: 2,
          height: 2,
        );
        final command = UpdateWidgetCommand('widget1', testWidget, updatedPlacement);
        final afterUpdate = command.execute(stateWithWidget);
        final afterUndo = command.undo(afterUpdate);
        
        final restoredWidget = afterUndo.getWidget('widget1');
        expect(restoredWidget, equals(testWidget));
      });

      test('stores update data correctly', () {
        final updatedPlacement = testWidget.copyWith(width: 2, height: 2);
        final command = UpdateWidgetCommand('widget1', testWidget, updatedPlacement);
        expect(command.widgetId, equals('widget1'));
        expect(command.oldPlacement, equals(testWidget));
        expect(command.newPlacement, equals(updatedPlacement));
      });
    });

    group('Command validation', () {
      test('AddWidgetCommand validates placement', () {
        // Test with invalid placement (out of bounds)
        final invalidWidget = WidgetPlacement(
          id: 'invalid',
          widgetName: 'Test',
          column: 5,
          row: 5,
          width: 1,
          height: 1,
        );
        final command = AddWidgetCommand(invalidWidget);
        
        expect(() => command.execute(initialState), throwsA(isA<ArgumentError>()));
      });

      test('RemoveWidgetCommand validates widget exists', () {
        final command = RemoveWidgetCommand('nonexistent', testWidget);
        
        expect(() => command.execute(initialState), throwsA(isA<ArgumentError>()));
      });

      test('MoveWidgetCommand validates new placement', () {
        final stateWithWidget = initialState.addWidget(testWidget);
        final invalidPlacement = testWidget.copyWith(column: 5, row: 5);
        final command = MoveWidgetCommand('widget1', testWidget, invalidPlacement);
        
        expect(() => command.execute(stateWithWidget), throwsA(isA<ArgumentError>()));
      });
    });
  });
}