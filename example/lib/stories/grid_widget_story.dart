import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'dart:math';

List<Story> get gridWidgetStories => [
  Story(
    name: 'Widgets/GridWidget/Default',
    builder: (context) => const GridWidgetDemo(),
  ),
  Story(
    name: 'Widgets/GridWidget/Interactive',
    builder: (context) => const InteractiveGridDemo(),
  ),
  Story(
    name: 'Widgets/GridWidget/Custom Styling',
    builder: (context) => const CustomStyledGridDemo(),
  ),
  Story(
    name: 'Widgets/GridWidget/Different Sizes',
    builder: (context) => const GridSizesDemo(),
  ),
  Story(
    name: 'Widgets/GridWidget/Cell Highlighting',
    builder: (context) => const CellHighlightingDemo(),
  ),
  Story(
    name: 'Widgets/GridWidget/Interactive Highlighting',
    builder: (context) => const InteractiveHighlightingDemo(),
  ),
];

class GridWidgetDemo extends StatelessWidget {
  const GridWidgetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Grid Widget',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'A 4x4 grid with default styling:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 400,
              child: GridWidget(
                dimensions: const GridDimensions(columns: 4, rows: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InteractiveGridDemo extends StatelessWidget {
  const InteractiveGridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = context.knobs
        .slider(label: 'Columns', initial: 4, min: 1, max: 12)
        .toInt();

    final rows = context.knobs
        .slider(label: 'Rows', initial: 4, min: 1, max: 10)
        .toInt();

    final gridLineWidth = context.knobs.slider(
      label: 'Grid Line Width',
      initial: 1.0,
      min: 0.5,
      max: 5.0,
    );

    final useCustomColors = context.knobs.boolean(
      label: 'Use Custom Colors',
      initial: false,
    );

    final gridLineColor = useCustomColors
        ? Colors.blue.shade300
        : Colors.grey.shade300;

    final backgroundColor = useCustomColors
        ? Colors.blue.shade50
        : Colors.white;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive Grid',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Grid size: $columns × $rows',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridWidget(
                dimensions: GridDimensions(columns: columns, rows: rows),
                gridLineColor: gridLineColor,
                gridLineWidth: gridLineWidth,
                backgroundColor: backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomStyledGridDemo extends StatelessWidget {
  const CustomStyledGridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Styled Grids',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Blue Theme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(
                              columns: 3,
                              rows: 3,
                            ),
                            gridLineColor: Colors.blue.shade300,
                            gridLineWidth: 2.0,
                            backgroundColor: Colors.blue.shade50,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dark Theme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(
                              columns: 3,
                              rows: 3,
                            ),
                            gridLineColor: Colors.grey.shade600,
                            gridLineWidth: 1.0,
                            backgroundColor: Colors.grey.shade900,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Green Theme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(
                              columns: 3,
                              rows: 3,
                            ),
                            gridLineColor: Colors.green.shade400,
                            gridLineWidth: 1.5,
                            backgroundColor: Colors.green.shade50,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Minimal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(
                              columns: 3,
                              rows: 3,
                            ),
                            gridLineColor: Colors.grey.shade200,
                            gridLineWidth: 0.5,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                      ],
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

class GridSizesDemo extends StatelessWidget {
  const GridSizesDemo({super.key});

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
                'Different Grid Sizes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              _buildGridExample(
                context,
                'Small (2×2)',
                const GridDimensions(columns: 2, rows: 2),
                200,
              ),
              const SizedBox(height: 24),
              _buildGridExample(
                context,
                'Square (4×4)',
                const GridDimensions(columns: 4, rows: 4),
                300,
              ),
              const SizedBox(height: 24),
              _buildGridExample(
                context,
                'Wide (6×3)',
                const GridDimensions(columns: 6, rows: 3),
                300,
              ),
              const SizedBox(height: 24),
              _buildGridExample(
                context,
                'Tall (3×6)',
                const GridDimensions(columns: 3, rows: 6),
                200,
              ),
              const SizedBox(height: 24),
              _buildGridExample(
                context,
                'Large (8×6)',
                const GridDimensions(columns: 8, rows: 6),
                400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridExample(
    BuildContext context,
    String label,
    GridDimensions dimensions,
    double height,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: GridWidget(dimensions: dimensions),
        ),
      ],
    );
  }
}

class CellHighlightingDemo extends StatelessWidget {
  const CellHighlightingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cell Highlighting',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Highlighting',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(
                              columns: 4,
                              rows: 4,
                            ),
                            highlightedCells: {
                              const Point(0, 0),
                              const Point(1, 0),
                              const Point(0, 1),
                              const Point(1, 1),
                            },
                            highlightColor: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Custom Colors',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(
                              columns: 4,
                              rows: 4,
                            ),
                            highlightedCells: {
                              const Point(2, 1),
                              const Point(3, 1),
                              const Point(2, 2),
                              const Point(3, 2),
                            },
                            highlightColor: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Invalid Cell Highlighting',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: GridWidget(
                dimensions: const GridDimensions(columns: 6, rows: 4),
                highlightedCells: GridWidget.getCellsInRectangle(1, 1, 4, 2),
                highlightColor: Colors.orange.withValues(alpha: 0.3),
                invalidHighlightColor: Colors.red.withValues(alpha: 0.3),
                isCellValid: (cell) {
                  // Make cells at (2,1) and (3,2) invalid
                  return !(cell == const Point(2, 1) ||
                      cell == const Point(3, 2));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InteractiveHighlightingDemo extends StatefulWidget {
  const InteractiveHighlightingDemo({super.key});

  @override
  State<InteractiveHighlightingDemo> createState() =>
      _InteractiveHighlightingDemoState();
}

class _InteractiveHighlightingDemoState
    extends State<InteractiveHighlightingDemo> {
  Set<Point<int>> _highlightedCells = <Point<int>>{};
  final int _columns = 6;
  final int _rows = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive Cell Highlighting',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Click/tap cells to toggle highlighting. You can also drag to highlight multiple cells.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _highlightedCells = <Point<int>>{};
                    });
                  },
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Add a 2x2 block at random position
                      final random = Random();
                      final col = random.nextInt(_columns - 1);
                      final row = random.nextInt(_rows - 1);
                      _highlightedCells = {
                        ..._highlightedCells,
                        ...GridWidget.getCellsInRectangle(col, row, 2, 2),
                      };
                    });
                  },
                  child: const Text('Add Random 2x2'),
                ),
                const SizedBox(width: 16),
                Text('Highlighted: ${_highlightedCells.length} cells'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellWidth = constraints.maxWidth / _columns;
                  final cellHeight = constraints.maxHeight / _rows;

                  return GestureDetector(
                    onTapDown: (details) {
                      final col = (details.localPosition.dx / cellWidth)
                          .floor();
                      final row = (details.localPosition.dy / cellHeight)
                          .floor();
                      if (col >= 0 &&
                          col < _columns &&
                          row >= 0 &&
                          row < _rows) {
                        setState(() {
                          final cell = Point(col, row);
                          if (_highlightedCells.contains(cell)) {
                            _highlightedCells = _highlightedCells.where((c) => c != cell).toSet();
                          } else {
                            _highlightedCells = {..._highlightedCells, cell};
                          }
                        });
                      }
                    },
                    child: GridWidget(
                      dimensions: GridDimensions(
                        columns: _columns,
                        rows: _rows,
                      ),
                      highlightedCells: _highlightedCells,
                      highlightColor: Colors.blue.withValues(alpha: 0.3),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
