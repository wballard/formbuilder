import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/widgets/form_layout.dart';
import 'package:formbuilder/form_layout/hooks/use_form_state.dart';

final List<Story> themeStories = [
  // Light vs Dark Theme
  Story(
    name: 'Themes/Light vs Dark',
    description: 'Compare light and dark theme appearances',
    builder: (context) => const LightDarkThemeStory(),
  ),
  
  // Custom Color Schemes
  Story(
    name: 'Themes/Color Schemes',
    description: 'Various color scheme options and customizations',
    builder: (context) => const ColorSchemesStory(),
  ),
  
  // Material 3 Design
  Story(
    name: 'Themes/Material 3',
    description: 'Material 3 design system integration',
    builder: (context) => const Material3ThemeStory(),
  ),
  
  // Widget Styling
  Story(
    name: 'Themes/Widget Styling',
    description: 'Custom styling options for form widgets',
    builder: (context) => const WidgetStylingStory(),
  ),
  
  // Grid Appearance
  Story(
    name: 'Themes/Grid Appearance',
    description: 'Grid visualization and styling options',
    builder: (context) => const GridAppearanceStory(),
  ),
  
  // Animation Settings
  Story(
    name: 'Themes/Animations',
    description: 'Animation and transition customizations',
    builder: (context) => const AnimationThemeStory(),
  ),
];

// Base theme story widget for consistent presentation
class ThemeStoryBase extends StatelessWidget {
  final String title;
  final String description;
  final Widget demo;
  final List<String> features;
  final String themeCode;

  const ThemeStoryBase({
    super.key,
    required this.title,
    required this.description,
    required this.demo,
    required this.features,
    required this.themeCode,
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
              Tab(text: 'Code'),
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
                            'Theme Features',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...features.map((feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.palette, 
                                  color: Colors.purple, size: 20),
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
                
                // Code Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Implementation',
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
                                  themeCode,
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

// Light vs Dark Theme Story
class LightDarkThemeStory extends HookWidget {
  const LightDarkThemeStory({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = useState(false);
    final formState = useFormState();
    
    // Pre-populate with sample widgets
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'name_field',
            gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'email_field',
            gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'subscribe_check',
            gridPosition: const GridPosition(x: 0, y: 1, width: 3, height: 1),
            widget: CheckboxListTile(
              title: const Text('Subscribe to newsletter'),
              value: true,
              onChanged: (_) {},
            ),
          ),
          WidgetPlacement(
            id: 'submit_button',
            gridPosition: const GridPosition(x: 3, y: 1, width: 1, height: 1),
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
      return null;
    }, []);
    
    return ThemeStoryBase(
      title: 'Light vs Dark Theme',
      description: 'Compare how the form builder appears in light and dark themes',
      demo: Column(
        children: [
          // Theme Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode.value ? Colors.yellow : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isDarkMode.value ? 'Dark Theme' : 'Light Theme',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                    value: isDarkMode.value,
                    onChanged: (value) {
                      isDarkMode.value = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout with Theme
          Expanded(
            child: Theme(
              data: isDarkMode.value
                  ? ThemeData.dark(useMaterial3: true)
                  : ThemeData.light(useMaterial3: true),
              child: Builder(
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FormLayout(
                    gridDimensions: const GridDimensions(width: 4, height: 4),
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
              ),
            ),
          ),
          
          // Theme Information
          Card(
            color: isDarkMode.value ? Colors.grey[800] : Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDarkMode.value ? Colors.white70 : Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isDarkMode.value
                          ? 'Dark theme reduces eye strain in low-light environments and provides a modern appearance.'
                          : 'Light theme offers high contrast and is suitable for bright environments.',
                      style: TextStyle(
                        color: isDarkMode.value ? Colors.white70 : Colors.black87,
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
        'Automatic color adaptation for light and dark modes',
        'Consistent Material Design theming',
        'Proper contrast ratios for accessibility',
        'Grid lines adapt to theme colors',
        'Widget borders and backgrounds adjust automatically',
        'Icon colors follow theme specifications',
      ],
      themeCode: '''
// Light and Dark theme setup
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system, // Follows system setting
      home: FormBuilderPage(),
    );
  }
}

// Custom theme switching
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  ThemeData get currentTheme => _isDarkMode 
    ? ThemeData.dark(useMaterial3: true)
    : ThemeData.light(useMaterial3: true);
}

// Using the theme in FormLayout
FormLayout(
  // Theme colors are automatically applied
  gridLineColor: Theme.of(context).dividerColor,
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  // ... other properties
)''',
    );
  }
}

// Color Schemes Story
class ColorSchemesStory extends HookWidget {
  const ColorSchemesStory({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedScheme = useState('Blue');
    final formState = useFormState();
    
    final colorSchemes = {
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Purple': Colors.purple,
      'Orange': Colors.orange,
      'Red': Colors.red,
      'Teal': Colors.teal,
    };
    
    // Pre-populate with sample widgets
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'title_card',
            gridPosition: const GridPosition(x: 0, y: 0, width: 4, height: 1),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Color Scheme Demo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'primary_button',
            gridPosition: const GridPosition(x: 0, y: 1, width: 2, height: 1),
            widget: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.star),
              label: const Text('Primary Action'),
            ),
          ),
          WidgetPlacement(
            id: 'secondary_button',
            gridPosition: const GridPosition(x: 2, y: 1, width: 2, height: 1),
            widget: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              label: const Text('Secondary'),
            ),
          ),
          WidgetPlacement(
            id: 'text_field',
            gridPosition: const GridPosition(x: 0, y: 2, width: 4, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Input Field',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'switch_tile',
            gridPosition: const GridPosition(x: 0, y: 3, width: 4, height: 1),
            widget: SwitchListTile(
              title: const Text('Enable notifications'),
              value: true,
              onChanged: (_) {},
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return ThemeStoryBase(
      title: 'Color Schemes',
      description: 'Explore different color schemes and their impact on the form builder',
      demo: Column(
        children: [
          // Color Scheme Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Color Scheme',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: colorSchemes.entries.map((entry) {
                      final isSelected = selectedScheme.value == entry.key;
                      return ChoiceChip(
                        label: Text(entry.key),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            selectedScheme.value = entry.key;
                          }
                        },
                        avatar: CircleAvatar(
                          backgroundColor: entry.value,
                          radius: 8,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout with Selected Color Scheme
          Expanded(
            child: Theme(
              data: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: colorSchemes[selectedScheme.value],
              ),
              child: Builder(
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FormLayout(
                    gridDimensions: const GridDimensions(width: 4, height: 4),
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
              ),
            ),
          ),
          
          // Color Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorSchemes[selectedScheme.value],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Current scheme: ${selectedScheme.value}. '
                      'Notice how all widgets adapt to the new color palette.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      features: [
        'Material 3 color scheme generation from seed colors',
        'Automatic adaptation of all UI elements',
        'Consistent color relationships across components',
        'Accessibility-compliant contrast ratios',
        'Dynamic theming based on brand colors',
        'Grid and selection colors match the scheme',
      ],
      themeCode: '''
// Custom color scheme implementation
class ColorSchemeProvider extends ChangeNotifier {
  Color _seedColor = Colors.blue;
  
  Color get seedColor => _seedColor;
  
  void setSeedColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }
  
  ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seedColor,
  );
}

// Usage in app
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.purple, // Your brand color
  ),
  home: FormBuilderPage(),
)

// Custom color scheme
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.light,
    ),
  ),
)

// Dark theme with custom colors
MaterialApp(
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.dark,
    ),
  ),
)''',
    );
  }
}

// Material 3 Theme Story
class Material3ThemeStory extends HookWidget {
  const Material3ThemeStory({super.key});

  @override
  Widget build(BuildContext context) {
    final useMaterial3 = useState(true);
    final formState = useFormState();
    
    // Pre-populate with Material 3 showcase widgets
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'filled_button',
            gridPosition: const GridPosition(x: 0, y: 0, width: 1, height: 1),
            widget: FilledButton(
              onPressed: () {},
              child: const Text('Filled'),
            ),
          ),
          WidgetPlacement(
            id: 'filled_tonal_button',
            gridPosition: const GridPosition(x: 1, y: 0, width: 1, height: 1),
            widget: FilledButton.tonal(
              onPressed: () {},
              child: const Text('Tonal'),
            ),
          ),
          WidgetPlacement(
            id: 'elevated_button',
            gridPosition: const GridPosition(x: 2, y: 0, width: 1, height: 1),
            widget: ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated'),
            ),
          ),
          WidgetPlacement(
            id: 'outlined_button',
            gridPosition: const GridPosition(x: 3, y: 0, width: 1, height: 1),
            widget: OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined'),
            ),
          ),
          WidgetPlacement(
            id: 'segmented_button',
            gridPosition: const GridPosition(x: 0, y: 1, width: 4, height: 1),
            widget: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'option1', label: Text('Option 1')),
                ButtonSegment(value: 'option2', label: Text('Option 2')),
                ButtonSegment(value: 'option3', label: Text('Option 3')),
              ],
              selected: const {'option1'},
              onSelectionChanged: (_) {},
            ),
          ),
          WidgetPlacement(
            id: 'filled_text_field',
            gridPosition: const GridPosition(x: 0, y: 2, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Filled TextField',
                filled: true,
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'outlined_text_field',
            gridPosition: const GridPosition(x: 2, y: 2, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Outlined TextField',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'cards_demo',
            gridPosition: const GridPosition(x: 0, y: 3, width: 4, height: 2),
            widget: Row(
              children: [
                Expanded(
                  child: Card.filled(
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.favorite, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Filled Card'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card.outlined(
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(height: 8),
                          Text('Outlined Card'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.thumb_up, color: Colors.blue),
                          SizedBox(height: 8),
                          Text('Elevated Card'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return ThemeStoryBase(
      title: 'Material 3 Design',
      description: 'Experience the latest Material 3 design system components and styling',
      demo: Column(
        children: [
          // Material 3 Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.design_services, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    useMaterial3.value ? 'Material 3 (You)' : 'Material 2 (Legacy)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                    value: useMaterial3.value,
                    onChanged: (value) {
                      useMaterial3.value = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout with Material 3
          Expanded(
            child: Theme(
              data: ThemeData(
                useMaterial3: useMaterial3.value,
                colorSchemeSeed: Colors.blue,
              ),
              child: Builder(
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(
                      useMaterial3.value ? 12 : 4,
                    ),
                  ),
                  child: FormLayout(
                    gridDimensions: const GridDimensions(width: 4, height: 5),
                    placements: formState.placements,
                    onPlacementChanged: (placement) {
                      formState.updatePlacement(placement);
                    },
                    onPlacementRemoved: (placement) {
                      formState.removePlacement(placement);
                    },
                    showGrid: false,
                  ),
                ),
              ),
            ),
          ),
          
          // Material Version Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    useMaterial3.value ? 'Material 3 (You)' : 'Material 2 (Legacy)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    useMaterial3.value
                        ? '• Enhanced color system with dynamic theming\n'
                          '• New button variants (Filled, Tonal)\n'
                          '• Improved accessibility and contrast\n'
                          '• Modern card styles and elevation\n'
                          '• Segmented buttons and updated components'
                        : '• Classic Material Design components\n'
                          '• Traditional color schemes\n'
                          '• Standard button styles\n'
                          '• Legacy card and elevation system',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      features: [
        'Dynamic color theming with seed colors',
        'Enhanced button variants (Filled, Tonal, Elevated)',
        'Improved accessibility and contrast ratios',
        'Modern card styles with filled and outlined variants',
        'Segmented buttons for grouped selections',
        'Updated text field styles and animations',
        'Better spacing and typography scales',
      ],
      themeCode: '''
// Material 3 theme setup
MaterialApp(
  theme: ThemeData(
    useMaterial3: true, // Enable Material 3
    colorSchemeSeed: Colors.blue, // Dynamic color generation
  ),
  home: MyFormBuilder(),
)

// Custom Material 3 theme
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    textTheme: Typography.material2021().black,
  ),
)

// Material 3 components in FormBuilder
// Filled buttons
FilledButton(
  onPressed: () {},
  child: Text('Primary Action'),
)

// Tonal buttons
FilledButton.tonal(
  onPressed: () {},
  child: Text('Secondary Action'),
)

// Segmented buttons
SegmentedButton<String>(
  segments: [
    ButtonSegment(value: 'option1', label: Text('Option 1')),
    ButtonSegment(value: 'option2', label: Text('Option 2')),
  ],
  selected: selectedOption,
  onSelectionChanged: (Set<String> newSelection) {
    setState(() {
      selectedOption = newSelection;
    });
  },
)

// Material 3 cards
Card.filled(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Filled Card'),
  ),
)''',
    );
  }
}

// Widget Styling Story
class WidgetStylingStory extends HookWidget {
  const WidgetStylingStory({super.key});

  @override
  Widget build(BuildContext context) {
    final borderRadius = useState(8.0);
    final elevation = useState(2.0);
    final borderWidth = useState(1.0);
    final formState = useFormState();
    
    // Pre-populate with styled widgets
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'styled_text_field',
            gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Styled TextField',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'styled_button',
            gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
            widget: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text('Styled Button'),
            ),
          ),
          WidgetPlacement(
            id: 'styled_card',
            gridPosition: const GridPosition(x: 0, y: 1, width: 4, height: 2),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.palette, size: 48, color: Colors.purple),
                    SizedBox(height: 8),
                    Text(
                      'Customized Card',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('This card demonstrates custom styling options'),
                  ],
                ),
              ),
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return ThemeStoryBase(
      title: 'Widget Styling',
      description: 'Customize the appearance of form widgets with various styling options',
      demo: Column(
        children: [
          // Styling Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Styling Controls',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Border Radius: ${borderRadius.value.toInt()}'),
                            Slider(
                              value: borderRadius.value,
                              min: 0,
                              max: 20,
                              divisions: 20,
                              onChanged: (value) {
                                borderRadius.value = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Elevation: ${elevation.value.toInt()}'),
                            Slider(
                              value: elevation.value,
                              min: 0,
                              max: 10,
                              divisions: 10,
                              onChanged: (value) {
                                elevation.value = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Border Width: ${borderWidth.value.toInt()}'),
                            Slider(
                              value: borderWidth.value,
                              min: 0,
                              max: 5,
                              divisions: 5,
                              onChanged: (value) {
                                borderWidth.value = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout with Custom Styling
          Expanded(
            child: Theme(
              data: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.purple,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius.value),
                    borderSide: BorderSide(width: borderWidth.value),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius.value),
                    borderSide: BorderSide(
                      color: Colors.purple.shade300,
                      width: borderWidth.value,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius.value),
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: borderWidth.value + 1,
                    ),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: elevation.value,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius.value),
                    ),
                  ),
                ),
                cardTheme: CardTheme(
                  elevation: elevation.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius.value),
                    side: BorderSide(
                      color: Colors.purple.shade200,
                      width: borderWidth.value,
                    ),
                  ),
                ),
              ),
              child: Builder(
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(
                      color: Colors.purple.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(borderRadius.value),
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
                ),
              ),
            ),
          ),
        ],
      ),
      features: [
        'Customizable border radius for rounded corners',
        'Adjustable elevation and shadow effects',
        'Variable border width and colors',
        'Consistent styling across all components',
        'Theme-based customization system',
        'Real-time preview of styling changes',
      ],
      themeCode: '''
// Custom widget styling theme
ThemeData(
  useMaterial3: true,
  
  // Text field styling
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.purple.shade300,
        width: 2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.purple,
        width: 3,
      ),
    ),
    filled: true,
    fillColor: Colors.purple.shade50,
  ),
  
  // Button styling
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  
  // Card styling
  cardTheme: CardTheme(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: Colors.purple.shade200,
        width: 1,
      ),
    ),
    margin: EdgeInsets.all(8),
  ),
  
  // Checkbox styling
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  ),
)

// FormLayout with custom styling
FormLayout(
  gridLineColor: Colors.purple.shade200,
  backgroundColor: Colors.purple.shade50,
  selectionColor: Colors.purple.shade300,
  // ... other properties
)''',
    );
  }
}

// Grid Appearance Story
class GridAppearanceStory extends HookWidget {
  const GridAppearanceStory({super.key});

  @override
  Widget build(BuildContext context) {
    final showGrid = useState(true);
    final gridOpacity = useState(0.3);
    final gridLineWidth = useState(1.0);
    final snapToGrid = useState(true);
    final formState = useFormState();
    
    // Pre-populate with widgets to demonstrate grid
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'demo_field_1',
            gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Field 1',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'demo_field_2',
            gridPosition: const GridPosition(x: 2, y: 1, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Field 2',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'demo_button',
            gridPosition: const GridPosition(x: 1, y: 2, width: 2, height: 1),
            widget: ElevatedButton(
              onPressed: () {},
              child: const Text('Demo Button'),
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return ThemeStoryBase(
      title: 'Grid Appearance',
      description: 'Customize the visual appearance and behavior of the grid system',
      demo: Column(
        children: [
          // Grid Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grid Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Show Grid'),
                          value: showGrid.value,
                          onChanged: (value) {
                            showGrid.value = value;
                          },
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Snap to Grid'),
                          value: snapToGrid.value,
                          onChanged: (value) {
                            snapToGrid.value = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Grid Opacity: ${(gridOpacity.value * 100).toInt()}%'),
                            Slider(
                              value: gridOpacity.value,
                              min: 0.1,
                              max: 1.0,
                              divisions: 9,
                              onChanged: showGrid.value
                                  ? (value) {
                                      gridOpacity.value = value;
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Line Width: ${gridLineWidth.value.toInt()}px'),
                            Slider(
                              value: gridLineWidth.value,
                              min: 0.5,
                              max: 3.0,
                              divisions: 5,
                              onChanged: showGrid.value
                                  ? (value) {
                                      gridLineWidth.value = value;
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout with Grid Customization
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FormLayout(
                gridDimensions: const GridDimensions(width: 6, height: 6),
                placements: formState.placements,
                onPlacementChanged: (placement) {
                  formState.updatePlacement(placement);
                },
                onPlacementRemoved: (placement) {
                  formState.removePlacement(placement);
                },
                showGrid: showGrid.value,
                gridLineColor: Colors.blue.withOpacity(gridOpacity.value),
                gridLineWidth: gridLineWidth.value,
                snapToGrid: snapToGrid.value,
              ),
            ),
          ),
          
          // Grid Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    showGrid.value ? Icons.grid_on : Icons.grid_off,
                    color: showGrid.value ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      showGrid.value
                          ? 'Grid is visible. Drag widgets to see how they align to grid cells.'
                          : 'Grid is hidden. Enable it to see precise positioning guides.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      features: [
        'Toggle grid visibility for clean preview mode',
        'Adjustable grid line opacity and width',
        'Snap-to-grid functionality for precise alignment',
        'Custom grid colors to match your design',
        'Grid helps with consistent widget spacing',
        'Visual guides for accurate layout creation',
      ],
      themeCode: '''
// Grid appearance customization
FormLayout(
  gridDimensions: GridDimensions(width: 6, height: 6),
  
  // Grid visibility
  showGrid: true,
  
  // Grid styling
  gridLineColor: Colors.blue.withOpacity(0.3),
  gridLineWidth: 1.0,
  
  // Grid behavior
  snapToGrid: true,
  
  // Grid spacing
  cellPadding: EdgeInsets.all(4),
  
  // Custom grid painter
  gridPainter: CustomGridPainter(
    lineColor: Colors.blue.withOpacity(0.3),
    lineWidth: 1.0,
    dashPattern: [5, 5], // Dashed lines
  ),
  
  // Other properties
  placements: placements,
  onPlacementChanged: updatePlacement,
)

// Custom grid appearance theme
class GridTheme {
  static const light = GridAppearance(
    lineColor: Color(0x33000000), // 20% black
    lineWidth: 1.0,
    backgroundColor: Color(0xFFFAFAFA),
    cellHighlightColor: Color(0x1A2196F3), // 10% blue
  );
  
  static const dark = GridAppearance(
    lineColor: Color(0x33FFFFFF), // 20% white
    lineWidth: 1.0,
    backgroundColor: Color(0xFF121212),
    cellHighlightColor: Color(0x1A64B5F6), // 10% light blue
  );
}

// Usage with theme
FormLayout(
  gridAppearance: Theme.of(context).brightness == Brightness.dark
    ? GridTheme.dark
    : GridTheme.light,
)''',
    );
  }
}

// Animation Theme Story
class AnimationThemeStory extends HookWidget {
  const AnimationThemeStory({super.key});

  @override
  Widget build(BuildContext context) {
    final animationSpeed = useState(300);
    final enableAnimations = useState(true);
    final animationType = useState('Ease');
    final formState = useFormState();
    
    final animationTypes = ['Linear', 'Ease', 'Bounce', 'Elastic'];
    
    // Pre-populate with widgets for animation demo
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'animated_card',
            gridPosition: const GridPosition(x: 1, y: 1, width: 2, height: 2),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.animation, size: 48, color: Colors.orange),
                    SizedBox(height: 8),
                    Text(
                      'Animated Widget',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Drag me around!'),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'button_demo',
            gridPosition: const GridPosition(x: 0, y: 3, width: 4, height: 1),
            widget: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.touch_app),
              label: const Text('Click to see button animations'),
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return ThemeStoryBase(
      title: 'Animation Settings',
      description: 'Configure animation behavior and timing for smooth interactions',
      demo: Column(
        children: [
          // Animation Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Animation Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Enable Animations'),
                    subtitle: const Text('Turn off for performance or accessibility'),
                    value: enableAnimations.value,
                    onChanged: (value) {
                      enableAnimations.value = value;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Speed: ${animationSpeed.value}ms'),
                            Slider(
                              value: animationSpeed.value.toDouble(),
                              min: 100,
                              max: 1000,
                              divisions: 18,
                              onChanged: enableAnimations.value
                                  ? (value) {
                                      animationSpeed.value = value.toInt();
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Animation Type'),
                            DropdownButton<String>(
                              value: animationType.value,
                              isExpanded: true,
                              onChanged: enableAnimations.value
                                  ? (value) {
                                      if (value != null) {
                                        animationType.value = value;
                                      }
                                    }
                                  : null,
                              items: animationTypes
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: () {
                      // Trigger a demo animation by moving the widget
                      final placement = formState.placements.first;
                      final newPosition = GridPosition(
                        x: (placement.gridPosition.x + 1) % 3,
                        y: placement.gridPosition.y,
                        width: placement.gridPosition.width,
                        height: placement.gridPosition.height,
                      );
                      formState.updatePlacement(
                        placement.copyWith(gridPosition: newPosition),
                      );
                    },
                    child: const Text('Test Animation'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form Layout with Animations
          Expanded(
            child: AnimatedTheme(
              duration: Duration(milliseconds: animationSpeed.value),
              data: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.orange,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade300, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FormLayout(
                  gridDimensions: const GridDimensions(width: 4, height: 4),
                  placements: formState.placements,
                  onPlacementChanged: (placement) {
                    formState.updatePlacement(placement);
                  },
                  onPlacementRemoved: (placement) {
                    formState.removePlacement(placement);
                  },
                  showGrid: true,
                  animationDuration: Duration(milliseconds: animationSpeed.value),
                  animationsEnabled: enableAnimations.value,
                ),
              ),
            ),
          ),
          
          // Animation Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    enableAnimations.value ? Icons.animation : Icons.motion_photos_off,
                    color: enableAnimations.value ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      enableAnimations.value
                          ? 'Animations enabled with ${animationSpeed.value}ms ${animationType.value} timing. '
                            'Drag widgets to see smooth transitions.'
                          : 'Animations disabled for reduced motion and better performance.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      features: [
        'Configurable animation duration and timing',
        'Multiple easing curve options',
        'Toggle animations for accessibility compliance',
        'Smooth drag and drop transitions',
        'Animated theme changes',
        'Performance-optimized animation system',
      ],
      themeCode: '''
// Animation configuration
class AnimationConfig {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
}

// FormLayout with animations
FormLayout(
  // Animation settings
  animationDuration: Duration(milliseconds: 300),
  animationCurve: Curves.easeInOut,
  animationsEnabled: true,
  
  // Reduce motion for accessibility
  animationsEnabled: !MediaQuery.of(context).disableAnimations,
  
  // Custom animation controllers
  dragAnimationController: dragController,
  resizeAnimationController: resizeController,
  
  // Other properties
  placements: placements,
  onPlacementChanged: updatePlacement,
)

// Animated theme transitions
AnimatedTheme(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  data: currentTheme,
  child: FormLayout(...),
)

// Custom animation builder
class AnimatedFormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            animation.value * targetPosition.dx,
            animation.value * targetPosition.dy,
          ),
          child: child,
        );
      },
      child: YourFormWidget(),
    );
  }
}

// Accessibility considerations
class ResponsiveAnimations {
  static Duration getDuration(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.disableAnimations) {
      return Duration.zero;
    }
    return Duration(milliseconds: 300);
  }
}''',
    );
  }
}