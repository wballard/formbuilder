import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

final List<Story> featureStories = [
  Story(
    name: 'Features/Drag and Drop',
    description: 'Demonstrates drag and drop functionality',
    builder: (context) => const DragDropFeatureDemo(),
  ),
  Story(
    name: 'Features/Resize Widgets',
    description: 'Demonstrates widget resizing capability',
    builder: (context) => const ResizeFeatureDemo(),
  ),
  Story(
    name: 'Features/Undo Redo',
    description: 'Demonstrates undo/redo functionality',
    builder: (context) => const UndoRedoFeatureDemo(),
  ),
  Story(
    name: 'Features/Preview Mode',
    description: 'Demonstrates preview mode toggle',
    builder: (context) => const PreviewModeFeatureDemo(),
  ),
];

class DragDropFeatureDemo extends StatelessWidget {
  const DragDropFeatureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildFeatureDemo(
      title: 'Drag and Drop Feature',
      description: 'Drag widgets from the toolbox to the grid, and move widgets around the grid.',
      instructions: [
        'Drag widgets from the toolbox on the left to the grid',
        'Drag existing widgets to new positions',
        'Drop zones are highlighted when dragging',
        'Widgets cannot overlap - conflicts are prevented',
      ],
    );
  }
}

class ResizeFeatureDemo extends StatelessWidget {
  const ResizeFeatureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildFeatureDemo(
      title: 'Widget Resize Feature',
      description: 'Click on widgets to see resize handles and adjust their size.',
      instructions: [
        'Click on any widget in the grid to select it',
        'Drag the resize handles to change widget size',
        'Resize is constrained by grid boundaries',
        'Widgets cannot be resized to overlap others',
      ],
      initialWidgets: [
        WidgetPlacement(
          id: 'resizable_text',
          widgetName: 'text_field',
          column: 0,
          row: 0,
          width: 2,
          height: 1,
          properties: {'label': 'Resizable Text Field'},
        ),
        WidgetPlacement(
          id: 'resizable_button',
          widgetName: 'button',
          column: 2,
          row: 1,
          width: 1,
          height: 1,
          properties: {'label': 'Resizable Button'},
        ),
      ],
    );
  }
}

class UndoRedoFeatureDemo extends StatelessWidget {
  const UndoRedoFeatureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildFeatureDemo(
      title: 'Undo/Redo Feature',
      description: 'Make changes and use undo/redo to navigate through history.',
      instructions: [
        'Make changes to the layout (drag, resize, delete)',
        'Use Ctrl+Z (Cmd+Z on Mac) to undo changes',
        'Use Ctrl+Y (Cmd+Shift+Z on Mac) to redo changes',
        'The toolbar shows undo/redo buttons',
      ],
      enableUndo: true,
      initialWidgets: [
        WidgetPlacement(
          id: 'demo_field',
          widgetName: 'text_field',
          column: 1,
          row: 1,
          width: 2,
          height: 1,
          properties: {'label': 'Try modifying this'},
        ),
      ],
    );
  }
}

class PreviewModeFeatureDemo extends StatelessWidget {
  const PreviewModeFeatureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildFeatureDemo(
      title: 'Preview Mode Feature',
      description: 'Toggle between edit and preview modes to see the form as end users would.',
      instructions: [
        'Use the preview toggle in the toolbar',
        'Preview mode hides editing controls',
        'Form becomes interactive for end users',
        'Switch back to edit mode to make changes',
      ],
      showModeToggle: true,
      initialWidgets: [
        WidgetPlacement(
          id: 'preview_title',
          widgetName: 'text_field',
          column: 0,
          row: 0,
          width: 4,
          height: 1,
          properties: {'label': 'Form Title'},
        ),
        WidgetPlacement(
          id: 'preview_name',
          widgetName: 'text_field',
          column: 0,
          row: 1,
          width: 2,
          height: 1,
          properties: {'label': 'Name'},
        ),
        WidgetPlacement(
          id: 'preview_email',
          widgetName: 'text_field',
          column: 2,
          row: 1,
          width: 2,
          height: 1,
          properties: {'label': 'Email'},
        ),
        WidgetPlacement(
          id: 'preview_submit',
          widgetName: 'button',
          column: 1,
          row: 2,
          width: 2,
          height: 1,
          properties: {'label': 'Submit'},
        ),
      ],
    );
  }
}

Widget _buildFeatureDemo({
  required String title,
  required String description,
  required List<String> instructions,
  List<WidgetPlacement> initialWidgets = const [],
  bool enableUndo = false,
  bool showModeToggle = false,
}) {
  // Create a toolbox with basic widgets
  final toolbox = CategorizedToolbox(
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
                  labelText: placement.properties['label'] as String? ?? 'Text Field',
                  border: const OutlineInputBorder(),
                  isDense: true,
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
            defaultWidth: 1,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'checkbox',
            displayName: 'Checkbox',
            toolboxBuilder: (context) => const Icon(Icons.check_box, size: 32),
            gridBuilder: (context, placement) => Padding(
              padding: const EdgeInsets.all(8),
              child: CheckboxListTile(
                title: Text(placement.properties['label'] as String? ?? 'Checkbox'),
                value: false,
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

  final initialLayout = LayoutState(
    dimensions: const GridDimensions(columns: 4, rows: 4),
    widgets: initialWidgets,
  );

  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.green.withValues(alpha: 0.1),
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
              const SizedBox(height: 12),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...instructions.map((instruction) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• $instruction'),
              )),
            ],
          ),
        ),
        Expanded(
          child: FormLayout(
            toolbox: toolbox,
            initialLayout: initialLayout,
            enableUndo: enableUndo,
            onLayoutChanged: (layout) {
              // Handle layout changes in the demo
            },
          ),
        ),
      ],
    ),
  );
}