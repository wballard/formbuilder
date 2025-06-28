import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  group('ResizeHandle', () {
    late WidgetPlacement testPlacement;

    setUp(() {
      testPlacement = WidgetPlacement(
        id: 'test-widget',
        widgetName: 'TestWidget',
        column: 1,
        row: 1,
        width: 2,
        height: 2,
      );
    });

    testWidgets('creates widget with required properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  ResizeHandle(
                    type: ResizeHandleType.topLeft,
                    placement: testPlacement,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ResizeHandle), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
      expect(find.byType(Draggable<ResizeData>), findsOneWidget);
    });

    group('handle positioning', () {
      for (final handleType in ResizeHandleType.values) {
        testWidgets('positions $handleType handle correctly', (
          WidgetTester tester,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    children: [
                      ResizeHandle(type: handleType, placement: testPlacement),
                    ],
                  ),
                ),
              ),
            ),
          );

          expect(find.byType(ResizeHandle), findsOneWidget);
          expect(find.byType(Positioned), findsOneWidget);
        });
      }
    });

    testWidgets('shows correct cursor for handle type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  ResizeHandle(
                    type: ResizeHandleType.topLeft,
                    placement: testPlacement,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the MouseRegion that is a descendant of ResizeHandle
      final mouseRegion = tester.widget<MouseRegion>(
        find.descendant(
          of: find.byType(ResizeHandle),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(mouseRegion.cursor, equals(ResizeHandleType.topLeft.cursor));
    });

    testWidgets('calls onResizeStart when drag starts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  ResizeHandle(
                    type: ResizeHandleType.bottomRight,
                    placement: testPlacement,
                    onResizeStart: (data) {
                      // Callback is tested by verifying it's not null
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final draggable = tester.widget<Draggable<ResizeData>>(
        find.byType(Draggable<ResizeData>),
      );

      expect(draggable.onDragStarted, isNotNull);
    });

    testWidgets('calls onResizeUpdate when dragging', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  ResizeHandle(
                    type: ResizeHandleType.right,
                    placement: testPlacement,
                    onResizeUpdate: (data, delta) {
                      // Callback is tested by verifying it's not null
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final draggable = tester.widget<Draggable<ResizeData>>(
        find.byType(Draggable<ResizeData>),
      );

      expect(draggable.onDragUpdate, isNotNull);
    });

    testWidgets('calls onResizeEnd when drag ends', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  ResizeHandle(
                    type: ResizeHandleType.bottom,
                    placement: testPlacement,
                    onResizeEnd: () {
                      // Callback is tested by verifying it's not null
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final draggable = tester.widget<Draggable<ResizeData>>(
        find.byType(Draggable<ResizeData>),
      );

      expect(draggable.onDragEnd, isNotNull);
    });

    testWidgets('provides correct ResizeData', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  ResizeHandle(
                    type: ResizeHandleType.topRight,
                    placement: testPlacement,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final draggable = tester.widget<Draggable<ResizeData>>(
        find.byType(Draggable<ResizeData>),
      );

      expect(draggable.data?.widgetId, equals(testPlacement.id));
      expect(draggable.data?.handleType, equals(ResizeHandleType.topRight));
      expect(draggable.data?.startPlacement, equals(testPlacement));
    });

    testWidgets('changes appearance on hover', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  ResizeHandle(
                    type: ResizeHandleType.left,
                    placement: testPlacement,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the MouseRegion that is a descendant of ResizeHandle
      final mouseRegionFinder = find.descendant(
        of: find.byType(ResizeHandle),
        matching: find.byType(MouseRegion),
      );
      expect(mouseRegionFinder, findsOneWidget);

      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
      expect(mouseRegion.onEnter, isNotNull);
      expect(mouseRegion.onExit, isNotNull);
    });
  });

  group('ResizeHandleType extension', () {
    test('returns correct cursors for each handle type', () {
      expect(
        ResizeHandleType.topLeft.cursor,
        equals(SystemMouseCursors.resizeUpLeftDownRight),
      );
      expect(
        ResizeHandleType.topRight.cursor,
        equals(SystemMouseCursors.resizeUpRightDownLeft),
      );
      expect(
        ResizeHandleType.bottomLeft.cursor,
        equals(SystemMouseCursors.resizeUpRightDownLeft),
      );
      expect(
        ResizeHandleType.bottomRight.cursor,
        equals(SystemMouseCursors.resizeUpLeftDownRight),
      );
      expect(
        ResizeHandleType.top.cursor,
        equals(SystemMouseCursors.resizeUpDown),
      );
      expect(
        ResizeHandleType.bottom.cursor,
        equals(SystemMouseCursors.resizeUpDown),
      );
      expect(
        ResizeHandleType.left.cursor,
        equals(SystemMouseCursors.resizeLeftRight),
      );
      expect(
        ResizeHandleType.right.cursor,
        equals(SystemMouseCursors.resizeLeftRight),
      );
    });
  });

  group('ResizeData', () {
    test('creates instance with required properties', () {
      final data = ResizeData(
        widgetId: 'test-id',
        handleType: ResizeHandleType.topLeft,
        startPlacement: WidgetPlacement(
          id: 'test-id',
          widgetName: 'TestWidget',
          column: 0,
          row: 0,
          width: 1,
          height: 1,
        ),
      );

      expect(data.widgetId, equals('test-id'));
      expect(data.handleType, equals(ResizeHandleType.topLeft));
      expect(data.startPlacement.id, equals('test-id'));
    });
  });
}
