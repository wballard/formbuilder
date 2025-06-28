import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/utils/performance_monitor.dart';
import 'package:formbuilder/form_layout/widgets/optimized_grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/optimized_value_listenable.dart';
import 'package:formbuilder/form_layout/widgets/optimized_drag_operations.dart';
import 'package:formbuilder/form_layout/widgets/virtual_grid.dart';
import 'package:formbuilder/form_layout/utils/memory_optimizer.dart';
import 'package:formbuilder/form_layout/models/performance_settings.dart';

void main() {
  group('Performance Integration Tests', () {
    late PerformanceMonitor monitor;
    late MemoryOptimizer memoryOptimizer;

    setUp(() {
      monitor = PerformanceMonitor();
      memoryOptimizer = MemoryOptimizer();
    });

    tearDown(() {
      monitor.dispose();
      memoryOptimizer.dispose();
    });

    testWidgets('should handle large grid with optimizations', (tester) async {
      const gridSize = 50; // 50x50 grid
      int cellBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: WidgetVirtualGrid(
                dimensions: const VirtualGridDimensions(
                  columns: gridSize,
                  rows: gridSize,
                ),
                cellSize: const Size(40, 40),
                cellBuilder: (context, x, y) {
                  cellBuilds++;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$x,$y',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should only render visible cells, not all 2500 cells
      expect(cellBuilds, lessThan(100));
      expect(cellBuilds, greaterThan(0));

      // Test scrolling performance
      monitor.startFrame();
      await tester.drag(
        find.byType(WidgetVirtualGrid),
        const Offset(-100, -100),
      );
      await tester.pump();
      monitor.endFrame();

      final stats = monitor.getStats();
      expect(stats.frameCount, equals(1));
      expect(stats.averageFrameTime, lessThan(100)); // Should be under 100ms
    });

    testWidgets('should optimize state updates with selective rebuilds', (
      tester,
    ) async {
      final state = ValueNotifier<TestComplexState>(
        TestComplexState(
          counter: 0,
          data: 'initial',
          timestamp: DateTime.now(),
        ),
      );

      int counterBuilds = 0;
      int dataBuilds = 0;
      int timestampBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SelectiveStateBuilder<TestComplexState, int>(
                  valueListenable: state,
                  selector: (s) => s.counter,
                  builder: (context, counter, child) {
                    counterBuilds++;
                    return Text('Counter: $counter');
                  },
                ),
                SelectiveStateBuilder<TestComplexState, String>(
                  valueListenable: state,
                  selector: (s) => s.data,
                  builder: (context, data, child) {
                    dataBuilds++;
                    return Text('Data: $data');
                  },
                ),
                SelectiveStateBuilder<TestComplexState, DateTime>(
                  valueListenable: state,
                  selector: (s) => s.timestamp,
                  builder: (context, timestamp, child) {
                    timestampBuilds++;
                    return Text('Time: ${timestamp.millisecondsSinceEpoch}');
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      expect(counterBuilds, equals(1));
      expect(dataBuilds, equals(1));
      expect(timestampBuilds, equals(1));

      // Update only counter
      state.value = state.value.copyWith(counter: 1);
      await tester.pump();

      // Only counter should rebuild
      expect(counterBuilds, equals(2));
      expect(dataBuilds, equals(1)); // No rebuild
      expect(timestampBuilds, equals(1)); // No rebuild

      // Update only data
      state.value = state.value.copyWith(data: 'updated');
      await tester.pump();

      // Only data should rebuild
      expect(counterBuilds, equals(2)); // No rebuild
      expect(dataBuilds, equals(2));
      expect(timestampBuilds, equals(1)); // No rebuild
    });

    testWidgets('should handle memory pressure gracefully', (tester) async {
      bool cleanupCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MemoryAwareWidget(
            onMemoryPressure: () {
              cleanupCalled = true;
            },
            child: const Text('Memory Test'),
          ),
        ),
      );

      // Simulate memory pressure
      memoryOptimizer.recordMemoryUsage(600 * 1024 * 1024); // 600 MB

      final state = tester.state<MemoryAwareWidgetState>(
        find.byType(MemoryAwareWidget),
      );
      state.simulateMemoryPressure();

      expect(cleanupCalled, isTrue);
    });

    testWidgets('should adapt performance settings automatically', (
      tester,
    ) async {
      final profiler = PerformanceProfiler();
      profiler.updateSettings(const PerformanceSettings.auto());

      // Simulate poor performance for several frames
      for (int i = 0; i < 10; i++) {
        profiler.recordPerformanceMetrics(
          frameTime: 40.0, // 25 FPS
          memoryUsage: 500 * 1024 * 1024, // 500 MB
        );
      }

      final adaptedSettings = profiler.getAdaptedSettings();

      // Should adapt to lower quality
      expect(adaptedSettings.qualityLevel, equals(QualityLevel.low));
      expect(adaptedSettings.enableAnimations, isFalse);

      profiler.dispose();
    });

    testWidgets('should handle complex drag operations efficiently', (
      tester,
    ) async {
      final dragCount = ValueNotifier<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ThrottledDragTarget<String>(
                  throttleInterval: const Duration(milliseconds: 16), // 60 FPS
                  onWillAccept: (data) => true,
                  onAccept: (data) {},
                  onMove: (details) {
                    dragCount.value++;
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: candidateData.isNotEmpty
                          ? Colors.blue
                          : Colors.grey,
                      child: const Center(child: Text('Drop Zone')),
                    );
                  },
                ),
                OptimizedDraggable<String>(
                  data: 'test',
                  dragQuality:
                      DragQuality.low, // Use low quality for performance
                  feedback: Container(
                    width: 50,
                    height: 50,
                    color: Colors.red.withValues(alpha: 0.7),
                    child: const Center(child: Text('Dragging')),
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.red,
                    child: const Center(child: Text('Drag')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Start drag and move multiple times quickly
      monitor.startFrame();

      // Simulate rapid drag movements
      await tester.press(find.text('Drag'));
      for (int i = 0; i < 20; i++) {
        await tester.drag(
          find.text('Drag'),
          Offset(i * 2.0, i * 2.0),
          warnIfMissed: false,
        );
        await tester.pump(
          const Duration(milliseconds: 8),
        ); // 120 FPS simulation
      }

      monitor.endFrame();

      // Drag updates should be throttled
      expect(dragCount.value, lessThan(20)); // Should be throttled
    });

    testWidgets('should optimize grid rendering with RepaintBoundary', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedGridWidget(
              dimensions: const GridDimensions(columns: 4, rows: 4),
              lineColor: Colors.black,
              backgroundColor: Colors.white,
              lineWidth: 1.0,
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify RepaintBoundary is used
      final optimizedGridFinder = find.byType(OptimizedGridWidget);
      final repaintBoundaryFinder = find.descendant(
        of: optimizedGridFinder,
        matching: find.byType(RepaintBoundary),
      );
      expect(repaintBoundaryFinder, findsOneWidget);
    });

    test('should manage memory with resource pools', () {
      final pool = ResourcePool<ExpensiveResource>(
        factory: () => ExpensiveResource(),
        maxSize: 3,
      );

      // Acquire and release resources
      final resources = <ExpensiveResource>[];
      for (int i = 0; i < 5; i++) {
        resources.add(pool.acquire());
      }

      // Release all resources
      for (final resource in resources) {
        pool.release(resource);
      }

      // Pool should only keep maxSize resources
      expect(pool.availableCount, equals(3));

      pool.dispose();
    });

    test('should limit history for memory efficiency', () {
      final history = LimitedHistoryManager<String>(maxSize: 5);

      // Add more items than max size
      for (int i = 0; i < 10; i++) {
        history.add('item$i');
      }

      // Should only keep last 5 items
      expect(history.length, equals(5));
      expect(
        history.items,
        equals(['item5', 'item6', 'item7', 'item8', 'item9']),
      );
    });

    testWidgets('should handle performance monitoring overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Performance Test'),
                if (kDebugMode)
                  Positioned(
                    top: 50,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FPS: 60.0\nFrames: 1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show performance test widget
      expect(find.text('Performance Test'), findsOneWidget);
    });
  });
}

class TestComplexState {
  const TestComplexState({
    required this.counter,
    required this.data,
    required this.timestamp,
  });

  final int counter;
  final String data;
  final DateTime timestamp;

  TestComplexState copyWith({int? counter, String? data, DateTime? timestamp}) {
    return TestComplexState(
      counter: counter ?? this.counter,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestComplexState &&
          runtimeType == other.runtimeType &&
          counter == other.counter &&
          data == other.data &&
          timestamp == other.timestamp;

  @override
  int get hashCode => counter.hashCode ^ data.hashCode ^ timestamp.hashCode;
}

class ExpensiveResource {
  final String id = DateTime.now().millisecondsSinceEpoch.toString();
}

class PerformanceOverlay extends StatelessWidget {
  const PerformanceOverlay({
    super.key,
    required this.monitor,
    required this.child,
  });

  final PerformanceMonitor monitor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (kDebugMode)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: ValueNotifier(monitor.getStats().frameCount),
                builder: (context, frameCount, child) {
                  final stats = monitor.getStats();
                  return Text(
                    'FPS: ${stats.currentFps.toStringAsFixed(1)}\n'
                    'Frames: $frameCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
