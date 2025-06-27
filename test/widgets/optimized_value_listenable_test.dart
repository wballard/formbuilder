import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/optimized_value_listenable.dart';
import 'dart:math';

void main() {
  group('OptimizedValueListenableBuilder', () {
    testWidgets('should only rebuild when value changes', (tester) async {
      final notifier = ValueNotifier<int>(0);
      int buildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedValueListenableBuilder<int>(
              valueListenable: notifier,
              builder: (context, value, child) {
                buildCount++;
                return Text('Value: $value');
              },
            ),
          ),
        ),
      );
      
      expect(buildCount, equals(1));
      expect(find.text('Value: 0'), findsOneWidget);
      
      // Change value
      notifier.value = 1;
      await tester.pump();
      
      expect(buildCount, equals(2));
      expect(find.text('Value: 1'), findsOneWidget);
      
      // Set same value - should not rebuild
      notifier.value = 1;
      await tester.pump();
      
      expect(buildCount, equals(2)); // No rebuild
    });

    testWidgets('should use child parameter for optimization', (tester) async {
      final notifier = ValueNotifier<int>(0);
      int childBuildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedValueListenableBuilder<int>(
              valueListenable: notifier,
              child: Builder(
                builder: (context) {
                  childBuildCount++;
                  return const Text('Child');
                },
              ),
              builder: (context, value, child) {
                return Column(
                  children: [
                    Text('Value: $value'),
                    child!,
                  ],
                );
              },
            ),
          ),
        ),
      );
      
      expect(childBuildCount, equals(1));
      expect(find.text('Value: 0'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
      
      // Change value - child should not rebuild
      notifier.value = 1;
      await tester.pump();
      
      expect(childBuildCount, equals(1)); // Child not rebuilt
      expect(find.text('Value: 1'), findsOneWidget);
    });

    testWidgets('should support complex value types', (tester) async {
      final notifier = ValueNotifier<Point<int>>(const Point(0, 0));
      int buildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedValueListenableBuilder<Point<int>>(
              valueListenable: notifier,
              builder: (context, point, child) {
                buildCount++;
                return Text('Point: (${point.x}, ${point.y})');
              },
            ),
          ),
        ),
      );
      
      expect(buildCount, equals(1));
      expect(find.text('Point: (0, 0)'), findsOneWidget);
      
      // Change point
      notifier.value = const Point(1, 2);
      await tester.pump();
      
      expect(buildCount, equals(2));
      expect(find.text('Point: (1, 2)'), findsOneWidget);
    });
  });

  group('DebouncedValueNotifier', () {
    testWidgets('should debounce rapid changes', (tester) async {
      final notifier = DebouncedValueNotifier<int>(
        initialValue: 0,
        debounceTime: const Duration(milliseconds: 100),
      );
      
      int buildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<int>(
              valueListenable: notifier,
              builder: (context, value, child) {
                buildCount++;
                return Text('Value: $value');
              },
            ),
          ),
        ),
      );
      
      expect(buildCount, equals(1));
      expect(find.text('Value: 0'), findsOneWidget);
      
      // Rapid changes
      notifier.value = 1;
      notifier.value = 2;
      notifier.value = 3;
      
      // Should not have updated yet
      expect(buildCount, equals(1));
      
      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 150));
      
      // Should have updated with final value
      expect(buildCount, equals(2));
      expect(find.text('Value: 3'), findsOneWidget);
    });

    testWidgets('should dispose properly', (tester) async {
      final notifier = DebouncedValueNotifier<int>(
        initialValue: 0,
        debounceTime: const Duration(milliseconds: 100),
      );
      
      // Set a value to start the timer
      notifier.value = 1;
      
      // Dispose should cancel timer and clean up
      notifier.dispose();
      
      // Test passes if no exception is thrown during disposal
      expect(true, isTrue);
    });
  });

  group('SelectiveStateBuilder', () {
    testWidgets('should only rebuild when selected state changes', (tester) async {
      final state = TestState(counter: 0, name: 'test');
      final stateNotifier = ValueNotifier<TestState>(state);
      
      int counterBuildCount = 0;
      int nameBuildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SelectiveStateBuilder<TestState, int>(
                  valueListenable: stateNotifier,
                  selector: (state) => state.counter,
                  builder: (context, counter, child) {
                    counterBuildCount++;
                    return Text('Counter: $counter');
                  },
                ),
                SelectiveStateBuilder<TestState, String>(
                  valueListenable: stateNotifier,
                  selector: (state) => state.name,
                  builder: (context, name, child) {
                    nameBuildCount++;
                    return Text('Name: $name');
                  },
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(counterBuildCount, equals(1));
      expect(nameBuildCount, equals(1));
      expect(find.text('Counter: 0'), findsOneWidget);
      expect(find.text('Name: test'), findsOneWidget);
      
      // Change only counter
      stateNotifier.value = TestState(counter: 1, name: 'test');
      await tester.pump();
      
      expect(counterBuildCount, equals(2)); // Counter rebuilt
      expect(nameBuildCount, equals(1)); // Name not rebuilt
      expect(find.text('Counter: 1'), findsOneWidget);
      
      // Change only name
      stateNotifier.value = TestState(counter: 1, name: 'updated');
      await tester.pump();
      
      expect(counterBuildCount, equals(2)); // Counter not rebuilt
      expect(nameBuildCount, equals(2)); // Name rebuilt
      expect(find.text('Name: updated'), findsOneWidget);
    });
  });
}

class TestState {
  final int counter;
  final String name;
  
  const TestState({required this.counter, required this.name});
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TestState &&
    runtimeType == other.runtimeType &&
    counter == other.counter &&
    name == other.name;
  
  @override
  int get hashCode => counter.hashCode ^ name.hashCode;
}