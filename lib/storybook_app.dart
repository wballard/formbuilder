import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'stories/models_story.dart';
import 'stories/grid_widget_story.dart';
import 'stories/placed_widget_story.dart';

void main() {
  runApp(const StorybookApp());
}

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Storybook(
      initialStory: 'Welcome',
      stories: [
        Story(
          name: 'Welcome',
          builder: (context) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FormLayout Storybook',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'A drag and drop form builder for Flutter',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 32),
                Text(
                  'Use the sidebar to navigate through components and examples',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        ...modelStories,
        ...gridWidgetStories,
        ...placedWidgetStories,
      ],
    );
  }
}