import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/widgets/form_layout.dart';
import 'package:formbuilder/form_layout/hooks/use_form_state.dart';

final List<Story> documentationStories = [
  // Getting Started Guide
  Story(
    name: 'Documentation/Getting Started',
    description: 'Complete guide to get started with the form builder',
    builder: (context) => const GettingStartedGuide(),
  ),
  
  // API Reference
  Story(
    name: 'Documentation/API Reference',
    description: 'Comprehensive API documentation with examples',
    builder: (context) => const ApiReferenceGuide(),
  ),
  
  // Best Practices
  Story(
    name: 'Documentation/Best Practices',
    description: 'Recommended patterns and best practices',
    builder: (context) => const BestPracticesGuide(),
  ),
  
  // Common Patterns
  Story(
    name: 'Documentation/Common Patterns',
    description: 'Frequently used patterns and solutions',
    builder: (context) => const CommonPatternsGuide(),
  ),
  
  // Troubleshooting
  Story(
    name: 'Documentation/Troubleshooting',
    description: 'Solutions to common issues and problems',
    builder: (context) => const TroubleshootingGuide(),
  ),
  
  // Migration Guide
  Story(
    name: 'Documentation/Migration Guide',
    description: 'Guide for migrating between versions',
    builder: (context) => const MigrationGuide(),
  ),
];

// Base documentation story widget for consistent presentation
class DocumentationStoryBase extends StatelessWidget {
  final String title;
  final String description;
  final List<DocumentationSection> sections;

  const DocumentationStoryBase({
    super.key,
    required this.title,
    required this.description,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Row(
        children: [
          // Table of Contents
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Row(
                    children: [
                      Icon(
                        Icons.list,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Table of Contents',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: sections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 12,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(section.title),
                        subtitle: Text(
                          section.subtitle,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          // Scroll to section
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.book,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                
                // Sections
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return _buildSection(context, section, index + 1);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, DocumentationSection section, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        section.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section content
            Text(
              section.content,
              style: const TextStyle(height: 1.6),
            ),
            
            // Code example
            if (section.codeExample != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Code Example',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: section.codeExample!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code copied to clipboard'),
                              ),
                            );
                          },
                          tooltip: 'Copy code',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      section.codeExample!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Interactive demo
            if (section.demo != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.play_circle, 
                          color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Interactive Demo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    section.demo!,
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DocumentationSection {
  final String title;
  final String subtitle;
  final String content;
  final String? codeExample;
  final Widget? demo;

  const DocumentationSection({
    required this.title,
    required this.subtitle,
    required this.content,
    this.codeExample,
    this.demo,
  });
}

// Getting Started Guide
class GettingStartedGuide extends StatelessWidget {
  const GettingStartedGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentationStoryBase(
      title: 'Getting Started',
      description: 'Learn how to integrate and use the form builder in your Flutter application',
      sections: [
        DocumentationSection(
          title: 'Installation',
          subtitle: 'Add the form builder to your Flutter project',
          content: '''
Add the form builder package to your pubspec.yaml file and run flutter pub get to install it. The package provides a comprehensive drag-and-drop form building solution for Flutter applications.

Make sure your Flutter version is compatible with the package requirements. The form builder requires Flutter 3.0 or higher and Dart SDK 2.17 or higher.
''',
          codeExample: '''
dependencies:
  flutter:
    sdk: flutter
  formbuilder: ^1.0.0
  flutter_hooks: ^0.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter pub get
''',
        ),
        
        DocumentationSection(
          title: 'Basic Setup',
          subtitle: 'Set up the basic form builder in your app',
          content: '''
Import the necessary packages and create a basic form builder widget. The FormLayout widget is the core component that provides the drag-and-drop grid functionality.

Use the useFormState hook to manage the form's state, including widget placements and layout changes. This hook provides a reactive state management solution that integrates well with Flutter's widget system.
''',
          codeExample: '''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/widgets/form_layout.dart';
import 'package:formbuilder/form_layout/hooks/use_form_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

class MyFormBuilder extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    return Scaffold(
      appBar: AppBar(title: Text('Form Builder')),
      body: FormLayout(
        gridDimensions: GridDimensions(width: 6, height: 8),
        placements: formState.placements,
        onPlacementChanged: formState.updatePlacement,
        onPlacementRemoved: formState.removePlacement,
        showGrid: true,
      ),
    );
  }
}
''',
          demo: _buildBasicSetupDemo(),
        ),
        
        DocumentationSection(
          title: 'Adding a Toolbox',
          subtitle: 'Create a toolbox with draggable widgets',
          content: '''
The toolbox provides users with widgets they can drag onto the form. Each ToolboxWidget represents a draggable component that can be placed on the grid.

Organize your toolbox widgets by category (input, selection, display, etc.) to make it easier for users to find the widgets they need. Provide clear labels and icons for each widget type.
''',
          codeExample: '''
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';

Widget _buildToolbox() {
  return Container(
    width: 250,
    child: Column(
      children: [
        Text('Toolbox', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: ListView(
            children: [
              ToolboxWidget(
                icon: Icons.text_fields,
                label: 'Text Field',
                widgetBuilder: () => TextField(
                  decoration: InputDecoration(
                    labelText: 'Text Field',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ToolboxWidget(
                icon: Icons.check_box,
                label: 'Checkbox',
                widgetBuilder: () => CheckboxListTile(
                  title: Text('Checkbox'),
                  value: false,
                  onChanged: (_) {},
                ),
              ),
              // Add more widgets...
            ],
          ),
        ),
      ],
    ),
  );
}
''',
        ),
        
        DocumentationSection(
          title: 'State Management',
          subtitle: 'Handle form state and persistence',
          content: '''
The form builder uses hooks for state management, providing a reactive and efficient way to handle form data. The useFormState hook manages widget placements, while additional hooks handle undo/redo functionality and persistence.

For production applications, you'll want to integrate with your preferred state management solution (Provider, Riverpod, Bloc, etc.) and implement persistence to save and load form configurations.
''',
          codeExample: '''
class FormBuilderPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final undoRedo = useUndoRedo(formState);
    
    // Auto-save effect
    useEffect(() {
      final timer = Timer.periodic(Duration(seconds: 30), (timer) {
        if (formState.isDirty) {
          saveFormState(formState);
        }
      });
      return timer.cancel;
    }, [formState.isDirty]);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Builder'),
        actions: [
          IconButton(
            onPressed: undoRedo.canUndo ? undoRedo.undo : null,
            icon: Icon(Icons.undo),
          ),
          IconButton(
            onPressed: undoRedo.canRedo ? undoRedo.redo : null,
            icon: Icon(Icons.redo),
          ),
        ],
      ),
      body: FormLayout(
        // ... layout configuration
      ),
    );
  }
}
''',
        ),
      ],
    );
  }
  
  static Widget _buildBasicSetupDemo() {
    return SizedBox(
      height: 300,
      child: _BasicSetupDemo(),
    );
  }
}

class _BasicSetupDemo extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    // Add a sample widget on mount
    useEffect(() {
      if (formState.placements.isEmpty) {
        formState.addPlacement(WidgetPlacement(
          id: 'demo_field',
          gridPosition: const GridPosition(x: 1, y: 1, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Demo Field',
              border: OutlineInputBorder(),
            ),
          ),
        ));
      }
      return null;
    }, []);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FormLayout(
        gridDimensions: const GridDimensions(width: 4, height: 3),
        placements: formState.placements,
        onPlacementChanged: (placement) {
          formState.updatePlacement(placement);
        },
        onPlacementRemoved: (placement) {
          formState.removePlacement(placement);
        },
        showGrid: true,
      ),
    );
  }
}

// API Reference Guide
class ApiReferenceGuide extends StatelessWidget {
  const ApiReferenceGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentationStoryBase(
      title: 'API Reference',
      description: 'Comprehensive reference for all form builder APIs and components',
      sections: [
        DocumentationSection(
          title: 'FormLayout Widget',
          subtitle: 'The main form builder widget',
          content: '''
FormLayout is the core widget that provides the drag-and-drop grid functionality. It manages widget placements, handles user interactions, and renders the form grid.

The widget is highly customizable and supports various configuration options for grid appearance, interaction behavior, and performance optimization.
''',
          codeExample: '''
FormLayout({
  Key? key,
  required GridDimensions gridDimensions,
  required List<WidgetPlacement> placements,
  ValueChanged<WidgetPlacement>? onPlacementChanged,
  ValueChanged<WidgetPlacement>? onPlacementRemoved,
  bool showGrid = true,
  Color? gridLineColor,
  double gridLineWidth = 1.0,
  bool previewMode = false,
  Duration animationDuration = const Duration(milliseconds: 300),
  Curve animationCurve = Curves.easeInOut,
  bool snapToGrid = true,
  EdgeInsets cellPadding = const EdgeInsets.all(4),
  String? selectedWidgetId,
  ValueChanged<String?>? onWidgetSelected,
  Map<String, String> validationErrors = const {},
})
''',
        ),
        
        DocumentationSection(
          title: 'WidgetPlacement Model',
          subtitle: 'Defines widget position and properties',
          content: '''
WidgetPlacement represents a widget's position and properties within the form grid. It contains the widget instance, its grid position, and metadata for state management.

This model is immutable and provides methods for creating modified copies, making it suitable for functional state management patterns.
''',
          codeExample: '''
class WidgetPlacement {
  final String id;
  final GridPosition gridPosition;
  final Widget widget;
  final Map<String, dynamic>? metadata;
  
  const WidgetPlacement({
    required this.id,
    required this.gridPosition,
    required this.widget,
    this.metadata,
  });
  
  WidgetPlacement copyWith({
    String? id,
    GridPosition? gridPosition,
    Widget? widget,
    Map<String, dynamic>? metadata,
  }) {
    return WidgetPlacement(
      id: id ?? this.id,
      gridPosition: gridPosition ?? this.gridPosition,
      widget: widget ?? this.widget,
      metadata: metadata ?? this.metadata,
    );
  }
}
''',
        ),
        
        DocumentationSection(
          title: 'useFormState Hook',
          subtitle: 'State management hook for form data',
          content: '''
The useFormState hook provides reactive state management for form builder data. It handles widget placements, tracks changes, and provides methods for updating the form state.

This hook integrates with Flutter's widget lifecycle and provides efficient updates when form data changes.
''',
          codeExample: '''
FormState useFormState() {
  final placements = useState<List<WidgetPlacement>>([]);
  final isDirty = useState(false);
  
  return FormState(
    placements: placements.value,
    isDirty: isDirty.value,
    updatePlacement: (WidgetPlacement placement) {
      placements.value = [
        ...placements.value.where((p) => p.id != placement.id),
        placement,
      ];
      isDirty.value = true;
    },
    removePlacement: (WidgetPlacement placement) {
      placements.value = placements.value
          .where((p) => p.id != placement.id)
          .toList();
      isDirty.value = true;
    },
    addPlacement: (WidgetPlacement placement) {
      placements.value = [...placements.value, placement];
      isDirty.value = true;
    },
    clearAll: () {
      placements.value = [];
      isDirty.value = true;
    },
  );
}
''',
        ),
      ],
    );
  }
}

// Best Practices Guide
class BestPracticesGuide extends StatelessWidget {
  const BestPracticesGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentationStoryBase(
      title: 'Best Practices',
      description: 'Recommended patterns and practices for building great form builders',
      sections: [
        DocumentationSection(
          title: 'Performance Optimization',
          subtitle: 'Keep your form builder fast and responsive',
          content: '''
Performance is crucial for a good user experience. Follow these guidelines to ensure your form builder remains responsive even with complex forms and many widgets.

Monitor performance metrics regularly and optimize based on your specific use cases and target devices.
''',
          codeExample: '''
// Use const constructors where possible
const TextField(
  decoration: InputDecoration(
    labelText: 'Optimized Field',
    border: OutlineInputBorder(),
  ),
);

// Implement efficient widget disposal
@override
void dispose() {
  textController.dispose();
  focusNode.dispose();
  super.dispose();
}

// Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ComplexCustomWidget(),
)
''',
        ),
        
        DocumentationSection(
          title: 'User Experience',
          subtitle: 'Design intuitive and accessible interfaces',
          content: '''
Focus on creating an intuitive user experience that makes form building easy and enjoyable. Provide clear visual feedback, helpful tooltips, and logical widget organization.

Consider accessibility from the beginning and test with screen readers and keyboard navigation.
''',
          codeExample: '''
// Provide clear visual feedback
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: isSelected ? Colors.blue : Colors.transparent,
      width: 2,
    ),
  ),
  child: widget,
)

// Add helpful tooltips
Tooltip(
  message: 'Drag this widget to the form',
  child: ToolboxWidget(...),
)

// Support keyboard navigation
Focus(
  onKeyEvent: (node, event) {
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      deleteSelectedWidget();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  },
  child: FormLayout(...),
)
''',
        ),
      ],
    );
  }
}

// Common Patterns Guide
class CommonPatternsGuide extends StatelessWidget {
  const CommonPatternsGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentationStoryBase(
      title: 'Common Patterns',
      description: 'Frequently used patterns and implementation examples',
      sections: [
        DocumentationSection(
          title: 'Custom Widget Creation',
          subtitle: 'Create reusable custom widgets for your toolbox',
          content: '''
Create custom widgets that integrate seamlessly with the form builder. Ensure your widgets follow Flutter best practices and provide appropriate configuration options.
''',
          codeExample: '''
class CustomRatingWidget extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int>? onRatingChanged;
  
  const CustomRatingWidget({
    Key? key,
    this.initialRating = 0,
    this.onRatingChanged,
  }) : super(key: key);
  
  @override
  State<CustomRatingWidget> createState() => _CustomRatingWidgetState();
}

class _CustomRatingWidgetState extends State<CustomRatingWidget> {
  late int currentRating;
  
  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              currentRating = index + 1;
            });
            widget.onRatingChanged?.call(currentRating);
          },
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}
''',
        ),
      ],
    );
  }
}

// Troubleshooting Guide
class TroubleshootingGuide extends StatelessWidget {
  const TroubleshootingGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentationStoryBase(
      title: 'Troubleshooting',
      description: 'Solutions to common issues and problems',
      sections: [
        DocumentationSection(
          title: 'Common Issues',
          subtitle: 'Solutions to frequently encountered problems',
          content: '''
Here are solutions to the most common issues developers encounter when using the form builder. If you don't find your issue here, check the GitHub issues or create a new one.
''',
          codeExample: '''
// Issue: Widgets not updating after state changes
// Solution: Ensure you're using the hook correctly
final formState = useFormState(); // ✓ Correct
final formState = FormState(); // ✗ Wrong - not reactive

// Issue: Performance issues with large grids
// Solution: Implement viewport culling
FormLayout(
  gridDimensions: GridDimensions(width: 100, height: 100),
  enableViewportCulling: true, // ✓ Enables optimization
  placements: placements,
)

// Issue: Memory leaks
// Solution: Proper disposal of resources
@override
void dispose() {
  controller.dispose();
  focusNode.dispose();
  super.dispose();
}
''',
        ),
      ],
    );
  }
}

// Migration Guide
class MigrationGuide extends StatelessWidget {
  const MigrationGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return DocumentationStoryBase(
      title: 'Migration Guide',
      description: 'Guide for migrating between different versions',
      sections: [
        DocumentationSection(
          title: 'Version 1.0 to 2.0',
          subtitle: 'Breaking changes and migration steps',
          content: '''
Version 2.0 introduces several breaking changes to improve performance and add new features. Follow this guide to migrate your existing code.

Most changes are related to the API surface and can be migrated with find-and-replace operations.
''',
          codeExample: '''
// Old API (v1.0)
FormBuilder(
  widgets: widgets,
  onWidgetAdded: (widget) => {},
  gridWidth: 6,
  gridHeight: 8,
)

// New API (v2.0)
FormLayout(
  placements: placements,
  onPlacementChanged: (placement) => {},
  gridDimensions: GridDimensions(width: 6, height: 8),
)

// Migration steps:
// 1. Replace FormBuilder with FormLayout
// 2. Update widget list to placements
// 3. Replace callback parameters
// 4. Update grid size specification
''',
        ),
      ],
    );
  }
}