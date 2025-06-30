import 'dart:async';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'widgets/dashboard_toolbox.dart';

class DashboardBuilder extends StatefulWidget {
  const DashboardBuilder({super.key});

  @override
  State<DashboardBuilder> createState() => _DashboardBuilderState();
}

class _DashboardBuilderState extends State<DashboardBuilder> {
  LayoutState? _currentLayout;
  bool _liveDataEnabled = false;
  Timer? _dataUpdateTimer;
  
  final _initialLayout = LayoutState(
    dimensions: const GridDimensions(columns: 6, rows: 6),
    widgets: [],
  );

  @override
  void initState() {
    super.initState();
    _startDataUpdates();
  }

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  void _startDataUpdates() {
    _dataUpdateTimer?.cancel();
    if (_liveDataEnabled) {
      _dataUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          setState(() {
            // Trigger rebuild to update data
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Builder'),
        actions: [
          Switch(
            value: _liveDataEnabled,
            onChanged: (value) {
              setState(() {
                _liveDataEnabled = value;
                _startDataUpdates();
              });
            },
          ),
          const SizedBox(width: 8),
          Text(_liveDataEnabled ? 'Live Data' : 'Static'),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Preview Dashboard',
            onPressed: _previewDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize),
            tooltip: 'Dashboard Settings',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_liveDataEnabled)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.sensors, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Live data updates every 2 seconds',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FormLayout(
              key: ValueKey(_currentLayout),
              toolbox: createDashboardToolbox(_liveDataEnabled),
              initialLayout: _currentLayout ?? _initialLayout,
              onLayoutChanged: (layout) {
                setState(() {
                  _currentLayout = layout;
                });
              },
              showToolbox: true,
              toolboxPosition: Axis.vertical,
              toolboxWidth: 180,
              enableUndo: true,
            ),
          ),
        ],
      ),
    );
  }

  void _previewDashboard() {
    if (_currentLayout == null || _currentLayout!.widgets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some widgets to preview')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPreview(
          layout: _currentLayout!,
          liveData: _liveDataEnabled,
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dashboard Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Dashboard Name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: 'Sales Dashboard'),
            ),
            const SizedBox(height: 16),
            const Text('Refresh Interval'),
            DropdownButtonFormField<int>(
              value: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 second')),
                DropdownMenuItem(value: 2, child: Text('2 seconds')),
                DropdownMenuItem(value: 5, child: Text('5 seconds')),
                DropdownMenuItem(value: 10, child: Text('10 seconds')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const Text('Theme'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'light', label: Text('Light')),
                ButtonSegment(value: 'dark', label: Text('Dark')),
                ButtonSegment(value: 'auto', label: Text('Auto')),
              ],
              selected: const {'auto'},
              onSelectionChanged: (values) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class DashboardPreview extends StatelessWidget {
  final LayoutState layout;
  final bool liveData;

  const DashboardPreview({
    super.key,
    required this.layout,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard Preview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sales Dashboard',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Text(
                          'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Expanded(
                      child: Center(
                        child: Text('Dashboard widgets would be rendered here'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}