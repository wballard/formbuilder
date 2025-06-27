import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/virtual_grid.dart';
import 'dart:math';

void main() {
  group('VirtualGrid', () {
    testWidgets('should only render visible cells', (tester) async {
      const gridSize = 1000; // Large grid
      int cellBuilderCallCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: WidgetVirtualGrid(
                dimensions: VirtualGridDimensions(columns: gridSize, rows: gridSize),
                cellSize: const Size(50, 50),
                cellBuilder: (context, x, y) {
                  cellBuilderCallCount++;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Text('$x,$y'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should only render visible cells, not all 1,000,000 cells
      expect(cellBuilderCallCount, lessThan(100));
      expect(cellBuilderCallCount, greaterThan(0));
      
      // Should find some cells in the viewport
      expect(find.text('0,0'), findsOneWidget);
    });

    testWidgets('should handle scrolling correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: WidgetVirtualGrid(
                dimensions: const VirtualGridDimensions(columns: 100, rows: 100),
                cellSize: const Size(50, 50),
                cellBuilder: (context, x, y) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Text('$x,$y'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      expect(find.text('0,0'), findsOneWidget);
      
      // Scroll and check new cells are rendered
      await tester.drag(find.byType(WidgetVirtualGrid), const Offset(-200, -150));
      await tester.pumpAndSettle();
      
      // Should now see different cells
      expect(find.text('0,0'), findsNothing);
      expect(find.text('4,3'), findsOneWidget);
    });

    testWidgets('should handle dynamic cell updates', (tester) async {
      final cellData = ValueNotifier<Map<Point<int>, String>>({
        const Point(0, 0): 'A',
        const Point(1, 1): 'B',
      });
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: ValueListenableBuilder<Map<Point<int>, String>>(
                valueListenable: cellData,
                builder: (context, data, child) {
                  return WidgetVirtualGrid(
                    dimensions: const VirtualGridDimensions(columns: 10, rows: 10),
                    cellSize: const Size(50, 50),
                    cellBuilder: (context, x, y) {
                      final point = Point(x, y);
                      final content = data[point] ?? '$x,$y';
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: data.containsKey(point) ? Colors.yellow : Colors.white,
                        ),
                        child: Center(
                          child: Text(content),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      
      // Update cell data
      cellData.value = {
        ...cellData.value,
        const Point(2, 2): 'C',
      };
      await tester.pump();
      
      expect(find.text('C'), findsOneWidget);
    });
  });

  group('LazyGridCell', () {
    testWidgets('should lazy load cell content', (tester) async {
      bool contentLoaded = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyGridCell(
              cellKey: 'test-cell',
              builder: () {
                contentLoaded = true;
                return const Text('Loaded Content');
              },
              placeholder: const Text('Loading...'),
            ),
          ),
        ),
      );
      
      // Initially should show placeholder
      expect(find.text('Loading...'), findsOneWidget);
      expect(contentLoaded, isFalse);
      
      // Wait for lazy loading
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.text('Loaded Content'), findsOneWidget);
      expect(contentLoaded, isTrue);
    });

    testWidgets('should cache loaded content', (tester) async {
      int buildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyGridCell(
              cellKey: 'cache-test',
              builder: () {
                buildCount++;
                return Text('Built $buildCount times');
              },
            ),
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Built 1 times'), findsOneWidget);
      
      // Rebuild widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyGridCell(
              cellKey: 'cache-test',
              builder: () {
                buildCount++;
                return Text('Built $buildCount times');
              },
            ),
          ),
        ),
      );
      
      await tester.pump();
      
      // Should still show cached content
      expect(find.text('Built 1 times'), findsOneWidget);
      expect(buildCount, equals(1));
    });
  });

  group('GridViewportCalculator', () {
    test('should calculate visible cells correctly', () {
      const calculator = GridViewportCalculator();
      
      const viewport = Rect.fromLTWH(100, 50, 400, 300);
      const cellSize = Size(50, 50);
      
      final visibleCells = calculator.getVisibleCells(viewport, cellSize);
      
      // Should include cells that are partially visible
      expect(visibleCells.startColumn, equals(2)); // 100 / 50 = 2
      expect(visibleCells.startRow, equals(1)); // 50 / 50 = 1
      expect(visibleCells.endColumn, equals(10)); // (100 + 400) / 50 = 10
      expect(visibleCells.endRow, equals(7)); // (50 + 300) / 50 = 7
    });

    test('should handle edge cases', () {
      const calculator = GridViewportCalculator();
      
      // Test with zero viewport
      const zeroViewport = Rect.fromLTWH(0, 0, 0, 0);
      const cellSize = Size(50, 50);
      
      final zeroCells = calculator.getVisibleCells(zeroViewport, cellSize);
      expect(zeroCells.startColumn, equals(0));
      expect(zeroCells.startRow, equals(0));
      expect(zeroCells.endColumn, equals(0));
      expect(zeroCells.endRow, equals(0));
      
      // Test with very small cells
      const smallCellSize = Size(1, 1);
      const viewport = Rect.fromLTWH(0, 0, 100, 100);
      
      final manyCells = calculator.getVisibleCells(viewport, smallCellSize);
      expect(manyCells.endColumn - manyCells.startColumn, equals(100));
      expect(manyCells.endRow - manyCells.startRow, equals(100));
    });
  });

  group('VirtualGridController', () {
    test('should track scroll position', () {
      final controller = VirtualGridController();
      
      expect(controller.scrollX, equals(0.0));
      expect(controller.scrollY, equals(0.0));
      
      controller.scrollTo(100, 50);
      
      expect(controller.scrollX, equals(100.0));
      expect(controller.scrollY, equals(50.0));
    });

    test('should notify listeners on scroll', () {
      final controller = VirtualGridController();
      bool listenerCalled = false;
      
      controller.addListener(() {
        listenerCalled = true;
      });
      
      controller.scrollTo(100, 50);
      
      expect(listenerCalled, isTrue);
    });

    test('should dispose properly', () {
      final controller = VirtualGridController();
      
      void listener() {}
      
      controller.addListener(listener);
      controller.dispose();
      
      // Should not crash when scrolling after disposal
      expect(() => controller.scrollTo(100, 50), throwsA(isA<StateError>()));
    });
  });
}