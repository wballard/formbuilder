// Extension of toolbox_widget_story.dart with drag and drop demo

import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';

class DragAndDropToolboxDemo extends StatefulWidget {
  const DragAndDropToolboxDemo({super.key});

  @override
  State<DragAndDropToolboxDemo> createState() => _DragAndDropToolboxDemoState();
}

class _DragAndDropToolboxDemoState extends State<DragAndDropToolboxDemo> {
  final toolbox = Toolbox.withDefaults();
  String? _currentDragItem;
  String? _lastDraggedItem;
  bool _isDragging = false;
  final List<String> _dragLog = [];
  
  void _addLog(String message) {
    setState(() {
      _dragLog.add('${DateTime.now().toString().substring(11, 19)}: $message');
      // Keep only last 10 entries
      if (_dragLog.length > 10) {
        _dragLog.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag and Drop ToolboxWidget'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbox on the left
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(
                  color: _isDragging ? Colors.blue : Colors.grey.shade300,
                  width: _isDragging ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Drag Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ToolboxWidget(
                      toolbox: toolbox,
                      onDragStarted: (item) {
                        setState(() {
                          _currentDragItem = item.displayName;
                          _isDragging = true;
                        });
                        _addLog('Started dragging ${item.displayName}');
                      },
                      onDragEnd: () {
                        setState(() {
                          if (_currentDragItem != null) {
                            _lastDraggedItem = _currentDragItem;
                          }
                          _currentDragItem = null;
                          _isDragging = false;
                        });
                        _addLog('Drag ended');
                      },
                      onDragCompleted: () {
                        _addLog('Drag completed successfully');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Drop zone and info
            Expanded(
              child: Column(
                children: [
                  // Drop zone
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(
                        color: _isDragging ? Colors.green : Colors.grey.shade400,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DragTarget<ToolboxItem>(
                      onWillAcceptWithDetails: (details) => true,
                      onAcceptWithDetails: (details) {
                        _addLog('Dropped ${details.data.displayName} into drop zone');
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                candidateData.isNotEmpty 
                                    ? Icons.add_circle_outline 
                                    : Icons.drag_indicator,
                                size: 48,
                                color: candidateData.isNotEmpty 
                                    ? Colors.green 
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                candidateData.isNotEmpty
                                    ? 'Drop here!'
                                    : 'Drag widgets here',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: candidateData.isNotEmpty 
                                      ? Colors.green 
                                      : Colors.grey.shade600,
                                  fontWeight: candidateData.isNotEmpty 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                              if (_lastDraggedItem != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Last dropped: $_lastDraggedItem',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info card
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Drag and Drop Demo',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'This demo shows the drag and drop functionality of the ToolboxWidget. '
                              'Long press any widget in the toolbox to start dragging it.',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Features:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text('• Long press to initiate drag'),
                            const Text('• Visual feedback during drag'),
                            const Text('• 80% opacity for drag feedback'),
                            const Text('• 30% opacity for original widget while dragging'),
                            const Text('• Drag callbacks for state management'),
                            const Text('• Drop zone with visual indicators'),
                            const SizedBox(height: 16),
                            if (_currentDragItem != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.drag_indicator, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Currently dragging: $_currentDragItem',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              'Event Log:',
                              style: Theme.of(context).textTheme.titleMedium,
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
                                  itemCount: _dragLog.length,
                                  itemBuilder: (context, index) {
                                    return Text(
                                      _dragLog[index],
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