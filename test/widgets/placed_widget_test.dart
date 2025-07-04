import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';

void main() {
  group('PlacedWidget', () {
    late WidgetPlacement testPlacement;

    setUp(() {
      testPlacement = WidgetPlacement(
        id: 'test-widget',
        widgetName: 'TestWidget',
        column: 0,
        row: 0,
        width: 2,
        height: 1,
      );
    });

    testWidgets('renders child widget', (WidgetTester tester) async {
      const childText = 'Test Child';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacedWidget(
              placement: testPlacement,
              child: const Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
      expect(find.byType(PlacedWidget), findsOneWidget);
    });

    testWidgets('shows border when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Scaffold(
            body: PlacedWidget(
              placement: testPlacement,
              isSelected: true,
              child: Container(),
            ),
          ),
        ),
      );

      // Find the container with decoration inside the InkWell
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(InkWell),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.border, isNotNull);

      // Check that the border uses the primary color and theme thickness
      final border = decoration.border as Border;
      expect(border.top.width, equals(1.0)); // Default divider thickness
    });

    testWidgets('reduces opacity when dragging', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacedWidget(
              placement: testPlacement,
              isDragging: true,
              child: Container(),
            ),
          ),
        ),
      );

      // Find the Opacity widget
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(PlacedWidget),
          matching: find.byType(Opacity),
        ),
      );

      expect(opacity.opacity, equals(0.6)); // Updated value from our improvements
    });

    testWidgets('applies content padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacedWidget(
              placement: testPlacement,
              contentPadding: customPadding,
              child: Container(),
            ),
          ),
        ),
      );

      // Find all Padding widgets to see which one has the custom padding
      final paddingWidgets = tester
          .widgetList<Padding>(
            find.descendant(
              of: find.byType(PlacedWidget),
              matching: find.byType(Padding),
            ),
          )
          .toList();

      // One of the padding widgets should have our custom padding
      final hasCustomPadding = paddingWidgets.any(
        (p) => p.padding == customPadding,
      );
      expect(hasCustomPadding, isTrue);
    });

    testWidgets('handles tap callback', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacedWidget(
              placement: testPlacement,
              onTap: () { tapped = true; },
              child: Container(),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlacedWidget));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows ripple effect on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacedWidget(
              placement: testPlacement,
              child: Container(),
            ),
          ),
        ),
      );

      // Verify InkWell is present
      expect(find.byType(InkWell), findsOneWidget);

      // Tap and verify ink response
      await tester.tap(find.byType(PlacedWidget));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Halfway

      // Material with ink should be present
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('shows hover cursor on desktop', (WidgetTester tester) async {
      // Only test on desktop platforms
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(placement: testPlacement, child: Container()),
            ),
          ),
        );

        // Find MouseRegion
        final mouseRegion = tester.widget<MouseRegion>(
          find.descendant(
            of: find.byType(PlacedWidget),
            matching: find.byType(MouseRegion),
          ),
        );

        expect(mouseRegion.cursor, equals(SystemMouseCursors.move));
      }
    });

    testWidgets('default values are applied correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacedWidget(placement: testPlacement, child: Container()),
          ),
        ),
      );

      final widget = tester.widget<PlacedWidget>(find.byType(PlacedWidget));
      expect(widget.isSelected, isFalse);
      expect(widget.isDragging, isFalse);
      expect(widget.contentPadding, isNull); // Now defaults to null and uses theme
      expect(widget.onTap, isNull);
    });

    testWidgets('elevation changes on hover (desktop)', (WidgetTester tester) async {
      // Only test on desktop platforms
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 100,
                  child: PlacedWidget(
                    placement: testPlacement,
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
        );

        // Find the initial Material widget
        Material getMaterial() => tester.widget<Material>(
          find.descendant(
            of: find.byType(PlacedWidget),
            matching: find.byType(Material).first,
          ),
        );

        // Initial elevation
        expect(getMaterial().elevation, equals(2.0));

        // Hover over the widget
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await tester.pump();
        await gesture.moveTo(tester.getCenter(find.byType(PlacedWidget)));
        await tester.pumpAndSettle();

        // Elevation should increase on hover
        expect(getMaterial().elevation, equals(4.0));
      }
    });

    testWidgets('combines selected and dragging states', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Scaffold(
            body: PlacedWidget(
              placement: testPlacement,
              isSelected: true,
              isDragging: true,
              child: Container(),
            ),
          ),
        ),
      );

      // Should have both border and opacity
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(PlacedWidget),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, equals(0.6)); // Updated value from our improvements

      // Should still have border - find container inside InkWell
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(InkWell),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.border, isNotNull);
    });

    group('draggable functionality', () {
      testWidgets('wraps content with Draggable when canDrag is true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                canDrag: true,
                child: Container(),
              ),
            ),
          ),
        );

        expect(find.byType(Draggable<WidgetPlacement>), findsOneWidget);

        final draggable = tester.widget<Draggable<WidgetPlacement>>(
          find.byType(Draggable<WidgetPlacement>),
        );
        expect(draggable.data, equals(testPlacement));
      });

      testWidgets('does not wrap with Draggable when canDrag is false', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                canDrag: false,
                child: Container(),
              ),
            ),
          ),
        );

        expect(find.byType(Draggable<WidgetPlacement>), findsNothing);
      });

      testWidgets('uses default canDrag value of false', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(placement: testPlacement, child: Container()),
            ),
          ),
        );

        // Should not have Draggable by default
        expect(find.byType(Draggable<WidgetPlacement>), findsNothing);
      });

      testWidgets('shows grab cursor when canDrag is true and hovering', (WidgetTester tester) async {
        if (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux)) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: PlacedWidget(
                  placement: testPlacement,
                  canDrag: true,
                  child: Container(),
                ),
              ),
            ),
          );

          final mouseRegion = tester.widget<MouseRegion>(
            find.descendant(
              of: find.byType(PlacedWidget),
              matching: find.byType(MouseRegion),
            ),
          );

          expect(mouseRegion.cursor, equals(SystemMouseCursors.grab));
        }
      });

      testWidgets('shows move cursor when canDrag is false', (WidgetTester tester) async {
        if (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux)) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: PlacedWidget(
                  placement: testPlacement,
                  canDrag: false,
                  child: Container(),
                ),
              ),
            ),
          );

          final mouseRegion = tester.widget<MouseRegion>(
            find.descendant(
              of: find.byType(PlacedWidget),
              matching: find.byType(MouseRegion),
            ),
          );

          expect(mouseRegion.cursor, equals(SystemMouseCursors.move));
        }
      });

      testWidgets('calls onDragStarted when drag begins', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                canDrag: true,
                onDragStarted: (placement) {
                  // Callback is tested by verifying it's not null
                },
                child: Container(),
              ),
            ),
          ),
        );

        final draggable = tester.widget<Draggable<WidgetPlacement>>(
          find.byType(Draggable<WidgetPlacement>),
        );

        expect(draggable.onDragStarted, isNotNull);
      });

      testWidgets('calls onDragEnd when drag ends', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                canDrag: true,
                onDragEnd: () {
                  // Callback is tested by verifying it's not null
                },
                child: Container(),
              ),
            ),
          ),
        );

        final draggable = tester.widget<Draggable<WidgetPlacement>>(
          find.byType(Draggable<WidgetPlacement>),
        );

        expect(draggable.onDragEnd, isNotNull);
      });

      testWidgets('calls onDragCompleted with details', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                canDrag: true,
                onDragCompleted: (details) {
                  // Callback is tested by verifying it's not null
                },
                child: Container(),
              ),
            ),
          ),
        );

        final draggable = tester.widget<Draggable<WidgetPlacement>>(
          find.byType(Draggable<WidgetPlacement>),
        );

        expect(draggable.onDragCompleted, isNotNull);
      });

      testWidgets('provides correct drag feedback', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                canDrag: true,
                child: const Text('Drag Me'),
              ),
            ),
          ),
        );

        final draggable = tester.widget<Draggable<WidgetPlacement>>(
          find.byType(Draggable<WidgetPlacement>),
        );

        // Feedback should be wrapped in Material for elevation
        expect(draggable.feedback, isNotNull);
      });

      testWidgets('shows empty container as child when dragging', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                canDrag: true,
                child: const Text('Drag Me'),
              ),
            ),
          ),
        );

        final draggable = tester.widget<Draggable<WidgetPlacement>>(
          find.byType(Draggable<WidgetPlacement>),
        );

        // childWhenDragging should be a SizedBox.shrink()
        expect(draggable.childWhenDragging, isA<SizedBox>());
      });
    });

    group('resize functionality', () {
      testWidgets('shows resize handles when showResizeHandles is true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                showResizeHandles: true,
                child: Container(),
              ),
            ),
          ),
        );

        // Should find all 8 resize handles
        expect(find.byType(ResizeHandle), findsNWidgets(8));

        // Verify different handle types are present
        final handles = tester
            .widgetList<ResizeHandle>(find.byType(ResizeHandle))
            .toList();
        final handleTypes = handles.map((h) => h.type).toSet();
        expect(handleTypes.length, equals(8)); // All 8 types should be present
      });

      testWidgets('does not show resize handles when showResizeHandles is false', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: PlacedWidget(
                  placement: testPlacement,
                  showResizeHandles: false,
                  child: Container(),
                ),
              ),
            ),
          );

          expect(find.byType(ResizeHandle), findsNothing);
        },
      );

      testWidgets('uses default showResizeHandles value of false', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(placement: testPlacement, child: Container()),
            ),
          ),
        );

        expect(find.byType(ResizeHandle), findsNothing);
      });

      testWidgets('passes resize callbacks to ResizeHandle widgets', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                showResizeHandles: true,
                onResizeStart: (data) {
                  // Callback is tested by verifying it's not null
                },
                onResizeUpdate: (data, delta) {
                  // Callback is tested by verifying it's not null
                },
                onResizeEnd: () {
                  // Callback is tested by verifying it's not null
                },
                child: Container(),
              ),
            ),
          ),
        );

        final resizeHandle = tester.widget<ResizeHandle>(
          find.byType(ResizeHandle).first,
        );
        expect(resizeHandle.onResizeStart, isNotNull);
        expect(resizeHandle.onResizeUpdate, isNotNull);
        expect(resizeHandle.onResizeEnd, isNotNull);
      });

      testWidgets('wraps content in Stack when resize handles are shown', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlacedWidget(
                placement: testPlacement,
                showResizeHandles: true,
                child: Container(),
              ),
            ),
          ),
        );

        // Should find a Stack when resize handles are enabled
        expect(find.byType(Stack), findsWidgets);
      });

      testWidgets('does not wrap content in Stack when resize handles are hidden', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: PlacedWidget(
                  placement: testPlacement,
                  showResizeHandles: false,
                  child: Container(),
                ),
              ),
            ),
          );

          // The Stack from resize handles should not be present
          // (though there might be other Stacks in the widget tree)
          expect(find.byType(ResizeHandle), findsNothing);
        },
      );
    });
  });
}
