import 'package:flutter_test/flutter_test.dart';

import 'package:formbuilder/main.dart';

void main() {
  testWidgets('FormBuilderApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FormBuilderApp());

    // Verify that the app shows the title
    expect(find.text('FormBuilder - Simple Demo'), findsOneWidget);

    // Verify that the demo info text is shown
    expect(find.text('This is a simple demo. For comprehensive examples, see the '), findsOneWidget);
  });
}
