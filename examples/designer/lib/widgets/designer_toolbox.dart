import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

CategorizedToolbox createDesignerToolbox() {
  return CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Input Fields',
        items: [
          ToolboxItem(
            name: 'advanced_text',
            displayName: 'Advanced Text Field',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.text_fields,
              'Text+',
            ),
            gridBuilder: (context, placement) => _buildAdvancedTextField(placement),
            defaultWidth: 3,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'rich_editor',
            displayName: 'Rich Text Editor',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.format_color_text,
              'Rich',
            ),
            gridBuilder: (context, placement) => _buildRichEditor(placement),
            defaultWidth: 4,
            defaultHeight: 3,
          ),
          ToolboxItem(
            name: 'code_editor',
            displayName: 'Code Editor',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.code,
              'Code',
            ),
            gridBuilder: (context, placement) => _buildCodeEditor(placement),
            defaultWidth: 4,
            defaultHeight: 3,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Advanced Selection',
        items: [
          ToolboxItem(
            name: 'multi_select',
            displayName: 'Multi-Select Dropdown',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.checklist,
              'Multi',
            ),
            gridBuilder: (context, placement) => _buildMultiSelect(placement),
            defaultWidth: 3,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'tag_input',
            displayName: 'Tag Input',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.label,
              'Tags',
            ),
            gridBuilder: (context, placement) => _buildTagInput(placement),
            defaultWidth: 3,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'color_picker',
            displayName: 'Color Picker',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.palette,
              'Color',
            ),
            gridBuilder: (context, placement) => _buildColorPicker(placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Data Input',
        items: [
          ToolboxItem(
            name: 'file_uploader',
            displayName: 'File Uploader',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.cloud_upload,
              'Upload',
            ),
            gridBuilder: (context, placement) => _buildFileUploader(placement),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'image_picker',
            displayName: 'Image Picker',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.image,
              'Image',
            ),
            gridBuilder: (context, placement) => _buildImagePicker(placement),
            defaultWidth: 3,
            defaultHeight: 3,
          ),
          ToolboxItem(
            name: 'location_picker',
            displayName: 'Location Picker',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.location_on,
              'Location',
            ),
            gridBuilder: (context, placement) => _buildLocationPicker(placement),
            defaultWidth: 4,
            defaultHeight: 3,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Custom Widgets',
        items: [
          ToolboxItem(
            name: 'custom_container',
            displayName: 'Custom Container',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.dashboard_customize,
              'Custom',
            ),
            gridBuilder: (context, placement) => _buildCustomContainer(placement),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'conditional_group',
            displayName: 'Conditional Group',
            toolboxBuilder: (context) => _buildToolboxWidget(
              context,
              Icons.rule,
              'If/Then',
            ),
            gridBuilder: (context, placement) => _buildConditionalGroup(placement),
            defaultWidth: 4,
            defaultHeight: 2,
          ),
        ],
      ),
    ],
  );
}

Widget _buildToolboxWidget(BuildContext context, IconData icon, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 24, color: Theme.of(context).primaryColor),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );
}

Widget _buildAdvancedTextField(WidgetPlacement placement) {
  return Container(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Advanced Text Field',
            hintText: 'With validation and formatting',
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.format_clear),
                  onPressed: () {},
                  tooltip: 'Clear formatting',
                ),
                IconButton(
                  icon: const Icon(Icons.spellcheck),
                  onPressed: () {},
                  tooltip: 'Spell check',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Max 100 characters • Required',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}

Widget _buildRichEditor(WidgetPlacement placement) {
  return Container(
    margin: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.format_bold, size: 20),
                onPressed: () {},
                tooltip: 'Bold',
              ),
              IconButton(
                icon: const Icon(Icons.format_italic, size: 20),
                onPressed: () {},
                tooltip: 'Italic',
              ),
              IconButton(
                icon: const Icon(Icons.format_underlined, size: 20),
                onPressed: () {},
                tooltip: 'Underline',
              ),
              const VerticalDivider(width: 20),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted, size: 20),
                onPressed: () {},
                tooltip: 'Bullet list',
              ),
              IconButton(
                icon: const Icon(Icons.link, size: 20),
                onPressed: () {},
                tooltip: 'Insert link',
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Rich text editor content...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildCodeEditor(WidgetPlacement placement) {
  return Container(
    margin: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          child: Row(
            children: [
              const Text(
                'main.dart',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: 'dart',
                items: const [
                  DropdownMenuItem(value: 'dart', child: Text('Dart')),
                  DropdownMenuItem(value: 'javascript', child: Text('JavaScript')),
                  DropdownMenuItem(value: 'python', child: Text('Python')),
                ],
                onChanged: (value) {},
                style: const TextStyle(fontSize: 12),
                isDense: true,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '// Code editor with syntax highlighting',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.green[300],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildMultiSelect(WidgetPlacement placement) {
  return Container(
    padding: const EdgeInsets.all(12),
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Select Multiple Options',
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 8,
        children: [
          Chip(
            label: const Text('Option 1'),
            onDeleted: () {},
          ),
          Chip(
            label: const Text('Option 2'),
            onDeleted: () {},
          ),
          ActionChip(
            label: const Text('+ Add'),
            onPressed: () {},
          ),
        ],
      ),
    ),
  );
}

Widget _buildTagInput(WidgetPlacement placement) {
  return Container(
    padding: const EdgeInsets.all(12),
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Tags',
        hintText: 'Type and press enter',
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 8,
        children: [
          Chip(
            label: const Text('flutter'),
            backgroundColor: Colors.blue[100],
            deleteIconColor: Colors.blue,
            onDeleted: () {},
          ),
          Chip(
            label: const Text('dart'),
            backgroundColor: Colors.green[100],
            deleteIconColor: Colors.green,
            onDeleted: () {},
          ),
        ],
      ),
    ),
  );
}

Widget _buildColorPicker(WidgetPlacement placement) {
  return Container(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Color'),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#2196F3',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'RGB(33, 150, 243)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFileUploader(WidgetPlacement placement) {
  return Container(
    margin: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, style: BorderStyle.solid, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload, size: 48, color: Colors.grey[600]),
        const SizedBox(height: 8),
        const Text('Drag & drop files here'),
        const Text(
          'or click to browse',
          style: TextStyle(fontSize: 12, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          'PDF, DOC, DOCX (max 10MB)',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}

Widget _buildImagePicker(WidgetPlacement placement) {
  return Container(
    margin: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Expanded(
          child: Center(
            child: Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Camera'),
                onPressed: () {},
              ),
              TextButton.icon(
                icon: const Icon(Icons.photo_library, size: 16),
                label: const Text('Gallery'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildLocationPicker(WidgetPlacement placement) {
  return Container(
    margin: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey),
    ),
    child: Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  const Text('Map preview'),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.red[700]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '37.7749° N, 122.4194° W',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Change'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCustomContainer(WidgetPlacement placement) {
  return Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue[400]!, Colors.purple[400]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.auto_awesome, color: Colors.white, size: 32),
        SizedBox(height: 8),
        Text(
          'Custom Widget',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Fully customizable',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Widget _buildConditionalGroup(WidgetPlacement placement) {
  return Container(
    margin: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.orange, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          child: Row(
            children: [
              Icon(Icons.rule, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'Conditional: If age > 18',
                style: TextStyle(
                  color: Colors.orange[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                'Drop widgets here to show conditionally',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}