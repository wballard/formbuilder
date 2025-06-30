# Migration Guide

This guide helps you migrate between different versions of FormBuilder and handle breaking changes.

## Version History

### Current Version: 1.0.0

Initial stable release with:
- Complete drag-and-drop form builder
- Grid-based layout system
- Undo/redo support
- Import/export functionality
- Comprehensive widget toolbox
- Full keyboard navigation
- Accessibility support

## Migrating from Pre-1.0 Versions

### Breaking Changes

#### Layout State Structure

The LayoutState JSON format has changed to support additional metadata:

**Old Format (pre-1.0):**
```json
{
  "dimensions": {
    "columns": 4,
    "rows": 4
  },
  "widgets": [
    {
      "id": "widget-1",
      "widgetName": "text_field",
      "column": 0,
      "row": 0,
      "width": 2,
      "height": 1
    }
  ]
}
```

**New Format (1.0.0):**
```json
{
  "version": "1.0.0",
  "timestamp": "2024-01-20T10:00:00Z",
  "metadata": {
    "widgetCount": 1,
    "gridSize": 16,
    "totalArea": 2
  },
  "dimensions": {
    "columns": 4,
    "rows": 4
  },
  "widgets": [
    {
      "id": "widget-1",
      "widgetName": "text_field",
      "column": 0,
      "row": 0,
      "width": 2,
      "height": 1,
      "properties": {}
    }
  ]
}
```

**Migration Code:**
```dart
Map<String, dynamic> migrateLayoutToV1(Map<String, dynamic> oldLayout) {
  // Check if already migrated
  if (oldLayout.containsKey('version')) {
    return oldLayout;
  }
  
  // Calculate metadata
  final widgets = oldLayout['widgets'] as List;
  final dimensions = oldLayout['dimensions'] as Map<String, dynamic>;
  final columns = dimensions['columns'] as int;
  final rows = dimensions['rows'] as int;
  
  int totalArea = 0;
  for (final widget in widgets) {
    totalArea += (widget['width'] as int) * (widget['height'] as int);
  }
  
  // Add properties field to widgets if missing
  final migratedWidgets = widgets.map((widget) {
    final w = Map<String, dynamic>.from(widget);
    if (!w.containsKey('properties')) {
      w['properties'] = {};
    }
    return w;
  }).toList();
  
  // Create migrated layout
  return {
    'version': '1.0.0',
    'timestamp': DateTime.now().toIso8601String(),
    'metadata': {
      'widgetCount': widgets.length,
      'gridSize': columns * rows,
      'totalArea': totalArea,
    },
    'dimensions': dimensions,
    'widgets': migratedWidgets,
  };
}

// Usage
LayoutState? loadAndMigrateLayout(String jsonString) {
  try {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final migrated = migrateLayoutToV1(json);
    return LayoutState.fromJson(migrated);
  } catch (e) {
    print('Failed to migrate layout: $e');
    return null;
  }
}
```

#### Widget Properties

Widget properties are now required and immutable:

**Old Usage:**
```dart
// Pre-1.0: Properties were optional
WidgetPlacement(
  id: 'widget-1',
  widgetName: 'text_field',
  column: 0,
  row: 0,
  width: 2,
  height: 1,
)
```

**New Usage:**
```dart
// 1.0.0: Properties are required (can be empty)
WidgetPlacement(
  id: 'widget-1',
  widgetName: 'text_field',
  column: 0,
  row: 0,
  width: 2,
  height: 1,
  properties: {}, // Required, even if empty
)
```

#### Toolbox Structure

The toolbox now uses a categorized structure:

**Old Toolbox:**
```dart
// Pre-1.0: Flat list of items
final toolbox = Toolbox(
  items: [
    ToolboxItem(name: 'text_field', ...),
    ToolboxItem(name: 'button', ...),
  ],
);
```

**New Toolbox:**
```dart
// 1.0.0: Categorized structure
final toolbox = CategorizedToolbox(
  categories: [
    ToolboxCategory(
      name: 'Input Fields',
      icon: Icons.input,
      items: [
        ToolboxItem(name: 'text_field', ...),
      ],
    ),
    ToolboxCategory(
      name: 'Actions',
      icon: Icons.touch_app,
      items: [
        ToolboxItem(name: 'button', ...),
      ],
    ),
  ],
);
```

**Migration Helper:**
```dart
CategorizedToolbox migrateToolbox(Toolbox oldToolbox) {
  // Group items by type
  final inputItems = <ToolboxItem>[];
  final actionItems = <ToolboxItem>[];
  final displayItems = <ToolboxItem>[];
  
  for (final item in oldToolbox.items) {
    if (['text_field', 'text_area', 'dropdown'].contains(item.name)) {
      inputItems.add(item);
    } else if (['button', 'submit'].contains(item.name)) {
      actionItems.add(item);
    } else {
      displayItems.add(item);
    }
  }
  
  final categories = <ToolboxCategory>[];
  
  if (inputItems.isNotEmpty) {
    categories.add(ToolboxCategory(
      name: 'Input Fields',
      icon: Icons.input,
      items: inputItems,
    ));
  }
  
  if (actionItems.isNotEmpty) {
    categories.add(ToolboxCategory(
      name: 'Actions',
      icon: Icons.touch_app,
      items: actionItems,
    ));
  }
  
  if (displayItems.isNotEmpty) {
    categories.add(ToolboxCategory(
      name: 'Display',
      icon: Icons.visibility,
      items: displayItems,
    ));
  }
  
  return CategorizedToolbox(categories: categories);
}
```

### API Changes

#### FormLayout Widget

**Old Parameters:**
```dart
// Pre-1.0
FormLayout(
  toolbox: myToolbox,
  layout: myLayout, // Changed
  onChanged: (layout) {}, // Changed
  showPreview: true, // Removed
)
```

**New Parameters:**
```dart
// 1.0.0
FormLayout(
  toolbox: myToolbox,
  initialLayout: myLayout, // Renamed
  onLayoutChanged: (layout) {}, // Renamed
  // Preview mode now controlled by FormLayoutController
  enableUndo: true, // New
  undoLimit: 50, // New
  theme: myTheme, // New
  animationSettings: settings, // New
  onExportLayout: (json) {}, // New
  onImportLayout: (layout, error) {}, // New
)
```

#### Controller Access

**Old Pattern:**
```dart
// Pre-1.0: Direct state manipulation
class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  LayoutState _layout = LayoutState.empty();
  
  void _addWidget(WidgetPlacement placement) {
    setState(() {
      _layout = _layout.addWidget(placement);
    });
  }
}
```

**New Pattern:**
```dart
// 1.0.0: Use controller via hooks
class MyForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useFormLayout(
      LayoutState.empty(),
      undoLimit: 50,
    );
    
    // Controller handles state management
    controller.addWidget(placement);
    controller.undo();
    controller.togglePreviewMode();
    
    return FormLayout(
      toolbox: myToolbox,
      initialLayout: controller.state,
    );
  }
}
```

### Deprecated Features

#### Direct Grid Manipulation

**Deprecated:**
```dart
// Don't use GridWidget directly
GridWidget(
  dimensions: dimensions,
  widgets: widgets,
  onDrop: (placement) {},
)
```

**Use Instead:**
```dart
// Use FormLayout with proper toolbox
FormLayout(
  toolbox: myToolbox,
  onLayoutChanged: (layout) {},
)
```

#### Manual Drag Handling

**Deprecated:**
```dart
// Don't implement drag handling manually
Draggable<ToolboxItem>(
  data: item,
  child: ItemWidget(item),
  feedback: DragFeedback(item),
)
```

**Use Instead:**
```dart
// FormLayout handles all drag operations
ToolboxItem(
  name: 'my_widget',
  icon: Icons.widgets,
  label: 'My Widget',
  gridBuilder: (context, placement) => MyWidget(placement),
)
```

## Migration Checklist

### Before Migration

- [ ] Backup existing layouts and data
- [ ] Document custom widget implementations
- [ ] Test current functionality
- [ ] Review breaking changes

### During Migration

- [ ] Update dependencies in pubspec.yaml
- [ ] Migrate layout JSON files
- [ ] Update toolbox structure
- [ ] Convert to new API patterns
- [ ] Update custom widgets
- [ ] Replace deprecated features

### After Migration

- [ ] Test all functionality
- [ ] Verify layout loading/saving
- [ ] Check custom widget behavior
- [ ] Update documentation
- [ ] Train users on new features

## Common Migration Issues

### Issue: Layouts Not Loading

**Symptom:** Old layouts fail to load with errors

**Solution:**
```dart
Future<LayoutState?> safeLoadLayout(String jsonString) async {
  try {
    final json = jsonDecode(jsonString);
    
    // Try direct load first
    try {
      return LayoutState.fromJson(json);
    } catch (e) {
      // Attempt migration
      final migrated = migrateLayoutToV1(json);
      return LayoutState.fromJson(migrated);
    }
  } catch (e) {
    print('Failed to load layout: $e');
    // Return empty layout as fallback
    return LayoutState.empty();
  }
}
```

### Issue: Missing Widget Properties

**Symptom:** Widgets crash due to missing properties

**Solution:**
```dart
class SafeWidget extends StatelessWidget {
  final WidgetPlacement placement;
  
  const SafeWidget({required this.placement});
  
  @override
  Widget build(BuildContext context) {
    // Provide defaults for all properties
    final label = placement.properties['label'] ?? 'Default Label';
    final required = placement.properties['required'] ?? false;
    final enabled = placement.properties['enabled'] ?? true;
    
    // Safe type casting
    final maxLength = placement.properties['maxLength'] as int? ?? 100;
    
    return TextFormField(
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
      validator: required 
          ? (value) => value?.isEmpty ?? true ? 'Required' : null
          : null,
      maxLength: maxLength,
    );
  }
}
```

### Issue: Toolbox Categories Missing

**Symptom:** Empty toolbox or missing widgets

**Solution:**
```dart
CategorizedToolbox createCompatibleToolbox(List<ToolboxItem> items) {
  if (items.isEmpty) {
    // Provide default items
    items = [
      ToolboxItem(
        name: 'text_field',
        icon: Icons.text_fields,
        label: 'Text Field',
        gridBuilder: (context, placement) => 
            TextField(key: ValueKey(placement.id)),
      ),
    ];
  }
  
  // Ensure at least one category exists
  return CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Widgets',
        icon: Icons.widgets,
        items: items,
      ),
    ],
  );
}
```

## Future Compatibility

### Preparing for Future Updates

1. **Use Version Checks:**
```dart
class VersionAwareLayout {
  static LayoutState fromJson(Map<String, dynamic> json) {
    final version = json['version'] ?? '0.0.0';
    
    switch (version) {
      case '1.0.0':
        return _fromJsonV1(json);
      case '1.1.0':
        return _fromJsonV1_1(json);
      default:
        // Attempt migration
        return _migrateAndLoad(json);
    }
  }
}
```

2. **Abstract Widget Properties:**
```dart
abstract class WidgetPropertyHandler {
  dynamic getProperty(String key, dynamic defaultValue);
  void setProperty(String key, dynamic value);
  Map<String, dynamic> getAllProperties();
}
```

3. **Use Feature Detection:**
```dart
bool supportsFeature(String feature) {
  const supportedFeatures = {
    'undo_redo': true,
    'categories': true,
    'animations': true,
    'themes': true,
  };
  
  return supportedFeatures[feature] ?? false;
}
```

## Getting Help

### Resources

- [API Documentation](api_guide.md)
- [GitHub Issues](https://github.com/yourusername/formbuilder/issues)
- [Discord Community](https://discord.gg/formbuilder)
- [Stack Overflow Tag](https://stackoverflow.com/questions/tagged/flutter-formbuilder)

### Migration Support

If you encounter issues during migration:

1. Check the [troubleshooting guide](api_guide.md#troubleshooting)
2. Search existing GitHub issues
3. Create a detailed bug report with:
   - FormBuilder version (old and new)
   - Flutter version
   - Sample code reproducing the issue
   - Error messages and stack traces

### Professional Support

For enterprise migrations or custom requirements, contact support@formbuilder.dev