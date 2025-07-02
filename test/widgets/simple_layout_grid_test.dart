import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

void main() {
  testWidgets('Simple LayoutGrid with spanning widget', (WidgetTester tester) async {
    // Build a simple LayoutGrid with a widget spanning multiple cells
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
              Container(
                color: Colors.blue,
                child: const Center(child: Text('Spanning Widget')),
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
    expect(find.text('Spanning Widget'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    
    // Try to get the center of the spanning widget
    print('Getting center of spanning widget...');
    try {
      final center = tester.getCenter(find.text('Spanning Widget'));
      print('Center found at: $center');
      
      // Now try to start a gesture on it
      print('Starting gesture...');
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(10, 10));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      
      print('Gesture completed successfully');
    } catch (e) {
      print('Error: $e');
      fail('Failed to interact with spanning widget: $e');
    }
  });
}