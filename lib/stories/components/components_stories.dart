import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

final List<Story> componentStories = [
  // Text Input Components
  Story(
    name: 'Components/Text Field',
    description: 'Basic text input field with various configurations',
    builder: (context) => const TextFieldStory(),
  ),
  Story(
    name: 'Components/Text Area',
    description: 'Multi-line text input for longer content',
    builder: (context) => const TextAreaStory(),
  ),
  Story(
    name: 'Components/Password Field',
    description: 'Secure text input with visibility toggle',
    builder: (context) => const PasswordFieldStory(),
  ),
  Story(
    name: 'Components/Number Field',
    description: 'Numeric input with validation',
    builder: (context) => const NumberFieldStory(),
  ),
  
  // Selection Components
  Story(
    name: 'Components/Dropdown',
    description: 'Single selection from a list',
    builder: (context) => const DropdownStory(),
  ),
  Story(
    name: 'Components/Checkbox',
    description: 'Boolean selection widget',
    builder: (context) => const CheckboxStory(),
  ),
  Story(
    name: 'Components/Radio Group',
    description: 'Single selection with radio buttons',
    builder: (context) => const RadioGroupStory(),
  ),
  Story(
    name: 'Components/Switch',
    description: 'Toggle switch for on/off states',
    builder: (context) => const SwitchStory(),
  ),
  
  // Date/Time Components
  Story(
    name: 'Components/Date Picker',
    description: 'Date selection widget',
    builder: (context) => const DatePickerStory(),
  ),
  Story(
    name: 'Components/Time Picker',
    description: 'Time selection widget',
    builder: (context) => const TimePickerStory(),
  ),
  Story(
    name: 'Components/Date Range',
    description: 'Date range selection',
    builder: (context) => const DateRangeStory(),
  ),
  
  // Action Components
  Story(
    name: 'Components/Button',
    description: 'Action buttons with various styles',
    builder: (context) => const ButtonStory(),
  ),
  Story(
    name: 'Components/Icon Button',
    description: 'Icon-based action buttons',
    builder: (context) => const IconButtonStory(),
  ),
  
  // Display Components
  Story(
    name: 'Components/Label',
    description: 'Static text display',
    builder: (context) => const LabelStory(),
  ),
  Story(
    name: 'Components/Divider',
    description: 'Visual separator',
    builder: (context) => const DividerStory(),
  ),
  Story(
    name: 'Components/Image',
    description: 'Image display widget',
    builder: (context) => const ImageStory(),
  ),
];

// Base story widget for consistent layout
class ComponentStoryBase extends StatelessWidget {
  final String title;
  final String description;
  final Widget preview;
  final Map<String, dynamic> properties;
  final String codeExample;

  const ComponentStoryBase({
    super.key,
    required this.title,
    required this.description,
    required this.preview,
    required this.properties,
    required this.codeExample,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Preview'),
                Tab(text: 'Properties'),
                Tab(text: 'Code'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Preview Tab
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: preview,
                      ),
                    ),
                  ),
                  // Properties Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: properties.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key),
                        subtitle: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  // Code Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      codeExample,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
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
}

// Text Field Story
class TextFieldStory extends HookWidget {
  const TextFieldStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Email Address',
    );
    
    final hint = context.knobs.text(
      label: 'Hint Text',
      initial: 'Enter your email',
    );
    
    final helper = context.knobs.text(
      label: 'Helper Text',
      initial: 'We\'ll never share your email',
    );
    
    final required = context.knobs.boolean(
      label: 'Required',
      initial: true,
    );
    
    final maxLength = context.knobs.nullableSlider(
      label: 'Max Length',
      min: 10,
      max: 100,
      initial: 50,
    );

    return ComponentStoryBase(
      title: 'Text Field',
      description: 'A basic text input field with customizable properties',
      preview: TextFormField(
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          helperText: helper,
          border: const OutlineInputBorder(),
        ),
        maxLength: maxLength?.toInt(),
        onChanged: (value) {
          context.actions.log('Text changed: $value');
        },
      ),
      properties: {
        'label': label,
        'hint': hint,
        'helper': helper,
        'required': required,
        'maxLength': maxLength?.toInt() ?? 'unlimited',
      },
      codeExample: '''
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
    validator: placement.properties['required'] == true
        ? (value) => value?.isEmpty ?? true ? 'Required' : null
        : null,
    maxLength: placement.properties['maxLength'],
  ),
  defaultProperties: {
    'label': '$label',
    'hint': '$hint',
    'helper': '$helper',
    'required': $required,
    'maxLength': ${maxLength?.toInt()},
  },
)
''',
    );
  }
}

// Text Area Story
class TextAreaStory extends HookWidget {
  const TextAreaStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Comments',
    );
    
    final rows = context.knobs.slider(
      label: 'Rows',
      min: 3,
      max: 10,
      initial: 5,
    );
    
    final maxLength = context.knobs.nullableSlider(
      label: 'Max Length',
      min: 100,
      max: 1000,
      initial: 500,
    );

    return ComponentStoryBase(
      title: 'Text Area',
      description: 'Multi-line text input for longer content',
      preview: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        maxLines: rows.toInt(),
        maxLength: maxLength?.toInt(),
        onChanged: (value) {
          context.actions.log('Text area changed: ${value.length} characters');
        },
      ),
      properties: {
        'label': label,
        'rows': rows.toInt(),
        'maxLength': maxLength?.toInt() ?? 'unlimited',
      },
      codeExample: '''
ToolboxItem(
  name: 'text_area',
  icon: Icons.notes,
  label: 'Text Area',
  defaultWidth: 3,
  defaultHeight: 2,
  gridBuilder: (context, placement) => TextFormField(
    key: ValueKey(placement.id),
    maxLines: placement.properties['rows'] ?? 5,
    decoration: InputDecoration(
      labelText: placement.properties['label'] ?? 'Text Area',
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    ),
    maxLength: placement.properties['maxLength'],
  ),
  defaultProperties: {
    'label': '$label',
    'rows': ${rows.toInt()},
    'maxLength': ${maxLength?.toInt()},
  },
)
''',
    );
  }
}

// Password Field Story
class PasswordFieldStory extends HookWidget {
  const PasswordFieldStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Password',
    );
    
    final showStrength = context.knobs.boolean(
      label: 'Show Strength Indicator',
      initial: true,
    );
    
    final minLength = context.knobs.slider(
      label: 'Minimum Length',
      min: 6,
      max: 12,
      initial: 8,
    );

    final obscureText = useState(true);
    final password = useState('');

    return ComponentStoryBase(
      title: 'Password Field',
      description: 'Secure text input with visibility toggle',
      preview: Column(
        children: [
          TextFormField(
            obscureText: obscureText.value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText.value ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  obscureText.value = !obscureText.value;
                  context.actions.log('Visibility toggled');
                },
              ),
            ),
            onChanged: (value) {
              password.value = value;
              context.actions.log('Password changed');
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < minLength) {
                return 'Password must be at least ${minLength.toInt()} characters';
              }
              return null;
            },
          ),
          if (showStrength && password.value.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PasswordStrengthIndicator(password: password.value),
          ],
        ],
      ),
      properties: {
        'label': label,
        'minLength': minLength.toInt(),
        'showStrength': showStrength,
      },
      codeExample: '''
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
        if (value.length < ${minLength.toInt()}) {
          return 'Password must be at least ${minLength.toInt()} characters';
        }
        return null;
      },
    );
  }
}
''',
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final color = _getStrengthColor(strength);
    final label = _getStrengthLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password Strength:', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  double _calculateStrength(String password) {
    if (password.length < 6) return 0.25;
    if (password.length < 8) return 0.5;
    if (password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]'))) {
      return 1.0;
    }
    return 0.75;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.amber;
    return Colors.green;
  }

  String _getStrengthLabel(double strength) {
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.5) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }
}

// Number Field Story
class NumberFieldStory extends HookWidget {
  const NumberFieldStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Quantity',
    );
    
    final min = context.knobs.slider(
      label: 'Minimum',
      min: 0,
      max: 10,
      initial: 1,
    );
    
    final max = context.knobs.slider(
      label: 'Maximum',
      min: 50,
      max: 1000,
      initial: 100,
    );
    
    final allowDecimals = context.knobs.boolean(
      label: 'Allow Decimals',
      initial: false,
    );

    return ComponentStoryBase(
      title: 'Number Field',
      description: 'Numeric input with validation',
      preview: TextFormField(
        keyboardType: TextInputType.numberWithOptions(
          decimal: allowDecimals,
        ),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          helperText: 'Enter a value between ${min.toInt()} and ${max.toInt()}',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a number';
          }
          final number = allowDecimals 
              ? double.tryParse(value) 
              : int.tryParse(value);
          if (number == null) {
            return 'Invalid number';
          }
          if (number < min) {
            return 'Minimum value is ${min.toInt()}';
          }
          if (number > max) {
            return 'Maximum value is ${max.toInt()}';
          }
          return null;
        },
        onChanged: (value) {
          context.actions.log('Number changed: $value');
        },
      ),
      properties: {
        'label': label,
        'min': min.toInt(),
        'max': max.toInt(),
        'allowDecimals': allowDecimals,
      },
      codeExample: '''
ToolboxItem(
  name: 'number_field',
  icon: Icons.numbers,
  label: 'Number Field',
  defaultWidth: 2,
  defaultHeight: 1,
  gridBuilder: (context, placement) => TextFormField(
    key: ValueKey(placement.id),
    keyboardType: TextInputType.numberWithOptions(
      decimal: placement.properties['allowDecimals'] ?? false,
    ),
    decoration: InputDecoration(
      labelText: placement.properties['label'] ?? 'Number',
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      // Number validation logic
    },
  ),
  defaultProperties: {
    'label': '$label',
    'min': ${min.toInt()},
    'max': ${max.toInt()},
    'allowDecimals': $allowDecimals,
  },
)
''',
    );
  }
}

// Dropdown Story
class DropdownStory extends HookWidget {
  const DropdownStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Select Country',
    );
    
    final required = context.knobs.boolean(
      label: 'Required',
      initial: true,
    );
    
    final searchable = context.knobs.boolean(
      label: 'Searchable',
      initial: false,
    );
    
    final items = [
      {'value': 'us', 'label': 'United States'},
      {'value': 'uk', 'label': 'United Kingdom'},
      {'value': 'ca', 'label': 'Canada'},
      {'value': 'au', 'label': 'Australia'},
      {'value': 'de', 'label': 'Germany'},
      {'value': 'fr', 'label': 'France'},
      {'value': 'jp', 'label': 'Japan'},
    ];
    
    final selectedValue = useState<String?>(null);

    return ComponentStoryBase(
      title: 'Dropdown',
      description: 'Single selection from a list of options',
      preview: DropdownButtonFormField<String>(
        value: selectedValue.value,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        items: items.map((item) => DropdownMenuItem<String>(
          value: item['value'] as String,
          child: Text(item['label'] as String),
        )).toList(),
        onChanged: (value) {
          selectedValue.value = value;
          context.actions.log('Selected: $value');
        },
        validator: required
            ? (value) => value == null ? 'Please select an option' : null
            : null,
      ),
      properties: {
        'label': label,
        'required': required,
        'searchable': searchable,
        'itemCount': items.length,
      },
      codeExample: '''
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
    'label': '$label',
    'required': $required,
    'items': ${items.map((e) => e.toString()).toList()},
  },
)
''',
    );
  }
}

// Checkbox Story
class CheckboxStory extends HookWidget {
  const CheckboxStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'I agree to the terms and conditions',
    );
    
    final required = context.knobs.boolean(
      label: 'Required',
      initial: true,
    );
    
    final checked = useState(false);

    return ComponentStoryBase(
      title: 'Checkbox',
      description: 'Boolean selection widget',
      preview: FormField<bool>(
        initialValue: checked.value,
        validator: required
            ? (value) => value != true ? 'This field is required' : null
            : null,
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: Text(label),
                value: checked.value,
                onChanged: (value) {
                  checked.value = value ?? false;
                  state.didChange(value);
                  context.actions.log('Checkbox changed: $value');
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      properties: {
        'label': label,
        'required': required,
        'checked': checked.value,
      },
      codeExample: '''
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
  defaultProperties: {
    'label': '$label',
    'required': $required,
    'checked': false,
  },
)
''',
    );
  }
}

// Radio Group Story
class RadioGroupStory extends HookWidget {
  const RadioGroupStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Select your preferred contact method',
    );
    
    final required = context.knobs.boolean(
      label: 'Required',
      initial: true,
    );
    
    final options = [
      {'value': 'email', 'label': 'Email'},
      {'value': 'phone', 'label': 'Phone'},
      {'value': 'sms', 'label': 'SMS'},
      {'value': 'mail', 'label': 'Postal Mail'},
    ];
    
    final selectedValue = useState<String?>(null);

    return ComponentStoryBase(
      title: 'Radio Group',
      description: 'Single selection with radio buttons',
      preview: FormField<String>(
        initialValue: selectedValue.value,
        validator: required
            ? (value) => value == null ? 'Please select an option' : null
            : null,
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...options.map((option) => RadioListTile<String>(
                title: Text(option['label'] as String),
                value: option['value'] as String,
                groupValue: selectedValue.value,
                onChanged: (value) {
                  selectedValue.value = value;
                  state.didChange(value);
                  context.actions.log('Radio selected: $value');
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              )),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      properties: {
        'label': label,
        'required': required,
        'options': options,
        'selected': selectedValue.value,
      },
      codeExample: '''
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
''',
    );
  }
}

// Switch Story
class SwitchStory extends HookWidget {
  const SwitchStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Enable notifications',
    );
    
    final subtitle = context.knobs.text(
      label: 'Subtitle',
      initial: 'Receive updates about your form submissions',
    );
    
    final enabled = useState(false);

    return ComponentStoryBase(
      title: 'Switch',
      description: 'Toggle switch for on/off states',
      preview: SwitchListTile(
        title: Text(label),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        value: enabled.value,
        onChanged: (value) {
          enabled.value = value;
          context.actions.log('Switch changed: $value');
        },
        contentPadding: EdgeInsets.zero,
      ),
      properties: {
        'label': label,
        'subtitle': subtitle,
        'value': enabled.value,
      },
      codeExample: '''
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
      subtitle: widget.placement.properties['subtitle'] != null
          ? Text(widget.placement.properties['subtitle'])
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
''',
    );
  }
}

// Date Picker Story
class DatePickerStory extends HookWidget {
  const DatePickerStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Select Date',
    );
    
    final allowPast = context.knobs.boolean(
      label: 'Allow Past Dates',
      initial: true,
    );
    
    final allowFuture = context.knobs.boolean(
      label: 'Allow Future Dates',
      initial: true,
    );
    
    final selectedDate = useState<DateTime?>(null);
    final controller = useTextEditingController();

    useEffect(() {
      if (selectedDate.value != null) {
        controller.text = '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}';
      }
      return null;
    }, [selectedDate.value]);

    return ComponentStoryBase(
      title: 'Date Picker',
      description: 'Date selection widget',
      preview: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () async {
          final now = DateTime.now();
          final firstDate = allowPast ? DateTime(1900) : now;
          final lastDate = allowFuture ? DateTime(2100) : now;
          
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate.value ?? now,
            firstDate: firstDate,
            lastDate: lastDate,
          );
          
          if (picked != null) {
            selectedDate.value = picked;
            context.actions.log('Date selected: $picked');
          }
        },
      ),
      properties: {
        'label': label,
        'allowPast': allowPast,
        'allowFuture': allowFuture,
        'selectedDate': selectedDate.value?.toString() ?? 'Not selected',
      },
      codeExample: '''
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
    );
  }
}
''',
    );
  }
}

// Time Picker Story
class TimePickerStory extends HookWidget {
  const TimePickerStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Select Time',
    );
    
    final use24Hour = context.knobs.boolean(
      label: 'Use 24-hour format',
      initial: false,
    );
    
    final selectedTime = useState<TimeOfDay?>(null);
    final controller = useTextEditingController();

    useEffect(() {
      if (selectedTime.value != null) {
        controller.text = selectedTime.value!.format(context);
      }
      return null;
    }, [selectedTime.value]);

    return ComponentStoryBase(
      title: 'Time Picker',
      description: 'Time selection widget',
      preview: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        readOnly: true,
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: selectedTime.value ?? TimeOfDay.now(),
            builder: use24Hour ? (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            } : null,
          );
          
          if (picked != null) {
            selectedTime.value = picked;
            context.actions.log('Time selected: ${picked.format(context)}');
          }
        },
      ),
      properties: {
        'label': label,
        'use24Hour': use24Hour,
        'selectedTime': selectedTime.value?.format(context) ?? 'Not selected',
      },
      codeExample: '''
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
''',
    );
  }
}

// Date Range Story
class DateRangeStory extends HookWidget {
  const DateRangeStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Select Date Range',
    );
    
    final selectedRange = useState<DateTimeRange?>(null);
    final controller = useTextEditingController();

    useEffect(() {
      if (selectedRange.value != null) {
        final start = selectedRange.value!.start;
        final end = selectedRange.value!.end;
        controller.text = '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
      }
      return null;
    }, [selectedRange.value]);

    return ComponentStoryBase(
      title: 'Date Range',
      description: 'Date range selection widget',
      preview: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.date_range),
        ),
        readOnly: true,
        onTap: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialDateRange: selectedRange.value,
          );
          
          if (picked != null) {
            selectedRange.value = picked;
            context.actions.log('Date range selected: ${picked.start} to ${picked.end}');
          }
        },
      ),
      properties: {
        'label': label,
        'startDate': selectedRange.value?.start.toString() ?? 'Not selected',
        'endDate': selectedRange.value?.end.toString() ?? 'Not selected',
      },
      codeExample: '''
class DateRangeWidget extends StatefulWidget {
  final WidgetPlacement placement;
  
  const DateRangeWidget({required this.placement});
  
  @override
  _DateRangeWidgetState createState() => _DateRangeWidgetState();
}

class _DateRangeWidgetState extends State<DateRangeWidget> {
  DateTimeRange? _selectedRange;
  final _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(widget.placement.id),
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.placement.properties['label'] ?? 'Date Range',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.date_range),
      ),
      readOnly: true,
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDateRange: _selectedRange,
        );
        
        if (picked != null) {
          setState(() {
            _selectedRange = picked;
            _controller.text = 
              '\${DateFormat('yyyy-MM-dd').format(picked.start)} - '
              '\${DateFormat('yyyy-MM-dd').format(picked.end)}';
          });
        }
      },
    );
  }
}
''',
    );
  }
}

// Button Story
class ButtonStory extends HookWidget {
  const ButtonStory({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.knobs.text(
      label: 'Label',
      initial: 'Submit',
    );
    
    final style = context.knobs.options(
      label: 'Style',
      options: const [
        Option('elevated', 'Elevated'),
        Option('filled', 'Filled'),
        Option('outlined', 'Outlined'),
        Option('text', 'Text'),
      ],
      initial: 'elevated',
    );
    
    final icon = context.knobs.options(
      label: 'Icon',
      options: const [
        Option('none', 'None'),
        Option('send', 'Send'),
        Option('save', 'Save'),
        Option('check', 'Check'),
      ],
      initial: 'none',
    );
    
    final fullWidth = context.knobs.boolean(
      label: 'Full Width',
      initial: false,
    );

    Widget button;
    final onPressed = () {
      context.actions.log('Button clicked: $label');
    };

    final iconWidget = icon == 'none' ? null : Icon(
      icon == 'send' ? Icons.send :
      icon == 'save' ? Icons.save :
      Icons.check,
    );

    switch (style) {
      case 'elevated':
        button = iconWidget != null
            ? ElevatedButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: Text(label),
              )
            : ElevatedButton(
                onPressed: onPressed,
                child: Text(label),
              );
        break;
      case 'filled':
        button = iconWidget != null
            ? FilledButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: Text(label),
              )
            : FilledButton(
                onPressed: onPressed,
                child: Text(label),
              );
        break;
      case 'outlined':
        button = iconWidget != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: Text(label),
              )
            : OutlinedButton(
                onPressed: onPressed,
                child: Text(label),
              );
        break;
      case 'text':
      default:
        button = iconWidget != null
            ? TextButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: Text(label),
              )
            : TextButton(
                onPressed: onPressed,
                child: Text(label),
              );
    }

    if (fullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return ComponentStoryBase(
      title: 'Button',
      description: 'Action buttons with various styles',
      preview: button,
      properties: {
        'label': label,
        'style': style,
        'icon': icon,
        'fullWidth': fullWidth,
      },
      codeExample: '''
ToolboxItem(
  name: 'button',
  icon: Icons.smart_button,
  label: 'Button',
  defaultWidth: 1,
  defaultHeight: 1,
  gridBuilder: (context, placement) => ${style == 'elevated' ? 'ElevatedButton' : 
    style == 'filled' ? 'FilledButton' : 
    style == 'outlined' ? 'OutlinedButton' : 'TextButton'}(
    key: ValueKey(placement.id),
    onPressed: () {
      // Handle button press
    },
    ${fullWidth ? 'style: ElevatedButton.styleFrom(minimumSize: Size.expand),' : ''}
    child: Text(placement.properties['label'] ?? 'Button'),
  ),
  defaultProperties: {
    'label': '$label',
    'style': '$style',
    'icon': '$icon',
    'fullWidth': $fullWidth,
  },
)
''',
    );
  }
}

// Icon Button Story
class IconButtonStory extends HookWidget {
  const IconButtonStory({super.key});

  @override
  Widget build(BuildContext context) {
    final icon = context.knobs.options(
      label: 'Icon',
      options: const [
        Option('add', 'Add'),
        Option('edit', 'Edit'),
        Option('delete', 'Delete'),
        Option('favorite', 'Favorite'),
        Option('share', 'Share'),
      ],
      initial: 'add',
    );
    
    final style = context.knobs.options(
      label: 'Style',
      options: const [
        Option('standard', 'Standard'),
        Option('filled', 'Filled'),
        Option('filled_tonal', 'Filled Tonal'),
        Option('outlined', 'Outlined'),
      ],
      initial: 'standard',
    );
    
    final size = context.knobs.slider(
      label: 'Size',
      min: 24,
      max: 48,
      initial: 24,
    );
    
    final tooltip = context.knobs.text(
      label: 'Tooltip',
      initial: 'Click me',
    );

    final iconData = icon == 'add' ? Icons.add :
                    icon == 'edit' ? Icons.edit :
                    icon == 'delete' ? Icons.delete :
                    icon == 'favorite' ? Icons.favorite :
                    Icons.share;

    Widget button;
    final onPressed = () {
      context.actions.log('Icon button clicked: $icon');
    };

    switch (style) {
      case 'filled':
        button = IconButton.filled(
          onPressed: onPressed,
          icon: Icon(iconData),
          iconSize: size,
          tooltip: tooltip,
        );
        break;
      case 'filled_tonal':
        button = IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(iconData),
          iconSize: size,
          tooltip: tooltip,
        );
        break;
      case 'outlined':
        button = IconButton.outlined(
          onPressed: onPressed,
          icon: Icon(iconData),
          iconSize: size,
          tooltip: tooltip,
        );
        break;
      case 'standard':
      default:
        button = IconButton(
          onPressed: onPressed,
          icon: Icon(iconData),
          iconSize: size,
          tooltip: tooltip,
        );
    }

    return ComponentStoryBase(
      title: 'Icon Button',
      description: 'Icon-based action buttons',
      preview: button,
      properties: {
        'icon': icon,
        'style': style,
        'size': size,
        'tooltip': tooltip,
      },
      codeExample: '''
ToolboxItem(
  name: 'icon_button',
  icon: Icons.touch_app,
  label: 'Icon Button',
  defaultWidth: 1,
  defaultHeight: 1,
  gridBuilder: (context, placement) => IconButton${style == 'filled' ? '.filled' : 
    style == 'filled_tonal' ? '.filledTonal' : 
    style == 'outlined' ? '.outlined' : ''}(
    key: ValueKey(placement.id),
    onPressed: () {
      // Handle button press
    },
    icon: Icon(${icon == 'add' ? 'Icons.add' :
      icon == 'edit' ? 'Icons.edit' :
      icon == 'delete' ? 'Icons.delete' :
      icon == 'favorite' ? 'Icons.favorite' :
      'Icons.share'}),
    iconSize: $size,
    tooltip: '$tooltip',
  ),
  defaultProperties: {
    'icon': '$icon',
    'style': '$style',
    'size': $size,
    'tooltip': '$tooltip',
  },
)
''',
    );
  }
}

// Label Story
class LabelStory extends HookWidget {
  const LabelStory({super.key});

  @override
  Widget build(BuildContext context) {
    final text = context.knobs.text(
      label: 'Text',
      initial: 'Form Title',
    );
    
    final style = context.knobs.options(
      label: 'Style',
      options: const [
        Option('display', 'Display'),
        Option('headline', 'Headline'),
        Option('title', 'Title'),
        Option('body', 'Body'),
        Option('label', 'Label'),
      ],
      initial: 'title',
    );
    
    final alignment = context.knobs.options(
      label: 'Alignment',
      options: const [
        Option('left', 'Left'),
        Option('center', 'Center'),
        Option('right', 'Right'),
      ],
      initial: 'left',
    );
    
    final color = context.knobs.options(
      label: 'Color',
      options: const [
        Option('default', 'Default'),
        Option('primary', 'Primary'),
        Option('secondary', 'Secondary'),
        Option('error', 'Error'),
      ],
      initial: 'default',
    );

    final textStyle = style == 'display' ? Theme.of(context).textTheme.displaySmall :
                     style == 'headline' ? Theme.of(context).textTheme.headlineMedium :
                     style == 'title' ? Theme.of(context).textTheme.titleLarge :
                     style == 'body' ? Theme.of(context).textTheme.bodyLarge :
                     Theme.of(context).textTheme.labelLarge;

    final textColor = color == 'primary' ? Theme.of(context).colorScheme.primary :
                     color == 'secondary' ? Theme.of(context).colorScheme.secondary :
                     color == 'error' ? Theme.of(context).colorScheme.error :
                     null;

    final textAlign = alignment == 'center' ? TextAlign.center :
                     alignment == 'right' ? TextAlign.right :
                     TextAlign.left;

    return ComponentStoryBase(
      title: 'Label',
      description: 'Static text display',
      preview: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: textStyle?.copyWith(color: textColor),
          textAlign: textAlign,
        ),
      ),
      properties: {
        'text': text,
        'style': style,
        'alignment': alignment,
        'color': color,
      },
      codeExample: '''
ToolboxItem(
  name: 'label',
  icon: Icons.label,
  label: 'Label',
  defaultWidth: 2,
  defaultHeight: 1,
  gridBuilder: (context, placement) => Container(
    key: ValueKey(placement.id),
    padding: EdgeInsets.all(8),
    alignment: ${alignment == 'center' ? 'Alignment.center' :
      alignment == 'right' ? 'Alignment.centerRight' :
      'Alignment.centerLeft'},
    child: Text(
      placement.properties['text'] ?? 'Label',
      style: Theme.of(context).textTheme.$style${textColor != null ? '.copyWith(color: Theme.of(context).colorScheme.$color)' : ''},
      textAlign: TextAlign.$alignment,
    ),
  ),
  defaultProperties: {
    'text': '$text',
    'style': '$style',
    'alignment': '$alignment',
    'color': '$color',
  },
)
''',
    );
  }
}

// Divider Story
class DividerStory extends HookWidget {
  const DividerStory({super.key});

  @override
  Widget build(BuildContext context) {
    final thickness = context.knobs.slider(
      label: 'Thickness',
      min: 0.5,
      max: 5,
      initial: 1,
    );
    
    final indent = context.knobs.slider(
      label: 'Indent',
      min: 0,
      max: 50,
      initial: 0,
    );
    
    final endIndent = context.knobs.slider(
      label: 'End Indent',
      min: 0,
      max: 50,
      initial: 0,
    );
    
    final color = context.knobs.options(
      label: 'Color',
      options: const [
        Option('default', 'Default'),
        Option('primary', 'Primary'),
        Option('secondary', 'Secondary'),
        Option('grey', 'Grey'),
      ],
      initial: 'default',
    );

    final dividerColor = color == 'primary' ? Theme.of(context).colorScheme.primary :
                        color == 'secondary' ? Theme.of(context).colorScheme.secondary :
                        color == 'grey' ? Colors.grey :
                        null;

    return ComponentStoryBase(
      title: 'Divider',
      description: 'Visual separator between content',
      preview: Column(
        children: [
          const Text('Content above divider'),
          const SizedBox(height: 16),
          Divider(
            thickness: thickness,
            indent: indent,
            endIndent: endIndent,
            color: dividerColor,
          ),
          const SizedBox(height: 16),
          const Text('Content below divider'),
        ],
      ),
      properties: {
        'thickness': thickness,
        'indent': indent,
        'endIndent': endIndent,
        'color': color,
      },
      codeExample: '''
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
      indent: placement.properties['indent']?.toDouble(),
      endIndent: placement.properties['endIndent']?.toDouble(),
      color: ${dividerColor != null ? 'Theme.of(context).colorScheme.$color' : 'null'},
    ),
  ),
  defaultProperties: {
    'thickness': $thickness,
    'indent': $indent,
    'endIndent': $endIndent,
    'color': '$color',
  },
)
''',
    );
  }
}

// Image Story
class ImageStory extends HookWidget {
  const ImageStory({super.key});

  @override
  Widget build(BuildContext context) {
    final source = context.knobs.options(
      label: 'Source',
      options: const [
        Option('asset', 'Asset'),
        Option('network', 'Network'),
        Option('placeholder', 'Placeholder'),
      ],
      initial: 'placeholder',
    );
    
    final fit = context.knobs.options(
      label: 'Fit',
      options: const [
        Option('cover', 'Cover'),
        Option('contain', 'Contain'),
        Option('fill', 'Fill'),
        Option('fitWidth', 'Fit Width'),
        Option('fitHeight', 'Fit Height'),
        Option('none', 'None'),
      ],
      initial: 'cover',
    );
    
    final width = context.knobs.nullableSlider(
      label: 'Width',
      min: 100,
      max: 400,
      initial: 200,
    );
    
    final height = context.knobs.nullableSlider(
      label: 'Height',
      min: 100,
      max: 400,
      initial: 200,
    );

    final boxFit = fit == 'cover' ? BoxFit.cover :
                  fit == 'contain' ? BoxFit.contain :
                  fit == 'fill' ? BoxFit.fill :
                  fit == 'fitWidth' ? BoxFit.fitWidth :
                  fit == 'fitHeight' ? BoxFit.fitHeight :
                  BoxFit.none;

    Widget image;
    if (source == 'asset') {
      image = Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: Text('Asset Image\n(would load from assets)'),
        ),
      );
    } else if (source == 'network') {
      image = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: DecorationImage(
            image: NetworkImage('https://picsum.photos/${width?.toInt() ?? 200}/${height?.toInt() ?? 200}'),
            fit: boxFit,
          ),
        ),
      );
    } else {
      image = Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: Icon(
          Icons.image,
          size: 48,
          color: Colors.grey[600],
        ),
      );
    }

    return ComponentStoryBase(
      title: 'Image',
      description: 'Image display widget',
      preview: image,
      properties: {
        'source': source,
        'fit': fit,
        'width': width,
        'height': height,
      },
      codeExample: '''
ToolboxItem(
  name: 'image',
  icon: Icons.image,
  label: 'Image',
  defaultWidth: 2,
  defaultHeight: 2,
  gridBuilder: (context, placement) => Container(
    key: ValueKey(placement.id),
    width: placement.properties['width']?.toDouble(),
    height: placement.properties['height']?.toDouble(),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      ${source == 'network' ? '''image: DecorationImage(
        image: NetworkImage(placement.properties['url'] ?? ''),
        fit: BoxFit.$fit,
      ),''' : ''}
    ),
    ${source == 'placeholder' ? '''child: Icon(
      Icons.image,
      size: 48,
      color: Colors.grey[600],
    ),''' : ''}
  ),
  defaultProperties: {
    'source': '$source',
    'fit': '$fit',
    'width': $width,
    'height': $height,
    ${source == 'network' ? "'url': 'https://example.com/image.jpg'," : ''}
  },
)
''',
    );
  }
}