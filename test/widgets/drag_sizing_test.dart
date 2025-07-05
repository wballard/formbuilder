import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/animated_drag_feedback.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  group('Drag Sizing Issues', () {
    testWidgets('AnimatedDragFeedback should not scale by default', (tester) async {
      const childSize = Size(100, 50);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedDragFeedback(
                scaleFactor: 1.0, // This should be 1.0, not 1.05
                child: SizedBox(
                  width: childSize.width,
                  height: childSize.height,
                  child: Container(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // The size should remain unchanged (no scaling)
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      
      final parentBox = tester.getSize(find.byType(AnimatedDragFeedback));
      
      // The parent should be the same size as the child when scaleFactor is 1.0
      expect(parentBox.width, equals(childSize.width));
      expect(parentBox.height, equals(childSize.height));
    });


    testWidgets('DraggingPlacedWidget should not scale drag feedback', (tester) async {
      final placement = WidgetPlacement(
        id: 'test-widget',
        widgetName: 'text',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
        properties: {'text': 'Test Widget'},
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          home: Scaffold(
            body: Center(
              child: DraggingPlacedWidget(
                placement: placement,
                child: const Text('Test Widget'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Find the AnimatedDragFeedback widget inside DraggingPlacedWidget
      final feedbackFinder = find.byType(AnimatedDragFeedback);
      expect(feedbackFinder, findsOneWidget);
      
      final feedbackWidget = tester.widget<AnimatedDragFeedback>(feedbackFinder);
      
      // The scaleFactor should be 1.05 for proper drag feedback visibility
      expect(feedbackWidget.scaleFactor, equals(1.05), 
        reason: 'DraggingPlacedWidget uses subtle scaling for better visual feedback during drag');
    });
  });
}