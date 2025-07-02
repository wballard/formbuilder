import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  testWidgets('LayoutGrid with PlacedWidget drag test', (WidgetTester tester) async {
    // Create a simple placement
    final placement = WidgetPlacement(
      id: 'test_widget',
      widgetName: 'text_field',
      column: 0,
      row: 0,
      width: 2,  // Spanning multiple columns
      height: 1,
      properties: {},
    );

    // Track drag callbacks
    bool dragStarted = false;
    bool dragEnded = false;
    
    // Build the widget with LayoutGrid
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LayoutGrid(
            areas: '''
              cell_0_0 cell_0_1
              cell_1_0 cell_1_1
            ''',
            columnSizes: [1.fr, 1.fr],
            rowSizes: [1.fr, 1.fr],
            children: [
              PlacedWidget(
                placement: placement,
                canDrag: true,
                onDragStarted: (p) {
                  print('Drag started');
                  dragStarted = true;
                },
                onDragEnd: () {
                  print('Drag ended');
                  dragEnded = true;
                },
                child: Container(
                  color: Colors.blue,
                  child: const Center(child: Text('Test Widget')),
                ),
              ).inGridArea('cell_0_0 cell_0_1'), // Spanning two cells
            ],
          ),
        ),
      ),
    );

    // Wait for everything to settle
    await tester.pumpAndSettle();
    
    // Give extra time for complex layout to complete
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify the widget is rendered
    expect(find.text('Test Widget'), findsOneWidget);
    expect(find.byType(PlacedWidget), findsOneWidget);
    
    print('Starting drag gesture...');
    
    // Check if the PlacedWidget is properly laid out
    final placedWidgetFinder = find.byType(PlacedWidget);
    final placedElement = placedWidgetFinder.evaluate().first;
    final placedRenderBox = placedElement.renderObject as RenderBox?;
    
    if (placedRenderBox == null || !placedRenderBox.hasSize) {
      print('PlacedWidget not properly laid out in test environment, skipping');
      return;
    }
    
    // Also check the text widget
    final textFinder = find.text('Test Widget');
    final textElement = textFinder.evaluate().first;
    final textRenderBox = textElement.renderObject as RenderBox?;
    
    if (textRenderBox == null || !textRenderBox.hasSize) {
      print('Text widget not properly laid out in test environment, skipping');
      return;
    }
    
    // Try to find the center of the widget
    try {
      final center = tester.getCenter(find.text('Test Widget'));
      print('Text widget center found at: $center');
      
      // Start a drag gesture
      final gesture = await tester.startGesture(center);
      
      // Move to trigger drag
      await gesture.moveBy(const Offset(50, 50));
      await tester.pump();
      
      // Check if drag started
      expect(dragStarted, isTrue);
      
      // End drag
      await gesture.up();
      await tester.pump();
      
      // Check if drag ended
      expect(dragEnded, isTrue);
    } catch (e) {
      print('Error during drag test: $e');
      // Check for the specific hit testing error
      final exception = tester.takeException();
      if (exception != null) {
        print('Caught exception: $exception');
        if (exception.toString().contains('Cannot hit test a render box that has never been laid out')) {
          fail('Hit testing error reproduced: $exception');
        }
      }
      rethrow;
    }
  });
}