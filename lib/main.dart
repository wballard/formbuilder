import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

void main() {
  runApp(const FormBuilderApp());
}

class FormBuilderApp extends StatelessWidget {
  const FormBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormBuilder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SimpleFormBuilderDemo(),
    );
  }
}

class SimpleFormBuilderDemo extends StatelessWidget {
  const SimpleFormBuilderDemo({super.key});

  // Simple toolbox with basic widgets
  static final _toolbox = CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Basic',
        items: [
          ToolboxItem(
            name: 'text_field',
            displayName: 'Text Field',
            toolboxBuilder: (context) => const Icon(Icons.text_fields, size: 32),
            gridBuilder: (context, placement) => Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Text Field',
                  border: const OutlineInputBorder(),
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
                child: const Text('Button'),
              ),
            ),
            defaultWidth: 1,
            defaultHeight: 1,
          ),
        ],
      ),
    ],
  );

  // Simple initial layout
  static final _initialLayout = LayoutState(
    dimensions: const GridDimensions(columns: 4, rows: 3),
    widgets: [
      WidgetPlacement(
        id: 'welcome_text',
        widgetName: 'text_field',
        column: 0,
        row: 0,
        width: 4,
        height: 1,
      ),
      WidgetPlacement(
        id: 'submit_btn',
        widgetName: 'button',
        column: 1,
        row: 2,
        width: 2,
        height: 1,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FormBuilder - Simple Demo'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                const Text('This is a simple demo. For comprehensive examples, see the '),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Example & Storybook'),
                        content: const Text(
                          'To see comprehensive examples and the interactive storybook:\n\n'
                          '1. Navigate to the example/ directory\n'
                          '2. Run: flutter run\n'
                          '3. Or run: flutter run -t lib/main_simple.dart\n\n'
                          'The example directory contains both the storybook showcase and detailed usage examples.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('example directory'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FormLayout(
              toolbox: _toolbox,
              initialLayout: _initialLayout,
              onLayoutChanged: (layout) {
                // Handle layout changes
              },
            ),
          ),
        ],
      ),
    );
  }
}
