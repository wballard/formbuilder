import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

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
    final columns = context.knobs.slider(
      label: 'Columns',
      initial: 4,
      min: 1,
      max: 12,
      divisions: 11,
    ).toInt();
    
    final rows = context.knobs.slider(
      label: 'Rows',
      initial: 4,
      min: 1,
      max: 10,
      divisions: 9,
    ).toInt();
    
    final gridLineWidth = context.knobs.slider(
      label: 'Grid Line Width',
      initial: 1.0,
      min: 0.5,
      max: 5.0,
      divisions: 9,
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(columns: 3, rows: 3),
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(columns: 3, rows: 3),
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(columns: 3, rows: 3),
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridWidget(
                            dimensions: const GridDimensions(columns: 3, rows: 3),
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
          child: GridWidget(
            dimensions: dimensions,
          ),
        ),
      ],
    );
  }
}