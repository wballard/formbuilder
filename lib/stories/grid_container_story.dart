import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'dart:math';

List<Story> get gridContainerStories => [
  Story(
    name: 'Widgets/GridContainer/Basic Layout',
    builder: (context) => const BasicGridContainerDemo(),
  ),
  Story(
    name: 'Widgets/GridContainer/Interactive Selection',
    builder: (context) => const InteractiveGridContainerDemo(),
  ),
  Story(
    name: 'Widgets/GridContainer/Different Sizes',
    builder: (context) => const GridContainerSizesDemo(),
  ),
  Story(
    name: 'Widgets/GridContainer/Form Example',
    builder: (context) => const FormExampleDemo(),
  ),
];

class BasicGridContainerDemo extends StatelessWidget {
  const BasicGridContainerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutState = LayoutState(
      dimensions: const GridDimensions(columns: 4, rows: 3),
      widgets: [
        WidgetPlacement(
          id: 'header',
          widgetName: 'HeaderText',
          column: 0,
          row: 0,
          width: 4,
          height: 1,
        ),
        WidgetPlacement(
          id: 'input1',
          widgetName: 'TextInput',
          column: 0,
          row: 1,
          width: 2,
          height: 1,
        ),
        WidgetPlacement(
          id: 'button1',
          widgetName: 'Button',
          column: 2,
          row: 1,
          width: 2,
          height: 1,
        ),
      ],
    );

    final widgetBuilders =
        <String, Widget Function(BuildContext, WidgetPlacement)>{
          'HeaderText': (context, placement) => Container(
            color: Colors.blue.shade50,
            child: const Center(
              child: Text(
                'Form Header',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          'TextInput': (context, placement) => const TextField(
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
          ),
          'Button': (context, placement) =>
              ElevatedButton(onPressed: () {}, child: const Text('Submit')),
        };

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Grid Container',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'A 4x3 grid with header, input field, and button:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridContainer(
                layoutState: layoutState,
                widgetBuilders: widgetBuilders,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InteractiveGridContainerDemo extends StatefulWidget {
  const InteractiveGridContainerDemo({super.key});

  @override
  State<InteractiveGridContainerDemo> createState() =>
      _InteractiveGridContainerDemoState();
}

class _InteractiveGridContainerDemoState
    extends State<InteractiveGridContainerDemo> {
  String? _selectedWidgetId;
  final Set<String> _draggingWidgetIds = {};
  Set<Point<int>>? _highlightedCells;

  late LayoutState _layoutState;
  late Map<String, Widget Function(BuildContext, WidgetPlacement)>
  _widgetBuilders;

  @override
  void initState() {
    super.initState();

    _layoutState = LayoutState(
      dimensions: const GridDimensions(columns: 6, rows: 4),
      widgets: [
        WidgetPlacement(
          id: 'title',
          widgetName: 'Title',
          column: 0,
          row: 0,
          width: 6,
          height: 1,
        ),
        WidgetPlacement(
          id: 'firstname',
          widgetName: 'TextInput',
          column: 0,
          row: 1,
          width: 3,
          height: 1,
        ),
        WidgetPlacement(
          id: 'lastname',
          widgetName: 'TextInput',
          column: 3,
          row: 1,
          width: 3,
          height: 1,
        ),
        WidgetPlacement(
          id: 'email',
          widgetName: 'EmailInput',
          column: 0,
          row: 2,
          width: 4,
          height: 1,
        ),
        WidgetPlacement(
          id: 'subscribe',
          widgetName: 'Checkbox',
          column: 4,
          row: 2,
          width: 2,
          height: 1,
        ),
        WidgetPlacement(
          id: 'submit',
          widgetName: 'Button',
          column: 2,
          row: 3,
          width: 2,
          height: 1,
        ),
      ],
    );

    _widgetBuilders = {
      'Title': (context, placement) => Container(
        color: Colors.purple.shade50,
        child: const Center(
          child: Text(
            'Contact Form',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ),
      ),
      'TextInput': (context, placement) => const TextField(
        decoration: InputDecoration(
          hintText: 'Enter text',
          border: OutlineInputBorder(),
        ),
      ),
      'EmailInput': (context, placement) => const TextField(
        decoration: InputDecoration(
          hintText: 'your@email.com',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.email),
        ),
      ),
      'Checkbox': (context, placement) => Row(
        children: [
          Checkbox(value: false, onChanged: (_) {}),
          const Text('Subscribe to newsletter'),
        ],
      ),
      'Button': (context, placement) => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        child: const Text('Submit Form'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            // Controls
            SizedBox(
              width: 300,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interactive Controls',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Selected Widget: ${_selectedWidgetId ?? 'None'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      const Text('Widget List:'),
                      const SizedBox(height: 8),

                      ..._layoutState.widgets.map((placement) {
                        final isSelected = _selectedWidgetId == placement.id;
                        final isDragging = _draggingWidgetIds.contains(
                          placement.id,
                        );

                        return ListTile(
                          dense: true,
                          title: Text(placement.id),
                          subtitle: Text(placement.widgetName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: isDragging,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _draggingWidgetIds.add(placement.id);
                                    } else {
                                      _draggingWidgetIds.remove(placement.id);
                                    }
                                  });
                                },
                              ),
                              const Text(
                                'Drag',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          tileColor: isSelected ? Colors.blue.shade50 : null,
                          onTap: () {
                            setState(() {
                              _selectedWidgetId = isSelected
                                  ? null
                                  : placement.id;
                            });
                          },
                        );
                      }),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedWidgetId = null;
                            _draggingWidgetIds.clear();
                            _highlightedCells = null;
                          });
                        },
                        child: const Text('Clear All'),
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Highlight a 2x2 area
                            _highlightedCells = GridWidget.getCellsInRectangle(
                              4,
                              0,
                              2,
                              2,
                            );
                          });
                        },
                        child: const Text('Highlight Area'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Grid Container
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive Grid Container',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Click widgets to select, use checkboxes to toggle dragging state:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridContainer(
                      layoutState: _layoutState,
                      widgetBuilders: _widgetBuilders,
                      selectedWidgetId: _selectedWidgetId,
                      draggingWidgetIds: _draggingWidgetIds,
                      highlightedCells: _highlightedCells,
                      onWidgetTap: (widgetId) {
                        setState(() {
                          _selectedWidgetId = _selectedWidgetId == widgetId
                              ? null
                              : widgetId;
                        });
                      },
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

class GridContainerSizesDemo extends StatelessWidget {
  const GridContainerSizesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Different Grid Sizes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildSizeExample('Small (2x2)', 2, 2)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildSizeExample('Wide (6x3)', 6, 3)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildSizeExample('Large (8x5)', 8, 5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeExample(String title, int columns, int rows) {
    final layoutState = LayoutState(
      dimensions: GridDimensions(columns: columns, rows: rows),
      widgets: [
        WidgetPlacement(
          id: 'widget1',
          widgetName: 'Widget',
          column: 0,
          row: 0,
          width: min(2, columns),
          height: 1,
        ),
        if (columns > 2)
          WidgetPlacement(
            id: 'widget2',
            widgetName: 'Widget',
            column: min(2, columns - 2),
            row: min(1, rows - 1),
            width: min(2, columns - 2),
            height: 1,
          ),
      ],
    );

    final widgetBuilders =
        <String, Widget Function(BuildContext, WidgetPlacement)>{
          'Widget': (context, placement) => Container(
            color: Colors.green.shade100,
            child: const Center(child: Text('Widget')),
          ),
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridContainer(
            layoutState: layoutState,
            widgetBuilders: widgetBuilders,
          ),
        ),
      ],
    );
  }
}

class FormExampleDemo extends StatelessWidget {
  const FormExampleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutState = LayoutState(
      dimensions: const GridDimensions(columns: 8, rows: 8),
      widgets: [
        // Header
        WidgetPlacement(
          id: 'form-title',
          widgetName: 'Title',
          column: 0,
          row: 0,
          width: 8,
          height: 1,
        ),

        // Personal Info Section
        WidgetPlacement(
          id: 'personal-label',
          widgetName: 'SectionLabel',
          column: 0,
          row: 1,
          width: 8,
          height: 1,
        ),
        WidgetPlacement(
          id: 'first-name',
          widgetName: 'TextInput',
          column: 0,
          row: 2,
          width: 4,
          height: 1,
        ),
        WidgetPlacement(
          id: 'last-name',
          widgetName: 'TextInput',
          column: 4,
          row: 2,
          width: 4,
          height: 1,
        ),
        WidgetPlacement(
          id: 'email',
          widgetName: 'EmailInput',
          column: 0,
          row: 3,
          width: 6,
          height: 1,
        ),
        WidgetPlacement(
          id: 'phone',
          widgetName: 'PhoneInput',
          column: 6,
          row: 3,
          width: 2,
          height: 1,
        ),

        // Address Section
        WidgetPlacement(
          id: 'address-label',
          widgetName: 'SectionLabel2',
          column: 0,
          row: 4,
          width: 8,
          height: 1,
        ),
        WidgetPlacement(
          id: 'street',
          widgetName: 'TextInput',
          column: 0,
          row: 5,
          width: 6,
          height: 1,
        ),
        WidgetPlacement(
          id: 'city',
          widgetName: 'TextInput',
          column: 0,
          row: 6,
          width: 3,
          height: 1,
        ),
        WidgetPlacement(
          id: 'zip',
          widgetName: 'TextInput',
          column: 3,
          row: 6,
          width: 2,
          height: 1,
        ),
        WidgetPlacement(
          id: 'country',
          widgetName: 'Dropdown',
          column: 5,
          row: 6,
          width: 3,
          height: 1,
        ),

        // Actions
        WidgetPlacement(
          id: 'cancel',
          widgetName: 'SecondaryButton',
          column: 4,
          row: 7,
          width: 2,
          height: 1,
        ),
        WidgetPlacement(
          id: 'submit',
          widgetName: 'PrimaryButton',
          column: 6,
          row: 7,
          width: 2,
          height: 1,
        ),
      ],
    );

    final widgetBuilders =
        <String, Widget Function(BuildContext, WidgetPlacement)>{
          'Title': (context, placement) => Container(
            color: Colors.indigo.shade50,
            child: const Center(
              child: Text(
                'Registration Form',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
          ),
          'SectionLabel': (context, placement) => Container(
            color: Colors.grey.shade100,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          'SectionLabel2': (context, placement) => Container(
            color: Colors.grey.shade100,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              'Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          'TextInput': (context, placement) => const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          'EmailInput': (context, placement) => const TextField(
            decoration: InputDecoration(
              hintText: 'email@example.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          'PhoneInput': (context, placement) => const TextField(
            decoration: InputDecoration(
              hintText: '(555) 123-4567',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          'Dropdown': (context, placement) => DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: 'US',
            items: const [
              DropdownMenuItem(value: 'US', child: Text('United States')),
              DropdownMenuItem(value: 'CA', child: Text('Canada')),
              DropdownMenuItem(value: 'MX', child: Text('Mexico')),
            ],
            onChanged: (_) {},
          ),
          'PrimaryButton': (context, placement) => ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
          'SecondaryButton': (context, placement) =>
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
        };

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complex Form Example',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'A realistic registration form built with GridContainer:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridContainer(
                layoutState: layoutState,
                widgetBuilders: widgetBuilders,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
