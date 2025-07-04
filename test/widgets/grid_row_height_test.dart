import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

void main() {
  group('Grid Row Height', () {
    testWidgets('should use default row height of 4 ems when not specified', 
        (WidgetTester tester) async {
      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 3, rows: 3),
        widgets: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: GridContainer(
                layoutState: layoutState,
                widgetBuilders: const {},
                animationSettings: const AnimationSettings(enabled: false),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the GridContainer widget
      final gridContainerFinder = find.byType(GridContainer);
      expect(gridContainerFinder, findsOneWidget);
      
      // Find the LayoutGrid widgets - there should be 2 (main grid + overlay)
      final layoutGridFinder = find.byType(LayoutGrid);
      expect(layoutGridFinder, findsNWidgets(2));

      // Get the first LayoutGrid (main grid for placing widgets)
      final layoutGrid = tester.widget<LayoutGrid>(layoutGridFinder.first);
      
      // Verify that rows use FixedTrackSize instead of fractional sizing
      for (final rowSize in layoutGrid.rowSizes) {
        expect(rowSize.runtimeType.toString(), equals('FixedTrackSize'),
            reason: 'Row should use fixed height, not fractional sizing');
      }
      
      // Verify the grid container has the expected height
      // With 3 rows of 56px each, total should be 168px
      final gridContainerRenderObject = tester.renderObject(gridContainerFinder);
      expect(gridContainerRenderObject.paintBounds.height, equals(3 * 56.0));
    });

    testWidgets('should use custom row height when specified in theme', 
        (WidgetTester tester) async {
      const customRowHeight = 80.0;
      
      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 2, rows: 2),
        widgets: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormLayoutThemeWidget(
              theme: const FormLayoutTheme(rowHeight: customRowHeight),
              child: SizedBox(
                width: 400,
                child: GridContainer(
                  layoutState: layoutState,
                  widgetBuilders: const {},
                  animationSettings: const AnimationSettings(enabled: false),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final layoutGridFinder = find.byType(LayoutGrid);
      expect(layoutGridFinder, findsNWidgets(2));

      final layoutGrid = tester.widget<LayoutGrid>(layoutGridFinder.first);
      
      // Verify that rows use FixedTrackSize instead of fractional sizing
      for (final rowSize in layoutGrid.rowSizes) {
        expect(rowSize.runtimeType.toString(), equals('FixedTrackSize'),
            reason: 'Row should use fixed custom height');
      }
      
      // Verify the grid container has the expected height based on custom row sizes
      // With 2 rows of 80px each, total should be 160px
      final gridContainerFinder = find.byType(GridContainer);
      final gridContainerRenderObject = tester.renderObject(gridContainerFinder);
      expect(gridContainerRenderObject.paintBounds.height, equals(2 * customRowHeight));
    });

    testWidgets('should maintain fixed row height when grid is resized', 
        (WidgetTester tester) async {
      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 2, rows: 3),
        widgets: [],
      );

      // Test that grid maintains fixed height regardless of available space
      for (final availableHeight in [400.0, 800.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: availableHeight,
                child: SingleChildScrollView(
                  child: GridContainer(
                    layoutState: layoutState,
                    widgetBuilders: const {},
                    animationSettings: const AnimationSettings(enabled: false),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final layoutGridFinder = find.byType(LayoutGrid);
        expect(layoutGridFinder, findsNWidgets(2));

        final layoutGrid = tester.widget<LayoutGrid>(layoutGridFinder.first);
        
        // Verify that rows use FixedTrackSize regardless of container size
        for (final rowSize in layoutGrid.rowSizes) {
          expect(rowSize.runtimeType.toString(), equals('FixedTrackSize'),
              reason: 'Row height should be fixed, not responsive to container size');
        }
        
        // Grid height should always be 3 rows * 56px = 168px, regardless of container size
        final gridContainerFinder = find.byType(GridContainer);
        final gridContainerRenderObject = tester.renderObject(gridContainerFinder);
        expect(gridContainerRenderObject.paintBounds.height, equals(3 * 56.0),
            reason: 'Grid height should be fixed at ${3 * 56.0}px regardless of available height $availableHeight');
      }
    });
  });
}