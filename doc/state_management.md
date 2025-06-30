# State Management Guide

This guide explains how to manage state in FormBuilder applications, from simple local state to complex application-wide state management.

## Understanding FormBuilder State

### State Layers

FormBuilder has three main layers of state:

1. **Layout State**: The grid configuration and widget placements
2. **Widget State**: Individual widget values and properties
3. **Application State**: User data, preferences, and business logic

```
┌─────────────────────────────────┐
│     Application State           │ ← Business logic, user data
├─────────────────────────────────┤
│     Layout State                │ ← Grid, widget positions
├─────────────────────────────────┤
│     Widget State                │ ← Form values, UI state
└─────────────────────────────────┘
```

## Using the Built-in Hooks

### useFormLayout Hook

The primary hook for managing form layout state:

```dart
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';

class MyFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize form layout controller
    final controller = useFormLayout(
      LayoutState.empty(),
      undoLimit: 50,
    );
    
    return Column(
      children: [
        // Access controller properties
        Text('Widgets: ${controller.state.widgets.length}'),
        
        // Use controller methods
        ElevatedButton(
          onPressed: controller.canUndo ? controller.undo : null,
          child: Text('Undo'),
        ),
        
        // Check mode
        if (controller.isPreviewMode)
          Text('Preview Mode'),
          
        // Build form
        Expanded(
          child: FormLayout(
            toolbox: myToolbox,
            initialLayout: controller.state,
          ),
        ),
      ],
    );
  }
}
```

### Controller Methods

```dart
// State access
controller.state                    // Current LayoutState
controller.selectedWidgetId         // Currently selected widget
controller.isPreviewMode           // Preview mode status

// State mutations
controller.addWidget(placement)     // Add widget
controller.removeWidget(id)         // Remove widget
controller.updateWidget(id, placement) // Update widget
controller.selectWidget(id)         // Select widget
controller.clearSelection()         // Clear selection

// Grid operations
controller.resizeGrid(dimensions)   // Resize grid

// History
controller.undo()                   // Undo last action
controller.redo()                   // Redo action
controller.canUndo                  // Can undo?
controller.canRedo                  // Can redo?

// Mode
controller.togglePreviewMode()      // Toggle preview
controller.setPreviewMode(bool)     // Set preview mode
```

## Managing Widget Values

### Local Widget State

For simple widget state, use StatefulWidget:

```dart
class StatefulFormWidget extends StatefulWidget {
  final WidgetPlacement placement;
  
  const StatefulFormWidget({required this.placement});
  
  @override
  _StatefulFormWidgetState createState() => _StatefulFormWidgetState();
}

class _StatefulFormWidgetState extends State<StatefulFormWidget> {
  late TextEditingController _controller;
  String? _errorText;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.placement.properties['value'],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _validate(String value) {
    setState(() {
      if (value.isEmpty && widget.placement.properties['required'] == true) {
        _errorText = 'This field is required';
      } else {
        _errorText = null;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(widget.placement.id),
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.placement.properties['label'],
        errorText: _errorText,
      ),
      onChanged: _validate,
    );
  }
}
```

### Lifting State Up

For state that needs to be shared, lift it to a parent widget:

```dart
class FormWithSharedState extends StatefulWidget {
  @override
  _FormWithSharedStateState createState() => _FormWithSharedStateState();
}

class _FormWithSharedStateState extends State<FormWithSharedState> {
  final Map<String, dynamic> _formData = {};
  
  void _updateFieldValue(String fieldId, dynamic value) {
    setState(() {
      _formData[fieldId] = value;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return FormLayout(
      toolbox: CategorizedToolbox(
        categories: [
          ToolboxCategory(
            name: 'Form Fields',
            icon: Icons.input,
            items: [
              ToolboxItem(
                name: 'connected_field',
                icon: Icons.link,
                label: 'Connected Field',
                gridBuilder: (context, placement) => ConnectedField(
                  placement: placement,
                  value: _formData[placement.id],
                  onChanged: (value) => _updateFieldValue(placement.id, value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConnectedField extends StatelessWidget {
  final WidgetPlacement placement;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  
  const ConnectedField({
    required this.placement,
    required this.value,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(placement.id),
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: placement.properties['label'],
      ),
      onChanged: onChanged,
    );
  }
}
```

## State Management Solutions

### Provider Integration

Using Provider for form state:

```dart
// Define state model
class FormStateModel extends ChangeNotifier {
  LayoutState _layout = LayoutState.empty();
  final Map<String, dynamic> _values = {};
  final Map<String, String?> _errors = {};
  
  LayoutState get layout => _layout;
  Map<String, dynamic> get values => Map.unmodifiable(_values);
  Map<String, String?> get errors => Map.unmodifiable(_errors);
  
  void updateLayout(LayoutState layout) {
    _layout = layout;
    notifyListeners();
  }
  
  void setValue(String fieldId, dynamic value) {
    _values[fieldId] = value;
    _validateField(fieldId, value);
    notifyListeners();
  }
  
  void _validateField(String fieldId, dynamic value) {
    // Find widget in layout
    final widget = _layout.widgets.firstWhere(
      (w) => w.id == fieldId,
      orElse: () => throw Exception('Widget not found'),
    );
    
    // Validate based on properties
    if (widget.properties['required'] == true && 
        (value == null || value.toString().isEmpty)) {
      _errors[fieldId] = 'This field is required';
    } else {
      _errors[fieldId] = null;
    }
  }
  
  bool get isValid => !_errors.values.any((error) => error != null);
  
  Map<String, dynamic> getFormData() {
    if (!isValid) {
      throw Exception('Form has validation errors');
    }
    return Map.from(_values);
  }
}

// Usage
class ProviderFormBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FormStateModel(),
      child: Consumer<FormStateModel>(
        builder: (context, formState, _) => FormLayout(
          toolbox: createToolbox(context),
          initialLayout: formState.layout,
          onLayoutChanged: formState.updateLayout,
        ),
      ),
    );
  }
  
  CategorizedToolbox createToolbox(BuildContext context) {
    return CategorizedToolbox(
      categories: [
        ToolboxCategory(
          name: 'Fields',
          icon: Icons.input,
          items: [
            ToolboxItem(
              name: 'managed_field',
              icon: Icons.text_fields,
              label: 'Managed Field',
              gridBuilder: (context, placement) => ManagedField(
                placement: placement,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ManagedField extends StatelessWidget {
  final WidgetPlacement placement;
  
  const ManagedField({required this.placement});
  
  @override
  Widget build(BuildContext context) {
    final formState = Provider.of<FormStateModel>(context);
    final value = formState.values[placement.id];
    final error = formState.errors[placement.id];
    
    return TextFormField(
      key: ValueKey(placement.id),
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: placement.properties['label'],
        errorText: error,
      ),
      onChanged: (value) => formState.setValue(placement.id, value),
    );
  }
}
```

### Riverpod Integration

Using Riverpod for more advanced state management:

```dart
// Define providers
final layoutStateProvider = StateNotifierProvider<LayoutNotifier, LayoutState>((ref) {
  return LayoutNotifier();
});

class LayoutNotifier extends StateNotifier<LayoutState> {
  LayoutNotifier() : super(LayoutState.empty());
  
  void updateLayout(LayoutState layout) {
    state = layout;
  }
  
  void addWidget(WidgetPlacement placement) {
    if (state.canAddWidget(placement)) {
      state = state.addWidget(placement);
    }
  }
  
  void removeWidget(String id) {
    state = state.removeWidget(id);
  }
}

// Form values provider
final formValuesProvider = StateNotifierProvider<FormValuesNotifier, Map<String, dynamic>>((ref) {
  return FormValuesNotifier();
});

class FormValuesNotifier extends StateNotifier<Map<String, dynamic>> {
  FormValuesNotifier() : super({});
  
  void setValue(String fieldId, dynamic value) {
    state = {...state, fieldId: value};
  }
  
  dynamic getValue(String fieldId) => state[fieldId];
}

// Validation provider
final formValidationProvider = Provider<Map<String, String?>>((ref) {
  final layout = ref.watch(layoutStateProvider);
  final values = ref.watch(formValuesProvider);
  final errors = <String, String?>{};
  
  for (final widget in layout.widgets) {
    final value = values[widget.id];
    
    if (widget.properties['required'] == true && 
        (value == null || value.toString().isEmpty)) {
      errors[widget.id] = 'Required field';
    }
  }
  
  return errors;
});

// Usage
class RiverpodFormBuilder extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(layoutStateProvider);
    
    return FormLayout(
      toolbox: createRiverpodToolbox(),
      initialLayout: layout,
      onLayoutChanged: (layout) {
        ref.read(layoutStateProvider.notifier).updateLayout(layout);
      },
    );
  }
}

class RiverpodManagedField extends ConsumerWidget {
  final WidgetPlacement placement;
  
  const RiverpodManagedField({required this.placement});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(formValuesProvider)[placement.id];
    final error = ref.watch(formValidationProvider)[placement.id];
    
    return TextFormField(
      key: ValueKey(placement.id),
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: placement.properties['label'],
        errorText: error,
      ),
      onChanged: (value) {
        ref.read(formValuesProvider.notifier).setValue(placement.id, value);
      },
    );
  }
}
```

## Advanced State Patterns

### Computed State

Calculate derived values from form state:

```dart
class ComputedFormState extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  
  void setValue(String fieldId, dynamic value) {
    _values[fieldId] = value;
    notifyListeners();
  }
  
  // Computed properties
  double get total {
    double sum = 0;
    _values.forEach((key, value) {
      if (key.startsWith('amount_') && value is num) {
        sum += value.toDouble();
      }
    });
    return sum;
  }
  
  double get tax {
    final taxRate = _values['tax_rate'] as num? ?? 0.1;
    return total * taxRate.toDouble();
  }
  
  double get grandTotal => total + tax;
}

// Widget that displays computed values
class TotalDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ComputedFormState>(
      builder: (context, state, _) => Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Subtotal: \$${state.total.toStringAsFixed(2)}'),
              Text('Tax: \$${state.tax.toStringAsFixed(2)}'),
              Divider(),
              Text(
                'Total: \$${state.grandTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Dependent Fields

Fields that update based on other fields:

```dart
class DependentFieldsState extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  final Map<String, bool> _visibility = {};
  
  dynamic getValue(String fieldId) => _values[fieldId];
  bool isVisible(String fieldId) => _visibility[fieldId] ?? true;
  
  void setValue(String fieldId, dynamic value) {
    _values[fieldId] = value;
    _updateDependencies(fieldId, value);
    notifyListeners();
  }
  
  void _updateDependencies(String fieldId, dynamic value) {
    // Example: Show additional fields based on selection
    if (fieldId == 'account_type') {
      if (value == 'business') {
        _visibility['company_name'] = true;
        _visibility['tax_id'] = true;
      } else {
        _visibility['company_name'] = false;
        _visibility['tax_id'] = false;
        _values.remove('company_name');
        _values.remove('tax_id');
      }
    }
    
    // Example: Auto-fill related fields
    if (fieldId == 'country' && value == 'US') {
      _values['currency'] = 'USD';
      _values['phone_prefix'] = '+1';
    }
  }
}

class DependentField extends StatelessWidget {
  final WidgetPlacement placement;
  final DependentFieldsState state;
  
  const DependentField({
    required this.placement,
    required this.state,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!state.isVisible(placement.id)) {
      return SizedBox.shrink();
    }
    
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: state.isVisible(placement.id) ? 1.0 : 0.0,
      child: TextFormField(
        key: ValueKey(placement.id),
        initialValue: state.getValue(placement.id)?.toString() ?? '',
        decoration: InputDecoration(
          labelText: placement.properties['label'],
        ),
        onChanged: (value) => state.setValue(placement.id, value),
      ),
    );
  }
}
```

### Form Sections

Organize complex forms into sections:

```dart
class FormSectionState extends ChangeNotifier {
  final Map<String, SectionData> _sections = {};
  String _activeSection = '';
  
  void registerSection(String id, String title, List<String> fieldIds) {
    _sections[id] = SectionData(
      id: id,
      title: title,
      fieldIds: fieldIds,
      isExpanded: true,
    );
    if (_activeSection.isEmpty) {
      _activeSection = id;
    }
    notifyListeners();
  }
  
  void toggleSection(String sectionId) {
    _sections[sectionId]?.isExpanded = !(_sections[sectionId]?.isExpanded ?? false);
    notifyListeners();
  }
  
  void setActiveSection(String sectionId) {
    _activeSection = sectionId;
    notifyListeners();
  }
  
  bool isSectionActive(String sectionId) => _activeSection == sectionId;
  bool isSectionExpanded(String sectionId) => _sections[sectionId]?.isExpanded ?? false;
}

class SectionData {
  final String id;
  final String title;
  final List<String> fieldIds;
  bool isExpanded;
  
  SectionData({
    required this.id,
    required this.title,
    required this.fieldIds,
    this.isExpanded = true,
  });
}
```

## Performance Optimization

### Selective Rebuilds

Optimize widget rebuilds with selective listening:

```dart
class OptimizedField extends StatelessWidget {
  final String fieldId;
  
  const OptimizedField({required this.fieldId});
  
  @override
  Widget build(BuildContext context) {
    // Only rebuild when this specific field changes
    return Selector<FormStateModel, FieldData?>(
      selector: (_, model) => model.getFieldData(fieldId),
      builder: (context, fieldData, _) {
        if (fieldData == null) return SizedBox.shrink();
        
        return TextFormField(
          initialValue: fieldData.value,
          decoration: InputDecoration(
            labelText: fieldData.label,
            errorText: fieldData.error,
          ),
          onChanged: (value) {
            context.read<FormStateModel>().setValue(fieldId, value);
          },
        );
      },
    );
  }
}
```

### Debounced Updates

Prevent excessive state updates:

```dart
class DebouncedFormField extends StatefulWidget {
  final WidgetPlacement placement;
  final ValueChanged<String> onChanged;
  
  const DebouncedFormField({
    required this.placement,
    required this.onChanged,
  });
  
  @override
  _DebouncedFormFieldState createState() => _DebouncedFormFieldState();
}

class _DebouncedFormFieldState extends State<DebouncedFormField> {
  Timer? _debounceTimer;
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.placement.properties['value'],
    );
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
  
  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      widget.onChanged(value);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(widget.placement.id),
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.placement.properties['label'],
      ),
      onChanged: _onChanged,
    );
  }
}
```

## Testing State Management

### Unit Tests

```dart
void main() {
  group('FormStateModel', () {
    late FormStateModel model;
    
    setUp(() {
      model = FormStateModel();
    });
    
    test('setValue updates values map', () {
      model.setValue('field1', 'test value');
      expect(model.values['field1'], equals('test value'));
    });
    
    test('validation sets error for required empty field', () {
      final layout = LayoutState(
        dimensions: GridDimensions(columns: 4, rows: 4),
        widgets: [
          WidgetPlacement(
            id: 'required-field',
            widgetName: 'text_field',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
            properties: {'required': true},
          ),
        ],
      );
      
      model.updateLayout(layout);
      model.setValue('required-field', '');
      
      expect(model.errors['required-field'], isNotNull);
      expect(model.isValid, isFalse);
    });
  });
}
```

### Widget Tests

```dart
testWidgets('ManagedField updates state on change', (tester) async {
  final model = FormStateModel();
  
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider.value(
        value: model,
        child: Scaffold(
          body: ManagedField(
            placement: WidgetPlacement(
              id: 'test-field',
              widgetName: 'text_field',
              column: 0,
              row: 0,
              width: 2,
              height: 1,
              properties: {'label': 'Test Field'},
            ),
          ),
        ),
      ),
    ),
  );
  
  await tester.enterText(find.byType(TextFormField), 'New Value');
  await tester.pump();
  
  expect(model.values['test-field'], equals('New Value'));
});
```

## Best Practices

### 1. Choose the Right Level
- Local state for UI-only concerns
- Lifted state for shared data
- Global state for app-wide data

### 2. Keep State Minimal
```dart
// Good: Only store what changes
class MinimalState {
  final Map<String, dynamic> values = {};
}

// Avoid: Storing derived values
class BloatedState {
  final Map<String, dynamic> values = {};
  final Map<String, bool> isValid = {}; // Can be computed
  final double total = 0; // Can be computed
}
```

### 3. Immutable Updates
```dart
// Good: Create new state
state = {...state, fieldId: newValue};

// Avoid: Mutating existing state
state[fieldId] = newValue; // Don't do this
```

### 4. Separation of Concerns
```dart
// Good: Separate UI and business logic
class FormBusinessLogic {
  Map<String, dynamic> calculateTotals(Map<String, dynamic> values) {
    // Business logic here
  }
}

class FormUIState extends ChangeNotifier {
  final FormBusinessLogic _logic = FormBusinessLogic();
  
  void updateValues(Map<String, dynamic> values) {
    final results = _logic.calculateTotals(values);
    // Update UI state
  }
}
```

## Next Steps

- Learn about [Form Submission](cookbook/09-form-submission.md)
- Explore [Backend Integration](cookbook/07-backend-integration.md)
- Read about [Performance Optimization](advanced/performance.md)