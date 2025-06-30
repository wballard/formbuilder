import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

class PropertyEditor extends StatelessWidget {
  final WidgetPlacement? selectedWidget;
  final Function(String property, dynamic value) onPropertyChanged;

  const PropertyEditor({
    super.key,
    required this.selectedWidget,
    required this.onPropertyChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedWidget == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app,
                size: 48,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Select a widget',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Click on any widget in the form to view and edit its properties',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Widget Properties',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                selectedWidget!.widgetName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                context,
                'General',
                [
                  _buildTextField(
                    context,
                    'Widget ID',
                    selectedWidget!.id,
                    (value) => onPropertyChanged('id', value),
                    enabled: false,
                  ),
                  _buildTextField(
                    context,
                    'Label',
                    'Widget Label',
                    (value) => onPropertyChanged('label', value),
                  ),
                  _buildTextField(
                    context,
                    'Placeholder',
                    'Enter placeholder text',
                    (value) => onPropertyChanged('placeholder', value),
                  ),
                  _buildSwitch(
                    context,
                    'Required',
                    true,
                    (value) => onPropertyChanged('required', value),
                  ),
                  _buildSwitch(
                    context,
                    'Disabled',
                    false,
                    (value) => onPropertyChanged('disabled', value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Layout',
                [
                  _buildNumberField(
                    context,
                    'Column',
                    selectedWidget!.column,
                    (value) => onPropertyChanged('column', value),
                  ),
                  _buildNumberField(
                    context,
                    'Row',
                    selectedWidget!.row,
                    (value) => onPropertyChanged('row', value),
                  ),
                  _buildNumberField(
                    context,
                    'Width',
                    selectedWidget!.width,
                    (value) => onPropertyChanged('width', value),
                  ),
                  _buildNumberField(
                    context,
                    'Height',
                    selectedWidget!.height,
                    (value) => onPropertyChanged('height', value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Validation',
                [
                  _buildDropdown(
                    context,
                    'Validation Type',
                    'none',
                    ['none', 'email', 'phone', 'number', 'custom'],
                    (value) => onPropertyChanged('validationType', value),
                  ),
                  _buildTextField(
                    context,
                    'Error Message',
                    'Please enter a valid value',
                    (value) => onPropertyChanged('errorMessage', value),
                  ),
                  _buildNumberField(
                    context,
                    'Min Length',
                    0,
                    (value) => onPropertyChanged('minLength', value),
                  ),
                  _buildNumberField(
                    context,
                    'Max Length',
                    100,
                    (value) => onPropertyChanged('maxLength', value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Appearance',
                [
                  _buildColorPicker(
                    context,
                    'Background Color',
                    Colors.white,
                    (value) => onPropertyChanged('backgroundColor', value),
                  ),
                  _buildColorPicker(
                    context,
                    'Text Color',
                    Colors.black,
                    (value) => onPropertyChanged('textColor', value),
                  ),
                  _buildDropdown(
                    context,
                    'Font Size',
                    'medium',
                    ['small', 'medium', 'large', 'extra-large'],
                    (value) => onPropertyChanged('fontSize', value),
                  ),
                  _buildSlider(
                    context,
                    'Border Radius',
                    4,
                    0,
                    20,
                    (value) => onPropertyChanged('borderRadius', value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Advanced',
                [
                  _buildTextField(
                    context,
                    'CSS Classes',
                    'form-input primary',
                    (value) => onPropertyChanged('cssClasses', value),
                  ),
                  _buildCodeEditor(
                    context,
                    'Custom Validation',
                    '// return true if valid\nreturn value.length > 5;',
                    (value) => onPropertyChanged('customValidation', value),
                  ),
                  _buildCodeEditor(
                    context,
                    'On Change Handler',
                    '// Handle value changes\nconsole.log(value);',
                    (value) => onPropertyChanged('onChange', value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    String initialValue,
    ValueChanged<String> onChanged, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        enabled: enabled,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField(
    BuildContext context,
    String label,
    int initialValue,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final number = int.tryParse(value);
          if (number != null) {
            onChanged(number);
          }
        },
      ),
    );
  }

  Widget _buildSwitch(
    BuildContext context,
    String label,
    bool initialValue,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        title: Text(label),
        value: initialValue,
        onChanged: onChanged,
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String label,
    String initialValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color initialValue,
    ValueChanged<Color> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              // Show color picker dialog
              onChanged(Colors.blue);
            },
            child: Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: initialValue,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    double initialValue,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                initialValue.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Slider(
            value: initialValue,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeEditor(
    BuildContext context,
    String label,
    String initialValue,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              initialValue: initialValue,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.green[300],
                fontSize: 12,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              maxLines: null,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}