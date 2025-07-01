import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

final List<Story> layoutStories = [
  Story(
    name: 'Layouts/Contact Form',
    description: 'Common contact form layout pattern',
    builder: (context) => const ContactFormLayoutDemo(),
  ),
  Story(
    name: 'Layouts/Survey Form',
    description: 'Survey/questionnaire layout pattern',
    builder: (context) => const SurveyFormLayoutDemo(),
  ),
  Story(
    name: 'Layouts/Registration Form',
    description: 'User registration form layout',
    builder: (context) => const RegistrationFormLayoutDemo(),
  ),
];

class ContactFormLayoutDemo extends StatelessWidget {
  const ContactFormLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildLayoutDemo(
      title: 'Contact Form Layout',
      description: 'A typical contact form with name, email, subject, and message fields.',
      layoutDescription: 'Standard vertical layout with grouped related fields.',
    );
  }
}

class SurveyFormLayoutDemo extends StatelessWidget {
  const SurveyFormLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildLayoutDemo(
      title: 'Survey Form Layout',
      description: 'Survey form with multiple question types and sections.',
      layoutDescription: 'Sectioned layout with different question types and clear grouping.',
    );
  }
}

class RegistrationFormLayoutDemo extends StatelessWidget {
  const RegistrationFormLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildLayoutDemo(
      title: 'Registration Form Layout',
      description: 'User registration with personal info, credentials, and preferences.',
      layoutDescription: 'Multi-section form with logical field grouping and validation.',
    );
  }
}

Widget _buildLayoutDemo({
  required String title,
  required String description,
  required String layoutDescription,
}) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.orange.withValues(alpha: 0.1),
    ),
    body: Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_on,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layout Pattern:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(layoutDescription),
                  const SizedBox(height: 16),
                  const Text(
                    'Coming Soon:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Interactive layout examples will be added once the story API is fully aligned with the FormBuilder implementation.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}