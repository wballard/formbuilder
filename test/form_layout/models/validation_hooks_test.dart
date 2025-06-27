import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/validation_hooks.dart';
import 'package:formbuilder/form_layout/models/validation_result.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  group('ValidationHooks', () {
    late LayoutState testState;

    setUp(() {
      testState = LayoutState(
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
        ],
      );
    });

    group('constructor and properties', () {
      test('can create empty hooks', () {
        const hooks = ValidationHooks();
        
        expect(hooks.beforeAddWidget, isNull);
        expect(hooks.beforeMoveWidget, isNull);
        expect(hooks.beforeResizeWidget, isNull);
        expect(hooks.beforeRemoveWidget, isNull);
        expect(hooks.beforeResizeGrid, isNull);
      });

      test('can create hooks with all validators', () {
        final hooks = ValidationHooks(
          beforeAddWidget: (state, placement) async => 
              const ValidationResult.success(),
          beforeMoveWidget: (state, widgetId, newPosition) async =>
              const ValidationResult.success(),
          beforeResizeWidget: (state, widgetId, newSize) async =>
              const ValidationResult.success(),
          beforeRemoveWidget: (state, widgetId) async =>
              const ValidationResult.success(),
          beforeResizeGrid: (state, newDimensions) async =>
              const ValidationResult.success(),
        );
        
        expect(hooks.beforeAddWidget, isNotNull);
        expect(hooks.beforeMoveWidget, isNotNull);
        expect(hooks.beforeResizeWidget, isNotNull);
        expect(hooks.beforeRemoveWidget, isNotNull);
        expect(hooks.beforeResizeGrid, isNotNull);
      });

      test('ValidationHooks.none provides empty hooks', () {
        expect(ValidationHooks.none.beforeAddWidget, isNull);
        expect(ValidationHooks.none.beforeMoveWidget, isNull);
        expect(ValidationHooks.none.beforeResizeWidget, isNull);
        expect(ValidationHooks.none.beforeRemoveWidget, isNull);
        expect(ValidationHooks.none.beforeResizeGrid, isNull);
      });
    });

    group('copyWith', () {
      test('copies all hooks when not overridden', () {
        final original = ValidationHooks(
          beforeAddWidget: (state, placement) async => 
              const ValidationResult.success(),
          beforeMoveWidget: (state, widgetId, newPosition) async =>
              const ValidationResult.success(),
        );
        
        final copy = original.copyWith();
        
        expect(copy.beforeAddWidget, equals(original.beforeAddWidget));
        expect(copy.beforeMoveWidget, equals(original.beforeMoveWidget));
      });

      test('replaces specified hooks', () {
        final original = ValidationHooks(
          beforeAddWidget: (state, placement) async => 
              const ValidationResult.success(),
          beforeMoveWidget: (state, widgetId, newPosition) async =>
              const ValidationResult.success(),
        );
        
        ValidateAddWidget newValidator = (state, placement) async =>
            const ValidationResult.error('New validator');
        
        final copy = original.copyWith(beforeAddWidget: newValidator);
        
        expect(copy.beforeAddWidget, equals(newValidator));
        expect(copy.beforeMoveWidget, equals(original.beforeMoveWidget));
      });
    });

    group('combine', () {
      test('combines with empty hooks returns original', () {
        final hooks = ValidationHooks(
          beforeAddWidget: (state, placement) async => 
              const ValidationResult.success(),
        );
        
        final combined = hooks.combine(ValidationHooks.none);
        
        expect(combined.beforeAddWidget, equals(hooks.beforeAddWidget));
      });

      test('combines two hooks by running both validators', () async {
        var firstCalled = false;
        var secondCalled = false;
        
        final first = ValidationHooks(
          beforeAddWidget: (state, placement) async {
            firstCalled = true;
            return const ValidationResult.success();
          },
        );
        
        final second = ValidationHooks(
          beforeAddWidget: (state, placement) async {
            secondCalled = true;
            return const ValidationResult.success();
          },
        );
        
        final combined = first.combine(second);
        
        final testPlacement = WidgetPlacement(
          id: 'test',
          widgetName: 'TestWidget',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        
        await combined.beforeAddWidget!(testState, testPlacement);
        
        expect(firstCalled, isTrue);
        expect(secondCalled, isTrue);
      });

      test('combined validator returns first error', () async {
        final first = ValidationHooks(
          beforeAddWidget: (state, placement) async =>
              const ValidationResult.error('First error'),
        );
        
        final second = ValidationHooks(
          beforeAddWidget: (state, placement) async =>
              const ValidationResult.error('Second error'),
        );
        
        final combined = first.combine(second);
        
        final testPlacement = WidgetPlacement(
          id: 'test',
          widgetName: 'TestWidget',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        
        final result = await combined.beforeAddWidget!(testState, testPlacement);
        
        expect(result.isValid, isFalse);
        expect(result.message, equals('First error'));
      });

      test('combined validator continues if first succeeds', () async {
        final first = ValidationHooks(
          beforeAddWidget: (state, placement) async =>
              const ValidationResult.success(),
        );
        
        final second = ValidationHooks(
          beforeAddWidget: (state, placement) async =>
              const ValidationResult.warning('Second warning'),
        );
        
        final combined = first.combine(second);
        
        final testPlacement = WidgetPlacement(
          id: 'test',
          widgetName: 'TestWidget',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        );
        
        final result = await combined.beforeAddWidget!(testState, testPlacement);
        
        expect(result.isValid, isTrue);
        expect(result.severity, equals(ValidationSeverity.warning));
        expect(result.message, equals('Second warning'));
      });
    });
  });

  group('ValidationSupport extension', () {
    late LayoutState testState;

    setUp(() {
      testState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: const [],
      );
    });

    test('canAddWidgetWithHooks returns success when no hooks', () async {
      final placement = WidgetPlacement(
        id: 'test',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      
      final result = await testState.canAddWidgetWithHooks(placement, null);
      
      expect(result.isValid, isTrue);
    });

    test('canAddWidgetWithHooks calls hook when provided', () async {
      final placement = WidgetPlacement(
        id: 'test',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      
      final hooks = ValidationHooks(
        beforeAddWidget: (state, p) async {
          expect(state, equals(testState));
          expect(p, equals(placement));
          return const ValidationResult.error('Test error');
        },
      );
      
      final result = await testState.canAddWidgetWithHooks(placement, hooks);
      
      expect(result.isValid, isFalse);
      expect(result.message, equals('Test error'));
    });

    test('canMoveWidgetWithHooks returns success when no hooks', () async {
      final result = await testState.canMoveWidgetWithHooks(
        'widget1',
        const Point(2, 2),
        null,
      );
      
      expect(result.isValid, isTrue);
    });

    test('canMoveWidgetWithHooks calls hook when provided', () async {
      const widgetId = 'widget1';
      const newPosition = Point(2, 2);
      
      final hooks = ValidationHooks(
        beforeMoveWidget: (state, id, pos) async {
          expect(state, equals(testState));
          expect(id, equals(widgetId));
          expect(pos, equals(newPosition));
          return const ValidationResult.warning('Test warning');
        },
      );
      
      final result = await testState.canMoveWidgetWithHooks(
        widgetId,
        newPosition,
        hooks,
      );
      
      expect(result.isValid, isTrue);
      expect(result.severity, equals(ValidationSeverity.warning));
      expect(result.message, equals('Test warning'));
    });

    test('canResizeWidgetWithHooks returns success when no hooks', () async {
      final result = await testState.canResizeWidgetWithHooks(
        'widget1',
        const Size(2, 2),
        null,
      );
      
      expect(result.isValid, isTrue);
    });

    test('canResizeWidgetWithHooks calls hook when provided', () async {
      const widgetId = 'widget1';
      const newSize = Size(2, 2);
      
      final hooks = ValidationHooks(
        beforeResizeWidget: (state, id, size) async {
          expect(state, equals(testState));
          expect(id, equals(widgetId));
          expect(size, equals(newSize));
          return const ValidationResult.info('Test info');
        },
      );
      
      final result = await testState.canResizeWidgetWithHooks(
        widgetId,
        newSize,
        hooks,
      );
      
      expect(result.isValid, isTrue);
      expect(result.severity, equals(ValidationSeverity.info));
      expect(result.message, equals('Test info'));
    });

    test('canRemoveWidgetWithHooks returns success when no hooks', () async {
      final result = await testState.canRemoveWidgetWithHooks(
        'widget1',
        null,
      );
      
      expect(result.isValid, isTrue);
    });

    test('canRemoveWidgetWithHooks calls hook when provided', () async {
      const widgetId = 'widget1';
      
      final hooks = ValidationHooks(
        beforeRemoveWidget: (state, id) async {
          expect(state, equals(testState));
          expect(id, equals(widgetId));
          return const ValidationResult.error('Cannot remove');
        },
      );
      
      final result = await testState.canRemoveWidgetWithHooks(
        widgetId,
        hooks,
      );
      
      expect(result.isValid, isFalse);
      expect(result.message, equals('Cannot remove'));
    });

    test('canResizeGridWithHooks returns success when no hooks', () async {
      const newDimensions = GridDimensions(columns: 5, rows: 5);
      
      final result = await testState.canResizeGridWithHooks(
        newDimensions,
        null,
      );
      
      expect(result.isValid, isTrue);
    });

    test('canResizeGridWithHooks calls hook when provided', () async {
      const newDimensions = GridDimensions(columns: 3, rows: 3);
      
      final hooks = ValidationHooks(
        beforeResizeGrid: (state, dims) async {
          expect(state, equals(testState));
          expect(dims, equals(newDimensions));
          return const ValidationResult.warning('Grid will be smaller');
        },
      );
      
      final result = await testState.canResizeGridWithHooks(
        newDimensions,
        hooks,
      );
      
      expect(result.isValid, isTrue);
      expect(result.severity, equals(ValidationSeverity.warning));
      expect(result.message, equals('Grid will be smaller'));
    });
  });
}