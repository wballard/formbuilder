import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/widgets/form_layout.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder/form_layout/hooks/use_form_state.dart';
import 'package:formbuilder/form_layout/hooks/use_undo_redo.dart';

final List<Story> playgroundStories = [
  // Full Form Builder Playground
  Story(
    name: 'Playground/Form Builder',
    description: 'Interactive form builder with all features enabled',
    builder: (context) => const FormBuilderPlayground(),
  ),
  
  // Widget Gallery Playground
  Story(
    name: 'Playground/Widget Gallery',
    description: 'Explore all available widgets in an interactive gallery',
    builder: (context) => const WidgetGalleryPlayground(),
  ),
  
  // Theme Playground
  Story(
    name: 'Playground/Theme Studio',
    description: 'Interactive theme customization and preview',
    builder: (context) => const ThemeStudioPlayground(),
  ),
  
  // Layout Playground
  Story(
    name: 'Playground/Layout Studio',
    description: 'Experiment with different grid layouts and arrangements',
    builder: (context) => const LayoutStudioPlayground(),
  ),
  
  // Advanced Playground
  Story(
    name: 'Playground/Advanced Features',
    description: 'Advanced form builder features and customizations',
    builder: (context) => const AdvancedPlayground(),
  ),
];

// Full Form Builder Playground
class FormBuilderPlayground extends HookWidget {
  const FormBuilderPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final undoRedo = useUndoRedo(formState);
    final selectedTheme = useState('Blue');
    final gridSize = useState(const GridDimensions(width: 6, height: 8));
    final showGrid = useState(true);
    final previewMode = useState(false);
    
    final themes = {
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Purple': Colors.purple,
      'Orange': Colors.orange,
      'Red': Colors.red,
    };
    
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: themes[selectedTheme.value],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Builder Playground'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            // Grid size selector
            PopupMenuButton<GridDimensions>(
              icon: const Icon(Icons.grid_view),
              tooltip: 'Grid Size',
              onSelected: (size) {
                gridSize.value = size;
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: GridDimensions(width: 4, height: 6),
                  child: Text('Small (4x6)'),
                ),
                const PopupMenuItem(
                  value: GridDimensions(width: 6, height: 8),
                  child: Text('Medium (6x8)'),
                ),
                const PopupMenuItem(
                  value: GridDimensions(width: 8, height: 10),
                  child: Text('Large (8x10)'),
                ),
              ],
            ),
            
            // Theme selector
            PopupMenuButton<String>(
              icon: const Icon(Icons.palette),
              tooltip: 'Theme',
              onSelected: (theme) {
                selectedTheme.value = theme;
              },
              itemBuilder: (context) => themes.entries
                  .map((entry) => PopupMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            
            // Preview mode toggle
            IconButton(
              onPressed: () {
                previewMode.value = !previewMode.value;
              },
              icon: Icon(
                previewMode.value ? Icons.edit : Icons.visibility,
              ),
              tooltip: previewMode.value ? 'Edit Mode' : 'Preview Mode',
            ),
            
            // Grid toggle
            IconButton(
              onPressed: () {
                showGrid.value = !showGrid.value;
              },
              icon: Icon(
                showGrid.value ? Icons.grid_off : Icons.grid_on,
              ),
              tooltip: showGrid.value ? 'Hide Grid' : 'Show Grid',
            ),
          ],
        ),
        body: Row(
          children: [
            // Toolbox
            if (!previewMode.value)
              Container(
                width: 280,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Row(
                        children: [
                          Icon(
                            Icons.widgets,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Widget Toolbox',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: [
                          _buildToolboxSection('Text Input', [
                            _buildToolboxItem(
                              'Text Field',
                              Icons.text_fields,
                              () => const TextField(
                                decoration: InputDecoration(
                                  labelText: 'Text Field',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            _buildToolboxItem(
                              'Text Area',
                              Icons.text_snippet,
                              () => const TextField(
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Text Area',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ),
                            _buildToolboxItem(
                              'Password Field',
                              Icons.lock,
                              () => const TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock),
                                ),
                              ),
                            ),
                          ]),
                          
                          _buildToolboxSection('Selection', [
                            _buildToolboxItem(
                              'Dropdown',
                              Icons.arrow_drop_down,
                              () => const DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Select Option',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                                  DropdownMenuItem(value: 'option2', child: Text('Option 2')),
                                  DropdownMenuItem(value: 'option3', child: Text('Option 3')),
                                ],
                                onChanged: null,
                              ),
                            ),
                            _buildToolboxItem(
                              'Checkbox',
                              Icons.check_box,
                              () => CheckboxListTile(
                                title: const Text('Checkbox Option'),
                                value: false,
                                onChanged: (_) {},
                              ),
                            ),
                            _buildToolboxItem(
                              'Radio Group',
                              Icons.radio_button_checked,
                              () => Column(
                                children: [
                                  RadioListTile<int>(
                                    title: const Text('Option 1'),
                                    value: 1,
                                    groupValue: 1,
                                    onChanged: (_) {},
                                  ),
                                  RadioListTile<int>(
                                    title: const Text('Option 2'),
                                    value: 2,
                                    groupValue: 1,
                                    onChanged: (_) {},
                                  ),
                                ],
                              ),
                            ),
                            _buildToolboxItem(
                              'Switch',
                              Icons.toggle_on,
                              () => SwitchListTile(
                                title: const Text('Switch Option'),
                                value: true,
                                onChanged: (_) {},
                              ),
                            ),
                          ]),
                          
                          _buildToolboxSection('Date & Time', [
                            _buildToolboxItem(
                              'Date Picker',
                              Icons.calendar_today,
                              () => const TextField(
                                decoration: InputDecoration(
                                  labelText: 'Select Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                ),
                                readOnly: true,
                              ),
                            ),
                            _buildToolboxItem(
                              'Time Picker',
                              Icons.access_time,
                              () => const TextField(
                                decoration: InputDecoration(
                                  labelText: 'Select Time',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                ),
                                readOnly: true,
                              ),
                            ),
                          ]),
                          
                          _buildToolboxSection('Actions', [
                            _buildToolboxItem(
                              'Button',
                              Icons.smart_button,
                              () => ElevatedButton(
                                onPressed: () {},
                                child: const Text('Button'),
                              ),
                            ),
                            _buildToolboxItem(
                              'Icon Button',
                              Icons.radio_button_unchecked,
                              () => IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.favorite),
                              ),
                            ),
                          ]),
                          
                          _buildToolboxSection('Display', [
                            _buildToolboxItem(
                              'Label',
                              Icons.label,
                              () => const Text(
                                'Label Text',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            _buildToolboxItem(
                              'Divider',
                              Icons.horizontal_rule,
                              () => const Divider(thickness: 2),
                            ),
                            _buildToolboxItem(
                              'Image',
                              Icons.image,
                              () => Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image, size: 48),
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Main content area
            Expanded(
              child: Column(
                children: [
                  // Toolbar
                  if (!previewMode.value)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Undo/Redo
                          IconButton(
                            onPressed: undoRedo.canUndo ? undoRedo.undo : null,
                            icon: const Icon(Icons.undo),
                            tooltip: 'Undo',
                          ),
                          IconButton(
                            onPressed: undoRedo.canRedo ? undoRedo.redo : null,
                            icon: const Icon(Icons.redo),
                            tooltip: 'Redo',
                          ),
                          
                          const VerticalDivider(),
                          
                          // Clear all
                          IconButton(
                            onPressed: formState.placements.isNotEmpty
                                ? () {
                                    formState.clearAll();
                                  }
                                : null,
                            icon: const Icon(Icons.clear_all),
                            tooltip: 'Clear All',
                          ),
                          
                          const VerticalDivider(),
                          
                          // Export/Import
                          IconButton(
                            onPressed: () {
                              final data = formState.exportToJson();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Exported ${formState.placements.length} widgets'),
                                  action: SnackBarAction(
                                    label: 'Copy',
                                    onPressed: () {
                                      // Copy to clipboard
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            tooltip: 'Export Layout',
                          ),
                          
                          IconButton(
                            onPressed: () {
                              // Show import dialog
                              _showImportDialog(context, formState);
                            },
                            icon: const Icon(Icons.upload),
                            tooltip: 'Import Layout',
                          ),
                          
                          const Spacer(),
                          
                          // Widget count
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${formState.placements.length} widgets',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Form canvas
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: previewMode.value 
                                ? Colors.green.shade300 
                                : Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FormLayout(
                          gridDimensions: gridSize.value,
                          placements: formState.placements,
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
                          showGrid: showGrid.value && !previewMode.value,
                          previewMode: previewMode.value,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          previewMode.value ? Icons.visibility : Icons.edit,
                          size: 16,
                          color: previewMode.value ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          previewMode.value ? 'Preview Mode' : 'Edit Mode',
                          style: TextStyle(
                            color: previewMode.value ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('Grid: ${gridSize.value.width}x${gridSize.value.height}'),
                        const SizedBox(width: 16),
                        Text('Theme: ${selectedTheme.value}'),
                        const Spacer(),
                        if (undoRedo.historyLength > 0)
                          Text('History: ${undoRedo.historyLength} actions'),
                      ],
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
  
  Widget _buildToolboxSection(String title, List<Widget> items) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: true,
      children: items,
    );
  }
  
  Widget _buildToolboxItem(
    String label,
    IconData icon,
    Widget Function() widgetBuilder,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ToolboxWidget(
        icon: icon,
        label: label,
        widgetBuilder: widgetBuilder,
      ),
    );
  }
  
  void _showImportDialog(BuildContext context, dynamic formState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Layout'),
        content: const SizedBox(
          width: 400,
          child: TextField(
            maxLines: 8,
            decoration: InputDecoration(
              labelText: 'Paste JSON layout data',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Import logic here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Layout imported successfully')),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}

// Widget Gallery Playground
class WidgetGalleryPlayground extends HookWidget {
  const WidgetGalleryPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCategory = useState('All');
    final searchQuery = useState('');
    
    final categories = ['All', 'Input', 'Selection', 'Display', 'Action', 'Layout'];
    
    final widgets = [
      {'name': 'Text Field', 'category': 'Input', 'icon': Icons.text_fields},
      {'name': 'Text Area', 'category': 'Input', 'icon': Icons.text_snippet},
      {'name': 'Password Field', 'category': 'Input', 'icon': Icons.lock},
      {'name': 'Number Field', 'category': 'Input', 'icon': Icons.numbers},
      {'name': 'Dropdown', 'category': 'Selection', 'icon': Icons.arrow_drop_down},
      {'name': 'Checkbox', 'category': 'Selection', 'icon': Icons.check_box},
      {'name': 'Radio Group', 'category': 'Selection', 'icon': Icons.radio_button_checked},
      {'name': 'Switch', 'category': 'Selection', 'icon': Icons.toggle_on},
      {'name': 'Date Picker', 'category': 'Input', 'icon': Icons.calendar_today},
      {'name': 'Time Picker', 'category': 'Input', 'icon': Icons.access_time},
      {'name': 'Button', 'category': 'Action', 'icon': Icons.smart_button},
      {'name': 'Icon Button', 'category': 'Action', 'icon': Icons.radio_button_unchecked},
      {'name': 'Label', 'category': 'Display', 'icon': Icons.label},
      {'name': 'Divider', 'category': 'Display', 'icon': Icons.horizontal_rule},
      {'name': 'Image', 'category': 'Display', 'icon': Icons.image},
      {'name': 'Card', 'category': 'Layout', 'icon': Icons.crop_portrait},
    ];
    
    final filteredWidgets = widgets.where((widget) {
      final matchesCategory = selectedCategory.value == 'All' || 
          widget['category'] == selectedCategory.value;
      final matchesSearch = searchQuery.value.isEmpty ||
          (widget['name'] as String).toLowerCase()
              .contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Gallery'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search widgets...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    searchQuery.value = value;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Category filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) =>
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: selectedCategory.value == category,
                          onSelected: (selected) {
                            if (selected) {
                              selectedCategory.value = category;
                            }
                          },
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: filteredWidgets.length,
        itemBuilder: (context, index) {
          final widget = filteredWidgets[index];
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                _showWidgetDetails(context, widget);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget['icon'] as IconData,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget['category'] as String,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showWidgetDetails(BuildContext context, Map<String, dynamic> widget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(widget['icon'] as IconData),
            const SizedBox(width: 8),
            Text(widget['name'] as String),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${widget['category']}'),
              const SizedBox(height: 16),
              const Text('Preview:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildWidgetPreview(widget['name'] as String),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${widget['name']} to form')),
              );
            },
            child: const Text('Add to Form'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWidgetPreview(String widgetName) {
    switch (widgetName) {
      case 'Text Field':
        return const TextField(
          decoration: InputDecoration(
            labelText: 'Text Field',
            border: OutlineInputBorder(),
          ),
        );
      case 'Button':
        return ElevatedButton(
          onPressed: () {},
          child: const Text('Button'),
        );
      case 'Checkbox':
        return CheckboxListTile(
          title: const Text('Checkbox'),
          value: false,
          onChanged: (_) {},
        );
      default:
        return Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(child: Text('Widget Preview')),
        );
    }
  }
}

// Theme Studio Playground (simplified for space)
class ThemeStudioPlayground extends HookWidget {
  const ThemeStudioPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Theme Studio Playground - Interactive theme customization'),
      ),
    );
  }
}

// Layout Studio Playground (simplified for space)
class LayoutStudioPlayground extends HookWidget {
  const LayoutStudioPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Layout Studio Playground - Grid layout experimentation'),
      ),
    );
  }
}

// Advanced Playground (simplified for space)
class AdvancedPlayground extends HookWidget {
  const AdvancedPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Advanced Playground - Custom widgets and integrations'),
      ),
    );
  }
}