import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

void main() {
  testWidgets('PlacedWidget drag interaction test', (WidgetTester tester) async {
    // Create a simple placement
    final placement = WidgetPlacement(
      id: 'test_widget',
      widgetName: 'text_field',
      column: 0,
      row: 0,
      width: 1,
      height: 1,
      properties: {},
    );

    // Track drag callbacks
    bool dragStarted = false;
    bool dragEnded = false;
    
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: PlacedWidget(
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
                child: const Text('Test Widget'),
              ),
            ),
          ),
        ),
      ),
    );

    // Wait for everything to settle
    await tester.pumpAndSettle();

    // Verify the widget is rendered
    expect(find.text('Test Widget'), findsOneWidget);
    expect(find.byType(PlacedWidget), findsOneWidget);
    
    print('Starting drag gesture...');
    
    // Start a drag gesture
    final center = tester.getCenter(find.byType(PlacedWidget));
    final gesture = await tester.startGesture(center);
    
    // Move to trigger drag
    await gesture.moveBy(const Offset(50, 50));
    await tester.pump();
    
    // Check if drag started
    expect(dragStarted, isTrue);
    
    // Continue drag
    await gesture.moveBy(const Offset(50, 50));
    await tester.pump();
    
    // End drag
    await gesture.up();
    await tester.pump();
    
    // Check if drag ended
    expect(dragEnded, isTrue);
    
    // Check for any exceptions
    final exception = tester.takeException();
    if (exception != null) {
      print('Exception during test: $exception');
      fail('Hit testing error occurred: $exception');
    }
  });
}