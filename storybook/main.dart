import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'stories/form_layout_stories.dart';

void main() {
  runApp(const StorybookApp());
}

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Storybook(
      initialStory: 'Form Layout/Default',
      stories: [...getFormLayoutStories()],
    );
  }
}
