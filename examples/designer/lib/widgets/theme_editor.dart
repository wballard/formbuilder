import 'package:flutter/material.dart';

class ThemeEditor extends StatefulWidget {
  final Function(Map<String, dynamic> themeConfig) onThemeChanged;

  const ThemeEditor({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<ThemeEditor> createState() => _ThemeEditorState();
}

class _ThemeEditorState extends State<ThemeEditor> {
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.teal;
  Color _backgroundColor = Colors.white;
  Color _surfaceColor = Colors.grey[50]!;
  Color _errorColor = Colors.red;
  
  double _borderRadius = 8.0;
  double _spacing = 16.0;
  double _fontSize = 14.0;
  
  String _fontFamily = 'Roboto';
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildThemeControls(),
        ),
        Expanded(
          flex: 3,
          child: _buildThemePreview(),
        ),
      ],
    );
  }

  Widget _buildThemeControls() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            'Color Scheme',
            [
              _buildColorControl('Primary Color', _primaryColor, (color) {
                setState(() => _primaryColor = color);
              }),
              _buildColorControl('Secondary Color', _secondaryColor, (color) {
                setState(() => _secondaryColor = color);
              }),
              _buildColorControl('Background', _backgroundColor, (color) {
                setState(() => _backgroundColor = color);
              }),
              _buildColorControl('Surface', _surfaceColor, (color) {
                setState(() => _surfaceColor = color);
              }),
              _buildColorControl('Error', _errorColor, (color) {
                setState(() => _errorColor = color);
              }),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: _darkMode,
                onChanged: (value) {
                  setState(() => _darkMode = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Typography',
            [
              _buildDropdownControl(
                'Font Family',
                _fontFamily,
                ['Roboto', 'Inter', 'Poppins', 'Open Sans', 'Lato'],
                (value) => setState(() => _fontFamily = value),
              ),
              _buildSliderControl(
                'Base Font Size',
                _fontSize,
                10,
                20,
                (value) => setState(() => _fontSize = value),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Layout',
            [
              _buildSliderControl(
                'Border Radius',
                _borderRadius,
                0,
                24,
                (value) => setState(() => _borderRadius = value),
              ),
              _buildSliderControl(
                'Spacing',
                _spacing,
                8,
                32,
                (value) => setState(() => _spacing = value),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetTheme,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _applyTheme,
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreview() {
    return Container(
      color: _darkMode ? Colors.grey[900] : Colors.grey[100],
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_spacing * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Form Preview',
                  style: TextStyle(
                    fontSize: _fontSize * 1.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: _fontFamily,
                    color: _darkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: _spacing),
                _buildPreviewField('Text Input'),
                SizedBox(height: _spacing),
                _buildPreviewDropdown(),
                SizedBox(height: _spacing),
                _buildPreviewCheckbox(),
                SizedBox(height: _spacing),
                _buildPreviewRadio(),
                SizedBox(height: _spacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryColor,
                        side: BorderSide(color: _primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontFamily: _fontFamily),
                      ),
                    ),
                    SizedBox(width: _spacing),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(fontFamily: _fontFamily),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildColorControl(String label, Color value, ValueChanged<Color> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          InkWell(
            onTap: () => _showColorPicker(value, onChanged),
            child: Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: value,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownControl(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewField(String label) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        filled: true,
        fillColor: _surfaceColor,
        labelStyle: TextStyle(
          color: _primaryColor,
          fontFamily: _fontFamily,
          fontSize: _fontSize,
        ),
      ),
      style: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _fontSize,
        color: _darkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildPreviewDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Dropdown',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        filled: true,
        fillColor: _surfaceColor,
        labelStyle: TextStyle(
          color: _primaryColor,
          fontFamily: _fontFamily,
          fontSize: _fontSize,
        ),
      ),
      value: 'option1',
      items: const [
        DropdownMenuItem(value: 'option1', child: Text('Option 1')),
        DropdownMenuItem(value: 'option2', child: Text('Option 2')),
      ],
      onChanged: (_) {},
      style: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _fontSize,
        color: _darkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildPreviewCheckbox() {
    return CheckboxListTile(
      title: Text(
        'Checkbox Option',
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: _fontSize,
          color: _darkMode ? Colors.white : Colors.black,
        ),
      ),
      value: true,
      onChanged: (_) {},
      activeColor: _primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius / 2),
      ),
    );
  }

  Widget _buildPreviewRadio() {
    return Column(
      children: [
        RadioListTile<int>(
          title: Text(
            'Radio Option 1',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: _fontSize,
              color: _darkMode ? Colors.white : Colors.black,
            ),
          ),
          value: 1,
          groupValue: 1,
          onChanged: (_) {},
          activeColor: _primaryColor,
        ),
        RadioListTile<int>(
          title: Text(
            'Radio Option 2',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: _fontSize,
              color: _darkMode ? Colors.white : Colors.black,
            ),
          ),
          value: 2,
          groupValue: 1,
          onChanged: (_) {},
          activeColor: _primaryColor,
        ),
      ],
    );
  }

  void _showColorPicker(Color currentColor, ValueChanged<Color> onColorChanged) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => InkWell(
            onTap: () {
              onColorChanged(color);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: currentColor == color ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _resetTheme() {
    setState(() {
      _primaryColor = Colors.blue;
      _secondaryColor = Colors.teal;
      _backgroundColor = Colors.white;
      _surfaceColor = Colors.grey[50]!;
      _errorColor = Colors.red;
      _borderRadius = 8.0;
      _spacing = 16.0;
      _fontSize = 14.0;
      _fontFamily = 'Roboto';
      _darkMode = false;
    });
  }

  void _applyTheme() {
    final themeConfig = {
      'primaryColor': _colorToHex(_primaryColor),
      'secondaryColor': _colorToHex(_secondaryColor),
      'backgroundColor': _colorToHex(_backgroundColor),
      'surfaceColor': _colorToHex(_surfaceColor),
      'errorColor': _colorToHex(_errorColor),
      'borderRadius': _borderRadius,
      'spacing': _spacing,
      'fontSize': _fontSize,
      'fontFamily': _fontFamily,
      'darkMode': _darkMode,
    };
    
    widget.onThemeChanged(themeConfig);
  }

  String _colorToHex(Color color) {
    final alpha = ((color.a * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final red = ((color.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final green = ((color.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final blue = ((color.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    return '#$alpha$red$green$blue';
  }
}