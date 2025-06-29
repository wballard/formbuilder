import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Utility class for asserting state conditions in tests
class StateAssertions {
  /// Asserts that the layout state contains expected widgets
  static void assertLayoutContainsWidgets(
    LayoutState state,
    List<String> expectedWidgetIds,
  ) {
    final actualIds = state.widgets.map((w) => w.id).toSet();
    final expectedIds = expectedWidgetIds.toSet();
    
    expect(
      actualIds,
      equals(expectedIds),
      reason: 'Layout should contain exactly widgets with IDs: $expectedWidgetIds',
    );
  }

  /// Asserts that a widget is at a specific position
  static void assertWidgetPosition(
    LayoutState state,
    String widgetId, {
    required int row,
    required int column,
  }) {
    final widget = state.getWidget(widgetId);
    expect(widget, isNotNull, reason: 'Widget with ID $widgetId should exist');
    expect(widget!.row, equals(row), 
        reason: 'Widget $widgetId should be at row $row');
    expect(widget.column, equals(column), 
        reason: 'Widget $widgetId should be at column $column');
  }

  /// Asserts that a widget has specific dimensions
  static void assertWidgetSize(
    LayoutState state,
    String widgetId, {
    required int width,
    required int height,
  }) {
    final widget = state.getWidget(widgetId);
    expect(widget, isNotNull, reason: 'Widget with ID $widgetId should exist');
    expect(widget!.width, equals(width), 
        reason: 'Widget $widgetId should have width $width');
    expect(widget.height, equals(height), 
        reason: 'Widget $widgetId should have height $height');
  }

  /// Asserts that no widgets overlap in the layout
  static void assertNoOverlappingWidgets(LayoutState state) {
    final widgets = state.widgets;
    for (int i = 0; i < widgets.length; i++) {
      for (int j = i + 1; j < widgets.length; j++) {
        expect(
          widgets[i].overlaps(widgets[j]),
          isFalse,
          reason: 'Widgets ${widgets[i].id} and ${widgets[j].id} should not overlap',
        );
      }
    }
  }

  /// Asserts that all widgets fit within the grid
  static void assertAllWidgetsFitInGrid(LayoutState state) {
    for (final widget in state.widgets) {
      expect(
        widget.fitsInGrid(state.dimensions),
        isTrue,
        reason: 'Widget ${widget.id} should fit within grid dimensions ${state.dimensions}',
      );
    }
  }

  /// Asserts grid dimensions
  static void assertGridDimensions(
    LayoutState state, {
    required int columns,
    required int rows,
  }) {
    expect(
      state.dimensions.columns,
      equals(columns),
      reason: 'Grid should have $columns columns',
    );
    expect(
      state.dimensions.rows,
      equals(rows),
      reason: 'Grid should have $rows rows',
    );
  }

  /// Asserts that a widget can be added at a specific position
  static void assertCanAddWidget(
    LayoutState state,
    WidgetPlacement placement,
  ) {
    expect(
      state.canAddWidget(placement),
      isTrue,
      reason: 'Should be able to add widget at position (${placement.row}, ${placement.column})',
    );
  }

  /// Asserts that a widget cannot be added at a specific position
  static void assertCannotAddWidget(
    LayoutState state,
    WidgetPlacement placement,
    String reason,
  ) {
    expect(
      state.canAddWidget(placement),
      isFalse,
      reason: reason,
    );
  }

  /// Asserts that the layout is empty
  static void assertLayoutEmpty(LayoutState state) {
    expect(
      state.widgets,
      isEmpty,
      reason: 'Layout should be empty',
    );
  }

  /// Asserts that the layout has a specific number of widgets
  static void assertWidgetCount(LayoutState state, int expectedCount) {
    expect(
      state.widgets.length,
      equals(expectedCount),
      reason: 'Layout should contain exactly $expectedCount widgets',
    );
  }

  /// Asserts that widgets are in a specific order
  static void assertWidgetOrder(
    LayoutState state,
    List<String> expectedOrder,
  ) {
    final actualOrder = state.widgets.map((w) => w.id).toList();
    expect(
      actualOrder,
      equals(expectedOrder),
      reason: 'Widgets should be in order: $expectedOrder',
    );
  }

  /// Asserts that a widget has specific properties
  static void assertWidgetProperties(
    LayoutState state,
    String widgetId,
    Map<String, dynamic> expectedProperties,
  ) {
    final widget = state.getWidget(widgetId);
    expect(widget, isNotNull, reason: 'Widget with ID $widgetId should exist');
    
    for (final entry in expectedProperties.entries) {
      expect(
        widget!.properties[entry.key],
        equals(entry.value),
        reason: 'Widget $widgetId property ${entry.key} should be ${entry.value}',
      );
    }
  }

  /// Asserts state consistency after an operation
  static void assertStateConsistency(LayoutState state) {
    // Check no duplicate IDs
    final ids = state.widgets.map((w) => w.id).toList();
    final uniqueIds = ids.toSet();
    expect(
      ids.length,
      equals(uniqueIds.length),
      reason: 'All widget IDs should be unique',
    );
    
    // Check no overlaps
    assertNoOverlappingWidgets(state);
    
    // Check all widgets fit
    assertAllWidgetsFitInGrid(state);
  }
}