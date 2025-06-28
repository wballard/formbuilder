import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/optimized_drag_operations.dart';

void main() {
  group('ThrottledDragTarget', () {
    testWidgets('should throttle drag updates', (tester) async {
      int updateCount = 0;
      final List<Offset> capturedPositions = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ThrottledDragTarget<String>(
                  throttleInterval: const Duration(milliseconds: 50),
                  onWillAccept: (data) => true,
                  onAccept: (data) {},
                  onMove: (details) {
                    updateCount++;
                    capturedPositions.add(details.offset);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.blue,
                      child: const Text('Drop Zone'),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Draggable<String>(
                    data: 'test',
                    feedback: Container(
                      width: 50,
                      height: 50,
                      color: Colors.red,
                    ),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                      child: const Text('Drag me'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Start drag
      await tester.press(find.text('Drag me'));
      await tester.pump();

      // Simulate multiple drag events in quick succession
      for (int i = 0; i < 10; i++) {
        await tester.drag(
          find.text('Drag me'),
          Offset(10 + i * 5.0, 10),
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 10));
      }

      // Should have throttled the updates
      expect(updateCount, lessThan(10));
    });

    testWidgets('should handle drag performance mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThrottledDragTarget<String>(
              onWillAccept: (data) => true,
              onAccept: (data) {},
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 200,
                  height: 200,
                  color: candidateData.isNotEmpty ? Colors.red : Colors.blue,
                  child: const Text('Drop Zone'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
    });
  });

  group('OptimizedDraggable', () {
    testWidgets('should reduce quality during drag', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedDraggable<String>(
              data: 'test',
              dragQuality: DragQuality.low,
              feedback: Container(
                width: 100,
                height: 100,
                color: Colors.red,
                child: const Text('Dragging...'),
              ),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.green,
                child: const Text('Drag me'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Drag me'), findsOneWidget);

      // Start drag
      await tester.press(find.text('Drag me'));
      await tester.pump();

      // Should render feedback during drag
      await tester.drag(find.text('Drag me'), const Offset(50, 50));
      await tester.pump();
    });

    testWidgets('should handle drag lifecycle callbacks', (tester) async {
      bool dragStarted = false;
      bool dragEnded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedDraggable<String>(
              data: 'test',
              onDragStarted: () {
                dragStarted = true;
              },
              onDragEnd: (details) {
                dragEnded = true;
              },
              feedback: Container(width: 100, height: 100, color: Colors.red),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.green,
                child: const Text('Drag me'),
              ),
            ),
          ),
        ),
      );

      // Start and complete drag
      await tester.drag(find.text('Drag me'), const Offset(100, 100));
      await tester.pumpAndSettle();

      expect(dragStarted, isTrue);
      expect(dragEnded, isTrue);
    });
  });

  group('DragPerformanceOptimizer', () {
    test('should calculate optimal drag frequency', () {
      final optimizer = DragPerformanceOptimizer();

      // Simulate good performance
      for (int i = 0; i < 10; i++) {
        optimizer.recordFrameTime(10.0); // 10ms = 100 FPS
      }

      final goodFreq = optimizer.getOptimalDragFrequency();
      expect(goodFreq, greaterThanOrEqualTo(60));

      // Reset and simulate poor performance
      optimizer.reset();
      for (int i = 0; i < 10; i++) {
        optimizer.recordFrameTime(50.0); // 50ms = 20 FPS
      }

      final poorFreq = optimizer.getOptimalDragFrequency();
      expect(poorFreq, lessThan(30));
    });

    test('should suggest quality level based on performance', () {
      final optimizer = DragPerformanceOptimizer();

      // Good performance - high quality
      for (int i = 0; i < 10; i++) {
        optimizer.recordFrameTime(8.0); // ~120 FPS
      }

      expect(optimizer.getSuggestedQuality(), equals(DragQuality.high));

      // Reset and test medium performance
      optimizer.reset();
      for (int i = 0; i < 10; i++) {
        optimizer.recordFrameTime(20.0); // 50 FPS
      }

      expect(optimizer.getSuggestedQuality(), equals(DragQuality.medium));

      // Reset and test poor performance
      optimizer.reset();
      for (int i = 0; i < 10; i++) {
        optimizer.recordFrameTime(60.0); // ~16 FPS
      }

      expect(optimizer.getSuggestedQuality(), equals(DragQuality.low));
    });

    test('should adapt drag parameters', () {
      final optimizer = DragPerformanceOptimizer();

      // Simulate poor performance
      for (int i = 0; i < 10; i++) {
        optimizer.recordFrameTime(40.0); // 25 FPS
      }

      final params = optimizer.getOptimizedDragParams();
      expect(params.quality, equals(DragQuality.low));
      expect(params.throttleMs, greaterThan(30));
      expect(params.updateFrequency, lessThan(40));
    });
  });

  group('DragDropPerformanceWrapper', () {
    testWidgets('should optimize drag performance automatically', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragDropPerformanceWrapper(
              child: Column(
                children: [
                  Draggable<String>(
                    data: 'item1',
                    feedback: Container(
                      width: 50,
                      height: 50,
                      color: Colors.red,
                    ),
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.green,
                      child: const Text('Item 1'),
                    ),
                  ),
                  DragTarget<String>(
                    onWillAcceptWithDetails: (details) => true,
                    onAcceptWithDetails: (details) {},
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 200,
                        height: 100,
                        color: Colors.blue,
                        child: const Text('Drop Zone'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Drop Zone'), findsOneWidget);

      // Test drag operation
      await tester.drag(find.text('Item 1'), const Offset(0, 100));
      await tester.pumpAndSettle();
    });
  });
}
