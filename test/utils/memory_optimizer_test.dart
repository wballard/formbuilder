import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/utils/memory_optimizer.dart';

void main() {
  group('MemoryOptimizer', () {
    late MemoryOptimizer optimizer;

    setUp(() {
      optimizer = MemoryOptimizer();
    });

    tearDown(() {
      optimizer.dispose();
    });

    test('should track memory usage', () {
      expect(optimizer.currentMemoryUsage, equals(0));

      optimizer.recordMemoryUsage(100 * 1024 * 1024); // 100 MB
      expect(optimizer.currentMemoryUsage, equals(100 * 1024 * 1024));
      expect(optimizer.peakMemoryUsage, equals(100 * 1024 * 1024));

      optimizer.recordMemoryUsage(150 * 1024 * 1024); // 150 MB
      expect(optimizer.currentMemoryUsage, equals(150 * 1024 * 1024));
      expect(optimizer.peakMemoryUsage, equals(150 * 1024 * 1024));

      optimizer.recordMemoryUsage(80 * 1024 * 1024); // 80 MB
      expect(optimizer.currentMemoryUsage, equals(80 * 1024 * 1024));
      expect(
        optimizer.peakMemoryUsage,
        equals(150 * 1024 * 1024),
      ); // Peak unchanged
    });

    test('should detect memory pressure', () {
      // Normal usage
      optimizer.recordMemoryUsage(50 * 1024 * 1024); // 50 MB
      expect(optimizer.isUnderMemoryPressure(), isFalse);

      // High usage
      optimizer.recordMemoryUsage(800 * 1024 * 1024); // 800 MB
      expect(optimizer.isUnderMemoryPressure(), isTrue);
    });

    test('should suggest memory cleanup', () {
      // Low memory - no cleanup needed
      optimizer.recordMemoryUsage(100 * 1024 * 1024);
      expect(optimizer.shouldCleanupMemory(), isFalse);

      // High memory - cleanup needed
      optimizer.recordMemoryUsage(600 * 1024 * 1024);
      expect(optimizer.shouldCleanupMemory(), isTrue);
    });

    test('should track allocations', () {
      const tag = 'test_allocation';

      optimizer.trackAllocation(tag, 1024 * 1024); // 1 MB
      expect(optimizer.getAllocationSize(tag), equals(1024 * 1024));

      optimizer.trackAllocation(tag, 2 * 1024 * 1024); // 2 MB (replace)
      expect(optimizer.getAllocationSize(tag), equals(2 * 1024 * 1024));

      optimizer.releaseAllocation(tag);
      expect(optimizer.getAllocationSize(tag), equals(0));
    });

    test('should reset stats', () {
      optimizer.recordMemoryUsage(100 * 1024 * 1024);
      optimizer.trackAllocation('test', 1024 * 1024);

      optimizer.reset();

      expect(optimizer.currentMemoryUsage, equals(0));
      expect(optimizer.peakMemoryUsage, equals(0));
      expect(optimizer.getAllocationSize('test'), equals(0));
    });
  });

  group('LimitedHistoryManager', () {
    test('should limit history size', () {
      final manager = LimitedHistoryManager<String>(maxSize: 3);

      manager.add('item1');
      manager.add('item2');
      manager.add('item3');

      expect(manager.length, equals(3));
      expect(manager.items, equals(['item1', 'item2', 'item3']));

      // Adding 4th item should remove the first
      manager.add('item4');

      expect(manager.length, equals(3));
      expect(manager.items, equals(['item2', 'item3', 'item4']));
    });

    test('should clear history', () {
      final manager = LimitedHistoryManager<String>(maxSize: 5);

      manager.add('item1');
      manager.add('item2');

      expect(manager.length, equals(2));

      manager.clear();

      expect(manager.length, equals(0));
      expect(manager.items, isEmpty);
    });

    test('should handle undo/redo with limits', () {
      final manager = LimitedHistoryManager<String>(maxSize: 3);

      manager.add('state1');
      manager.add('state2');
      manager.add('state3');
      manager.add('state4'); // Should remove state1

      expect(manager.canUndo, isTrue);
      expect(manager.canRedo, isFalse);

      final undoState = manager.undo();
      expect(undoState, equals('state3'));
      expect(manager.canRedo, isTrue);

      final redoState = manager.redo();
      expect(redoState, equals('state4'));
    });
  });

  group('ResourcePool', () {
    test('should reuse resources', () {
      final pool = ResourcePool<String>(
        factory: () => 'new_resource',
        maxSize: 2,
      );

      final resource1 = pool.acquire();
      final resource2 = pool.acquire();

      expect(resource1, equals('new_resource'));
      expect(resource2, equals('new_resource'));

      pool.release(resource1);

      // Should reuse the released resource
      final resource3 = pool.acquire();
      expect(resource3, equals(resource1));
    });

    test('should limit pool size', () {
      final pool = ResourcePool<String>(factory: () => 'resource', maxSize: 2);

      final res1 = pool.acquire();
      final res2 = pool.acquire();
      final res3 = pool.acquire();

      // Release all
      pool.release(res1);
      pool.release(res2);
      pool.release(res3);

      // Pool should only keep 2 resources
      expect(pool.availableCount, equals(2));
    });

    test('should dispose resources', () {
      bool disposed = false;

      final pool = ResourcePool<String>(
        factory: () => 'resource',
        onDispose: (resource) => disposed = true,
        maxSize: 1,
      );

      final resource = pool.acquire();
      pool.release(resource);

      pool.dispose();

      expect(disposed, isTrue);
    });
  });

  group('MemoryAwareWidget', () {
    testWidgets('should respond to memory pressure', (tester) async {
      bool cleanupCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MemoryAwareWidget(
            onMemoryPressure: () {
              cleanupCalled = true;
            },
            child: const Text('Test Widget'),
          ),
        ),
      );

      expect(find.text('Test Widget'), findsOneWidget);

      // Simulate memory pressure
      final state = tester.state<MemoryAwareWidgetState>(
        find.byType(MemoryAwareWidget),
      );
      state.simulateMemoryPressure();

      expect(cleanupCalled, isTrue);
    });

    testWidgets('should dispose properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MemoryAwareWidget(child: Text('Test Widget'))),
      );

      expect(find.text('Test Widget'), findsOneWidget);

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(home: Text('Different Widget')),
        );

      expect(find.text('Test Widget'), findsNothing);
    });
  });

  group('AutoCleanupMixin', () {
    testWidgets('should cleanup resources automatically', (tester) async {
      bool disposed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TestAutoCleanupWidget(onDispose: () => disposed = true),
        ),
      );

      // Remove widget to trigger disposal
      await tester.pumpWidget(const MaterialApp(home: Text('Other Widget')));

      expect(disposed, isTrue);
    });
  });
}

class TestAutoCleanupWidget extends StatefulWidget {
  const TestAutoCleanupWidget({super.key, this.onDispose});

  final VoidCallback? onDispose;

  @override
  State<TestAutoCleanupWidget> createState() => _TestAutoCleanupWidgetState();
}

class _TestAutoCleanupWidgetState extends State<TestAutoCleanupWidget>
    with AutoCleanupMixin {
  @override
  void initState() {
    super.initState();
    // Register cleanup callback
    registerCleanup(widget.onDispose ?? () {});
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Auto Cleanup Widget');
  }
}
