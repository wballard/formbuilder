# Widget Documentation

This guide covers all widgets available in FormBuilder and how to use them effectively.

## Core Widget Components

### FormLayout

The main container widget that provides the form building interface.

```dart
FormLayout(
  toolbox: myToolbox,           // Required: Available widgets
  initialLayout: savedLayout,   // Optional: Previously saved layout
  showToolbox: true,           // Show/hide widget toolbox
  toolboxPosition: Axis.horizontal, // Toolbox position
  enableUndo: true,            // Enable undo/redo
  theme: customTheme,          // Custom styling
  onLayoutChanged: (layout) {  // Handle changes
    saveLayout(layout);
  },
)
```

**Key Features:**
- Drag-and-drop interface
- Grid-based layout system
- Built-in undo/redo
- Preview mode
- Keyboard navigation
- Responsive design

### GridDragTarget

The grid area where widgets are placed. This is automatically created by FormLayout.

**Features:**
- Visual grid lines
- Drag indicators
- Drop zones
- Selection highlighting
- Resize handles

### WidgetToolbox

Container for draggable widget types.

```dart
CategorizedToolbox(
  categories: [
    ToolboxCategory(
      name: 'Input Fields',
      icon: Icons.input,
      items: [...],
    ),
  ],
)
```

## Built-in Form Widgets

### Text Input Widgets

#### TextField
Basic text input field.

```dart
ToolboxItem(
  name: 'text_field',
  icon: Icons.text_fields,
  label: 'Text Field',
  defaultWidth: 2,
  defaultHeight: 1,
  gridBuilder: (context, placement) => TextFormField(
    key: ValueKey(placement.id),
    decoration: InputDecoration(
      labelText: placement.properties['label'] ?? 'Text Field',
      hintText: placement.properties['hint'],
      helperText: placement.properties['helper'],
      border: OutlineInputBorder(),
    ),
    validator: getValidator(placement.properties['validation']),
    maxLength: placement.properties['maxLength'],
  ),
  defaultProperties: {
    'label': 'Text Field',
    'hint': 'Enter text',
    'validation': 'none',
  },
)
```

**Properties:**
- `label`: Field label text
- `hint`: Placeholder text
- `helper`: Helper text below field
- `validation`: Validation type (email, phone, required)
- `maxLength`: Maximum character count

#### TextArea
Multi-line text input.

```dart
ToolboxItem(
  name: 'text_area',
  icon: Icons.notes,
  label: 'Text Area',
  defaultWidth: 3,
  defaultHeight: 2,
  gridBuilder: (context, placement) => TextFormField(
    key: ValueKey(placement.id),
    maxLines: placement.properties['rows'] ?? 4,
    decoration: InputDecoration(
      labelText: placement.properties['label'] ?? 'Text Area',
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    ),
  ),
  defaultProperties: {
    'label': 'Comments',
    'rows': 4,
    'maxLength': 500,
  },
)
```

**Properties:**
- `rows`: Number of visible text lines
- `maxLength`: Maximum character count

#### Password Field
Secure text input with visibility toggle.

```dart
class PasswordField extends StatefulWidget {
  final WidgetPlacement placement;
  
  const PasswordField({required this.placement});
  
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(widget.placement.id),
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.placement.properties['label'] ?? 'Password',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }
}
```

### Selection Widgets

#### Dropdown
Single selection from a list.

```dart
ToolboxItem(
  name: 'dropdown',
  icon: Icons.arrow_drop_down,
  label: 'Dropdown',
  defaultWidth: 2,
  defaultHeight: 1,
  gridBuilder: (context, placement) {
    final items = placement.properties['items'] as List? ?? [];
    return DropdownButtonFormField<String>(
      key: ValueKey(placement.id),
      decoration: InputDecoration(
        labelText: placement.properties['label'],
        border: OutlineInputBorder(),
      ),
      items: items.map((item) => DropdownMenuItem<String>(
        value: item['value'],
        child: Text(item['label']),
      )).toList(),
      onChanged: (value) {},
      validator: placement.properties['required'] == true
          ? (value) => value == null ? 'Please select an option' : null
          : null,
    );
  },
  defaultProperties: {
    'label': 'Select Option',
    'items': [
      {'value': 'option1', 'label': 'Option 1'},
      {'value': 'option2', 'label': 'Option 2'},
    ],
    'required': false,
  },
)
```

#### Radio Group
Single selection with radio buttons.

```dart
class RadioGroupWidget extends StatefulWidget {
  final WidgetPlacement placement;
  
  const RadioGroupWidget({required this.placement});
  
  @override
  _RadioGroupWidgetState createState() => _RadioGroupWidgetState();
}

class _RadioGroupWidgetState extends State<RadioGroupWidget> {
  String? _selectedValue;
  
  @override
  Widget build(BuildContext context) {
    final options = widget.placement.properties['options'] as List? ?? [];
    final label = widget.placement.properties['label'] ?? 'Select One';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        ...options.map((option) => RadioListTile<String>(
          title: Text(option['label']),
          value: option['value'],
          groupValue: _selectedValue,
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        )),
      ],
    );
  }
}
```

#### Checkbox
Boolean selection.

```dart
ToolboxItem(
  name: 'checkbox',
  icon: Icons.check_box,
  label: 'Checkbox',
  defaultWidth: 2,
  defaultHeight: 1,
  gridBuilder: (context, placement) => CheckboxFormField(
    key: ValueKey(placement.id),
    title: Text(placement.properties['label'] ?? 'Checkbox'),
    initialValue: placement.properties['checked'] ?? false,
    validator: placement.properties['required'] == true
        ? (value) => value != true ? 'This field is required' : null
        : null,
  ),
)
```

#### Switch
Toggle switch for on/off states.

```dart
class SwitchWidget extends StatefulWidget {
  final WidgetPlacement placement;
  
  const SwitchWidget({required this.placement});
  
  @override
  _SwitchWidgetState createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  bool _value = false;
  
  @override
  void initState() {
    super.initState();
    _value = widget.placement.properties['value'] ?? false;
  }
  
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.placement.properties['label'] ?? 'Enable'),
      subtitle: widget.placement.properties['description'] != null
          ? Text(widget.placement.properties['description'])
          : null,
      value: _value,
      onChanged: (value) {
        setState(() {
          _value = value;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
```

### Date & Time Widgets

#### Date Picker
Single date selection.

```dart
class DatePickerWidget extends StatefulWidget {
  final WidgetPlacement placement;
  
  const DatePickerWidget({required this.placement});
  
  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? _selectedDate;
  final _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(widget.placement.id),
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.placement.properties['label'] ?? 'Date',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _controller.text = DateFormat('yyyy-MM-dd').format(picked);
          });
        }
      },
      validator: widget.placement.properties['required'] == true
          ? (value) => value?.isEmpty ?? true ? 'Please select a date' : null
          : null,
    );
  }
}
```

#### Time Picker
Time selection widget.

```dart
class TimePickerWidget extends StatefulWidget {
  final WidgetPlacement placement;
  
  const TimePickerWidget({required this.placement});
  
  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  TimeOfDay? _selectedTime;
  final _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(widget.placement.id),
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.placement.properties['label'] ?? 'Time',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.access_time),
      ),
      readOnly: true,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        
        if (picked != null) {
          setState(() {
            _selectedTime = picked;
            _controller.text = picked.format(context);
          });
        }
      },
    );
  }
}
```

### Action Widgets

#### Button
Standard action button.

```dart
ToolboxItem(
  name: 'button',
  icon: Icons.smart_button,
  label: 'Button',
  defaultWidth: 1,
  defaultHeight: 1,
  gridBuilder: (context, placement) => ElevatedButton(
    key: ValueKey(placement.id),
    onPressed: () {
      // Handle button press
      final action = placement.properties['action'];
      if (action == 'submit') {
        Form.of(context)?.validate();
      } else if (action == 'reset') {
        Form.of(context)?.reset();
      }
    },
    style: ElevatedButton.styleFrom(
      minimumSize: Size.expand,
      backgroundColor: placement.properties['color'] != null
          ? Color(placement.properties['color'])
          : null,
    ),
    child: Text(
      placement.properties['label'] ?? 'Button',
      style: TextStyle(fontSize: 16),
    ),
  ),
  defaultProperties: {
    'label': 'Submit',
    'action': 'submit',
  },
)
```

### Display Widgets

#### Label
Static text display.

```dart
ToolboxItem(
  name: 'label',
  icon: Icons.label,
  label: 'Label',
  defaultWidth: 2,
  defaultHeight: 1,
  gridBuilder: (context, placement) => Container(
    key: ValueKey(placement.id),
    padding: EdgeInsets.all(8),
    alignment: _getAlignment(placement.properties['align']),
    child: Text(
      placement.properties['text'] ?? 'Label',
      style: TextStyle(
        fontSize: placement.properties['fontSize']?.toDouble() ?? 16,
        fontWeight: placement.properties['bold'] == true
            ? FontWeight.bold
            : FontWeight.normal,
        color: placement.properties['color'] != null
            ? Color(placement.properties['color'])
            : null,
      ),
    ),
  ),
  defaultProperties: {
    'text': 'Label Text',
    'fontSize': 16,
    'align': 'left',
  },
)
```

#### Divider
Visual separator.

```dart
ToolboxItem(
  name: 'divider',
  icon: Icons.horizontal_rule,
  label: 'Divider',
  defaultWidth: 4,
  defaultHeight: 1,
  gridBuilder: (context, placement) => Center(
    key: ValueKey(placement.id),
    child: Divider(
      thickness: placement.properties['thickness']?.toDouble() ?? 1,
      color: placement.properties['color'] != null
          ? Color(placement.properties['color'])
          : null,
    ),
  ),
)
```

## Widget Configuration

### Common Properties

Most widgets support these standard properties:

- `label`: Display label
- `required`: Whether the field is required
- `enabled`: Whether the widget is interactive
- `visible`: Whether the widget is shown
- `helperText`: Additional help text
- `errorText`: Custom error message

### Validation

Built-in validation types:

```dart
FormFieldValidator<String>? getValidator(String? type) {
  switch (type) {
    case 'required':
      return (value) => value?.isEmpty ?? true ? 'Required' : null;
    case 'email':
      return (value) {
        if (value?.isEmpty ?? true) return null;
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return emailRegex.hasMatch(value!) ? null : 'Invalid email';
      };
    case 'phone':
      return (value) {
        if (value?.isEmpty ?? true) return null;
        final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
        return phoneRegex.hasMatch(value!) ? null : 'Invalid phone';
      };
    case 'number':
      return (value) {
        if (value?.isEmpty ?? true) return null;
        return int.tryParse(value!) != null ? null : 'Must be a number';
      };
    default:
      return null;
  }
}
```

### Styling

Customize widget appearance:

```dart
// Global theme
FormLayout(
  theme: ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.grey[100],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  ),
)

// Per-widget styling
gridBuilder: (context, placement) => TextFormField(
  decoration: InputDecoration(
    fillColor: Color(placement.properties['backgroundColor'] ?? 0xFFFFFFFF),
    border: placement.properties['borderStyle'] == 'none'
        ? InputBorder.none
        : OutlineInputBorder(),
  ),
)
```

## Best Practices

### 1. Widget Keys
Always use placement ID as the widget key:
```dart
key: ValueKey(placement.id),
```

### 2. Property Defaults
Provide sensible defaults:
```dart
final label = placement.properties['label'] ?? 'Default Label';
```

### 3. Size Awareness
Respect grid cell dimensions:
```dart
minimumSize: Size.expand, // For buttons
maxLines: null,          // For text areas
```

### 4. State Management
Handle state changes properly:
```dart
onChanged: (value) {
  // Update form data
  // Trigger validation
  // Notify listeners
}
```

### 5. Accessibility
Include semantic labels:
```dart
Semantics(
  label: 'Required email field',
  child: TextFormField(...),
)
```

## Creating Custom Widgets

See the [Custom Widget Guide](cookbook/02-adding-custom-widgets.md) for detailed instructions on creating your own widgets.

## Widget Gallery

Visit our [interactive widget gallery](https://formbuilder-demo.com/widgets) to see all widgets in action.