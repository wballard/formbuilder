import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/widgets/form_layout.dart';
import 'package:formbuilder/form_layout/hooks/use_form_state.dart';
import 'package:formbuilder/form_layout/hooks/use_undo_redo.dart';

final List<Story> integrationStories = [
  // State Management Integration
  Story(
    name: 'Integration/State Management',
    description: 'Complete state management with Provider and form validation',
    builder: (context) => const StateManagementStory(),
  ),
  
  // Form Validation
  Story(
    name: 'Integration/Form Validation',
    description: 'Comprehensive form validation with real-time feedback',
    builder: (context) => const FormValidationStory(),
  ),
  
  // Data Persistence
  Story(
    name: 'Integration/Data Persistence',
    description: 'Save and load form data with local storage',
    builder: (context) => const DataPersistenceStory(),
  ),
  
  // API Integration
  Story(
    name: 'Integration/API Integration',
    description: 'Submit form data to REST API with error handling',
    builder: (context) => const ApiIntegrationStory(),
  ),
  
  // Custom Widget Integration
  Story(
    name: 'Integration/Custom Widgets',
    description: 'Create and integrate custom form widgets',
    builder: (context) => const CustomWidgetStory(),
  ),
  
  // Complete Application Example
  Story(
    name: 'Integration/Complete App',
    description: 'Full application with all features integrated',
    builder: (context) => const CompleteAppStory(),
  ),
];

// Base integration story widget for consistent presentation
class IntegrationStoryBase extends StatelessWidget {
  final String title;
  final String description;
  final Widget demo;
  final List<String> features;
  final String integrationCode;

  const IntegrationStoryBase({
    super.key,
    required this.title,
    required this.description,
    required this.demo,
    required this.features,
    required this.integrationCode,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Demo'),
              Tab(text: 'Features'),
              Tab(text: 'Implementation'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Demo Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: demo,
                ),
                
                // Features Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Integration Features',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...features.map((feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.integration_instructions, 
                                  color: Colors.teal, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(feature)),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Implementation Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Implementation Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  integrationCode,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                  ),
                                ),
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
    );
  }
}

// State Management Integration Story
class StateManagementStory extends HookWidget {
  const StateManagementStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final undoRedo = useUndoRedo(formState);
    final isLoading = useState(false);
    final lastSaved = useState<DateTime?>(null);
    
    // Auto-save functionality
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (formState.placements.isNotEmpty) {
          // Simulate auto-save
          lastSaved.value = DateTime.now();
        }
      });
      return timer.cancel;
    }, [formState.placements.length]);
    
    // Pre-populate with form
    useEffect(() {
      if (formState.placements.isEmpty) {
        _loadSampleForm(formState);
      }
      return null;
    }, []);
    
    return IntegrationStoryBase(
      title: 'State Management Integration',
      description: 'Comprehensive state management with hooks, persistence, and real-time updates',
      demo: Column(
        children: [
          // State Management Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'State Management',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      // Undo/Redo
                      IconButton(
                        onPressed: undoRedo.canUndo ? undoRedo.undo : null,
                        icon: const Icon(Icons.undo),
                        tooltip: 'Undo',
                      ),
                      IconButton(
                        onPressed: undoRedo.canRedo ? undoRedo.redo : null,
                        icon: const Icon(Icons.redo),
                        tooltip: 'Redo',
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Save/Load
                      ElevatedButton.icon(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                isLoading.value = true;
                                await _saveForm(formState);
                                lastSaved.value = DateTime.now();
                                isLoading.value = false;
                              },
                        icon: isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: const Text('Save'),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      ElevatedButton.icon(
                        onPressed: () => _loadForm(formState),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reload'),
                      ),
                      
                      const Spacer(),
                      
                      // Status
                      if (lastSaved.value != null)
                        Row(
                          children: [
                            const Icon(Icons.check_circle, 
                              color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Saved ${_formatTime(lastSaved.value!)}',
                              style: const TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // State Information
                  Wrap(
                    spacing: 16,
                    children: [
                      _buildStatChip('Widgets', '${formState.placements.length}'),
                      _buildStatChip('History', '${undoRedo.historyLength}'),
                      _buildStatChip('Can Undo', undoRedo.canUndo ? 'Yes' : 'No'),
                      _buildStatChip('Can Redo', undoRedo.canRedo ? 'Yes' : 'No'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout
          Expanded(
            child: Row(
              children: [
                // Form Builder
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Form Builder (State Managed)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: FormLayout(
                            gridDimensions: const GridDimensions(width: 4, height: 6),
                            placements: formState.placements,
                            onPlacementChanged: (placement) {
                              formState.updatePlacement(placement);
                            },
                            onPlacementRemoved: (placement) {
                              formState.removePlacement(placement);
                            },
                            showGrid: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // State Inspector
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'State Inspector',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              ...formState.placements.map((placement) => 
                                Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      placement.id,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    subtitle: Text(
                                      'x:${placement.gridPosition.x}, y:${placement.gridPosition.y}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, size: 16),
                                      onPressed: () {
                                        formState.removePlacement(placement);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              if (formState.placements.isEmpty)
                                const Text(
                                  'No widgets in form',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      features: [
        'React-style hooks for state management',
        'Undo/redo functionality with history tracking',
        'Auto-save with visual feedback',
        'Real-time state inspection and debugging',
        'Optimistic updates for better UX',
        'State persistence across sessions',
        'Change detection and dirty state tracking',
      ],
      integrationCode: '''
// State management with hooks
class FormBuilderPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final undoRedo = useUndoRedo(formState);
    final isLoading = useState(false);
    final lastSaved = useState<DateTime?>(null);
    
    // Auto-save effect
    useEffect(() {
      final timer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (formState.isDirty) {
          saveFormState(formState);
          lastSaved.value = DateTime.now();
        }
      });
      return timer.cancel;
    }, [formState.isDirty]);
    
    // Load initial state
    useEffect(() {
      loadFormState().then((state) {
        formState.loadState(state);
      });
      return null;
    }, []);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Builder'),
        actions: [
          // Undo/Redo buttons
          IconButton(
            onPressed: undoRedo.canUndo ? undoRedo.undo : null,
            icon: Icon(Icons.undo),
          ),
          IconButton(
            onPressed: undoRedo.canRedo ? undoRedo.redo : null,
            icon: Icon(Icons.redo),
          ),
          
          // Save button
          IconButton(
            onPressed: isLoading.value ? null : () async {
              isLoading.value = true;
              await saveFormState(formState);
              isLoading.value = false;
              lastSaved.value = DateTime.now();
            },
            icon: isLoading.value 
              ? CircularProgressIndicator() 
              : Icon(Icons.save),
          ),
        ],
      ),
      body: FormLayout(
        placements: formState.placements,
        onPlacementChanged: formState.updatePlacement,
        onPlacementRemoved: formState.removePlacement,
      ),
    );
  }
}

// Custom form state hook
FormState useFormState() {
  final placements = useState<List<WidgetPlacement>>([]);
  final isDirty = useState(false);
  
  return FormState(
    placements: placements.value,
    isDirty: isDirty.value,
    updatePlacement: (placement) {
      placements.value = [
        ...placements.value.where((p) => p.id != placement.id),
        placement,
      ];
      isDirty.value = true;
    },
    removePlacement: (placement) {
      placements.value = placements.value
          .where((p) => p.id != placement.id)
          .toList();
      isDirty.value = true;
    },
    addPlacement: (placement) {
      placements.value = [...placements.value, placement];
      isDirty.value = true;
    },
    clearAll: () {
      placements.value = [];
      isDirty.value = true;
    },
    loadState: (state) {
      placements.value = state.placements;
      isDirty.value = false;
    },
  );
}

// Undo/Redo hook
UndoRedoState useUndoRedo(FormState formState) {
  final history = useState<List<List<WidgetPlacement>>>([]);
  final currentIndex = useState(-1);
  
  // Save state to history when changes occur
  useEffect(() {
    final newHistory = [...history.value];
    
    // Remove any future history if we're not at the end
    if (currentIndex.value < newHistory.length - 1) {
      newHistory.removeRange(currentIndex.value + 1, newHistory.length);
    }
    
    // Add current state
    newHistory.add([...formState.placements]);
    
    // Limit history size
    if (newHistory.length > 50) {
      newHistory.removeAt(0);
    } else {
      currentIndex.value++;
    }
    
    history.value = newHistory;
    return null;
  }, [formState.placements.length]);
  
  return UndoRedoState(
    canUndo: currentIndex.value > 0,
    canRedo: currentIndex.value < history.value.length - 1,
    historyLength: history.value.length,
    undo: () {
      if (currentIndex.value > 0) {
        currentIndex.value--;
        formState.loadState(FormStateSnapshot(
          placements: history.value[currentIndex.value],
        ));
      }
    },
    redo: () {
      if (currentIndex.value < history.value.length - 1) {
        currentIndex.value++;
        formState.loadState(FormStateSnapshot(
          placements: history.value[currentIndex.value],
        ));
      }
    },
  );
}''',
    );
  }
  
  Widget _buildStatChip(String label, String value) {
    return Chip(
      label: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
  
  void _loadSampleForm(dynamic formState) {
    final placements = [
      WidgetPlacement(
        id: 'name_field',
        gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      WidgetPlacement(
        id: 'email_field',
        gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      WidgetPlacement(
        id: 'submit_button',
        gridPosition: const GridPosition(x: 0, y: 1, width: 1, height: 1),
        widget: ElevatedButton(
          onPressed: () {},
          child: const Text('Submit'),
        ),
      ),
    ];
    
    for (final placement in placements) {
      formState.addPlacement(placement);
    }
  }
  
  Future<void> _saveForm(dynamic formState) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
  }
  
  void _loadForm(dynamic formState) {
    formState.clearAll();
    _loadSampleForm(formState);
  }
}

// Form Validation Story
class FormValidationStory extends HookWidget {
  const FormValidationStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final validationErrors = useState<Map<String, String>>({});
    final isValidating = useState(false);
    
    // Pre-populate with validation form
    useEffect(() {
      if (formState.placements.isEmpty) {
        _loadValidationForm(formState);
      }
      return null;
    }, []);
    
    return IntegrationStoryBase(
      title: 'Form Validation Integration',
      description: 'Real-time form validation with error handling and user feedback',
      demo: Column(
        children: [
          // Validation Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Form Validation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isValidating.value
                            ? null
                            : () async {
                                isValidating.value = true;
                                await _validateForm(formKey, validationErrors);
                                isValidating.value = false;
                              },
                        icon: isValidating.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle),
                        label: const Text('Validate Form'),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      ElevatedButton.icon(
                        onPressed: () {
                          validationErrors.value = {};
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Errors'),
                      ),
                      
                      const Spacer(),
                      
                      // Validation Status
                      Row(
                        children: [
                          Icon(
                            validationErrors.value.isEmpty 
                                ? Icons.check_circle 
                                : Icons.error,
                            color: validationErrors.value.isEmpty 
                                ? Colors.green 
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            validationErrors.value.isEmpty
                                ? 'Form is valid'
                                : '${validationErrors.value.length} errors',
                            style: TextStyle(
                              color: validationErrors.value.isEmpty 
                                  ? Colors.green 
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Error List
                  if (validationErrors.value.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Validation Errors:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...validationErrors.value.entries.map((entry) =>
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, 
                                    color: Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Text('${entry.key}: ${entry.value}'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form with Validation
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Form with Validation',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: FormLayout(
                        gridDimensions: const GridDimensions(width: 4, height: 6),
                        placements: formState.placements,
                        onPlacementChanged: (placement) {
                          formState.updatePlacement(placement);
                          // Clear validation error for this field
                          if (validationErrors.value.containsKey(placement.id)) {
                            final newErrors = {...validationErrors.value};
                            newErrors.remove(placement.id);
                            validationErrors.value = newErrors;
                          }
                        },
                        onPlacementRemoved: (placement) {
                          formState.removePlacement(placement);
                        },
                        showGrid: true,
                        // Highlight fields with errors
                        validationErrors: validationErrors.value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      features: [
        'Real-time validation with visual feedback',
        'Custom validation rules per field type',
        'Error highlighting and messaging',
        'Form-wide validation state management',
        'Async validation support for API calls',
        'Field-level and form-level validation',
        'Accessibility-compliant error handling',
      ],
      integrationCode: '''
// Form validation integration
class ValidatedFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final validationErrors = useState<Map<String, String>>({});
    final validators = useMemoized(() => _createValidators());
    
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Validation controls
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _validateForm(
                  formKey, 
                  formState, 
                  validators, 
                  validationErrors,
                ),
                child: Text('Validate'),
              ),
            ],
          ),
          
          // Form layout with validation
          Expanded(
            child: FormLayout(
              placements: formState.placements,
              validationErrors: validationErrors.value,
              onPlacementChanged: (placement) {
                formState.updatePlacement(placement);
                _clearFieldError(placement.id, validationErrors);
              },
              validators: validators,
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, FormFieldValidator> _createValidators() {
    return {
      'email': (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        return null;
      },
      'name': (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        }
        if (value.length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
      'phone': (value) {
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^\+?[\d\s\-\(\)]+\$').hasMatch(value)) {
            return 'Enter a valid phone number';
          }
        }
        return null;
      },
    };
  }
  
  Future<void> _validateForm(
    GlobalKey<FormState> formKey,
    FormState formState,
    Map<String, FormFieldValidator> validators,
    ValueNotifier<Map<String, String>> validationErrors,
  ) async {
    final errors = <String, String>{};
    
    // Form-level validation
    if (!formKey.currentState!.validate()) {
      // Extract errors from form fields
      // This would be implemented based on your form structure
    }
    
    // Custom validation
    for (final placement in formState.placements) {
      final validator = validators[placement.id];
      if (validator != null) {
        final value = _getFieldValue(placement);
        final error = validator(value);
        if (error != null) {
          errors[placement.id] = error;
        }
      }
    }
    
    // Async validation (e.g., check if email exists)
    if (!errors.containsKey('email')) {
      final emailExists = await _checkEmailExists(
        _getFieldValue(formState.placements
            .firstWhere((p) => p.id == 'email')),
      );
      if (emailExists) {
        errors['email'] = 'Email address is already taken';
      }
    }
    
    validationErrors.value = errors;
  }
  
  void _clearFieldError(
    String fieldId, 
    ValueNotifier<Map<String, String>> validationErrors,
  ) {
    if (validationErrors.value.containsKey(fieldId)) {
      final newErrors = {...validationErrors.value};
      newErrors.remove(fieldId);
      validationErrors.value = newErrors;
    }
  }
  
  String? _getFieldValue(WidgetPlacement placement) {
    // Extract value from widget based on type
    final widget = placement.widget;
    if (widget is TextField) {
      return widget.controller?.text ?? '';
    }
    // Handle other widget types...
    return null;
  }
  
  Future<bool> _checkEmailExists(String? email) async {
    if (email == null || email.isEmpty) return false;
    
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 500));
    
    // Mock response
    return email == 'taken@example.com';
  }
}

// Enhanced FormLayout with validation support
class ValidatedFormLayout extends FormLayout {
  final Map<String, String> validationErrors;
  final Map<String, FormFieldValidator> validators;
  
  const ValidatedFormLayout({
    super.key,
    required super.gridDimensions,
    required super.placements,
    super.onPlacementChanged,
    super.onPlacementRemoved,
    this.validationErrors = const {},
    this.validators = const {},
    super.showGrid,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base form layout
        super.build(context),
        
        // Error overlays
        ...validationErrors.entries.map((entry) {
          final placement = placements
              .firstWhere((p) => p.id == entry.key);
          
          return Positioned(
            left: placement.gridPosition.x * cellWidth,
            top: placement.gridPosition.y * cellHeight,
            width: placement.gridPosition.width * cellWidth,
            height: placement.gridPosition.height * cellHeight,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}''',
    );
  }
  
  void _loadValidationForm(dynamic formState) {
    final placements = [
      WidgetPlacement(
        id: 'name',
        gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Full Name *',
            border: OutlineInputBorder(),
            helperText: 'Required field',
          ),
        ),
      ),
      WidgetPlacement(
        id: 'email',
        gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Email Address *',
            border: OutlineInputBorder(),
            helperText: 'Must be valid email',
          ),
        ),
      ),
      WidgetPlacement(
        id: 'phone',
        gridPosition: const GridPosition(x: 0, y: 1, width: 2, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            helperText: 'Optional',
          ),
        ),
      ),
      WidgetPlacement(
        id: 'age',
        gridPosition: const GridPosition(x: 2, y: 1, width: 2, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Age',
            border: OutlineInputBorder(),
            helperText: 'Must be 18 or older',
          ),
        ),
      ),
      WidgetPlacement(
        id: 'terms',
        gridPosition: const GridPosition(x: 0, y: 2, width: 4, height: 1),
        widget: CheckboxListTile(
          title: const Text('I agree to the terms and conditions *'),
          value: false,
          onChanged: (_) {},
        ),
      ),
      WidgetPlacement(
        id: 'submit',
        gridPosition: const GridPosition(x: 3, y: 3, width: 1, height: 1),
        widget: ElevatedButton(
          onPressed: () {},
          child: const Text('Submit'),
        ),
      ),
    ];
    
    for (final placement in placements) {
      formState.addPlacement(placement);
    }
  }
  
  Future<void> _validateForm(
    GlobalKey<FormState> formKey, 
    ValueNotifier<Map<String, String>> validationErrors,
  ) async {
    final errors = <String, String>{};
    
    // Simulate validation logic
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Mock validation errors
    errors['name'] = 'Name must be at least 2 characters';
    errors['email'] = 'Email format is invalid';
    errors['age'] = 'Must be 18 or older';
    
    validationErrors.value = errors;
  }
}

// Data Persistence Story
class DataPersistenceStory extends HookWidget {
  const DataPersistenceStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final savedForms = useState<List<String>>([]);
    final currentFormName = useState<String?>(null);
    final isLoading = useState(false);
    
    // Load saved forms list on mount
    useEffect(() {
      _loadSavedFormsList(savedForms);
      return null;
    }, []);
    
    return IntegrationStoryBase(
      title: 'Data Persistence Integration',
      description: 'Save and load form layouts with local storage and cloud sync',
      demo: Column(
        children: [
          // Persistence Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Persistence',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      // Save current form
                      ElevatedButton.icon(
                        onPressed: isLoading.value
                            ? null
                            : () => _saveCurrentForm(
                                formState, 
                                currentFormName, 
                                savedForms, 
                                isLoading,
                              ),
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Save Form'),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Create new form
                      ElevatedButton.icon(
                        onPressed: () => _createNewForm(formState, currentFormName),
                        icon: const Icon(Icons.add),
                        label: const Text('New Form'),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Current form name
                      if (currentFormName.value != null)
                        Chip(
                          label: Text('Current: ${currentFormName.value}'),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () {
                            currentFormName.value = null;
                          },
                        ),
                      
                      const Spacer(),
                      
                      // Loading indicator
                      if (isLoading.value)
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Syncing...'),
                          ],
                        ),
                    ],
                  ),
                  
                  // Saved forms list
                  if (savedForms.value.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Saved Forms:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: savedForms.value.map((formName) =>
                        ActionChip(
                          label: Text(formName),
                          onPressed: () => _loadForm(
                            formName, 
                            formState, 
                            currentFormName, 
                            isLoading,
                          ),
                          deleteIcon: const Icon(Icons.delete, size: 18),
                          onDeleted: () => _deleteForm(
                            formName, 
                            savedForms, 
                            currentFormName,
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout
          Expanded(
            child: Row(
              children: [
                // Form Builder
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text(
                                'Form Builder',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (currentFormName.value != null)
                                Text(
                                  'Editing: ${currentFormName.value}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: FormLayout(
                            gridDimensions: const GridDimensions(width: 4, height: 6),
                            placements: formState.placements,
                            onPlacementChanged: (placement) {
                              formState.updatePlacement(placement);
                            },
                            onPlacementRemoved: (placement) {
                              formState.removePlacement(placement);
                            },
                            showGrid: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Storage Info
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Storage Info',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildStorageItem(
                            'Local Storage', 
                            '${savedForms.value.length} forms',
                            Icons.storage,
                            Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          _buildStorageItem(
                            'Cloud Sync', 
                            'Enabled',
                            Icons.cloud,
                            Colors.green,
                          ),
                          const SizedBox(height: 8),
                          _buildStorageItem(
                            'Auto Save', 
                            'Every 30s',
                            Icons.save,
                            Colors.orange,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          const Text(
                            'Recent Activity:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          
                          ...['Form saved locally', 'Synced to cloud', 'Auto-save triggered']
                              .map((activity) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.history, size: 12),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        activity,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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
      features: [
        'Local storage for offline form access',
        'Cloud synchronization across devices',
        'Auto-save functionality with configurable intervals',
        'Form versioning and backup system',
        'Import/export capabilities with multiple formats',
        'Conflict resolution for concurrent edits',
        'Storage quota management and cleanup',
      ],
      integrationCode: '''
// Data persistence integration
class PersistentFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final persistence = useFormPersistence();
    final autoSave = useAutoSave(formState, persistence);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Persistent Form Builder'),
        actions: [
          // Save dropdown
          PopupMenuButton<String>(
            icon: Icon(Icons.save),
            onSelected: (action) async {
              switch (action) {
                case 'save':
                  await persistence.saveForm(formState);
                  break;
                case 'saveAs':
                  await persistence.saveFormAs(formState);
                  break;
                case 'export':
                  await persistence.exportForm(formState);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'save', child: Text('Save')),
              PopupMenuItem(value: 'saveAs', child: Text('Save As...')),
              PopupMenuItem(value: 'export', child: Text('Export')),
            ],
          ),
        ],
      ),
      body: FormLayout(
        placements: formState.placements,
        onPlacementChanged: formState.updatePlacement,
        onPlacementRemoved: formState.removePlacement,
      ),
    );
  }
}

// Form persistence hook
FormPersistence useFormPersistence() {
  final localStorage = useMemoized(() => LocalStorage());
  final cloudStorage = useMemoized(() => CloudStorage());
  
  return FormPersistence(
    saveForm: (formState, {String? name}) async {
      final formData = formState.toJson();
      
      // Save locally first
      await localStorage.saveForm(name ?? 'current', formData);
      
      // Then sync to cloud
      try {
        await cloudStorage.saveForm(name ?? 'current', formData);
      } catch (e) {
        // Handle offline or sync errors
        print('Cloud sync failed: \$e');
      }
    },
    
    loadForm: (String name) async {
      try {
        // Try cloud first for latest version
        return await cloudStorage.loadForm(name);
      } catch (e) {
        // Fallback to local storage
        return await localStorage.loadForm(name);
      }
    },
    
    listForms: () async {
      final localForms = await localStorage.listForms();
      try {
        final cloudForms = await cloudStorage.listForms();
        return _mergeForms(localForms, cloudForms);
      } catch (e) {
        return localForms;
      }
    },
    
    deleteForm: (String name) async {
      await localStorage.deleteForm(name);
      try {
        await cloudStorage.deleteForm(name);
      } catch (e) {
        // Mark for deletion when online
        await localStorage.markForDeletion(name);
      }
    },
    
    exportForm: (FormState formState, {String format = 'json'}) async {
      final data = formState.toJson();
      switch (format) {
        case 'json':
          return await _exportAsJson(data);
        case 'yaml':
          return await _exportAsYaml(data);
        case 'xml':
          return await _exportAsXml(data);
        default:
          throw UnsupportedError('Format \$format not supported');
      }
    },
  );
}

// Auto-save hook
void useAutoSave(
  FormState formState, 
  FormPersistence persistence,
  {Duration interval = const Duration(seconds: 30)}
) {
  final lastSaved = useRef<String?>(null);
  
  useEffect(() {
    final timer = Timer.periodic(interval, (timer) async {
      final currentData = formState.toJson();
      if (lastSaved.value != currentData) {
        await persistence.saveForm(formState, name: 'autosave');
        lastSaved.value = currentData;
      }
    });
    
    return timer.cancel;
  }, [formState.placements, interval]);
}

// Local storage implementation
class LocalStorage {
  static const String _prefix = 'formbuilder_';
  
  Future<void> saveForm(String name, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('\$_prefix\$name', data);
    await _updateFormsList(name);
  }
  
  Future<String?> loadForm(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('\$_prefix\$name');
  }
  
  Future<List<String>> listForms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('\${_prefix}forms') ?? [];
  }
  
  Future<void> deleteForm(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('\$_prefix\$name');
    await _removeFromFormsList(name);
  }
  
  Future<void> _updateFormsList(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final forms = prefs.getStringList('\${_prefix}forms') ?? [];
    if (!forms.contains(name)) {
      forms.add(name);
      await prefs.setStringList('\${_prefix}forms', forms);
    }
  }
}

// Cloud storage implementation
class CloudStorage {
  Future<void> saveForm(String name, String data) async {
    final response = await http.post(
      Uri.parse('https://api.example.com/forms/\$name'),
      headers: {'Content-Type': 'application/json'},
      body: data,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to save form: \${response.statusCode}');
    }
  }
  
  Future<String> loadForm(String name) async {
    final response = await http.get(
      Uri.parse('https://api.example.com/forms/\$name'),
    );
    
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load form: \${response.statusCode}');
    }
  }
  
  Future<List<String>> listForms() async {
    final response = await http.get(
      Uri.parse('https://api.example.com/forms'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return List<String>.from(data['forms'] ?? []);
    } else {
      throw Exception('Failed to list forms: \${response.statusCode}');
    }
  }
}''',
    );
  }
  
  Widget _buildStorageItem(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _loadSavedFormsList(ValueNotifier<List<String>> savedForms) {
    // Simulate loading saved forms
    savedForms.value = ['Contact Form', 'Survey Form', 'Registration Form'];
  }
  
  Future<void> _saveCurrentForm(
    dynamic formState,
    ValueNotifier<String?> currentFormName,
    ValueNotifier<List<String>> savedForms,
    ValueNotifier<bool> isLoading,
  ) async {
    isLoading.value = true;
    
    // Simulate save operation
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final name = currentFormName.value ?? 'Unnamed Form ${DateTime.now().millisecondsSinceEpoch}';
    
    if (!savedForms.value.contains(name)) {
      savedForms.value = [...savedForms.value, name];
    }
    currentFormName.value = name;
    
    isLoading.value = false;
  }
  
  void _createNewForm(
    dynamic formState,
    ValueNotifier<String?> currentFormName,
  ) {
    formState.clearAll();
    currentFormName.value = null;
  }
  
  Future<void> _loadForm(
    String formName,
    dynamic formState,
    ValueNotifier<String?> currentFormName,
    ValueNotifier<bool> isLoading,
  ) async {
    isLoading.value = true;
    
    // Simulate load operation
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Load sample form data
    formState.clearAll();
    _loadSampleFormForPersistence(formState);
    currentFormName.value = formName;
    
    isLoading.value = false;
  }
  
  void _deleteForm(
    String formName,
    ValueNotifier<List<String>> savedForms,
    ValueNotifier<String?> currentFormName,
  ) {
    savedForms.value = savedForms.value.where((name) => name != formName).toList();
    if (currentFormName.value == formName) {
      currentFormName.value = null;
    }
  }
  
  void _loadSampleFormForPersistence(dynamic formState) {
    final placements = [
      WidgetPlacement(
        id: 'loaded_field',
        gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Loaded Field',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      WidgetPlacement(
        id: 'loaded_button',
        gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
        widget: ElevatedButton(
          onPressed: () {},
          child: const Text('Loaded Button'),
        ),
      ),
    ];
    
    for (final placement in placements) {
      formState.addPlacement(placement);
    }
  }
}

// API Integration Story (simplified for space)
class ApiIntegrationStory extends HookWidget {
  const ApiIntegrationStory({super.key});

  @override
  Widget build(BuildContext context) {
    return IntegrationStoryBase(
      title: 'API Integration',
      description: 'Submit form data to REST API with error handling',
      demo: const Center(
        child: Text('API Integration Demo - Submit forms to backend services'),
      ),
      features: [
        'RESTful API integration with HTTP client',
        'Form data serialization and validation',
        'Error handling and retry mechanisms',
        'Loading states and user feedback',
        'Authentication and authorization support',
        'File upload capabilities',
        'Response handling and success notifications',
      ],
      integrationCode: '''
// API integration example
class ApiFormSubmission extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final isSubmitting = useState(false);
    final apiClient = useMemoized(() => ApiClient());
    
    return FormLayout(
      placements: formState.placements,
      onSubmit: () async {
        isSubmitting.value = true;
        try {
          await apiClient.submitForm(formState.toApiPayload());
          _showSuccessMessage(context);
        } catch (e) {
          _showErrorMessage(context, e.toString());
        } finally {
          isSubmitting.value = false;
        }
      },
    );
  }
}''',
    );
  }
}

// Custom Widget Integration Story (simplified for space)
class CustomWidgetStory extends HookWidget {
  const CustomWidgetStory({super.key});

  @override
  Widget build(BuildContext context) {
    return IntegrationStoryBase(
      title: 'Custom Widget Integration',
      description: 'Create and integrate custom form widgets',
      demo: const Center(
        child: Text('Custom Widget Demo - Extend with your own components'),
      ),
      features: [
        'Custom widget creation framework',
        'Widget registration and discovery',
        'Toolbox integration for custom widgets',
        'Property panels and configuration',
        'Custom validation rules',
        'Event handling and data binding',
        'Reusable component library system',
      ],
      integrationCode: '''
// Custom widget integration
class CustomWidgetRegistry {
  static void registerWidget(String type, WidgetBuilder builder) {
    _registry[type] = builder;
  }
  
  static Widget buildWidget(String type, Map<String, dynamic> config) {
    final builder = _registry[type];
    return builder?.call(config) ?? Container();
  }
}

// Register custom widgets
CustomWidgetRegistry.registerWidget('date_range_picker', (config) {
  return CustomDateRangePicker(
    startDate: config['startDate'],
    endDate: config['endDate'],
    onChanged: config['onChanged'],
  );
});''',
    );
  }
}

// Complete Application Example Story (simplified for space)
class CompleteAppStory extends HookWidget {
  const CompleteAppStory({super.key});

  @override
  Widget build(BuildContext context) {
    return IntegrationStoryBase(
      title: 'Complete Application',
      description: 'Full application with all features integrated',
      demo: const Center(
        child: Text('Complete App Demo - Production-ready form builder'),
      ),
      features: [
        'Full-featured form builder application',
        'User authentication and authorization',
        'Multi-tenant support with workspace isolation',
        'Real-time collaboration features',
        'Advanced theme customization',
        'Plugin system for extensibility',
        'Enterprise-grade security and compliance',
      ],
      integrationCode: '''
// Complete application structure
class FormBuilderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FormProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.currentTheme,
            home: AuthGuard(
              child: FormBuilderHomePage(),
            ),
          );
        },
      ),
    );
  }
}''',
    );
  }
}