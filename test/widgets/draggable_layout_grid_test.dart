import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

void main() {
  testWidgets('LayoutGrid with Draggable spanning widget', (WidgetTester tester) async {
    bool dragStarted = false;
    
    // Build a LayoutGrid with a Draggable widget spanning multiple cells
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LayoutGrid(
            areas: '''
              a a
              b c
            ''',
            columnSizes: [1.fr, 1.fr],
            rowSizes: [1.fr, 1.fr],
            children: [
              Draggable<String>(
                data: 'test',
                feedback: Container(
                  width: 100,
                  height: 50,
                  color: Colors.blue.withOpacity(0.5),
                  child: const Center(child: Text('Dragging')),
                ),
                childWhenDragging: Container(),
                onDragStarted: () {
                  print('Drag started!');
                  dragStarted = true;
                },
                child: Container(
                  color: Colors.blue,
                  child: const Center(child: Text('Drag Me')),
                ),
              ).inGridArea('a'), // This spans two columns
              Container(
                color: Colors.red,
                child: const Center(child: Text('B')),
              ).inGridArea('b'),
              Container(
                color: Colors.green,
                child: const Center(child: Text('C')),
              ).inGridArea('c'),
            ],
          ),
        ),
      ),
    );

    // Wait for everything to settle
    await tester.pumpAndSettle();

    // Verify widgets are rendered
    expect(find.text('Drag Me'), findsOneWidget);
    
    // Try to start a drag on the Draggable widget
    print('Starting drag on Draggable widget...');
    try {
      final center = tester.getCenter(find.text('Drag Me'));
      print('Center found at: $center');
      
      // Start drag gesture
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(20, 20));
      await tester.pump();
      
      // Check if drag started
      expect(dragStarted, isTrue);
      
      // Continue drag
      await gesture.moveBy(const Offset(50, 50));
      await tester.pump();
      
      // End drag
      await gesture.up();
      await tester.pump();
      
      print('Drag completed successfully');
    } catch (e) {
      print('Error during drag: $e');
      final exception = tester.takeException();
      if (exception != null) {
        print('Caught exception: $exception');
      }
      fail('Failed to drag widget: $e');
    }
  });
}