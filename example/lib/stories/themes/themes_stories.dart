import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

final List<Story> themesStories = [
  Story(
    name: 'Themes/Coming Soon',
    description: 'Theme stories are being prepared',
    builder: (context) => const ComingSoonThemesDemo(),
  ),
];

class ComingSoonThemesDemo extends StatelessWidget {
  const ComingSoonThemesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes Stories'),
        backgroundColor: Colors.purple.withValues(alpha: 0.1),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.palette,
                size: 80,
                color: Colors.purple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Themes Stories',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Interactive theme examples are coming soon.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'These stories will demonstrate theme capabilities once the story API is fully aligned with the FormBuilder implementation.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}