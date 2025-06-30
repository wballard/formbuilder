# FormBuilder API Guide

Welcome to the FormBuilder API documentation. This guide provides comprehensive information about using the FormBuilder library to create dynamic, drag-and-drop form layouts in Flutter applications.

## Table of Contents

- [Getting Started](#getting-started)
- [Core Concepts](#core-concepts)
- [Basic Usage](#basic-usage)
- [Advanced Features](#advanced-features)
- [API Reference](#api-reference)
- [Integration Guide](#integration-guide)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Installation

Add FormBuilder to your `pubspec.yaml`:

```yaml
dependencies:
  formbuilder: ^1.0.0
```

### Quick Start

Here's a minimal example to get you started:

```dart
import 'package:flutter/material.dart';
import 'package:formbuilder/formbuilder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FormLayout(
          toolbox: CategorizedToolbox(
            categories: [
              ToolboxCategory(
                name: 'Basic Inputs',
                icon: Icons.input,
                items: [
                  ToolboxItem(
                    name: 'text_field',
                    icon: Icons.text_fields,
                    label: 'Text Field',
                    gridBuilder: (context, placement) => TextFormField(
                      key: ValueKey(placement.id),
                      decoration: InputDecoration(
                        labelText: placement.properties['label'] ?? 'Text Field',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Core Concepts

### Grid System

FormBuilder uses a flexible grid-based layout system:

- **Grid Dimensions**: Configurable columns (1-12) and rows (1-20)
- **Widget Placement**: Widgets can span multiple cells
- **Responsive Design**: Adapts to different screen sizes

### Widget Placement

Every widget in the form has a `WidgetPlacement` that defines:

- **Position**: Column and row in the grid
- **Size**: Width and height in grid cells
- **Properties**: Custom configuration for each widget

### Layout State

The `LayoutState` class represents the complete form configuration:

```dart
// Create an empty layout
final layout = LayoutState.empty();

// Add a widget
final placement = WidgetPlacement(
  id: 'field-1',
  widgetName: 'text_field',
  column: 0,
  row: 0,
  width: 2,
  height: 1,
  properties: {'label': 'Name'},
);

if (layout.canAddWidget(placement)) {
  final newLayout = layout.addWidget(placement);
}
```

### Toolbox

The toolbox defines available widgets that users can drag onto the form:

```dart
final toolbox = CategorizedToolbox(
  categories: [
    ToolboxCategory(
      name: 'Text Inputs',
      icon: Icons.text_fields,
      items: [
        ToolboxItem(
          name: 'text_field',
          icon: Icons.short_text,
          label: 'Text Field',
          defaultWidth: 2,
          defaultHeight: 1,
          gridBuilder: (context, placement) => MyTextField(placement),
        ),
      ],
    ),
  ],
);
```

## Basic Usage

### Creating a Form Builder

```dart
class FormBuilderPage extends StatefulWidget {
  @override
  _FormBuilderPageState createState() => _FormBuilderPageState();
}

class _FormBuilderPageState extends State<FormBuilderPage> {
  LayoutState? _currentLayout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Builder')),
      body: FormLayout(
        toolbox: _createToolbox(),
        initialLayout: _currentLayout,
        onLayoutChanged: (layout) {
          setState(() {
            _currentLayout = layout;
          });
          _saveLayout(layout);
        },
      ),
    );
  }

  CategorizedToolbox _createToolbox() {
    return CategorizedToolbox(
      categories: [
        ToolboxCategory(
          name: 'Input Fields',
          icon: Icons.input,
          items: [
            ToolboxItem(
              name: 'text_field',
              icon: Icons.text_fields,
              label: 'Text Field',
              gridBuilder: (context, placement) => TextFormField(
                key: ValueKey(placement.id),
                decoration: InputDecoration(
                  labelText: placement.properties['label'] ?? 'Text',
                ),
              ),
            ),
            ToolboxItem(
              name: 'checkbox',
              icon: Icons.check_box,
              label: 'Checkbox',
              defaultWidth: 1,
              defaultHeight: 1,
              gridBuilder: (context, placement) => CheckboxListTile(
                key: ValueKey(placement.id),
                title: Text(placement.properties['label'] ?? 'Checkbox'),
                value: placement.properties['value'] ?? false,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        ToolboxCategory(
          name: 'Buttons',
          icon: Icons.smart_button,
          items: [
            ToolboxItem(
              name: 'button',
              icon: Icons.button_base,
              label: 'Button',
              defaultWidth: 1,
              defaultHeight: 1,
              gridBuilder: (context, placement) => ElevatedButton(
                key: ValueKey(placement.id),
                onPressed: () {},
                child: Text(placement.properties['label'] ?? 'Button'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveLayout(LayoutState layout) async {
    // Save to SharedPreferences or backend
    final json = layout.toJson();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_layout', jsonEncode(json));
  }
}
```

### Loading a Saved Layout

```dart
Future<LayoutState?> _loadLayout() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('saved_layout');
  
  if (jsonString != null) {
    try {
      final json = jsonDecode(jsonString);
      return LayoutState.fromJson(json);
    } catch (e) {
      print('Failed to load layout: $e');
    }
  }
  
  return null;
}
```

## Advanced Features

### Custom Widget Properties

Create widgets with custom property editors:

```dart
class CustomTextField extends StatelessWidget {
  final WidgetPlacement placement;
  
  const CustomTextField(this.placement);
  
  @override
  Widget build(BuildContext context) {
    final properties = placement.properties;
    
    return TextFormField(
      key: ValueKey(placement.id),
      decoration: InputDecoration(
        labelText: properties['label'] ?? 'Text Field',
        hintText: properties['placeholder'],
        helperText: properties['helperText'],
        prefixIcon: properties['icon'] != null 
          ? Icon(IconData(properties['icon'])) 
          : null,
      ),
      validator: _getValidator(properties['validation']),
      maxLength: properties['maxLength'],
      obscureText: properties['obscureText'] ?? false,
    );
  }
  
  FormFieldValidator<String>? _getValidator(String? validationType) {
    switch (validationType) {
      case 'email':
        return (value) => value?.contains('@') ?? false 
          ? null 
          : 'Please enter a valid email';
      case 'required':
        return (value) => value?.isNotEmpty ?? false 
          ? null 
          : 'This field is required';
      default:
        return null;
    }
  }
}
```

### Programmatic Control

Use the `FormLayoutController` for programmatic control:

```dart
class ControlledFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useFormLayout(
      LayoutState.empty(),
      undoLimit: 50,
    );
    
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: controller.canUndo ? controller.undo : null,
              child: Text('Undo'),
            ),
            ElevatedButton(
              onPressed: controller.canRedo ? controller.redo : null,
              child: Text('Redo'),
            ),
            ElevatedButton(
              onPressed: () => controller.togglePreviewMode(),
              child: Text(controller.isPreviewMode ? 'Edit' : 'Preview'),
            ),
          ],
        ),
        Expanded(
          child: FormLayout(
            toolbox: createToolbox(),
            initialLayout: controller.state,
            onLayoutChanged: (layout) {
              // Controller automatically manages state
            },
          ),
        ),
      ],
    );
  }
}
```

### Theme Customization

Customize the appearance with themes:

```dart
FormLayout(
  toolbox: myToolbox,
  theme: ThemeData(
    primarySwatch: Colors.blue,
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
    ),
  ),
  animationSettings: AnimationSettings(
    enableAnimations: true,
    animationDuration: Duration(milliseconds: 200),
    animationCurve: Curves.easeInOut,
  ),
)
```

### Export and Import

Enable users to export and import form layouts:

```dart
FormLayout(
  toolbox: myToolbox,
  onExportLayout: (jsonString) {
    // Option 1: Copy to clipboard
    Clipboard.setData(ClipboardData(text: jsonString));
    
    // Option 2: Share via platform share
    Share.share(jsonString, subject: 'Form Layout');
    
    // Option 3: Save to file
    final file = File('layout.json');
    file.writeAsString(jsonString);
  },
  onImportLayout: (layout, error) {
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    } else if (layout != null) {
      setState(() {
        _currentLayout = layout;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Layout imported successfully')),
      );
    }
  },
)
```

## API Reference

### Main Classes

#### FormLayout

The main widget for creating form builders.

**Constructor Parameters:**
- `toolbox` (required): Widget toolbox configuration
- `initialLayout`: Initial layout state
- `onLayoutChanged`: Layout change callback
- `showToolbox`: Whether to show the toolbox (default: true)
- `toolboxPosition`: Horizontal or vertical position
- `toolboxWidth`/`toolboxHeight`: Toolbox dimensions
- `enableUndo`: Enable undo/redo (default: true)
- `undoLimit`: Maximum undo history (default: 50)
- `theme`: Custom theme
- `animationSettings`: Animation configuration
- `onExportLayout`: Export callback
- `onImportLayout`: Import callback

#### LayoutState

Immutable representation of the form layout.

**Key Methods:**
- `empty()`: Create empty layout
- `addWidget(placement)`: Add a widget
- `removeWidget(id)`: Remove a widget
- `updateWidget(id, placement)`: Update widget
- `canAddWidget(placement)`: Check if widget can be added
- `resizeGrid(dimensions)`: Resize the grid
- `toJson()`/`fromJson()`: Serialization

#### WidgetPlacement

Represents a widget's position and configuration.

**Properties:**
- `id`: Unique identifier
- `widgetName`: Widget type
- `column`/`row`: Grid position
- `width`/`height`: Size in cells
- `properties`: Custom configuration

**Key Methods:**
- `fitsInGrid(dimensions)`: Check grid fit
- `overlaps(other)`: Check overlap
- `copyWith()`: Create modified copy
- `toJson()`/`fromJson()`: Serialization

#### GridDimensions

Grid size configuration.

**Properties:**
- `columns`: Number of columns (1-12)
- `rows`: Number of rows (1-20)

**Constants:**
- `minColumns`/`maxColumns`: Column limits
- `minRows`/`maxRows`: Row limits

### Toolbox Classes

#### CategorizedToolbox

Organizes widgets into categories.

```dart
CategorizedToolbox(
  categories: [
    ToolboxCategory(
      name: 'Category Name',
      icon: Icons.category,
      items: [...],
    ),
  ],
)
```

#### ToolboxItem

Defines a draggable widget type.

```dart
ToolboxItem(
  name: 'widget_type',
  icon: Icons.widget,
  label: 'Display Name',
  defaultWidth: 2,
  defaultHeight: 1,
  gridBuilder: (context, placement) => MyWidget(placement),
)
```

## Integration Guide

### State Management

FormBuilder works with any state management solution:

#### Provider Example

```dart
class FormBuilderProvider extends ChangeNotifier {
  LayoutState _layout = LayoutState.empty();
  
  LayoutState get layout => _layout;
  
  void updateLayout(LayoutState newLayout) {
    _layout = newLayout;
    notifyListeners();
    _persistLayout();
  }
  
  Future<void> _persistLayout() async {
    // Save to backend or local storage
  }
}

// In your widget
Consumer<FormBuilderProvider>(
  builder: (context, provider, _) => FormLayout(
    toolbox: myToolbox,
    initialLayout: provider.layout,
    onLayoutChanged: provider.updateLayout,
  ),
)
```

#### Riverpod Example

```dart
final layoutProvider = StateNotifierProvider<LayoutNotifier, LayoutState>((ref) {
  return LayoutNotifier();
});

class LayoutNotifier extends StateNotifier<LayoutState> {
  LayoutNotifier() : super(LayoutState.empty());
  
  void updateLayout(LayoutState layout) {
    state = layout;
  }
}

// In your widget
class FormBuilderView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(layoutProvider);
    
    return FormLayout(
      toolbox: myToolbox,
      initialLayout: layout,
      onLayoutChanged: (newLayout) {
        ref.read(layoutProvider.notifier).updateLayout(newLayout);
      },
    );
  }
}
```

### Backend Integration

Save and load layouts from a backend:

```dart
class FormService {
  final String apiUrl = 'https://api.example.com';
  
  Future<LayoutState?> loadLayout(String formId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/forms/$formId'),
      );
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return LayoutState.fromJson(json);
      }
    } catch (e) {
      print('Failed to load layout: $e');
    }
    return null;
  }
  
  Future<bool> saveLayout(String formId, LayoutState layout) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/forms/$formId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(layout.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to save layout: $e');
      return false;
    }
  }
}
```

### Form Submission

Handle form submission with placed widgets:

```dart
class FormRenderer extends StatefulWidget {
  final LayoutState layout;
  
  const FormRenderer({required this.layout});
  
  @override
  _FormRendererState createState() => _FormRendererState();
}

class _FormRendererState extends State<FormRenderer> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.layout.dimensions.columns,
              ),
              itemCount: widget.layout.widgets.length,
              itemBuilder: (context, index) {
                final placement = widget.layout.widgets[index];
                return _buildFormField(placement);
              },
            ),
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormField(WidgetPlacement placement) {
    switch (placement.widgetName) {
      case 'text_field':
        return TextFormField(
          decoration: InputDecoration(
            labelText: placement.properties['label'],
          ),
          onSaved: (value) => _formData[placement.id] = value,
          validator: (value) {
            if (placement.properties['required'] == true && 
                (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        );
      // Add more widget types...
      default:
        return Container();
    }
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Process _formData
      print('Form data: $_formData');
    }
  }
}
```

## Troubleshooting

### Common Issues

#### Widgets Not Dragging

**Problem**: Widgets from toolbox won't drag to grid.

**Solutions**:
1. Ensure `gridBuilder` is properly defined in ToolboxItem
2. Check that widget names match between toolbox and builders
3. Verify grid is not in preview mode

#### Layout Not Persisting

**Problem**: Layout changes are lost on reload.

**Solutions**:
1. Implement `onLayoutChanged` callback
2. Ensure proper JSON serialization
3. Check storage permissions

#### Performance Issues

**Problem**: Lag with many widgets.

**Solutions**:
1. Use `AnimationSettings` to reduce animations
2. Implement virtual scrolling for large grids
3. Optimize widget builders

### Debug Tips

Enable debug output:

```dart
// Log all layout changes
onLayoutChanged: (layout) {
  debugPrint('Layout updated: ${layout.widgets.length} widgets');
  debugPrint('JSON: ${jsonEncode(layout.toJson())}');
},

// Track widget operations
FormLayout(
  toolbox: myToolbox,
  onLayoutChanged: (layout) {
    for (final widget in layout.widgets) {
      debugPrint('Widget ${widget.id} at (${widget.column}, ${widget.row})');
    }
  },
)
```

### Best Practices

1. **Widget IDs**: Always use unique, stable IDs for widgets
2. **Properties**: Validate widget properties before use
3. **Grid Size**: Start with smaller grids and expand as needed
4. **Persistence**: Save layouts frequently to prevent data loss
5. **Testing**: Test with different screen sizes and orientations

## Further Resources

- [API Reference](https://pub.dev/documentation/formbuilder/latest/)
- [Example App](https://github.com/yourusername/formbuilder/tree/main/example)
- [Video Tutorials](https://youtube.com/formbuilder-tutorials)
- [Community Forum](https://forum.formbuilder.dev)

For additional help, please file issues on our [GitHub repository](https://github.com/yourusername/formbuilder/issues).