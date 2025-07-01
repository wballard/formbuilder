import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/widgets/form_layout.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder/form_layout/hooks/use_form_state.dart';
import 'package:formbuilder/form_layout/hooks/use_undo_redo.dart';

final List<Story> featureStories = [
  // Drag and Drop Feature
  Story(
    name: 'Features/Drag and Drop',
    description: 'Interactive drag and drop functionality demonstration',
    builder: (context) => const DragDropFeatureStory(),
  ),
  
  // Widget Resizing Feature
  Story(
    name: 'Features/Widget Resizing',
    description: 'Widget resizing with handles demonstration',
    builder: (context) => const ResizingFeatureStory(),
  ),
  
  // Keyboard Navigation Feature
  Story(
    name: 'Features/Keyboard Navigation',
    description: 'Complete keyboard navigation and shortcuts',
    builder: (context) => const KeyboardNavigationStory(),
  ),
  
  // Undo/Redo Feature
  Story(
    name: 'Features/Undo Redo',
    description: 'Undo/redo functionality with history tracking',
    builder: (context) => const UndoRedoFeatureStory(),
  ),
  
  // Preview Mode Feature
  Story(
    name: 'Features/Preview Mode',
    description: 'Toggle between edit and preview modes',
    builder: (context) => const PreviewModeStory(),
  ),
  
  // Import/Export Feature
  Story(
    name: 'Features/Import Export',
    description: 'Save and load form layouts',
    builder: (context) => const ImportExportStory(),
  ),
];

// Base feature story widget for consistent layout
class FeatureStoryBase extends StatelessWidget {
  final String title;
  final String description;
  final Widget demo;
  final List<String> instructions;
  final String codeExample;

  const FeatureStoryBase({
    super.key,
    required this.title,
    required this.description,
    required this.demo,
    required this.instructions,
    required this.codeExample,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Demo'),
              Tab(text: 'Instructions'),
              Tab(text: 'Code'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Demo Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: demo,
                ),
                
                // Instructions Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to use:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          ...instructions.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(entry.value)),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Code Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Implementation Example',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: codeExample));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Code copied to clipboard')),
                                  );
                                },
                                tooltip: 'Copy code',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  codeExample,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                  ),
                                ),
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
        ],
      ),
    );
  }
}

// Drag and Drop Feature Story
class DragDropFeatureStory extends HookWidget {
  const DragDropFeatureStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    return FeatureStoryBase(
      title: 'Drag and Drop Operations',
      description: 'Demonstrates dragging widgets from toolbox to grid and rearranging existing widgets',
      demo: Row(
        children: [
          // Toolbox
          SizedBox(
            width: 200,
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Toolbox',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ToolboxWidget(
                          icon: Icons.text_fields,
                          label: 'Text Field',
                          widgetBuilder: () => const TextField(
                            decoration: InputDecoration(
                              labelText: 'Text Field',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        ToolboxWidget(
                          icon: Icons.check_box,
                          label: 'Checkbox',
                          widgetBuilder: () => CheckboxListTile(
                            title: const Text('Checkbox'),
                            value: false,
                            onChanged: (_) {},
                          ),
                        ),
                        ToolboxWidget(
                          icon: Icons.smart_button,
                          label: 'Button',
                          widgetBuilder: () => ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Form Layout
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Form Grid (Drop widgets here)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: FormLayout(
                      gridDimensions: const GridDimensions(width: 4, height: 6),
                      placements: formState.placements,
                      onPlacementChanged: (placement) {
                        formState.updatePlacement(placement);
                      },
                      onPlacementRemoved: (placement) {
                        formState.removePlacement(placement);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      instructions: [
        'Drag a widget from the toolbox on the left',
        'Drop it onto an empty cell in the grid',
        'Drag existing widgets within the grid to rearrange them',
        'Use the resize handles to adjust widget size',
        'Right-click widgets for context menu options',
      ],
      codeExample: '''
// Basic drag and drop setup
class MyFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    return Row(
      children: [
        // Toolbox
        ToolboxWidget(
          icon: Icons.text_fields,
          label: 'Text Field',
          widgetBuilder: () => TextField(
            decoration: InputDecoration(
              labelText: 'Text Field',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        
        // Form Layout
        Expanded(
          child: FormLayout(
            gridDimensions: GridDimensions(width: 4, height: 6),
            placements: formState.placements,
            onPlacementChanged: formState.updatePlacement,
            onPlacementRemoved: formState.removePlacement,
          ),
        ),
      ],
    );
  }
}''',
    );
  }
}

// Widget Resizing Feature Story
class ResizingFeatureStory extends HookWidget {
  const ResizingFeatureStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    // Pre-populate with a few widgets for resizing demo
    useEffect(() {
      if (formState.placements.isEmpty) {
        formState.addPlacement(WidgetPlacement(
          id: 'text_field_1',
          gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Resizable Text Field',
              border: OutlineInputBorder(),
            ),
          ),
        ));
        
        formState.addPlacement(WidgetPlacement(
          id: 'button_1',
          gridPosition: const GridPosition(x: 2, y: 1, width: 1, height: 1),
          widget: ElevatedButton(
            onPressed: () {},
            child: const Text('Resize Me'),
          ),
        ));
      }
      return null;
    }, []);
    
    return FeatureStoryBase(
      title: 'Widget Resizing',
      description: 'Demonstrates resizing widgets using drag handles on all sides',
      demo: Container(
        height: 400,
        child: Card(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Resize widgets by dragging the handles',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: FormLayout(
                  gridDimensions: const GridDimensions(width: 6, height: 6),
                  placements: formState.placements,
                  onPlacementChanged: (placement) {
                    formState.updatePlacement(placement);
                  },
                  onPlacementRemoved: (placement) {
                    formState.removePlacement(placement);
                  },
                  showGrid: true,
                ),
              ),
            ],
          ),
        ),
      ),
      instructions: [
        'Hover over a widget to see the resize handles',
        'Drag the corner handles to resize both width and height',
        'Drag the side handles to resize in one direction only',
        'The widget will snap to the grid boundaries',
        'Minimum size constraints prevent widgets from becoming too small',
      ],
      codeExample: '''
// Widget with resizing enabled
FormLayout(
  gridDimensions: GridDimensions(width: 6, height: 6),
  placements: placements,
  onPlacementChanged: (placement) {
    // Handle placement updates during resize
    updatePlacement(placement);
  },
  enableResize: true, // Enable resize handles
  showGrid: true, // Show grid for visual reference
)''',
    );
  }
}

// Keyboard Navigation Story
class KeyboardNavigationStory extends HookWidget {
  const KeyboardNavigationStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final selectedWidget = useState<String?>(null);
    
    // Pre-populate with widgets for navigation demo
    useEffect(() {
      if (formState.placements.isEmpty) {
        formState.addPlacement(WidgetPlacement(
          id: 'field_1',
          gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(labelText: 'Field 1'),
          ),
        ));
        
        formState.addPlacement(WidgetPlacement(
          id: 'field_2',
          gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(labelText: 'Field 2'),
          ),
        ));
        
        formState.addPlacement(WidgetPlacement(
          id: 'button_1',
          gridPosition: const GridPosition(x: 0, y: 2, width: 1, height: 1),
          widget: ElevatedButton(
            onPressed: () {},
            child: const Text('Button'),
          ),
        ));
      }
      return null;
    }, []);
    
    return FeatureStoryBase(
      title: 'Keyboard Navigation',
      description: 'Navigate and manipulate widgets using keyboard shortcuts',
      demo: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.tab:
                // Navigate between widgets
                final placements = formState.placements;
                if (placements.isNotEmpty) {
                  final currentIndex = selectedWidget.value != null
                      ? placements.indexWhere((p) => p.id == selectedWidget.value)
                      : -1;
                  final nextIndex = (currentIndex + 1) % placements.length;
                  selectedWidget.value = placements[nextIndex].id;
                }
                return KeyEventResult.handled;
              case LogicalKeyboardKey.delete:
                // Delete selected widget
                if (selectedWidget.value != null) {
                  final placement = formState.placements
                      .firstWhere((p) => p.id == selectedWidget.value);
                  formState.removePlacement(placement);
                  selectedWidget.value = null;
                }
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowUp:
              case LogicalKeyboardKey.arrowDown:
              case LogicalKeyboardKey.arrowLeft:
              case LogicalKeyboardKey.arrowRight:
                // Move selected widget
                if (selectedWidget.value != null) {
                  final placement = formState.placements
                      .firstWhere((p) => p.id == selectedWidget.value);
                  int deltaX = 0, deltaY = 0;
                  
                  switch (event.logicalKey) {
                    case LogicalKeyboardKey.arrowLeft:
                      deltaX = -1;
                      break;
                    case LogicalKeyboardKey.arrowRight:
                      deltaX = 1;
                      break;
                    case LogicalKeyboardKey.arrowUp:
                      deltaY = -1;
                      break;
                    case LogicalKeyboardKey.arrowDown:
                      deltaY = 1;
                      break;
                  }
                  
                  final newPosition = GridPosition(
                    x: (placement.gridPosition.x + deltaX).clamp(0, 5),
                    y: (placement.gridPosition.y + deltaY).clamp(0, 5),
                    width: placement.gridPosition.width,
                    height: placement.gridPosition.height,
                  );
                  
                  formState.updatePlacement(
                    placement.copyWith(gridPosition: newPosition),
                  );
                }
                return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.keyboard, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Keyboard Navigation Active',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (selectedWidget.value != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Selected: ${selectedWidget.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: FormLayout(
                  gridDimensions: const GridDimensions(width: 6, height: 6),
                  placements: formState.placements,
                  selectedWidgetId: selectedWidget.value,
                  onPlacementChanged: (placement) {
                    formState.updatePlacement(placement);
                  },
                  onPlacementRemoved: (placement) {
                    formState.removePlacement(placement);
                    if (selectedWidget.value == placement.id) {
                      selectedWidget.value = null;
                    }
                  },
                  onWidgetSelected: (id) {
                    selectedWidget.value = id;
                  },
                  showGrid: true,
                ),
              ),
            ],
          ),
        ),
      ),
      instructions: [
        'Click in the blue bordered area to focus keyboard navigation',
        'Press TAB to cycle through widgets',
        'Use arrow keys to move the selected widget',
        'Press DELETE to remove the selected widget',
        'The selected widget is highlighted with a blue border',
      ],
      codeExample: '''
// Keyboard navigation setup
Focus(
  autofocus: true,
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.tab:
          // Navigate between widgets
          selectNextWidget();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.delete:
          // Delete selected widget
          deleteSelectedWidget();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.arrowRight:
          // Move selected widget
          moveSelectedWidget(event.logicalKey);
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  },
  child: FormLayout(
    selectedWidgetId: selectedWidgetId,
    onWidgetSelected: (id) => setState(() => selectedWidgetId = id),
    // ... other properties
  ),
)''',
    );
  }
}

// Undo/Redo Feature Story
class UndoRedoFeatureStory extends HookWidget {
  const UndoRedoFeatureStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final undoRedo = useUndoRedo(formState);
    
    return FeatureStoryBase(
      title: 'Undo/Redo Operations',
      description: 'Track and revert changes with comprehensive undo/redo functionality',
      demo: Column(
        children: [
          // Undo/Redo Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: undoRedo.canUndo ? undoRedo.undo : null,
                    icon: const Icon(Icons.undo),
                    label: const Text('Undo'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: undoRedo.canRedo ? undoRedo.redo : null,
                    icon: const Icon(Icons.redo),
                    label: const Text('Redo'),
                  ),
                  const SizedBox(width: 16),
                  Text('History: ${undoRedo.historyLength} operations'),
                  const Spacer(),
                  // Quick action buttons for testing
                  ElevatedButton(
                    onPressed: () {
                      formState.addPlacement(WidgetPlacement(
                        id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
                        gridPosition: GridPosition(
                          x: (formState.placements.length % 4),
                          y: (formState.placements.length ~/ 4),
                          width: 1,
                          height: 1,
                        ),
                        widget: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Button'),
                        ),
                      ));
                    },
                    child: const Text('Add Widget'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: formState.placements.isNotEmpty
                        ? () {
                            formState.removePlacement(formState.placements.last);
                          }
                        : null,
                    child: const Text('Remove Last'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout
          Expanded(
            child: FormLayout(
              gridDimensions: const GridDimensions(width: 6, height: 6),
              placements: formState.placements,
              onPlacementChanged: (placement) {
                formState.updatePlacement(placement);
              },
              onPlacementRemoved: (placement) {
                formState.removePlacement(placement);
              },
              showGrid: true,
            ),
          ),
        ],
      ),
      instructions: [
        'Use "Add Widget" to add new widgets to the grid',
        'Use "Remove Last" to remove the most recent widget',
        'Drag widgets around to change their positions',
        'Click "Undo" to revert the last operation',
        'Click "Redo" to reapply reverted operations',
        'The history counter shows the number of tracked operations',
      ],
      codeExample: '''
// Undo/Redo integration
class MyFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final undoRedo = useUndoRedo(formState);
    
    return Column(
      children: [
        // Controls
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: undoRedo.canUndo ? undoRedo.undo : null,
              icon: Icon(Icons.undo),
              label: Text('Undo'),
            ),
            ElevatedButton.icon(
              onPressed: undoRedo.canRedo ? undoRedo.redo : null,
              icon: Icon(Icons.redo),
              label: Text('Redo'),
            ),
          ],
        ),
        
        // Form Layout
        Expanded(
          child: FormLayout(
            placements: formState.placements,
            onPlacementChanged: formState.updatePlacement,
            onPlacementRemoved: formState.removePlacement,
          ),
        ),
      ],
    );
  }
}''',
    );
  }
}

// Preview Mode Story
class PreviewModeStory extends HookWidget {
  const PreviewModeStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final previewMode = useState(false);
    
    // Pre-populate with a sample form
    useEffect(() {
      if (formState.placements.isEmpty) {
        formState.addPlacement(WidgetPlacement(
          id: 'name_field',
          gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
        ));
        
        formState.addPlacement(WidgetPlacement(
          id: 'email_field',
          gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
            ),
          ),
        ));
        
        formState.addPlacement(WidgetPlacement(
          id: 'subscribe_checkbox',
          gridPosition: const GridPosition(x: 0, y: 2, width: 3, height: 1),
          widget: CheckboxListTile(
            title: const Text('Subscribe to newsletter'),
            value: false,
            onChanged: (_) {},
          ),
        ));
        
        formState.addPlacement(WidgetPlacement(
          id: 'submit_button',
          gridPosition: const GridPosition(x: 3, y: 2, width: 1, height: 1),
          widget: ElevatedButton(
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ));
      }
      return null;
    }, []);
    
    return FeatureStoryBase(
      title: 'Preview Mode Toggle',
      description: 'Switch between edit mode and preview mode to see how the form will look to end users',
      demo: Column(
        children: [
          // Mode Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    previewMode.value ? Icons.visibility : Icons.edit,
                    color: previewMode.value ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    previewMode.value ? 'Preview Mode' : 'Edit Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: previewMode.value ? Colors.green : Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: previewMode.value,
                    onChanged: (value) {
                      previewMode.value = value;
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(previewMode.value ? 'Preview' : 'Edit'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout with Preview Mode
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: previewMode.value ? Colors.green : Colors.blue,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FormLayout(
                gridDimensions: const GridDimensions(width: 6, height: 6),
                placements: formState.placements,
                previewMode: previewMode.value,
                onPlacementChanged: !previewMode.value
                    ? (placement) {
                        formState.updatePlacement(placement);
                      }
                    : null,
                onPlacementRemoved: !previewMode.value
                    ? (placement) {
                        formState.removePlacement(placement);
                      }
                    : null,
                showGrid: !previewMode.value,
              ),
            ),
          ),
          
          // Mode Description
          Card(
            color: previewMode.value ? Colors.green.shade50 : Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                previewMode.value
                    ? 'Preview Mode: This is how your form will appear to end users. '
                      'Widget editing is disabled, and only functional interactions are available.'
                    : 'Edit Mode: You can drag, resize, and modify widgets. '
                      'Grid lines are visible to help with positioning.',
                style: TextStyle(
                  color: previewMode.value ? Colors.green.shade800 : Colors.blue.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
      instructions: [
        'Toggle the switch to change between Edit and Preview modes',
        'In Edit Mode: drag widgets, resize them, see grid lines',
        'In Preview Mode: interact with widgets as an end user would',
        'Notice how the border color changes to indicate the current mode',
        'Use Preview Mode to test the user experience of your forms',
      ],
      codeExample: '''
// Preview mode implementation
class MyFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final previewMode = useState(false);
    
    return Column(
      children: [
        // Mode Toggle
        Switch(
          value: previewMode.value,
          onChanged: (value) => previewMode.value = value,
        ),
        
        // Form Layout
        FormLayout(
          placements: placements,
          previewMode: previewMode.value,
          onPlacementChanged: !previewMode.value 
            ? updatePlacement 
            : null, // Disable editing in preview
          showGrid: !previewMode.value, // Hide grid in preview
        ),
      ],
    );
  }
}''',
    );
  }
}

// Import/Export Story
class ImportExportStory extends HookWidget {
  const ImportExportStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final exportedData = useState<String>('');
    final importData = useState<String>('');
    
    return FeatureStoryBase(
      title: 'Import/Export Layouts',
      description: 'Save form layouts as JSON and load them back for reuse or sharing',
      demo: Column(
        children: [
          // Import/Export Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layout Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Export current layout
                          final data = formState.exportToJson();
                          exportedData.value = data;
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Export Layout'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Create sample layout
                          formState.addPlacement(WidgetPlacement(
                            id: 'sample_${DateTime.now().millisecondsSinceEpoch}',
                            gridPosition: GridPosition(
                              x: (formState.placements.length % 4),
                              y: (formState.placements.length ~/ 4),
                              width: 2,
                              height: 1,
                            ),
                            widget: const TextField(
                              decoration: InputDecoration(
                                labelText: 'Sample Field',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ));
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Sample Widget'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          formState.clearAll();
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear All'),
                      ),
                    ],
                  ),
                  
                  if (exportedData.value.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Exported Layout (JSON):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          exportedData.value,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: exportedData.value));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            importData.value = exportedData.value;
                          },
                          icon: const Icon(Icons.arrow_downward),
                          label: const Text('Use for Import'),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Import Layout:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Paste JSON layout data here...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      importData.value = value;
                    },
                    controller: TextEditingController(text: importData.value),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: importData.value.isNotEmpty
                        ? () {
                            try {
                              formState.importFromJson(importData.value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Layout imported successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Import failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.upload),
                    label: const Text('Import Layout'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout
          Expanded(
            child: FormLayout(
              gridDimensions: const GridDimensions(width: 6, height: 6),
              placements: formState.placements,
              onPlacementChanged: (placement) {
                formState.updatePlacement(placement);
              },
              onPlacementRemoved: (placement) {
                formState.removePlacement(placement);
              },
              showGrid: true,
            ),
          ),
        ],
      ),
      instructions: [
        'Add some widgets using "Add Sample Widget"',
        'Click "Export Layout" to generate JSON data',
        'Copy the exported JSON or use "Use for Import"',
        'Clear the current layout with "Clear All"',
        'Paste JSON into the import field and click "Import Layout"',
        'The layout will be restored exactly as it was exported',
      ],
      codeExample: '''
// Import/Export implementation
class MyFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    return Column(
      children: [
        // Export
        ElevatedButton(
          onPressed: () {
            final jsonData = formState.exportToJson();
            // Save to file, clipboard, or API
            saveLayout(jsonData);
          },
          child: Text('Export Layout'),
        ),
        
        // Import
        ElevatedButton(
          onPressed: () async {
            final jsonData = await loadLayout();
            formState.importFromJson(jsonData);
          },
          child: Text('Import Layout'),
        ),
        
        // Form Layout
        FormLayout(
          placements: formState.placements,
          // ... other properties
        ),
      ],
    );
  }
}''',
    );
  }
}