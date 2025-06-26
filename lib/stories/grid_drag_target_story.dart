import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

List<Story> get gridDragTargetStories => [
  Story(
    name: 'Widgets/GridDragTarget/Basic Drag and Drop',
    builder: (context) => const BasicDragDropDemo(),
  ),
  Story(
    name: 'Widgets/GridDragTarget/Complex Layout',
    builder: (context) => const ComplexLayoutDemo(),
  ),
  Story(
    name: 'Widgets/GridDragTarget/Validation Demo',
    builder: (context) => const ValidationDemo(),
  ),
];

class BasicDragDropDemo extends StatefulWidget {
  const BasicDragDropDemo({super.key});

  @override
  State<BasicDragDropDemo> createState() => _BasicDragDropDemoState();
}

class _BasicDragDropDemoState extends State<BasicDragDropDemo> {
  late LayoutState _layoutState;
  final _toolbox = Toolbox.withDefaults();
  String? _selectedWidgetId;
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    _layoutState = LayoutState(
      dimensions: const GridDimensions(columns: 6, rows: 4),
      widgets: [],
    );
  }

  void _addEvent(String event) {
    setState(() {
      _eventLog.add('${DateTime.now().toString().substring(11, 19)}: $event');
      if (_eventLog.length > 10) {
        _eventLog.removeAt(0);
      }
    });
  }

  void _onWidgetDropped(WidgetPlacement placement) {
    setState(() {
      _layoutState = _layoutState.addWidget(placement);
    });
    _addEvent('Dropped ${placement.widgetName} at (${placement.column}, ${placement.row})');
  }

  void _onWidgetMoved(String widgetId, WidgetPlacement newPlacement) {
    setState(() {
      _layoutState = _layoutState.updateWidget(widgetId, newPlacement);
    });
    _addEvent('Moved $widgetId to (${newPlacement.column}, ${newPlacement.row})');
  }

  void _onWidgetTap(String widgetId) {
    setState(() {
      _selectedWidgetId = _selectedWidgetId == widgetId ? null : widgetId;
    });
    _addEvent('Tapped widget $widgetId');
  }

  void _clearGrid() {
    setState(() {
      _layoutState = LayoutState(
        dimensions: _layoutState.dimensions,
        widgets: [],
      );
      _selectedWidgetId = null;
    });
    _addEvent('Cleared grid');
  }

  Map<String, Widget> get _widgetBuilders => {
    'text_input': Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Icon(Icons.text_fields, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text('Text Input')),
        ],
      ),
    ),
    'button': Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: const Center(
        child: Text(
          'Button',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    'label': Container(
      padding: const EdgeInsets.all(8),
      child: const Text(
        'Label',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    'checkbox': Container(
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Icon(Icons.check_box_outline_blank, size: 16),
          SizedBox(width: 8),
          Text('Checkbox'),
        ],
      ),
    ),
    'radio': Container(
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Icon(Icons.radio_button_unchecked, size: 16),
          SizedBox(width: 8),
          Text('Radio'),
        ],
      ),
    ),
    'dropdown': Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Expanded(child: Text('Select option')),
          Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    ),
    'datepicker': Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Icon(Icons.calendar_today, size: 16),
          SizedBox(width: 8),
          Text('Select date'),
        ],
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Drag and Drop Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _clearGrid,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Grid',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbox
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Toolbox',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ToolboxWidget(
                      toolbox: _toolbox,
                      onDragStarted: (item) {
                        _addEvent('Started dragging ${item.displayName}');
                      },
                      onDragEnd: () {
                        _addEvent('Drag ended');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Grid area
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form Grid (${_layoutState.dimensions.columns}x${_layoutState.dimensions.rows})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridDragTarget(
                        layoutState: _layoutState,
                        widgetBuilders: _widgetBuilders,
                        toolbox: _toolbox,
                        selectedWidgetId: _selectedWidgetId,
                        onWidgetTap: _onWidgetTap,
                        onWidgetDropped: _onWidgetDropped,
                        onWidgetMoved: _onWidgetMoved,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Info panel
            SizedBox(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. Long press any item in the toolbox'),
                          const Text('2. Drag it over the grid'),
                          const Text('3. Green highlights = valid placement'),
                          const Text('4. Red highlights = invalid placement'),
                          const Text('5. Release to drop the widget'),
                          const Text('6. Tap widgets to select them'),
                          const Text('7. Drag existing widgets to move them'),
                          const SizedBox(height: 8),
                          Text(
                            'Widgets: ${_layoutState.widgets.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Event Log',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListView.builder(
                        itemCount: _eventLog.length,
                        itemBuilder: (context, index) {
                          return Text(
                            _eventLog[index],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          );
                        },
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

class ComplexLayoutDemo extends StatefulWidget {
  const ComplexLayoutDemo({super.key});

  @override
  State<ComplexLayoutDemo> createState() => _ComplexLayoutDemoState();
}

class _ComplexLayoutDemoState extends State<ComplexLayoutDemo> {
  late LayoutState _layoutState;
  final _toolbox = Toolbox.withDefaults();
  String? _selectedWidgetId;

  @override
  void initState() {
    super.initState();
    
    // Create a pre-populated layout
    final widgets = [
      WidgetPlacement(
        id: 'header',
        widgetName: 'label',
        column: 0,
        row: 0,
        width: 6,
        height: 1,
      ),
      WidgetPlacement(
        id: 'name_input',
        widgetName: 'text_input',
        column: 0,
        row: 1,
        width: 3,
        height: 1,
      ),
      WidgetPlacement(
        id: 'email_input',
        widgetName: 'text_input',
        column: 3,
        row: 1,
        width: 3,
        height: 1,
      ),
      WidgetPlacement(
        id: 'submit_btn',
        widgetName: 'button',
        column: 4,
        row: 3,
        width: 2,
        height: 1,
      ),
    ];

    _layoutState = LayoutState(
      dimensions: const GridDimensions(columns: 6, rows: 4),
      widgets: widgets,
    );
  }

  Map<String, Widget> get _widgetBuilders => {
    'text_input': Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: const Text('Text Input'),
    ),
    'button': Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: const Center(
        child: Text(
          'Submit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    'label': Container(
      padding: const EdgeInsets.all(8),
      child: const Text(
        'Contact Form',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complex Layout Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Toolbox
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Add More Widgets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ToolboxWidget(toolbox: _toolbox),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Grid
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Form Layout',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridDragTarget(
                        layoutState: _layoutState,
                        widgetBuilders: _widgetBuilders,
                        toolbox: _toolbox,
                        selectedWidgetId: _selectedWidgetId,
                        onWidgetTap: (id) {
                          setState(() {
                            _selectedWidgetId = _selectedWidgetId == id ? null : id;
                          });
                        },
                        onWidgetDropped: (placement) {
                          if (_layoutState.canAddWidget(placement)) {
                            setState(() {
                              _layoutState = _layoutState.addWidget(placement);
                            });
                          }
                        },
                        onWidgetMoved: (widgetId, newPlacement) {
                          setState(() {
                            _layoutState = _layoutState.updateWidget(widgetId, newPlacement);
                          });
                        },
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

class ValidationDemo extends StatefulWidget {
  const ValidationDemo({super.key});

  @override
  State<ValidationDemo> createState() => _ValidationDemoState();
}

class _ValidationDemoState extends State<ValidationDemo> {
  late LayoutState _layoutState;
  final _toolbox = Toolbox.withDefaults();

  @override
  void initState() {
    super.initState();
    
    // Create a layout with some blocking widgets to test validation
    final widgets = [
      WidgetPlacement(
        id: 'blocker1',
        widgetName: 'button',
        column: 1,
        row: 1,
        width: 2,
        height: 1,
      ),
      WidgetPlacement(
        id: 'blocker2',
        widgetName: 'text_input',
        column: 0,
        row: 3,
        width: 3,
        height: 1,
      ),
    ];

    _layoutState = LayoutState(
      dimensions: const GridDimensions(columns: 4, rows: 4),
      widgets: widgets,
    );
  }

  Map<String, Widget> get _widgetBuilders => {
    'text_input': Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: const Text('Text Input'),
    ),
    'button': Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: const Center(
        child: Text(
          'Button',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Instructions
            SizedBox(
              width: 200,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Validation Rules',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      const Text('✅ Green = Valid placement'),
                      const Text('❌ Red = Invalid placement'),
                      const SizedBox(height: 12),
                      const Text('Invalid when:'),
                      const Text('• Overlaps existing widgets'),
                      const Text('• Extends beyond grid bounds'),
                      const SizedBox(height: 12),
                      const Text('Try dragging widgets to different positions to see validation in action.'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Grid
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validation Grid (4x4)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridDragTarget(
                        layoutState: _layoutState,
                        widgetBuilders: _widgetBuilders,
                        toolbox: _toolbox,
                        onWidgetDropped: (placement) {
                          if (_layoutState.canAddWidget(placement)) {
                            setState(() {
                              _layoutState = _layoutState.addWidget(placement);
                            });
                          }
                        },
                        onWidgetMoved: (widgetId, newPlacement) {
                          setState(() {
                            _layoutState = _layoutState.updateWidget(widgetId, newPlacement);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Toolbox
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Toolbox',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ToolboxWidget(toolbox: _toolbox),
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