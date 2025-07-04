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
    name: 'Overview',
    description: 'All form components demonstration',
    builder: (context) => const OverviewStoryDemo(),
  ),
];

// Overview story demonstration widget
class OverviewStoryDemo extends StatelessWidget {
  const OverviewStoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a toolbox with all 4 widget types
    final toolbox = CategorizedToolbox(
      categories: [
        ToolboxCategory(
          name: 'Form Widgets',
          items: [
            ToolboxItem(
              name: 'text_field',
              displayName: 'Text Field',
              toolboxBuilder: (context) => const Icon(Icons.text_fields, size: 32),
              gridBuilder: (context, placement) => Container(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: placement.properties['label'] as String? ?? 'Text Field',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              defaultWidth: 2,
              defaultHeight: 1,
            ),
            ToolboxItem(
              name: 'button',
              displayName: 'Button',
              toolboxBuilder: (context) => const Icon(Icons.smart_button, size: 32),
              gridBuilder: (context, placement) => Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(placement.properties['label'] as String? ?? 'Button'),
                ),
              ),
              defaultWidth: 2,
              defaultHeight: 1,
            ),
            ToolboxItem(
              name: 'checkbox',
              displayName: 'Checkbox',
              toolboxBuilder: (context) => const Icon(Icons.check_box, size: 32),
              gridBuilder: (context, placement) => Container(
                padding: const EdgeInsets.all(8),
                child: CheckboxListTile(
                  title: Text(placement.properties['label'] as String? ?? 'Checkbox'),
                  value: placement.properties['checked'] as bool? ?? false,
                  onChanged: (value) {},
                  tileColor: Colors.grey[50],
                ),
              ),
              defaultWidth: 2,
              defaultHeight: 1,
            ),
            ToolboxItem(
              name: 'dropdown',
              displayName: 'Dropdown',
              toolboxBuilder: (context) => const Icon(Icons.arrow_drop_down_circle, size: 32),
              gridBuilder: (context, placement) => Container(
                padding: const EdgeInsets.all(8),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: placement.properties['label'] as String? ?? 'Dropdown',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                    DropdownMenuItem(value: 'option2', child: Text('Option 2')),
                    DropdownMenuItem(value: 'option3', child: Text('Option 3')),
                  ],
                  onChanged: (value) {},
                ),
              ),
              defaultWidth: 2,
              defaultHeight: 1,
            ),
          ],
        ),
      ],
    );

    // Create initial layout with all 4 widget types placed on a 6x6 grid
    final initialLayout = LayoutState(
      dimensions: const GridDimensions(columns: 6, rows: 6),
      widgets: [
        WidgetPlacement(
          id: 'text_field_1',
          widgetName: 'text_field',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
          properties: {
            'label': 'Name',
          },
        ),
        WidgetPlacement(
          id: 'button_1',
          widgetName: 'button',
          column: 3,
          row: 0,
          width: 2,
          height: 1,
          properties: {
            'label': 'Submit',
          },
        ),
        WidgetPlacement(
          id: 'checkbox_1',
          widgetName: 'checkbox',
          column: 0,
          row: 2,
          width: 2,
          height: 1,
          properties: {
            'label': 'I agree',
            'checked': false,
          },
        ),
        WidgetPlacement(
          id: 'dropdown_1',
          widgetName: 'dropdown',
          column: 3,
          row: 2,
          width: 2,
          height: 1,
          properties: {
            'label': 'Select Option',
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Builder Overview'),
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.withValues(alpha: 0.1),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Builder Components Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('This demonstrates all 4 widget types available in the form builder:'),
                SizedBox(height: 4),
                Text('• Text Field - For text input'),
                Text('• Button - For actions'),
                Text('• Checkbox - For boolean selections'),
                Text('• Dropdown - For option selection'),
                SizedBox(height: 8),
                Text(
                  'The grid is 6x6 and shows all 4 widget types. Drag widgets from the toolbox to add more.',
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
}
