import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

// Import all story categories
import 'stories/components/components_stories.dart';
import 'stories/features/features_stories.dart';
import 'stories/layouts/layouts_stories.dart';
import 'stories/themes/themes_stories.dart';
import 'stories/integration/integration_stories.dart';
import 'stories/playground/playground_stories.dart';
import 'stories/use_cases/use_cases_stories.dart';
import 'stories/performance/performance_stories.dart';
import 'stories/documentation/documentation_stories.dart';

// Import legacy stories
import 'stories/models_story.dart';
import 'stories/grid_widget_story.dart';
import 'stories/placed_widget_story.dart';
import 'stories/grid_container_story.dart';
import 'stories/toolbox_widget_story.dart';

void main() {
  runApp(const StorybookApp());
}

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Storybook(
      initialStory: 'Welcome',
      plugins: [
        DeviceFramePlugin(),
      ],
      wrapperBuilder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: Scaffold(body: child),
      ),
      stories: [
        Story(
          name: 'Welcome',
          builder: (context) => const WelcomePage(),
        ),
        
        // Comprehensive story categories
        ...componentStories,
        ...featureStories,
        ...layoutStories,
        ...themesStories,
        ...integrationStories,
        ...playgroundStories,
        ...useCasesStories,
        ...performanceStories,
        ...documentationStories,
        
        // Legacy stories (keeping for backward compatibility)
        Story(
          name: 'Legacy/Divider',
          builder: (context) => const Divider(),
        ),
        ...modelStories,
        ...gridWidgetStories,
        ...placedWidgetStories,
        ...gridContainerStories,
        ...toolboxWidgetStories,
      ],
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const Icon(
              Icons.dashboard_customize,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'FormBuilder Storybook',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'A comprehensive drag-and-drop form builder for Flutter',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildFeatureCard(
              context,
              icon: Icons.widgets,
              title: 'Components',
              description: 'Explore individual form widgets and their properties',
              color: Colors.blue,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.touch_app,
              title: 'Features',
              description: 'Interactive demos of drag & drop, resize, and more',
              color: Colors.green,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.grid_on,
              title: 'Layouts',
              description: 'Common form layouts and arrangements',
              color: Colors.orange,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.palette,
              title: 'Themes',
              description: 'Visual customization and styling options',
              color: Colors.purple,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.integration_instructions,
              title: 'Integration',
              description: 'Complete examples with state management',
              color: Colors.teal,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.play_arrow,
              title: 'Playground',
              description: 'Interactive form builder with all features',
              color: Colors.indigo,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Getting Started',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Use the sidebar to navigate through different sections\n'
                      '• Each section contains interactive examples\n'
                      '• Code snippets are provided for all examples\n'
                      '• Use knobs to adjust properties in real-time\n'
                      '• Check the console for logged actions',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}

// Overview pages for each section
class ComponentsOverview extends StatelessWidget {
  const ComponentsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Components',
      description: 'Individual form widgets that can be placed in the grid',
      icon: Icons.widgets,
      color: Colors.blue,
      features: [
        'Text input fields with various configurations',
        'Selection widgets (dropdowns, checkboxes, radio buttons)',
        'Date and time pickers',
        'Buttons and actions',
        'Display elements (labels, dividers)',
        'Custom widget examples',
      ],
    );
  }
}

class FeaturesOverview extends StatelessWidget {
  const FeaturesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Features',
      description: 'Core functionality demonstrations',
      icon: Icons.touch_app,
      color: Colors.green,
      features: [
        'Drag and drop operations',
        'Widget resizing with handles',
        'Keyboard navigation',
        'Undo/redo functionality',
        'Preview mode toggle',
        'Import/export layouts',
      ],
    );
  }
}

class LayoutsOverview extends StatelessWidget {
  const LayoutsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Layouts',
      description: 'Common form arrangements and patterns',
      icon: Icons.grid_on,
      color: Colors.orange,
      features: [
        'Contact form layout',
        'Survey form layout',
        'Registration form layout',
        'Multi-column layouts',
        'Responsive grid examples',
        'Complex form patterns',
      ],
    );
  }
}

class ThemesOverview extends StatelessWidget {
  const ThemesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Themes',
      description: 'Visual customization options',
      icon: Icons.palette,
      color: Colors.purple,
      features: [
        'Light and dark themes',
        'Custom color schemes',
        'Material 3 theming',
        'Widget styling options',
        'Grid appearance customization',
        'Animation settings',
      ],
    );
  }
}

class IntegrationOverview extends StatelessWidget {
  const IntegrationOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Integration',
      description: 'Complete implementation examples',
      icon: Icons.integration_instructions,
      color: Colors.teal,
      features: [
        'State management integration',
        'Form validation',
        'Data persistence',
        'API integration',
        'Custom widget integration',
        'Real-world examples',
      ],
    );
  }
}

class PlaygroundOverview extends StatelessWidget {
  const PlaygroundOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Playground',
      description: 'Interactive form builder with all features enabled',
      icon: Icons.play_arrow,
      color: Colors.indigo,
      features: [
        'Full form builder interface',
        'All widget types available',
        'Save and load functionality',
        'Theme switching',
        'Export/import layouts',
        'Performance monitoring',
      ],
    );
  }
}

class UseCasesOverview extends StatelessWidget {
  const UseCasesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Use Cases',
      description: 'Real-world application examples',
      icon: Icons.business,
      color: Colors.red,
      features: [
        'Contact form builder',
        'Survey creator',
        'Dashboard designer',
        'Registration forms',
        'Feedback forms',
        'Order forms',
      ],
    );
  }
}

class PerformanceOverview extends StatelessWidget {
  const PerformanceOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Performance',
      description: 'Performance testing and optimization',
      icon: Icons.speed,
      color: Colors.amber,
      features: [
        'Large grid stress tests',
        'Many widgets example',
        'Rapid operations test',
        'Memory usage monitoring',
        'Frame rate analysis',
        'Optimization techniques',
      ],
    );
  }
}

class DocumentationOverview extends StatelessWidget {
  const DocumentationOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildOverviewPage(
      context,
      title: 'Documentation',
      description: 'Guides and API documentation',
      icon: Icons.book,
      color: Colors.grey,
      features: [
        'Getting started guide',
        'API reference',
        'Best practices',
        'Common patterns',
        'Troubleshooting',
        'Migration guides',
      ],
    );
  }
}

Widget _buildOverviewPage(
  BuildContext context, {
  required String title,
  required String description,
  required IconData icon,
  required Color color,
  required List<String> features,
}) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What\'s included:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Navigate to specific examples using the sidebar →',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}