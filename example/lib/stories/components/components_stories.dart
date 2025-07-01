import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

final List<Story> componentStories = [
  Story(
    name: 'Components/Text Field',
    description: 'Basic text input field demonstration',
    builder: (context) => const TextFieldStoryDemo(),
  ),
  Story(
    name: 'Components/Button',
    description: 'Button widget demonstration',
    builder: (context) => const ButtonStoryDemo(),
  ),
  Story(
    name: 'Components/Checkbox',
    description: 'Checkbox widget demonstration',
    builder: (context) => const CheckboxStoryDemo(),
  ),
  Story(
    name: 'Components/Dropdown',
    description: 'Dropdown widget demonstration',
    builder: (context) => const DropdownStoryDemo(),
  ),
];

// Simple story demonstration widgets
class TextFieldStoryDemo extends StatelessWidget {
  const TextFieldStoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildComponentDemo(
      title: 'Text Field Component',
      description: 'Demonstrates a basic text input field in the form builder',
      widgetName: 'text_field',
      icon: Icons.text_fields,
      builder: (placement) => Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: placement.properties['label'] as String? ?? 'Text Field',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

class ButtonStoryDemo extends StatelessWidget {
  const ButtonStoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildComponentDemo(
      title: 'Button Component',
      description: 'Demonstrates a button widget in the form builder',
      widgetName: 'button',
      icon: Icons.smart_button,
      builder: (placement) => Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: () {},
          child: Text(placement.properties['label'] as String? ?? 'Button'),
        ),
      ),
    );
  }
}

class CheckboxStoryDemo extends StatelessWidget {
  const CheckboxStoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildComponentDemo(
      title: 'Checkbox Component',
      description: 'Demonstrates a checkbox widget in the form builder',
      widgetName: 'checkbox',
      icon: Icons.check_box,
      builder: (placement) => Padding(
        padding: const EdgeInsets.all(8),
        child: CheckboxListTile(
          title: Text(placement.properties['label'] as String? ?? 'Checkbox'),
          value: placement.properties['checked'] as bool? ?? false,
          onChanged: (value) {},
        ),
      ),
    );
  }
}

class DropdownStoryDemo extends StatelessWidget {
  const DropdownStoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildComponentDemo(
      title: 'Dropdown Component',
      description: 'Demonstrates a dropdown widget in the form builder',
      widgetName: 'dropdown',
      icon: Icons.arrow_drop_down_circle,
      builder: (placement) => Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: placement.properties['label'] as String? ?? 'Dropdown',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 'option1', child: Text('Option 1')),
            DropdownMenuItem(value: 'option2', child: Text('Option 2')),
            DropdownMenuItem(value: 'option3', child: Text('Option 3')),
          ],
          onChanged: (value) {},
        ),
      ),
    );
  }
}

// Helper function to build component demonstrations
Widget _buildComponentDemo({
  required String title,
  required String description,
  required String widgetName,
  required IconData icon,
  required Widget Function(WidgetPlacement) builder,
}) {
  // Create a simple toolbox with the component
  final toolbox = CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Demo',
        items: [
          ToolboxItem(
            name: widgetName,
            displayName: title,
            toolboxBuilder: (context) => Icon(icon, size: 32),
            gridBuilder: (context, placement) => builder(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
        ],
      ),
    ],
  );

  // Create initial layout with the component
  final initialLayout = LayoutState(
    dimensions: const GridDimensions(columns: 4, rows: 3),
    widgets: [
      WidgetPlacement(
        id: 'demo_widget',
        widgetName: widgetName,
        column: 1,
        row: 1,
        width: 2,
        height: 1,
        properties: {
          'label': title,
          'demo': true,
        },
      ),
    ],
  );

  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 8),
              const Text(
                'This component is shown both in the toolbox and placed in the grid below.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        Expanded(
          child: FormLayout(
            toolbox: toolbox,
            initialLayout: initialLayout,
            onLayoutChanged: (layout) {
              // Handle layout changes in the demo
            },
          ),
        ),
      ],
    ),
  );
}