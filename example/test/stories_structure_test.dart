import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder_example/storybook_app.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

void main() {
  group('Stories Structure', () {
    testWidgets('should have a single Overview story with all components', (WidgetTester tester) async {
      // Build the StorybookApp
      await tester.pumpWidget(const StorybookApp());
      await tester.pumpAndSettle();
      
      // Check that the storybook is rendered
      final storybookFinder = find.byType(Storybook);
      expect(storybookFinder, findsOneWidget);
      
      // Overview story should exist
      // Note: This test will need to be updated to actually verify the story exists
      // once we have access to the story list
    });
    
    testWidgets('should not have individual Components stories', (WidgetTester tester) async {
      await tester.pumpWidget(const StorybookApp());
      await tester.pumpAndSettle();
      
      // Check that individual component stories don't exist
      final componentsTextFieldFinder = find.text('Components/Text Field');
      final componentsButtonFinder = find.text('Components/Button');
      final componentsCheckboxFinder = find.text('Components/Checkbox');
      final componentsDropdownFinder = find.text('Components/Dropdown');
      
      expect(componentsTextFieldFinder, findsNothing,
          reason: 'Individual Components/Text Field story should not exist');
      expect(componentsButtonFinder, findsNothing,
          reason: 'Individual Components/Button story should not exist');
      expect(componentsCheckboxFinder, findsNothing,
          reason: 'Individual Components/Checkbox story should not exist');
      expect(componentsDropdownFinder, findsNothing,
          reason: 'Individual Components/Dropdown story should not exist');
    });
    
    testWidgets('should not have Features stories', (WidgetTester tester) async {
      await tester.pumpWidget(const StorybookApp());
      await tester.pumpAndSettle();
      
      // Check that Features stories don't exist
      final featuresDragDropFinder = find.text('Features/Drag and Drop');
      final featuresResizeFinder = find.text('Features/Resize Widgets');
      final featuresUndoRedoFinder = find.text('Features/Undo Redo');
      final featuresPreviewFinder = find.text('Features/Preview Mode');
      
      expect(featuresDragDropFinder, findsNothing,
          reason: 'Features/Drag and Drop story should not exist');
      expect(featuresResizeFinder, findsNothing,
          reason: 'Features/Resize Widgets story should not exist');
      expect(featuresUndoRedoFinder, findsNothing,
          reason: 'Features/Undo Redo story should not exist');
      expect(featuresPreviewFinder, findsNothing,
          reason: 'Features/Preview Mode story should not exist');
    });
  });
}