import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';

void main() {
  testWidgets('TextField drag issue reproduction', (WidgetTester tester) async {
    // Create a layout state similar to what's in the stories
    final layoutState = LayoutState(
      dimensions: const GridDimensions(columns: 4, rows: 3),
      widgets: [
        WidgetPlacement(
          id: 'text_field_1',
          widgetName: 'text_field',
          column: 1,
          row: 1,
          width: 2, // Spanning multiple columns
          height: 1,
          properties: {'label': 'Test Field'},
        ),
      ],
    );

    // Create widget builders similar to the stories
    final widgetBuilders = <String, Widget Function(BuildContext, WidgetPlacement)>{
      'text_field': (context, placement) => Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: placement.properties['label'] as String? ?? 'Text Field',
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    };

    // Track drag state
    bool dragStarted = false;
    bool dragEnded = false;
    
    // Use GridContainer directly
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridContainer(
            layoutState: layoutState,
            widgetBuilders: widgetBuilders,
            isPreviewMode: false,
            animationSettings: const AnimationSettings(enabled: false),
            canDragWidgets: true,
            onWidgetDragStarted: (placement) {
              print('Drag started for widget: ${placement.id}');
              dragStarted = true;
            },
            onWidgetDragEnd: () {
              print('Drag ended');
              dragEnded = true;
            },
          ),
        ),
      ),
    );

    // Wait for everything to settle
    await tester.pumpAndSettle();
    
    // Give extra time for complex layout to complete
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Check if GridContainer is rendered
    expect(find.byType(GridContainer), findsOneWidget);
    
    // Check if any widget is placed
    final paddingFinder = find.byType(Padding);
    print('Padding widgets found: ${paddingFinder.evaluate().length}');
    
    // Try to find TextFormField
    final textFieldFinder = find.byType(TextFormField);
    print('TextFormField widgets found: ${textFieldFinder.evaluate().length}');
    
    // Look for Material widgets (might be wrapping the TextFormField)
    final materialFinder = find.byType(Material);
    print('Material widgets found: ${materialFinder.evaluate().length}');
    
    // Look for Draggable widgets
    final draggableFinder = find.byType(Draggable);
    print('Draggable widgets found: ${draggableFinder.evaluate().length}');
    
    // Skip the test if no TextFormField is found
    if (textFieldFinder.evaluate().isEmpty) {
      print('No TextFormField found, skipping drag test');
      return;
    }
    
    // Check if the widget is properly laid out
    final element = textFieldFinder.evaluate().first;
    final renderBox = element.renderObject as RenderBox?;
    
    if (renderBox == null || !renderBox.hasSize) {
      print('TextFormField not properly laid out in test environment, skipping');
      return;
    }
    
    // Now test dragging
    expect(textFieldFinder, findsOneWidget);
    
    print('Starting drag test...');
    
    // Start a drag gesture
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(textFieldFinder),
    );
    
    // Move to trigger drag
    await gesture.moveBy(const Offset(20, 20));
    await tester.pump();
    
    print('Drag started, checking for exceptions...');
    
    // Check if any exception was thrown
    final exception = tester.takeException();
    if (exception != null) {
      print('Exception during drag: $exception');
      // Don't rethrow - we want to see what happened
    }
    
    // Continue drag
    await gesture.moveBy(const Offset(50, 50));
    await tester.pump();
    
    // End drag
    await gesture.up();
    await tester.pump();
  });
}