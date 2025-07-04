import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/animated_drag_feedback.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';

void main() {
  group('GridDragTarget Animation', () {
    testWidgets('should not scale the grid during drag operations', (WidgetTester tester) async {
      // Create a toolbox
      final toolbox = Toolbox.withDefaults();

      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 4),
        widgets: [],
      );

      // Widget builders map
      final widgetBuilders = <String, Widget Function(BuildContext, WidgetPlacement)>{
        'test_widget': (context, placement) => Container(
          color: Colors.blue,
          child: const Center(child: Text('Test')),
        ),
      };

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDragTarget(
              layoutState: layoutState,
              widgetBuilders: widgetBuilders,
              toolbox: toolbox,
              animationSettings: const AnimationSettings(),
              onWidgetDropped: (placement) {},
              onWidgetMoved: (widgetId, newPlacement) {},
              onWidgetResize: (widgetId, newPlacement) {},
              onWidgetDelete: (widgetId) {},
              onGridResize: (dimensions) {},
              selectedWidgetId: null,
              onWidgetTap: (widgetId) {},
            ),
          ),
        ),
      );

      // Find AnimatedDropTarget widgets
      final animatedDropTargets = find.byType(AnimatedDropTarget);
      
      // There should be at least one AnimatedDropTarget
      expect(animatedDropTargets, findsOneWidget);

      // Check that the AnimatedDropTarget has no scale transformation
      final AnimatedDropTarget animatedDropTarget = tester.widget(animatedDropTargets.first);
      
      // The activeScale should be 1.0 (no scaling) to prevent grid animation
      expect(animatedDropTarget.activeScale, 1.0,
          reason: 'Grid should not scale during drag operations');
    });
  });
}