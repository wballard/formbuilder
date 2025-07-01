import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder_example/stories/toolbox_widget_story_drag.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

List<Story> get toolboxWidgetStories => [
  Story(
    name: 'Widgets/ToolboxWidget/Default',
    builder: (context) => const DefaultToolboxDemo(),
  ),
  Story(
    name: 'Widgets/ToolboxWidget/Horizontal Layout',
    builder: (context) => const HorizontalToolboxDemo(),
  ),
  Story(
    name: 'Widgets/ToolboxWidget/Custom Spacing',
    builder: (context) => const CustomSpacingToolboxDemo(),
  ),
  Story(
    name: 'Widgets/ToolboxWidget/Limited Items',
    builder: (context) => const LimitedItemsToolboxDemo(),
  ),
  Story(
    name: 'Widgets/ToolboxWidget/Single Item',
    builder: (context) => const SingleItemToolboxDemo(),
  ),
  Story(
    name: 'Widgets/ToolboxWidget/Drag and Drop',
    builder: (context) => const DragAndDropToolboxDemo(),
  ),
];

class DefaultToolboxDemo extends StatelessWidget {
  const DefaultToolboxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final toolbox = Toolbox.withDefaults();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Default ToolboxWidget'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbox on the left
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Toolbox',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: ToolboxWidget(toolbox: toolbox)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Description on the right
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Default ToolboxWidget',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'The ToolboxWidget displays available form widgets that can be dragged onto the form. '
                        'This shows the default vertical layout with all available widgets.',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Features:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('• Vertical layout (default)'),
                      const Text('• 8px spacing between items'),
                      const Text('• Cards with hover effects'),
                      const Text('• Tooltips showing widget names'),
                      const Text('• ${7} widgets available'),
                      const SizedBox(height: 16),
                      Text(
                        'Available Widgets:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...toolbox.items.map(
                        (item) => Text(
                          '• ${item.displayName} (${item.defaultWidth}x${item.defaultHeight})',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalToolboxDemo extends StatelessWidget {
  const HorizontalToolboxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final toolbox = Toolbox.withDefaults();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizontal ToolboxWidget'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbox at the top
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Toolbox (Horizontal)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ToolboxWidget(
                        toolbox: toolbox,
                        direction: Axis.horizontal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Description below
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horizontal Layout',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'The ToolboxWidget can be configured to use a horizontal layout, '
                        'which is useful when the toolbox is placed at the top or bottom of the form builder.',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Configuration:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('• direction: Axis.horizontal'),
                      const Text(
                        '• Wrapped in SingleChildScrollView for overflow',
                      ),
                      const Text('• Same spacing and styling as vertical'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ToolboxWidget(\n'
                          '  toolbox: toolbox,\n'
                          '  direction: Axis.horizontal,\n'
                          ')',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSpacingToolboxDemo extends StatelessWidget {
  const CustomSpacingToolboxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final toolbox = Toolbox.withDefaults();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Spacing ToolboxWidget'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Tight spacing toolbox
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Tight Spacing (4px)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ToolboxWidget(
                        toolbox: toolbox,
                        spacing: 4.0,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Default spacing toolbox
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Default Spacing (8px)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ToolboxWidget(toolbox: toolbox),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Loose spacing toolbox
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Loose Spacing (16px)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ToolboxWidget(
                        toolbox: toolbox,
                        spacing: 16.0,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LimitedItemsToolboxDemo extends StatelessWidget {
  const LimitedItemsToolboxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a toolbox with just a few essential items
    final limitedToolbox = Toolbox(
      items: [
        ToolboxItem(
          name: 'text_input',
          displayName: 'Text Input',
          toolboxBuilder: (context) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(8),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.text_fields, size: 20),
                SizedBox(width: 8),
                Text('Input'),
              ],
            ),
          ),
          gridBuilder: (context, placement) => Container(
            color: Colors.blue.withValues(alpha: 0.1),
            child: const Center(child: Text('Text Input')),
          ),
          defaultWidth: 2,
          defaultHeight: 1,
        ),
        ToolboxItem(
          name: 'button',
          displayName: 'Button',
          toolboxBuilder: (context) => Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(8),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_button, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text('Button', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          gridBuilder: (context, placement) => Container(
            color: Colors.blue,
            child: const Center(
              child: Text('Button', style: TextStyle(color: Colors.white)),
            ),
          ),
          defaultWidth: 1,
          defaultHeight: 1,
        ),
        ToolboxItem(
          name: 'label',
          displayName: 'Label',
          toolboxBuilder: (context) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(8),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.label_outline, size: 20),
                SizedBox(width: 8),
                Text('Label'),
              ],
            ),
          ),
          gridBuilder: (context, placement) => const Text('Label'),
          defaultWidth: 1,
          defaultHeight: 1,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limited Items ToolboxWidget'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Essential Tools',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: ToolboxWidget(toolbox: limitedToolbox)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Limited Items Toolbox',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sometimes you may want to provide a simplified toolbox with only essential widgets. '
                        'This example shows a toolbox with just the most commonly used form elements.',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Use Cases:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('• Beginner-friendly form builders'),
                      const Text('• Quick prototyping'),
                      const Text('• Specific use case applications'),
                      const Text('• Mobile interfaces with limited space'),
                      const SizedBox(height: 16),
                      Text(
                        'This toolbox includes:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...limitedToolbox.items.map(
                        (item) => Text('• ${item.displayName}'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SingleItemToolboxDemo extends StatelessWidget {
  const SingleItemToolboxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final singleItemToolbox = Toolbox(
      items: [
        ToolboxItem(
          name: 'custom_widget',
          displayName: 'Custom Widget',
          toolboxBuilder: (context) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.blue.shade300],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.extension, size: 24, color: Colors.white),
                SizedBox(height: 4),
                Text(
                  'Custom',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          gridBuilder: (context, placement) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.blue.shade300],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'Custom Widget',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          defaultWidth: 2,
          defaultHeight: 2,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Item ToolboxWidget'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Single Item',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: ToolboxWidget(toolbox: singleItemToolbox)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Single Item Toolbox',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'The ToolboxWidget handles edge cases gracefully, including toolboxes with just a single item. '
                        'This example shows a custom widget with gradient styling.',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Features Demonstrated:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('• Custom toolbox builders with gradients'),
                      const Text('• Single item layout'),
                      const Text('• Custom icons and styling'),
                      const Text('• Larger default size (2x2)'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ToolboxItem(\n'
                          '  name: \'custom_widget\',\n'
                          '  displayName: \'Custom Widget\',\n'
                          '  toolboxBuilder: (context) => Container(\n'
                          '    decoration: BoxDecoration(\n'
                          '      gradient: LinearGradient(...),\n'
                          '    ),\n'
                          '    child: ...,\n'
                          '  ),\n'
                          '  defaultWidth: 2,\n'
                          '  defaultHeight: 2,\n'
                          ')',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
