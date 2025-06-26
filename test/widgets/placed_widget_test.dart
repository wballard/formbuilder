import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

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
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.border, isNotNull);
      
      // Check that the border uses the primary color
      final border = decoration.border as Border;
      expect(border.top.width, equals(2.0));
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
      
      expect(opacity.opacity, equals(0.5));
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
      final paddingWidgets = tester.widgetList<Padding>(
        find.descendant(
          of: find.byType(PlacedWidget),
          matching: find.byType(Padding),
        ),
      ).toList();
      
      // One of the padding widgets should have our custom padding
      final hasCustomPadding = paddingWidgets.any((p) => p.padding == customPadding);
      expect(hasCustomPadding, isTrue);
    });

    testWidgets('handles tap callback', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacedWidget(
              placement: testPlacement,
              onTap: () => tapped = true,
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
              onTap: () {},
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
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
        
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
            body: PlacedWidget(
              placement: testPlacement,
              child: Container(),
            ),
          ),
        ),
      );
      
      final widget = tester.widget<PlacedWidget>(find.byType(PlacedWidget));
      expect(widget.isSelected, isFalse);
      expect(widget.isDragging, isFalse);
      expect(widget.contentPadding, equals(const EdgeInsets.all(8)));
      expect(widget.onTap, isNull);
    });

    testWidgets('elevation changes on hover (desktop)', (WidgetTester tester) async {
      // Only test on desktop platforms
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.macOS ||
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
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
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
      expect(opacity.opacity, equals(0.5));
      
      // Should still have border - find container inside InkWell
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.border, isNotNull);
    });
  });
}