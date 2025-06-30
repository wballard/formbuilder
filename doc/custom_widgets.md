# Custom Widget Guide

This guide explains how to create custom widgets for FormBuilder, from simple components to complex, configurable widgets.

## Understanding the Widget System

### Widget Lifecycle

1. **Toolbox Definition**: Widget appears in the toolbox
2. **Drag Operation**: User drags widget to grid
3. **Placement Creation**: System creates WidgetPlacement
4. **Widget Building**: gridBuilder creates the actual widget
5. **Property Updates**: Widget responds to property changes
6. **State Persistence**: Widget state saved with layout

### Key Components

```dart
// 1. ToolboxItem - Defines the draggable item
ToolboxItem(
  name: 'unique_widget_id',
  icon: Icons.widget,
  label: 'Display Name',
  gridBuilder: (context, placement) => YourWidget(placement),
)

// 2. WidgetPlacement - Position and configuration
WidgetPlacement(
  id: 'instance-id',
  widgetName: 'unique_widget_id',
  column: 0,
  row: 0,
  width: 2,
  height: 1,
  properties: {'key': 'value'},
)

// 3. Your Widget Implementation
class YourWidget extends StatelessWidget {
  final WidgetPlacement placement;
  YourWidget(this.placement);
  // ...
}
```

## Creating Simple Custom Widgets

### Step 1: Define the Widget

```dart
class CustomBadge extends StatelessWidget {
  final WidgetPlacement placement;
  
  const CustomBadge({
    Key? key,
    required this.placement,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final text = placement.properties['text'] ?? 'Badge';
    final color = placement.properties['color'] != null
        ? Color(placement.properties['color'])
        : Theme.of(context).primaryColor;
    
    return Container(
      key: ValueKey(placement.id),
      padding: EdgeInsets.all(8),
      child: Chip(
        label: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        avatar: placement.properties['icon'] != null
            ? Icon(
                IconData(placement.properties['icon'], fontFamily: 'MaterialIcons'),
                size: 18,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
```

### Step 2: Create Toolbox Item

```dart
ToolboxItem createBadgeItem() {
  return ToolboxItem(
    name: 'badge',
    icon: Icons.label,
    label: 'Badge',
    defaultWidth: 1,
    defaultHeight: 1,
    gridBuilder: (context, placement) => CustomBadge(placement: placement),
    defaultProperties: {
      'text': 'New',
      'color': Colors.blue.value,
      'icon': Icons.star.codePoint,
    },
  );
}
```

### Step 3: Add to Toolbox

```dart
CategorizedToolbox(
  categories: [
    ToolboxCategory(
      name: 'Custom Widgets',
      icon: Icons.widgets,
      items: [
        createBadgeItem(),
        // Other custom widgets...
      ],
    ),
  ],
)
```

## Advanced Custom Widgets

### Stateful Custom Widget

Create widgets that maintain their own state:

```dart
class CounterWidget extends StatefulWidget {
  final WidgetPlacement placement;
  
  const CounterWidget({
    Key? key,
    required this.placement,
  }) : super(key: key);
  
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _count;
  
  @override
  void initState() {
    super.initState();
    _count = widget.placement.properties['initialValue'] ?? 0;
  }
  
  void _increment() {
    setState(() {
      _count++;
    });
    // Optionally notify parent of state change
    _notifyChange();
  }
  
  void _decrement() {
    setState(() {
      _count--;
    });
    _notifyChange();
  }
  
  void _notifyChange() {
    // Use a callback or state management solution
    // to persist the counter value
  }
  
  @override
  Widget build(BuildContext context) {
    final min = widget.placement.properties['min'] ?? 0;
    final max = widget.placement.properties['max'] ?? 100;
    
    return Card(
      key: ValueKey(widget.placement.id),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.placement.properties['label'] ?? 'Counter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _count > min ? _decrement : null,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$_count',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _count < max ? _increment : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Widget with External Dependencies

Integrate third-party packages:

```dart
// Using charts_flutter for data visualization
import 'package:charts_flutter/flutter.dart' as charts;

class ChartWidget extends StatelessWidget {
  final WidgetPlacement placement;
  
  const ChartWidget({required this.placement});
  
  @override
  Widget build(BuildContext context) {
    final chartType = placement.properties['type'] ?? 'bar';
    final data = _parseData(placement.properties['data']);
    
    return Container(
      key: ValueKey(placement.id),
      padding: EdgeInsets.all(8),
      child: charts.BarChart(
        _createSeries(data),
        animate: placement.properties['animate'] ?? true,
        behaviors: [
          if (placement.properties['showLegend'] == true)
            charts.SeriesLegend(),
        ],
      ),
    );
  }
  
  List<charts.Series<DataPoint, String>> _createSeries(List<DataPoint> data) {
    return [
      charts.Series<DataPoint, String>(
        id: 'Data',
        domainFn: (DataPoint point, _) => point.label,
        measureFn: (DataPoint point, _) => point.value,
        data: data,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];
  }
  
  List<DataPoint> _parseData(dynamic data) {
    // Parse data from properties
    return [];
  }
}

class DataPoint {
  final String label;
  final int value;
  DataPoint(this.label, this.value);
}
```

## Property System

### Basic Properties

Define default properties for your widget:

```dart
ToolboxItem(
  // ...
  defaultProperties: {
    'label': 'My Widget',
    'color': Colors.blue.value,
    'enabled': true,
    'size': 'medium',
  },
)
```

### Dynamic Properties

Properties that change based on other properties:

```dart
class ConditionalWidget extends StatelessWidget {
  final WidgetPlacement placement;
  
  const ConditionalWidget({required this.placement});
  
  @override
  Widget build(BuildContext context) {
    final type = placement.properties['type'] ?? 'text';
    
    switch (type) {
      case 'text':
        return _buildTextField();
      case 'number':
        return _buildNumberField();
      case 'date':
        return _buildDateField();
      default:
        return _buildTextField();
    }
  }
  
  Widget _buildTextField() {
    return TextFormField(
      key: ValueKey(placement.id),
      decoration: InputDecoration(
        labelText: placement.properties['label'],
      ),
    );
  }
  
  Widget _buildNumberField() {
    return TextFormField(
      key: ValueKey(placement.id),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: placement.properties['label'],
      ),
    );
  }
  
  Widget _buildDateField() {
    return DatePickerFormField(
      key: ValueKey(placement.id),
      decoration: InputDecoration(
        labelText: placement.properties['label'],
      ),
    );
  }
}
```

### Property Validation

Validate properties before use:

```dart
class ValidatedWidget extends StatelessWidget {
  final WidgetPlacement placement;
  
  const ValidatedWidget({required this.placement});
  
  @override
  Widget build(BuildContext context) {
    // Validate and provide defaults
    final validatedProps = _validateProperties(placement.properties);
    
    if (validatedProps['error'] != null) {
      return _buildErrorWidget(validatedProps['error']);
    }
    
    return _buildWidget(validatedProps);
  }
  
  Map<String, dynamic> _validateProperties(Map<String, dynamic> props) {
    final validated = <String, dynamic>{};
    
    // Validate URL
    if (props['url'] != null) {
      try {
        final uri = Uri.parse(props['url']);
        if (!uri.hasScheme) {
          return {'error': 'Invalid URL: missing scheme'};
        }
        validated['url'] = props['url'];
      } catch (e) {
        return {'error': 'Invalid URL format'};
      }
    }
    
    // Validate color
    if (props['color'] != null) {
      if (props['color'] is int) {
        validated['color'] = Color(props['color']);
      } else if (props['color'] is String) {
        // Parse hex color
        try {
          validated['color'] = Color(int.parse(props['color'].substring(1), radix: 16));
        } catch (e) {
          validated['color'] = Colors.blue;
        }
      }
    }
    
    return validated;
  }
}
```

## Layout-Aware Widgets

### Responsive to Grid Size

```dart
class ResponsiveWidget extends StatelessWidget {
  final WidgetPlacement placement;
  
  const ResponsiveWidget({required this.placement});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: ValueKey(placement.id),
      builder: (context, constraints) {
        // Determine layout based on available space
        final isCompact = constraints.maxWidth < 200;
        final isTall = constraints.maxHeight > 150;
        
        if (isCompact) {
          return _buildCompactLayout();
        } else if (isTall) {
          return _buildTallLayout();
        } else {
          return _buildStandardLayout();
        }
      },
    );
  }
  
  Widget _buildCompactLayout() {
    // Vertical layout for narrow spaces
    return Column(
      children: [
        Icon(Icons.info),
        Text(placement.properties['label'] ?? 'Info'),
      ],
    );
  }
  
  Widget _buildTallLayout() {
    // Take advantage of vertical space
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.info, size: 48),
        Text(
          placement.properties['label'] ?? 'Info',
          style: TextStyle(fontSize: 18),
        ),
        if (placement.properties['description'] != null)
          Text(placement.properties['description']),
      ],
    );
  }
  
  Widget _buildStandardLayout() {
    // Horizontal layout for standard sizes
    return Row(
      children: [
        Icon(Icons.info),
        SizedBox(width: 8),
        Expanded(
          child: Text(placement.properties['label'] ?? 'Info'),
        ),
      ],
    );
  }
}
```

## Form Integration

### Custom Form Fields

Create widgets that integrate with Flutter's Form system:

```dart
class CustomFormField extends FormField<String> {
  CustomFormField({
    Key? key,
    required WidgetPlacement placement,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator ?? _defaultValidator(placement),
          initialValue: placement.properties['value'],
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputWidget(
                  placement: placement,
                  value: state.value,
                  onChanged: state.didChange,
                ),
                if (state.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(state.context).errorColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
  
  static FormFieldValidator<String>? _defaultValidator(WidgetPlacement placement) {
    if (placement.properties['required'] == true) {
      return (value) => value?.isEmpty ?? true 
          ? '${placement.properties['label'] ?? 'Field'} is required' 
          : null;
    }
    return null;
  }
}
```

## Testing Custom Widgets

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomBadge', () {
    testWidgets('displays text from properties', (tester) async {
      final placement = WidgetPlacement(
        id: 'test-badge',
        widgetName: 'badge',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
        properties: {'text': 'Test Badge'},
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBadge(placement: placement),
          ),
        ),
      );
      
      expect(find.text('Test Badge'), findsOneWidget);
    });
    
    testWidgets('uses default text when not provided', (tester) async {
      final placement = WidgetPlacement(
        id: 'test-badge',
        widgetName: 'badge',
        column: 0,
        row: 0,
        width: 1,
        height: 1,
        properties: {},
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBadge(placement: placement),
          ),
        ),
      );
      
      expect(find.text('Badge'), findsOneWidget);
    });
  });
}
```

### Integration Tests

```dart
testWidgets('custom widget integrates with FormLayout', (tester) async {
  final toolbox = CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Custom',
        icon: Icons.widgets,
        items: [createBadgeItem()],
      ),
    ],
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FormLayout(
          toolbox: toolbox,
        ),
      ),
    ),
  );
  
  // Find widget in toolbox
  expect(find.text('Badge'), findsOneWidget);
  
  // Drag to grid
  final badge = find.text('Badge');
  final grid = find.byType(GridDragTarget);
  
  await tester.drag(badge, tester.getCenter(grid));
  await tester.pumpAndSettle();
  
  // Verify widget was placed
  expect(find.byType(CustomBadge), findsOneWidget);
});
```

## Best Practices

### 1. Always Use Widget Keys
```dart
key: ValueKey(placement.id),
```

### 2. Handle Missing Properties
```dart
final label = placement.properties['label'] ?? 'Default Label';
```

### 3. Validate Input
```dart
final fontSize = placement.properties['fontSize'];
if (fontSize != null && fontSize is num && fontSize > 0) {
  // Use fontSize
}
```

### 4. Follow Material Design
```dart
Card(
  child: InkWell(
    onTap: () {},
    child: Padding(
      padding: EdgeInsets.all(16),
      child: content,
    ),
  ),
)
```

### 5. Support Themes
```dart
color: placement.properties['color'] != null
    ? Color(placement.properties['color'])
    : Theme.of(context).primaryColor,
```

### 6. Document Properties
```dart
/// Custom Progress Widget
/// 
/// Properties:
/// - value (double): Current progress value (0.0 to 1.0)
/// - label (String): Display label
/// - color (int): Progress bar color
/// - showPercentage (bool): Show percentage text
```

## Publishing Custom Widgets

### Package Structure

```
my_custom_widgets/
├── lib/
│   ├── my_custom_widgets.dart
│   ├── src/
│   │   ├── widgets/
│   │   │   ├── badge.dart
│   │   │   ├── counter.dart
│   │   │   └── chart.dart
│   │   └── toolbox_items.dart
├── test/
├── example/
├── README.md
└── pubspec.yaml
```

### Export Configuration

```dart
// lib/my_custom_widgets.dart
library my_custom_widgets;

export 'src/widgets/badge.dart';
export 'src/widgets/counter.dart';
export 'src/widgets/chart.dart';
export 'src/toolbox_items.dart';

// Convenience method to get all items
List<ToolboxItem> getCustomToolboxItems() {
  return [
    createBadgeItem(),
    createCounterItem(),
    createChartItem(),
  ];
}
```

### Usage

```dart
import 'package:my_custom_widgets/my_custom_widgets.dart';

final toolbox = CategorizedToolbox(
  categories: [
    ToolboxCategory(
      name: 'Custom Widgets',
      icon: Icons.widgets,
      items: getCustomToolboxItems(),
    ),
  ],
);
```

## Next Steps

- Explore the [Widget Gallery](widgets.md) for more examples
- Learn about [State Management](state_management.md) for complex widgets
- Share your widgets with the community!