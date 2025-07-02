import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/animated_grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/accessible_grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';

void main() {
  group('Grid Visibility Tests', () {
    testWidgets('GridWidget should show grid lines by default', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 3);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: GridWidget(
                dimensions: dimensions,
                gridLineColor: Colors.grey,
                gridLineWidth: 1.0,
              ),
            ),
          ),
        ),
      );

      // Verify the widget is built without errors
      expect(find.byType(GridWidget), findsOneWidget);
      
      // The grid should have visible border and internal grid lines
      // We'll look for Container widgets with borders (grid cells)
      final containerWidgets = find.byType(Container);
      expect(containerWidgets, findsWidgets);
    });

    testWidgets('AnimatedGridWidget with animations enabled should show grid lines immediately', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 3);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AnimatedGridWidget(
                dimensions: dimensions,
                lineColor: Colors.black,
                lineWidth: 2.0,
                animationSettings: const AnimationSettings(enabled: true),
                showGridLines: true,
              ),
            ),
          ),
        ),
      );

      // Should build without errors
      expect(find.byType(AnimatedGridWidget), findsOneWidget);
      
      // With animations enabled, it should use CustomPaint (could be multiple)
      expect(find.byType(CustomPaint), findsWidgets);
      
      // Grid lines should be immediately visible when showGridLines is true
      // (no animation delay should be needed)
      await tester.pump();
      
      // Find the grid container's custom paint
      final customPaints = find.byType(CustomPaint);
      expect(customPaints, findsWidgets);
      
      // At least one CustomPaint should have a painter that draws grid lines
      bool foundGridPainter = false;
      for (int i = 0; i < tester.widgetList(customPaints).length; i++) {
        final customPaint = tester.widgetList<CustomPaint>(customPaints).elementAt(i);
        if (customPaint.painter != null) {
          foundGridPainter = true;
          break;
        }
      }
      expect(foundGridPainter, isTrue);
    });

    testWidgets('AnimatedGridWidget should show grid lines when animations disabled and showGridLines is true', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 3);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AnimatedGridWidget(
                dimensions: dimensions,
                lineColor: Colors.grey,
                lineWidth: 1.0,
                animationSettings: const AnimationSettings(enabled: false),
                showGridLines: true,
              ),
            ),
          ),
        ),
      );

      // Should build without errors
      expect(find.byType(AnimatedGridWidget), findsOneWidget);
      
      // When animations are disabled, it should use GridWidget internally
      expect(find.byType(GridWidget), findsOneWidget);
      
      // Grid lines should be visible (non-transparent color)
      final gridWidget = tester.widget<GridWidget>(find.byType(GridWidget));
      expect(gridWidget.gridLineColor, isNot(Colors.transparent));
      expect(gridWidget.gridLineColor, Colors.grey);
    });

    testWidgets('AccessibleGridWidget should show grid lines by default', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 3);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AccessibleGridWidget(
                dimensions: dimensions,
                lineColor: Colors.grey,
                lineWidth: 1.0,
                showGridLines: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AccessibleGridWidget), findsOneWidget);
      expect(find.byType(AnimatedGridWidget), findsOneWidget);
    });

    testWidgets('GridContainer should show grid lines when not in preview mode', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 3);
      final layoutState = LayoutState(
        dimensions: dimensions,
        widgets: [],
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: GridContainer(
                layoutState: layoutState,
                widgetBuilders: const {},
                isPreviewMode: false, // Edit mode should show grid
                animationSettings: const AnimationSettings(enabled: false),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GridContainer), findsOneWidget);
      expect(find.byType(AccessibleGridWidget), findsOneWidget);
      
      // In edit mode, grid lines should be visible
      final accessibleGrid = tester.widget<AccessibleGridWidget>(find.byType(AccessibleGridWidget));
      expect(accessibleGrid.showGridLines, isTrue);
    });

    testWidgets('GridContainer should NOT show grid when in preview mode', (tester) async {
      const dimensions = GridDimensions(columns: 4, rows: 3);
      final layoutState = LayoutState(
        dimensions: dimensions,
        widgets: [],
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: GridContainer(
                layoutState: layoutState,
                widgetBuilders: const {},
                isPreviewMode: true, // Preview mode should hide grid
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GridContainer), findsOneWidget);
      
      // In preview mode, grid should not be shown
      expect(find.byType(AccessibleGridWidget), findsNothing);
    });
  });
}