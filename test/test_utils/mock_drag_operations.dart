import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

/// Utility class for simulating drag operations in tests
class MockDragOperations {
  /// Performs a drag operation from one widget to another
  static Future<void> dragFromTo(
    WidgetTester tester, {
    required Finder from,
    required Finder to,
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    final fromCenter = tester.getCenter(from);
    final toCenter = tester.getCenter(to);
    
    await tester.dragFrom(fromCenter, toCenter - fromCenter);
    await tester.pumpAndSettle();
  }

  /// Performs a drag operation from a widget by a specific offset
  static Future<void> dragByOffset(
    WidgetTester tester, {
    required Finder widget,
    required Offset offset,
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await tester.drag(widget, offset);
    await tester.pumpAndSettle();
  }

  /// Performs a long press and drag operation
  static Future<void> longPressDrag(
    WidgetTester tester, {
    required Finder from,
    required Offset offset,
    Duration longPressDuration = const Duration(seconds: 1),
  }) async {
    final TestGesture gesture = await tester.startGesture(tester.getCenter(from));
    await tester.pump(longPressDuration);
    await gesture.moveBy(offset);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  /// Simulates a drag and drop operation
  static Future<void> dragAndDrop(
    WidgetTester tester, {
    required Finder draggable,
    required Finder dropTarget,
    Duration? dragDuration,
  }) async {
    final draggableCenter = tester.getCenter(draggable);
    final dropTargetCenter = tester.getCenter(dropTarget);
    
    final TestGesture gesture = await tester.startGesture(draggableCenter);
    
    if (dragDuration != null) {
      // Animate the drag over time
      const steps = 10;
      final stepDuration = dragDuration ~/ steps;
      final stepOffset = (dropTargetCenter - draggableCenter) / steps.toDouble();
      
      for (int i = 0; i < steps; i++) {
        await gesture.moveBy(stepOffset);
        await tester.pump(stepDuration);
      }
    } else {
      // Instant drag
      await gesture.moveTo(dropTargetCenter);
      await tester.pump();
    }
    
    await gesture.up();
    await tester.pumpAndSettle();
  }

  /// Simulates a canceled drag operation
  static Future<void> startDragAndCancel(
    WidgetTester tester, {
    required Finder widget,
    required Offset moveBy,
  }) async {
    final TestGesture gesture = await tester.startGesture(tester.getCenter(widget));
    await gesture.moveBy(moveBy);
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();
  }

  /// Simulates multiple simultaneous drags (for testing multi-touch)
  static Future<void> multiDrag(
    WidgetTester tester, {
    required List<Finder> widgets,
    required List<Offset> offsets,
  }) async {
    assert(widgets.length == offsets.length, 
        'Number of widgets must match number of offsets');
    
    final gestures = <TestGesture>[];
    
    // Start all gestures
    for (int i = 0; i < widgets.length; i++) {
      final gesture = await tester.startGesture(tester.getCenter(widgets[i]));
      gestures.add(gesture);
    }
    
    await tester.pump();
    
    // Move all gestures
    for (int i = 0; i < gestures.length; i++) {
      await gestures[i].moveBy(offsets[i]);
    }
    
    await tester.pump();
    
    // Release all gestures
    for (final gesture in gestures) {
      await gesture.up();
    }
    
    await tester.pumpAndSettle();
  }

  /// Performs a fling gesture
  static Future<void> fling(
    WidgetTester tester, {
    required Finder widget,
    required Offset velocity,
  }) async {
    await tester.fling(widget, velocity, 1000.0);
    await tester.pumpAndSettle();
  }

  /// Simulates a drag with specific pointer device
  static Future<void> dragWithDevice(
    WidgetTester tester, {
    required Finder widget,
    required Offset offset,
    PointerDeviceKind device = PointerDeviceKind.touch,
  }) async {
    final TestGesture gesture = await tester.createGesture(kind: device);
    await gesture.down(tester.getCenter(widget));
    await tester.pump();
    await gesture.moveBy(offset);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }
}