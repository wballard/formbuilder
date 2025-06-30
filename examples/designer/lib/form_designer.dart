import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'widgets/designer_toolbox.dart';
import 'widgets/property_editor.dart';
import 'widgets/theme_editor.dart';

class FormDesigner extends StatefulWidget {
  const FormDesigner({super.key});

  @override
  State<FormDesigner> createState() => _FormDesignerState();
}

class _FormDesignerState extends State<FormDesigner> {
  LayoutState? _currentLayout;
  WidgetPlacement? _selectedWidget;
  bool _showPropertyPanel = true;
  int _currentTab = 0; // 0: Design, 1: Theme, 2: Export
  
  final _initialLayout = LayoutState(
    dimensions: const GridDimensions(columns: 6, rows: 8),
    widgets: [],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Form Designer'),
        bottom: TabBar(
          controller: TabController(length: 3, vsync: Scaffold.of(context), initialIndex: _currentTab),
          onTap: (index) => setState(() => _currentTab = index),
          tabs: const [
            Tab(text: 'Design', icon: Icon(Icons.design_services)),
            Tab(text: 'Theme', icon: Icon(Icons.palette)),
            Tab(text: 'Export', icon: Icon(Icons.download)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showPropertyPanel ? Icons.view_sidebar : Icons.view_sidebar_outlined),
            tooltip: 'Toggle Property Panel',
            onPressed: () {
              setState(() {
                _showPropertyPanel = !_showPropertyPanel;
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildDesignTab(),
          _buildThemeTab(),
          _buildExportTab(),
        ],
      ),
    );
  }

  Widget _buildDesignTab() {
    return Row(
      children: [
        Expanded(
          child: FormLayout(
            key: ValueKey(_currentLayout),
            toolbox: createDesignerToolbox(),
            initialLayout: _currentLayout ?? _initialLayout,
            onLayoutChanged: (layout) {
              setState(() {
                _currentLayout = layout;
              });
            },
            showToolbox: true,
            toolboxPosition: Axis.vertical,
            toolboxWidth: 220,
            enableUndo: true,
          ),
        ),
        if (_showPropertyPanel)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: PropertyEditor(
              selectedWidget: _selectedWidget,
              onPropertyChanged: (property, value) {
                // Handle property changes
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Property "$property" changed to "$value"'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildThemeTab() {
    return ThemeEditor(
      onThemeChanged: (themeConfig) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme updated')),
        );
      },
    );
  }

  Widget _buildExportTab() {
    if (_currentLayout == null || _currentLayout!.widgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No form to export',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Design a form first, then come back to export',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Export Options',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildExportCard(
                      'JSON',
                      'Standard JSON format for data exchange',
                      Icons.code,
                      () => _exportAsJson(),
                    ),
                    _buildExportCard(
                      'YAML',
                      'Human-readable YAML configuration',
                      Icons.description,
                      () => _exportAsYaml(),
                    ),
                    _buildExportCard(
                      'Flutter Code',
                      'Generate Flutter widget code',
                      Icons.flutter_dash,
                      () => _exportAsFlutterCode(),
                    ),
                    _buildExportCard(
                      'Template',
                      'Save as reusable template',
                      Icons.save_as,
                      () => _saveAsTemplate(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportAsJson() {
    final json = _currentLayout!.toJson();
    _showExportDialog('JSON Export', JsonEncoder.withIndent('  ').convert(json));
  }

  void _exportAsYaml() {
    // Simplified YAML representation
    final yaml = '''
name: My Form
version: 1.0.0
dimensions:
  columns: ${_currentLayout!.dimensions.columns}
  rows: ${_currentLayout!.dimensions.rows}
widgets:
${_currentLayout!.widgets.map((w) => '''
  - id: ${w.id}
    type: ${w.widgetName}
    position:
      column: ${w.column}
      row: ${w.row}
      width: ${w.width}
      height: ${w.height}''').join('\n')}
''';
    _showExportDialog('YAML Export', yaml);
  }

  void _exportAsFlutterCode() {
    final code = '''
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/form_layout.dart';

class GeneratedForm extends StatelessWidget {
  const GeneratedForm({super.key});

  @override
  Widget build(BuildContext context) {
    return FormLayout(
      initialLayout: LayoutState(
        dimensions: GridDimensions(
          columns: ${_currentLayout!.dimensions.columns},
          rows: ${_currentLayout!.dimensions.rows},
        ),
        widgets: [
${_currentLayout!.widgets.map((w) => '''          WidgetPlacement(
            id: '${w.id}',
            widgetName: '${w.widgetName}',
            column: ${w.column},
            row: ${w.row},
            width: ${w.width},
            height: ${w.height},
          ),''').join('\n')}
        ],
      ),
      // Add your toolbox configuration here
    );
  }
}
''';
    _showExportDialog('Flutter Code Export', code);
  }

  void _saveAsTemplate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Template'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Template Name',
            hintText: 'Enter a name for this template',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: 'My Form Template'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template saved successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                content,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}