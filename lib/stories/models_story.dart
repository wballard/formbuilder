import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

List<Story> get modelStories => [
      Story(
        name: 'Models/GridDimensions',
        builder: (context) => const GridDimensionsDemo(),
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