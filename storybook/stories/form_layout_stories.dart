import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// Stories for the FormLayout widget
List<Story> getFormLayoutStories() {
  // Create sample toolbox
  final sampleToolbox = CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Basic',
        items: [
          ToolboxItem(
            name: 'text',
            displayName: 'Text Input',
            toolboxBuilder: (context) => const Card(
              child: Center(
                child: Icon(Icons.text_fields, size: 32),
              ),
            ),
            gridBuilder: (context, placement) => Card(
              color: Colors.blue.shade100,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Text Field ${placement.id}',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'button',
            displayName: 'Button',
            toolboxBuilder: (context) => const Card(
              child: Center(
                child: Icon(Icons.smart_button, size: 32),
              ),
            ),
            gridBuilder: (context, placement) => Card(
              color: Colors.green.shade100,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Button ${placement.id}'),
                ),
              ),
            ),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Advanced',
        items: [
          ToolboxItem(
            name: 'image',
            displayName: 'Image',
            toolboxBuilder: (context) => const Card(
              child: Center(
                child: Icon(Icons.image, size: 32),
              ),
            ),
            gridBuilder: (context, placement) => Card(
              color: Colors.purple.shade100,
              child: const Center(
                child: Icon(Icons.image, size: 48),
              ),
            ),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'chart',
            displayName: 'Chart',
            toolboxBuilder: (context) => const Card(
              child: Center(
                child: Icon(Icons.bar_chart, size: 32),
              ),
            ),
            gridBuilder: (context, placement) => Card(
              color: Colors.orange.shade100,
              child: const Center(
                child: Icon(Icons.bar_chart, size: 48),
              ),
            ),
            defaultWidth: 4,
            defaultHeight: 3,
          ),
        ],
      ),
    ],
  );

  return [
    Story(
      name: 'Form Layout/Default',
      description: 'Default FormLayout configuration with horizontal toolbox',
      builder: (context) => FormLayout(
        toolbox: sampleToolbox,
        onLayoutChanged: (layout) {
          debugPrint('Layout changed: ${layout.widgets.length} widgets');
        },
      ),
    ),
    
    Story(
      name: 'Form Layout/Vertical Toolbox',
      description: 'FormLayout with toolbox positioned at the top',
      builder: (context) => FormLayout(
        toolbox: sampleToolbox,
        toolboxPosition: context.knobs.options(
          label: 'Toolbox Position',
          initial: Axis.vertical,
          options: const [
            Option(label: 'Horizontal', value: Axis.horizontal),
            Option(label: 'Vertical', value: Axis.vertical),
          ],
        ),
        toolboxHeight: context.knobs.slider(
          label: 'Toolbox Height',
          initial: 150,
          min: 100,
          max: 300,
        ),
      ),
    ),
    
    Story(
      name: 'Form Layout/No Toolbox',
      description: 'FormLayout with hidden toolbox (grid only)',
      builder: (context) => FormLayout(
        toolbox: sampleToolbox,
        showToolbox: false,
        initialLayout: LayoutState(
          dimensions: const GridDimensions(columns: 4, rows: 5),
          widgets: [
            WidgetPlacement(
              id: 'sample1',
              widgetName: 'text',
              column: 0,
              row: 0,
              width: 2,
              height: 1,
            ),
            WidgetPlacement(
              id: 'sample2',
              widgetName: 'button',
              column: 2,
              row: 0,
              width: 2,
              height: 1,
            ),
            WidgetPlacement(
              id: 'sample3',
              widgetName: 'image',
              column: 0,
              row: 1,
              width: 3,
              height: 2,
            ),
          ],
        ),
      ),
    ),
    
    Story(
      name: 'Form Layout/Custom Dimensions',
      description: 'FormLayout with custom grid dimensions',
      builder: (context) => FormLayout(
        toolbox: sampleToolbox,
        initialLayout: LayoutState(
          dimensions: GridDimensions(
            columns: context.knobs.slider(
              label: 'Columns',
              initial: 6,
              min: 2,
              max: 12,
            ).toInt(),
            rows: context.knobs.slider(
              label: 'Rows',
              initial: 8,
              min: 2,
              max: 12,
            ).toInt(),
          ),
          widgets: const [],
        ),
      ),
    ),
    
    Story(
      name: 'Form Layout/Disabled Undo',
      description: 'FormLayout with undo/redo disabled',
      builder: (context) => FormLayout(
        toolbox: sampleToolbox,
        enableUndo: context.knobs.boolean(
          label: 'Enable Undo',
          initial: false,
        ),
      ),
    ),
    
    Story(
      name: 'Form Layout/Custom Theme',
      description: 'FormLayout with custom Material theme',
      builder: (context) => FormLayout(
        toolbox: sampleToolbox,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: context.knobs.options(
              label: 'Theme Brightness',
              initial: Brightness.light,
              options: const [
                Option(label: 'Light', value: Brightness.light),
                Option(label: 'Dark', value: Brightness.dark),
              ],
            ),
          ),
        ),
      ),
    ),
    
    Story(
      name: 'Form Layout/Pre-populated',
      description: 'FormLayout with pre-populated widgets',
      builder: (context) {
        final columns = 6;
        final rows = 8;
        
        // Create a sample form layout
        final widgets = <WidgetPlacement>[
          // Header
          WidgetPlacement(
            id: 'header',
            widgetName: 'text',
            column: 0,
            row: 0,
            width: columns,
            height: 1,
          ),
          // Two columns of fields
          for (int i = 0; i < 3; i++) ...[
            WidgetPlacement(
              id: 'left_$i',
              widgetName: 'text',
              column: 0,
              row: i + 1,
              width: 3,
              height: 1,
            ),
            WidgetPlacement(
              id: 'right_$i',
              widgetName: 'text',
              column: 3,
              row: i + 1,
              width: 3,
              height: 1,
            ),
          ],
          // Image in the middle
          WidgetPlacement(
            id: 'image',
            widgetName: 'image',
            column: 1,
            row: 4,
            width: 4,
            height: 2,
          ),
          // Submit button at bottom
          WidgetPlacement(
            id: 'submit',
            widgetName: 'button',
            column: 2,
            row: 6,
            width: 2,
            height: 1,
          ),
        ];
        
        return FormLayout(
          toolbox: sampleToolbox,
          initialLayout: LayoutState(
            dimensions: GridDimensions(columns: columns, rows: rows),
            widgets: widgets,
          ),
        );
      },
    ),
    
    Story(
      name: 'Form Layout/Callback Example',
      description: 'FormLayout with layout change callback',
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String statusMessage = 'No changes yet';
            
            return Column(
              children: [
                Container(
                  color: Colors.blue.shade100,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(statusMessage),
                    ],
                  ),
                ),
                Expanded(
                  child: FormLayout(
                    toolbox: sampleToolbox,
                    onLayoutChanged: (layout) {
                      setState(() {
                        statusMessage = 'Layout has ${layout.widgets.length} widgets '
                            'on a ${layout.dimensions.columns}×${layout.dimensions.rows} grid';
                      });
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
    
    Story(
      name: 'Form Layout/Responsive',
      description: 'FormLayout that adapts to screen size',
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        
        return FormLayout(
          toolbox: sampleToolbox,
          toolboxPosition: isSmallScreen ? Axis.vertical : Axis.horizontal,
          toolboxWidth: isSmallScreen ? null : 250,
          toolboxHeight: isSmallScreen ? 120 : null,
        );
      },
    ),
  ];
}