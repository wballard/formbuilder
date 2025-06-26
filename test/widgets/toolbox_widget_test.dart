import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';

void main() {
  group('ToolboxWidget', () {
    late Toolbox testToolbox;

    setUp(() {
      testToolbox = Toolbox.withDefaults();
    });

    testWidgets('displays all toolbox items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: testToolbox),
          ),
        ),
      );

      // Verify all items are displayed
      expect(find.byType(ToolboxWidget), findsOneWidget);
      
      // Check that we have the expected number of cards
      expect(find.byType(Card), findsNWidgets(testToolbox.items.length));
      
      // Verify each item's display name is shown in the item labels (not just in toolbox builders)
      // Use a more specific finder to avoid conflicts with text in toolbox builders
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final itemNames = testToolbox.items.map((item) => item.displayName).toSet();
      
      // Count how many Text widgets contain each item name
      for (final itemName in itemNames) {
        final matchingTexts = textWidgets.where((text) => text.data == itemName).length;
        expect(matchingTexts, greaterThanOrEqualTo(1), reason: 'Should find at least one Text widget for $itemName');
      }
    });

    testWidgets('applies vertical layout by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: testToolbox),
          ),
        ),
      );

      final wrapWidget = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrapWidget.direction, equals(Axis.vertical));
    });

    testWidgets('applies horizontal layout when specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(
              toolbox: testToolbox,
              direction: Axis.horizontal,
            ),
          ),
        ),
      );

      final wrapWidget = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrapWidget.direction, equals(Axis.horizontal));
    });

    testWidgets('applies custom spacing', (WidgetTester tester) async {
      const customSpacing = 16.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(
              toolbox: testToolbox,
              spacing: customSpacing,
            ),
          ),
        ),
      );

      final wrapWidget = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrapWidget.spacing, equals(customSpacing));
      expect(wrapWidget.runSpacing, equals(customSpacing));
    });

    testWidgets('applies custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(16.0);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(
              toolbox: testToolbox,
              padding: customPadding,
            ),
          ),
        ),
      );

      // Find the padding widget and verify it has the expected padding
      final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));
      expect(paddingWidgets.any((p) => p.padding == customPadding), isTrue);
    });

    testWidgets('uses default values when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: testToolbox),
          ),
        ),
      );

      final toolboxWidget = tester.widget<ToolboxWidget>(find.byType(ToolboxWidget));
      expect(toolboxWidget.direction, equals(Axis.vertical));
      expect(toolboxWidget.spacing, equals(8.0));
      expect(toolboxWidget.padding, equals(const EdgeInsets.all(8)));
    });

    testWidgets('items have consistent sizing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: testToolbox),
          ),
        ),
      );

      // Find all SizedBox widgets that should contain our items
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      
      // Filter for item containers (width 100)
      final itemContainers = sizedBoxes.where((box) => box.width == 100).toList();
      expect(itemContainers.length, equals(testToolbox.items.length));
      
      // Verify each item container has consistent sizing
      for (final box in itemContainers) {
        expect(box.width, equals(100));
      }
    });

    testWidgets('items have tooltips with display names', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: testToolbox),
          ),
        ),
      );

      // Verify tooltips exist
      expect(find.byType(Tooltip), findsNWidgets(testToolbox.items.length));
      
      // Check that each tooltip has the correct message
      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      final expectedMessages = testToolbox.items.map((item) => item.displayName).toSet();
      final actualMessages = tooltips.map((tooltip) => tooltip.message).toSet();
      
      expect(actualMessages, equals(expectedMessages));
    });

    testWidgets('cards have correct elevation styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: testToolbox),
          ),
        ),
      );

      // Verify cards have default elevation
      final cards = tester.widgetList<Card>(find.byType(Card));
      for (final card in cards) {
        expect(card.elevation, equals(2));
      }

      // Verify cards have rounded corners
      for (final card in cards) {
        expect(card.shape, isA<RoundedRectangleBorder>());
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(8.0)));
      }
    });

    testWidgets('handles empty toolbox gracefully', (WidgetTester tester) async {
      final emptyToolbox = Toolbox(items: []);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: emptyToolbox),
          ),
        ),
      );

      expect(find.byType(ToolboxWidget), findsOneWidget);
      expect(find.byType(Card), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles single item toolbox', (WidgetTester tester) async {
      final singleItemToolbox = Toolbox(items: [
        ToolboxItem(
          name: 'test_item',
          displayName: 'Test Item',
          toolboxBuilder: (context) => const Icon(Icons.widgets),
          gridBuilder: (context, placement) => const Text('Test'),
          defaultWidth: 1,
          defaultHeight: 1,
        ),
      ]);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: singleItemToolbox),
          ),
        ),
      );

      expect(find.byType(ToolboxWidget), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Test Item'), findsOneWidget);
      expect(find.byIcon(Icons.widgets), findsOneWidget);
    });

    testWidgets('text truncates when too long', (WidgetTester tester) async {
      final longNameToolbox = Toolbox(items: [
        ToolboxItem(
          name: 'long_name_item',
          displayName: 'This is a very long display name that should truncate',
          toolboxBuilder: (context) => const Icon(Icons.text_fields),
          gridBuilder: (context, placement) => const Text('Long'),
          defaultWidth: 1,
          defaultHeight: 1,
        ),
      ]);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolboxWidget(toolbox: longNameToolbox),
          ),
        ),
      );

      // Find the text widget displaying the name
      final textWidget = tester.widget<Text>(
        find.text('This is a very long display name that should truncate'),
      );
      
      expect(textWidget.maxLines, equals(2));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      expect(textWidget.textAlign, equals(TextAlign.center));
    });

    group('hover effects', () {
      testWidgets('cards have hover region', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ToolboxWidget(toolbox: testToolbox),
            ),
          ),
        );

        // Verify MouseRegion widgets exist for hover effects (should be at least as many as items)
        expect(find.byType(MouseRegion), findsAtLeastNWidgets(testToolbox.items.length));
      });

      testWidgets('cards have animated containers for hover effects', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ToolboxWidget(toolbox: testToolbox),
            ),
          ),
        );

        // Verify AnimatedContainer widgets exist for smooth transitions
        expect(find.byType(AnimatedContainer), findsAtLeastNWidgets(testToolbox.items.length));
        
        // Check animation duration
        final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
        for (final container in animatedContainers) {
          expect(container.duration, equals(const Duration(milliseconds: 200)));
        }
      });
    });
  });
}