import 'package:flutter/material.dart';
import 'package:formbuilder/formbuilder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Sizing Test',
      home: TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
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
      appBar: AppBar(title: const Text('Widget Sizing Test')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test 1: GridContainer (should show widgets)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: GridContainer(
                layoutState: layoutState,
                widgetBuilders: widgetBuilders,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Test 2: Simple Container (for comparison)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 168, // 3 rows * 56 pixels
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    height: 56,
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Submit'),
                          ),
                        ),
                      ),
                    ],
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