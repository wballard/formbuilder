import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder_example/storybook_app.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

void main() {
  group('StorybookApp', () {
    testWidgets('should not contain Legacy/Divider story', (WidgetTester tester) async {
      // Build the StorybookApp
      await tester.pumpWidget(const StorybookApp());
      
      // Wait for the widget to build completely
      await tester.pumpAndSettle();
      
      // Check that the storybook is rendered
      final storybookFinder = find.byType(Storybook);
      expect(storybookFinder, findsOneWidget);
      
      // Check that no Legacy/Divider text exists in the story list
      final legacyDividerFinder = find.text('Legacy/Divider');
      expect(legacyDividerFinder, findsNothing, 
          reason: 'Legacy/Divider story should be removed from the storybook');
    });
  });
}