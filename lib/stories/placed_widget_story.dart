import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

List<Story> get placedWidgetStories => [
      Story(
        name: 'Widgets/PlacedWidget/States',
        builder: (context) => const PlacedWidgetStatesDemo(),
      ),
      Story(
        name: 'Widgets/PlacedWidget/Different Children',
        builder: (context) => const PlacedWidgetChildrenDemo(),
      ),
      Story(
        name: 'Widgets/PlacedWidget/Interactive',
        builder: (context) => const InteractivePlacedWidgetDemo(),
      ),
      Story(
        name: 'Widgets/PlacedWidget/Resize Handles',
        builder: (context) => const PlacedWidgetResizeDemo(),
      ),
    ];

class PlacedWidgetStatesDemo extends StatelessWidget {
  const PlacedWidgetStatesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final placement = WidgetPlacement(
      id: 'demo-widget',
      widgetName: 'DemoWidget',
      column: 0,
      row: 0,
      width: 2,
      height: 1,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PlacedWidget States',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _StateExample(
                  label: 'Normal',
                  child: PlacedWidget(
                    placement: placement,
                    child: _DemoContent(),
                  ),
                ),
                _StateExample(
                  label: 'Selected',
                  child: PlacedWidget(
                    placement: placement,
                    isSelected: true,
                    child: _DemoContent(),
                  ),
                ),
                _StateExample(
                  label: 'Dragging',
                  child: PlacedWidget(
                    placement: placement,
                    isDragging: true,
                    child: _DemoContent(),
                  ),
                ),
                _StateExample(
                  label: 'Selected & Dragging',
                  child: PlacedWidget(
                    placement: placement,
                    isSelected: true,
                    isDragging: true,
                    child: _DemoContent(),
                  ),
                ),
                _StateExample(
                  label: 'With Tap Handler',
                  child: PlacedWidget(
                    placement: placement,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Widget tapped!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: _DemoContent(),
                  ),
                ),
                _StateExample(
                  label: 'Custom Padding',
                  child: PlacedWidget(
                    placement: placement,
                    contentPadding: const EdgeInsets.all(16),
                    child: _DemoContent(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desktop Features',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('• Hover over widgets to see elevation change'),
                    const Text('• Mouse cursor changes to "move" on hover'),
                    const Text('• Click widgets with tap handlers to see ripple effect'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateExample extends StatelessWidget {
  final String label;
  final Widget child;

  const _StateExample({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          height: 80,
          child: child,
        ),
      ],
    );
  }
}

class _DemoContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.widgets, color: Colors.blue),
            SizedBox(height: 4),
            Text(
              'Widget Content',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class PlacedWidgetChildrenDemo extends StatelessWidget {
  const PlacedWidgetChildrenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final placement = WidgetPlacement(
      id: 'demo-widget',
      widgetName: 'DemoWidget',
      column: 0,
      row: 0,
      width: 2,
      height: 1,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Different Child Widgets',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _ChildExample(
                  label: 'Text Input',
                  placement: placement,
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter text...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                _ChildExample(
                  label: 'Button',
                  placement: placement,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Submit'),
                    ),
                  ),
                ),
                _ChildExample(
                  label: 'Checkbox',
                  placement: placement,
                  child: Row(
                    children: [
                      Checkbox(value: true, onChanged: (_) {}),
                      const Text('Option'),
                    ],
                  ),
                ),
                _ChildExample(
                  label: 'Dropdown',
                  placement: placement,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: 'option1',
                    items: const [
                      DropdownMenuItem(
                        value: 'option1',
                        child: Text('Option 1'),
                      ),
                      DropdownMenuItem(
                        value: 'option2',
                        child: Text('Option 2'),
                      ),
                    ],
                    onChanged: (_) {},
                  ),
                ),
                _ChildExample(
                  label: 'Switch',
                  placement: placement,
                  child: Row(
                    children: [
                      Switch(value: true, onChanged: (_) {}),
                      const Text('Toggle'),
                    ],
                  ),
                ),
                _ChildExample(
                  label: 'Custom Widget',
                  placement: placement,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Custom',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildExample extends StatelessWidget {
  final String label;
  final WidgetPlacement placement;
  final Widget child;

  const _ChildExample({
    required this.label,
    required this.placement,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 250,
          height: 80,
          child: PlacedWidget(
            placement: placement,
            child: child,
          ),
        ),
      ],
    );
  }
}

class InteractivePlacedWidgetDemo extends StatefulWidget {
  const InteractivePlacedWidgetDemo({super.key});

  @override
  State<InteractivePlacedWidgetDemo> createState() => _InteractivePlacedWidgetDemoState();
}

class _InteractivePlacedWidgetDemoState extends State<InteractivePlacedWidgetDemo> {
  bool _isSelected = false;
  bool _isDragging = false;
  EdgeInsets _padding = const EdgeInsets.all(8);
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    final placement = WidgetPlacement(
      id: 'interactive-widget',
      widgetName: 'InteractiveWidget',
      column: 0,
      row: 0,
      width: 3,
      height: 2,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive PlacedWidget',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Controls',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Selected'),
                            value: _isSelected,
                            onChanged: (value) {
                              setState(() => _isSelected = value);
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Dragging'),
                            value: _isDragging,
                            onChanged: (value) {
                              setState(() => _isDragging = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          Text('Content Padding: ${_padding.left.toInt()}px'),
                          Slider(
                            value: _padding.left,
                            min: 0,
                            max: 32,
                            divisions: 8,
                            label: '${_padding.left.toInt()}px',
                            onChanged: (value) {
                              setState(() {
                                _padding = EdgeInsets.all(value);
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text('Tap Count: $_tapCount'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _tapCount = 0);
                            },
                            child: const Text('Reset Count'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 300,
                            height: 150,
                            child: PlacedWidget(
                              placement: placement,
                              isSelected: _isSelected,
                              isDragging: _isDragging,
                              contentPadding: _padding,
                              onTap: () {
                                setState(() => _tapCount++);
                              },
                              child: Container(
                                color: Colors.amber.shade50,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.touch_app,
                                      size: 32,
                                      color: Colors.amber.shade700,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tap me!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Tapped $_tapCount times',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlacedWidgetResizeDemo extends StatefulWidget {
  const PlacedWidgetResizeDemo({super.key});

  @override
  State<PlacedWidgetResizeDemo> createState() => _PlacedWidgetResizeDemoState();
}

class _PlacedWidgetResizeDemoState extends State<PlacedWidgetResizeDemo> {
  bool _showResizeHandles = true;
  WidgetPlacement _placement = WidgetPlacement(
    id: 'resize-demo-widget',
    widgetName: 'ResizableWidget',
    column: 1,
    row: 1,
    width: 3,
    height: 2,
  );
  String _lastAction = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PlacedWidget Resize Handles',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Controls',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Show Resize Handles'),
                            value: _showResizeHandles,
                            onChanged: (value) {
                              setState(() => _showResizeHandles = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Widget Dimensions',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Width: ${_placement.width} cells'),
                          Text('Height: ${_placement.height} cells'),
                          Text('Position: (${_placement.column}, ${_placement.row})'),
                          const SizedBox(height: 16),
                          Text(
                            'Last Action: $_lastAction',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _placement = WidgetPlacement(
                                  id: 'resize-demo-widget',
                                  widgetName: 'ResizableWidget',
                                  column: 1,
                                  row: 1,
                                  width: 3,
                                  height: 2,
                                );
                                _lastAction = 'Reset to default size';
                              });
                            },
                            child: const Text('Reset Size'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resize Demo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Stack(
                          children: [
                            // Grid background
                            _GridBackground(),
                            // Positioned widget
                            Positioned(
                              left: _placement.column * 50.0,
                              top: _placement.row * 50.0,
                              width: _placement.width * 50.0,
                              height: _placement.height * 50.0,
                              child: PlacedWidget(
                                placement: _placement,
                                isSelected: _showResizeHandles,
                                showResizeHandles: _showResizeHandles,
                                onResizeStart: (data) {
                                  setState(() {
                                    _lastAction = 'Resize started: ${data.handleType.name}';
                                  });
                                },
                                onResizeUpdate: (data, delta) {
                                  setState(() {
                                    _lastAction = 'Resizing: ${data.handleType.name} (${delta.dx.toStringAsFixed(1)}, ${delta.dy.toStringAsFixed(1)})';
                                  });
                                },
                                onResizeEnd: () {
                                  setState(() {
                                    _lastAction = 'Resize ended';
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.purple.shade200, Colors.blue.shade200],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.open_with,
                                        size: 32,
                                        color: Colors.purple.shade700,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Resizable Widget',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '${_placement.width}×${_placement.height}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                'Instructions',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              const Text('• Toggle "Show Resize Handles" to see the resize handles'),
                              const Text('• Hover over resize handles to see cursor changes'),
                              const Text('• Drag handles to resize the widget'),
                              const Text('• 8 resize handles: 4 corners + 4 edges'),
                              const Text('• Watch the dimensions and actions update'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GridBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const cellSize = 50.0;
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}