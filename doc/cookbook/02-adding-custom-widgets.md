# Adding Custom Widgets

Learn how to create and add custom widgets to your FormBuilder toolbox.

## Overview

Custom widgets allow you to:
- Add specialized input types
- Create reusable components
- Implement business-specific fields
- Integrate third-party widgets

## Creating a Custom Rating Widget

Let's create a star rating widget as an example.

### Step 1: Define the Widget

First, create the actual widget that will be displayed:

```dart
class RatingWidget extends StatefulWidget {
  final String id;
  final Map<String, dynamic> properties;
  final ValueChanged<int>? onChanged;

  const RatingWidget({
    Key? key,
    required this.id,
    required this.properties,
    this.onChanged,
  }) : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late int _rating;
  late int _maxRating;

  @override
  void initState() {
    super.initState();
    _rating = widget.properties['value'] ?? 0;
    _maxRating = widget.properties['maxRating'] ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.properties['label'] != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.properties['label'],
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_maxRating, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: widget.properties['size'] ?? 32.0,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1;
                });
                widget.onChanged?.call(_rating);
              },
            );
          }),
        ),
        if (widget.properties['showValue'] == true)
          Center(
            child: Text(
              '$_rating / $_maxRating',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
```

### Step 2: Create a Toolbox Item

Add your custom widget to the toolbox:

```dart
ToolboxItem createRatingToolboxItem() {
  return ToolboxItem(
    name: 'rating',
    icon: Icons.star,
    label: 'Rating',
    defaultWidth: 2,
    defaultHeight: 1,
    gridBuilder: (context, placement) => RatingWidget(
      id: placement.id,
      properties: placement.properties,
      onChanged: (rating) {
        print('Rating changed to $rating for ${placement.id}');
      },
    ),
    // Optional: Define default properties
    defaultProperties: {
      'label': 'Rating',
      'maxRating': 5,
      'value': 0,
      'size': 32.0,
      'showValue': true,
    },
  );
}
```

### Step 3: Add to Your Toolbox

Include the custom widget in your toolbox categories:

```dart
CategorizedToolbox createToolboxWithCustomWidgets() {
  return CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Custom Widgets',
        icon: Icons.widgets,
        items: [
          createRatingToolboxItem(),
          // Add more custom widgets here
        ],
      ),
      // Other categories...
    ],
  );
}
```

## Advanced Custom Widget Example

Here's a more complex example - a date range picker:

```dart
class DateRangeWidget extends StatefulWidget {
  final String id;
  final Map<String, dynamic> properties;

  const DateRangeWidget({
    Key? key,
    required this.id,
    required this.properties,
  }) : super(key: key);

  @override
  _DateRangeWidgetState createState() => _DateRangeWidgetState();
}

class _DateRangeWidgetState extends State<DateRangeWidget> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    // Load saved date range if available
    if (widget.properties['startDate'] != null && 
        widget.properties['endDate'] != null) {
      _selectedRange = DateTimeRange(
        start: DateTime.parse(widget.properties['startDate']),
        end: DateTime.parse(widget.properties['endDate']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _selectDateRange(context),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.properties['label'] ?? 'Date Range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedRange != null
                          ? '${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}'
                          : 'Select date range',
                      style: TextStyle(
                        color: _selectedRange != null 
                            ? null 
                            : Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.properties['primaryColor'] != null
                  ? Color(widget.properties['primaryColor'])
                  : Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedRange) {
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Toolbox item for date range picker
ToolboxItem createDateRangeToolboxItem() {
  return ToolboxItem(
    name: 'date_range',
    icon: Icons.date_range,
    label: 'Date Range',
    defaultWidth: 2,
    defaultHeight: 1,
    gridBuilder: (context, placement) => DateRangeWidget(
      id: placement.id,
      properties: placement.properties,
    ),
    defaultProperties: {
      'label': 'Select Dates',
      'allowPastDates': true,
      'allowFutureDates': true,
    },
  );
}
```

## Widget with Custom Properties

Create widgets that can be configured through properties:

```dart
class ConfigurableDropdown extends StatelessWidget {
  final WidgetPlacement placement;

  const ConfigurableDropdown({
    Key? key,
    required this.placement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final properties = placement.properties;
    final items = properties['items'] as List<dynamic>? ?? [];
    final label = properties['label'] ?? 'Dropdown';
    final hint = properties['hint'] ?? 'Select an option';
    final isRequired = properties['required'] ?? false;

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          hintText: hint,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']),
          );
        }).toList(),
        onChanged: (value) {
          print('Dropdown ${placement.id} selected: $value');
        },
        validator: isRequired 
            ? (value) => value == null ? 'Please select an option' : null
            : null,
      ),
    );
  }
}

// Create with predefined options
ToolboxItem createCountryDropdown() {
  return ToolboxItem(
    name: 'country_dropdown',
    icon: Icons.flag,
    label: 'Country',
    defaultWidth: 2,
    defaultHeight: 1,
    gridBuilder: (context, placement) => ConfigurableDropdown(
      placement: placement,
    ),
    defaultProperties: {
      'label': 'Country',
      'hint': 'Select your country',
      'required': true,
      'items': [
        {'value': 'us', 'label': 'United States'},
        {'value': 'uk', 'label': 'United Kingdom'},
        {'value': 'ca', 'label': 'Canada'},
        {'value': 'au', 'label': 'Australia'},
        // Add more countries...
      ],
    },
  );
}
```

## Best Practices

### 1. Widget Identification
Always use the placement ID as the widget key:
```dart
key: ValueKey(placement.id),
```

### 2. Property Validation
Validate and provide defaults for properties:
```dart
final label = properties['label'] ?? 'Default Label';
final maxLength = properties['maxLength'] as int? ?? 100;
```

### 3. Consistent Styling
Follow Material Design guidelines:
```dart
decoration: InputDecoration(
  labelText: label,
  border: OutlineInputBorder(),
  filled: true,
  fillColor: Theme.of(context).colorScheme.surface,
),
```

### 4. Size Considerations
Respect the grid placement size:
```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Adjust widget based on available space
      final isCompact = constraints.maxWidth < 200;
      return isCompact 
          ? _buildCompactView() 
          : _buildFullView();
    },
  );
}
```

### 5. State Management
Handle state appropriately for form widgets:
```dart
class StatefulCustomWidget extends StatefulWidget {
  // Use StatefulWidget for widgets that maintain state
  // Pass changes up through callbacks
}
```

## Testing Custom Widgets

Always test your custom widgets:

```dart
testWidgets('Rating widget updates on tap', (tester) async {
  int? lastRating;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RatingWidget(
          id: 'test-rating',
          properties: {'maxRating': 5},
          onChanged: (rating) => lastRating = rating,
        ),
      ),
    ),
  );

  // Tap the third star
  await tester.tap(find.byIcon(Icons.star_border).at(2));
  await tester.pump();

  expect(lastRating, equals(3));
  expect(find.byIcon(Icons.star), findsNWidgets(3));
});
```

## Next Steps

- [Implement validation](04-implementing-validation.md) for your custom widgets
- [Create property editors](06-custom-property-editors.md) for advanced configuration
- [Share your widgets](../contributing.md) with the community