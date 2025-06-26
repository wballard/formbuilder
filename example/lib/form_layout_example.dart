import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// Comprehensive example of using the FormLayout widget
class FormLayoutExample extends StatefulWidget {
  const FormLayoutExample({super.key});

  @override
  State<FormLayoutExample> createState() => _FormLayoutExampleState();
}

class _FormLayoutExampleState extends State<FormLayoutExample> {
  LayoutState? _currentLayout;
  bool _showToolbox = true;
  Axis _toolboxPosition = Axis.horizontal;
  bool _enableUndo = true;

  // Create a comprehensive toolbox with various widget types
  final _toolbox = CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Basic Input',
        items: [
          ToolboxItem(
            name: 'text_field',
            displayName: 'Text Field',
            toolboxBuilder: (context) => const Icon(Icons.text_fields, size: 32),
            gridBuilder: (context, placement) => _buildTextField(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'number_field',
            displayName: 'Number Field',
            toolboxBuilder: (context) => const Icon(Icons.numbers, size: 32),
            gridBuilder: (context, placement) => _buildNumberField(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'dropdown',
            displayName: 'Dropdown',
            toolboxBuilder: (context) => const Icon(Icons.arrow_drop_down_circle, size: 32),
            gridBuilder: (context, placement) => _buildDropdown(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Selection',
        items: [
          ToolboxItem(
            name: 'checkbox',
            displayName: 'Checkbox',
            toolboxBuilder: (context) => const Icon(Icons.check_box, size: 32),
            gridBuilder: (context, placement) => _buildCheckbox(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'radio_group',
            displayName: 'Radio Group',
            toolboxBuilder: (context) => const Icon(Icons.radio_button_checked, size: 32),
            gridBuilder: (context, placement) => _buildRadioGroup(placement),
            defaultWidth: 2,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'switch',
            displayName: 'Switch',
            toolboxBuilder: (context) => const Icon(Icons.toggle_on, size: 32),
            gridBuilder: (context, placement) => _buildSwitch(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Layout',
        items: [
          ToolboxItem(
            name: 'label',
            displayName: 'Label',
            toolboxBuilder: (context) => const Icon(Icons.label, size: 32),
            gridBuilder: (context, placement) => _buildLabel(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'divider',
            displayName: 'Divider',
            toolboxBuilder: (context) => const Icon(Icons.horizontal_rule, size: 32),
            gridBuilder: (context, placement) => _buildDivider(placement),
            defaultWidth: 4,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'spacer',
            displayName: 'Spacer',
            toolboxBuilder: (context) => const Icon(Icons.space_bar, size: 32),
            gridBuilder: (context, placement) => _buildSpacer(placement),
            defaultWidth: 1,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Advanced',
        items: [
          ToolboxItem(
            name: 'date_picker',
            displayName: 'Date Picker',
            toolboxBuilder: (context) => const Icon(Icons.calendar_today, size: 32),
            gridBuilder: (context, placement) => _buildDatePicker(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'file_upload',
            displayName: 'File Upload',
            toolboxBuilder: (context) => const Icon(Icons.upload_file, size: 32),
            gridBuilder: (context, placement) => _buildFileUpload(placement),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'signature',
            displayName: 'Signature',
            toolboxBuilder: (context) => const Icon(Icons.draw, size: 32),
            gridBuilder: (context, placement) => _buildSignature(placement),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
        ],
      ),
    ],
  );

  // Example initial layout with some pre-placed widgets
  final _initialLayout = LayoutState(
    dimensions: const GridDimensions(columns: 6, rows: 8),
    widgets: [
      WidgetPlacement(
        id: 'title_label',
        widgetName: 'label',
        column: 0,
        row: 0,
        width: 6,
        height: 1,
      ),
      WidgetPlacement(
        id: 'first_name',
        widgetName: 'text_field',
        column: 0,
        row: 1,
        width: 3,
        height: 1,
      ),
      WidgetPlacement(
        id: 'last_name',
        widgetName: 'text_field',
        column: 3,
        row: 1,
        width: 3,
        height: 1,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormLayout Example'),
        actions: [
          // Settings menu
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'toggle_toolbox':
                    _showToolbox = !_showToolbox;
                    break;
                  case 'horizontal':
                    _toolboxPosition = Axis.horizontal;
                    break;
                  case 'vertical':
                    _toolboxPosition = Axis.vertical;
                    break;
                  case 'toggle_undo':
                    _enableUndo = !_enableUndo;
                    break;
                  case 'reset':
                    setState(() {
                      _currentLayout = null;
                    });
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'toggle_toolbox',
                checked: _showToolbox,
                child: const Text('Show Toolbox'),
              ),
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                value: 'horizontal',
                checked: _toolboxPosition == Axis.horizontal,
                child: const Text('Horizontal Layout'),
              ),
              CheckedPopupMenuItem(
                value: 'vertical',
                checked: _toolboxPosition == Axis.vertical,
                child: const Text('Vertical Layout'),
              ),
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                value: 'toggle_undo',
                checked: _enableUndo,
                child: const Text('Enable Undo/Redo'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset Layout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar showing current layout info
          if (_currentLayout != null)
            Container(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    'Widgets: ${_currentLayout!.widgets.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Grid: ${_currentLayout!.dimensions.columns}×${_currentLayout!.dimensions.rows}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    label: const Text('Export JSON'),
                    onPressed: () => _showJsonExport(context),
                  ),
                ],
              ),
            ),
          
          // The main FormLayout widget
          Expanded(
            child: FormLayout(
              key: ValueKey(_currentLayout), // Force rebuild on reset
              toolbox: _toolbox,
              initialLayout: _currentLayout ?? _initialLayout,
              onLayoutChanged: (layout) {
                setState(() {
                  _currentLayout = layout;
                });
              },
              showToolbox: _showToolbox,
              toolboxPosition: _toolboxPosition,
              toolboxWidth: 280,
              toolboxHeight: 180,
              enableUndo: _enableUndo,
              undoLimit: 50,
            ),
          ),
        ],
      ),
    );
  }

  void _showJsonExport(BuildContext context) {
    if (_currentLayout == null) return;
    
    // Convert layout to JSON (simplified for example)
    final json = {
      'dimensions': {
        'columns': _currentLayout!.dimensions.columns,
        'rows': _currentLayout!.dimensions.rows,
      },
      'widgets': _currentLayout!.widgets.map((w) => {
        'id': w.id,
        'type': w.widgetName,
        'position': {
          'column': w.column,
          'row': w.row,
          'width': w.width,
          'height': w.height,
        },
      }).toList(),
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Layout JSON'),
        content: SingleChildScrollView(
          child: SelectableText(
            json.toString(),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Widget builders for different form elements
  static Widget _buildTextField(WidgetPlacement placement) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Text Field ${placement.id}',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  static Widget _buildNumberField(WidgetPlacement placement) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Number ${placement.id}',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  static Widget _buildDropdown(WidgetPlacement placement) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Dropdown ${placement.id}',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 'option1', child: Text('Option 1')),
          DropdownMenuItem(value: 'option2', child: Text('Option 2')),
          DropdownMenuItem(value: 'option3', child: Text('Option 3')),
        ],
        onChanged: (_) {},
      ),
    );
  }

  static Widget _buildCheckbox(WidgetPlacement placement) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Checkbox(value: false, onChanged: (_) {}),
          Text('Checkbox ${placement.id}'),
        ],
      ),
    );
  }

  static Widget _buildRadioGroup(WidgetPlacement placement) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Radio Group ${placement.id}'),
          Radio<int>(value: 1, groupValue: 0, onChanged: (_) {}),
          Radio<int>(value: 2, groupValue: 0, onChanged: (_) {}),
        ],
      ),
    );
  }

  static Widget _buildSwitch(WidgetPlacement placement) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Switch(value: false, onChanged: (_) {}),
          Text('Switch ${placement.id}'),
        ],
      ),
    );
  }

  static Widget _buildLabel(WidgetPlacement placement) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      child: Text(
        'Label ${placement.id}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _buildDivider(WidgetPlacement placement) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(),
    );
  }

  static Widget _buildSpacer(WidgetPlacement placement) {
    return Container(
      color: Colors.grey.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.space_bar, color: Colors.grey),
      ),
    );
  }

  static Widget _buildDatePicker(WidgetPlacement placement) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date ${placement.id}',
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () {
          // Would show date picker
        },
      ),
    );
  }

  static Widget _buildFileUpload(WidgetPlacement placement) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload, size: 32),
          Text('File Upload ${placement.id}'),
        ],
      ),
    );
  }

  static Widget _buildSignature(WidgetPlacement placement) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.draw, size: 32),
          Text('Signature ${placement.id}'),
        ],
      ),
    );
  }
}