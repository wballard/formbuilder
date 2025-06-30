import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'widgets/basic_toolbox.dart';

class BasicFormBuilder extends StatefulWidget {
  const BasicFormBuilder({super.key});

  @override
  State<BasicFormBuilder> createState() => _BasicFormBuilderState();
}

class _BasicFormBuilderState extends State<BasicFormBuilder> {
  LayoutState? _currentLayout;
  bool _previewMode = false;
  
  final _initialLayout = LayoutState(
    dimensions: const GridDimensions(columns: 4, rows: 6),
    widgets: [],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Form Builder'),
        actions: [
          IconButton(
            icon: Icon(_previewMode ? Icons.edit : Icons.preview),
            tooltip: _previewMode ? 'Edit Mode' : 'Preview Mode',
            onPressed: () {
              setState(() {
                _previewMode = !_previewMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Layout',
            onPressed: _saveLayout,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load Layout',
            onPressed: _loadLayout,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Layout',
            onPressed: _clearLayout,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_previewMode)
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.visibility, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Preview Mode - Form is not editable',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _previewMode ? _buildPreview() : _buildEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return FormLayout(
      key: ValueKey(_currentLayout),
      toolbox: createBasicToolbox(),
      initialLayout: _currentLayout ?? _initialLayout,
      onLayoutChanged: (layout) {
        setState(() {
          _currentLayout = layout;
        });
      },
      showToolbox: true,
      toolboxPosition: Axis.horizontal,
      toolboxHeight: 120,
      enableUndo: true,
    );
  }

  Widget _buildPreview() {
    if (_currentLayout == null || _currentLayout!.widgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No form to preview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Switch to edit mode and add some widgets',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Contact Form',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildPreviewForm(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewForm() {
    final toolbox = createBasicToolbox();
    final widgets = <Widget>[];
    
    for (final placement in _currentLayout!.widgets) {
      final toolboxItem = toolbox.findItem(placement.widgetName);
      if (toolboxItem != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: toolboxItem.gridBuilder(context, placement),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Future<void> _saveLayout() async {
    if (_currentLayout == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutJson = {
        'dimensions': {
          'columns': _currentLayout!.dimensions.columns,
          'rows': _currentLayout!.dimensions.rows,
        },
        'widgets': _currentLayout!.widgets.map((w) => {
          'id': w.id,
          'widgetName': w.widgetName,
          'column': w.column,
          'row': w.row,
          'width': w.width,
          'height': w.height,
        }).toList(),
      };
      
      await prefs.setString('basic_form_layout', jsonEncode(layoutJson));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layout saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save layout: $e')),
        );
      }
    }
  }

  Future<void> _loadLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutString = prefs.getString('basic_form_layout');
      
      if (layoutString == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No saved layout found')),
          );
        }
        return;
      }

      final layoutJson = jsonDecode(layoutString) as Map<String, dynamic>;
      final dimensions = GridDimensions(
        columns: layoutJson['dimensions']['columns'],
        rows: layoutJson['dimensions']['rows'],
      );
      
      final widgets = (layoutJson['widgets'] as List).map((w) {
        return WidgetPlacement(
          id: w['id'],
          widgetName: w['widgetName'],
          column: w['column'],
          row: w['row'],
          width: w['width'],
          height: w['height'],
        );
      }).toList();

      setState(() {
        _currentLayout = LayoutState(
          dimensions: dimensions,
          widgets: widgets,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layout loaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load layout: $e')),
        );
      }
    }
  }

  void _clearLayout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Layout'),
        content: const Text('Are you sure you want to clear the current layout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _currentLayout = null;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Layout cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}