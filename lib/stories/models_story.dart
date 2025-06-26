import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

List<Story> get modelStories => [
      Story(
        name: 'Models/GridDimensions',
        builder: (context) => const GridDimensionsDemo(),
      ),
      Story(
        name: 'Models/WidgetPlacement',
        builder: (context) => const WidgetPlacementDemo(),
      ),
    ];

class GridDimensionsDemo extends StatelessWidget {
  const GridDimensionsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GridDimensions Model',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'GridDimensions defines the size of the form layout grid.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Constraints',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Columns: ${GridDimensions.minColumns} - ${GridDimensions.maxColumns}'),
                    Text('Rows: ${GridDimensions.minRows} - ${GridDimensions.maxRows}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example Usage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('const dimensions = GridDimensions('),
                    const Text('  columns: 4,'),
                    const Text('  rows: 6,'),
                    const Text(');'),
                    const SizedBox(height: 8),
                    const Text('// Creates a 4x6 grid'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Common Grid Sizes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildGridExample('Small', 2, 2),
                    _buildGridExample('Medium', 4, 4),
                    _buildGridExample('Large', 6, 8),
                    _buildGridExample('Wide', 12, 4),
                    _buildGridExample('Tall', 4, 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridExample(String label, int columns, int rows) {
    final dimensions = GridDimensions(columns: columns, rows: rows);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:'),
          ),
          Text(dimensions.toString()),
        ],
      ),
    );
  }
}

class WidgetPlacementDemo extends StatelessWidget {
  const WidgetPlacementDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WidgetPlacement Model',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'WidgetPlacement defines where a widget is positioned on the grid and its size.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Properties',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('• id: Unique identifier for the widget'),
                      const Text('• widgetName: Name from the toolbox'),
                      const Text('• column: 0-based column position'),
                      const Text('• row: 0-based row position'),
                      const Text('• width: Number of columns spanned (min 1)'),
                      const Text('• height: Number of rows spanned (min 1)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example Usage',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('final placement = WidgetPlacement('),
                      const Text('  id: "widget1",'),
                      const Text('  widgetName: "TextInput",'),
                      const Text('  column: 2,'),
                      const Text('  row: 1,'),
                      const Text('  width: 2,'),
                      const Text('  height: 1,'),
                      const Text(');'),
                      const SizedBox(height: 8),
                      const Text('// Places a TextInput at column 2, row 1'),
                      const Text('// spanning 2 columns and 1 row'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Validation Methods',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildValidationExample(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visual Example',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildVisualExample(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationExample(BuildContext context) {
    final placement1 = WidgetPlacement(
      id: 'widget1',
      widgetName: 'Button',
      column: 0,
      row: 0,
      width: 2,
      height: 1,
    );
    
    final placement2 = WidgetPlacement(
      id: 'widget2',
      widgetName: 'TextInput',
      column: 1,
      row: 0,
      width: 2,
      height: 1,
    );
    
    const grid = GridDimensions(columns: 4, rows: 4);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('placement1.fitsInGrid(4x4): ${placement1.fitsInGrid(grid)}'),
        const SizedBox(height: 4),
        Text('placement1.overlaps(placement2): ${placement1.overlaps(placement2)}'),
        const SizedBox(height: 4),
        Text('placement1.bounds: ${placement1.bounds}'),
      ],
    );
  }

  Widget _buildVisualExample(BuildContext context) {
    const cellSize = 40.0;
    const gridColumns = 6;
    const gridRows = 4;
    
    final placements = [
      WidgetPlacement(
        id: 'widget1',
        widgetName: 'Header',
        column: 0,
        row: 0,
        width: 6,
        height: 1,
      ),
      WidgetPlacement(
        id: 'widget2',
        widgetName: 'Sidebar',
        column: 0,
        row: 1,
        width: 2,
        height: 3,
      ),
      WidgetPlacement(
        id: 'widget3',
        widgetName: 'Content',
        column: 2,
        row: 1,
        width: 4,
        height: 2,
      ),
      WidgetPlacement(
        id: 'widget4',
        widgetName: 'Footer',
        column: 2,
        row: 3,
        width: 4,
        height: 1,
      ),
    ];
    
    return Container(
      width: gridColumns * cellSize,
      height: gridRows * cellSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          // Grid lines
          ...List.generate(gridRows + 1, (index) {
            return Positioned(
              top: index * cellSize,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            );
          }),
          ...List.generate(gridColumns + 1, (index) {
            return Positioned(
              left: index * cellSize,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1,
                color: Colors.grey.shade300,
              ),
            );
          }),
          // Placed widgets
          ...placements.map((placement) {
            return Positioned(
              left: placement.column * cellSize,
              top: placement.row * cellSize,
              width: placement.width * cellSize,
              height: placement.height * cellSize,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    placement.widgetName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}