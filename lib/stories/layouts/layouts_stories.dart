import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/widgets/form_layout.dart';
import 'package:formbuilder/form_layout/hooks/use_form_state.dart';

final List<Story> layoutStories = [
  // Contact Form Layout
  Story(
    name: 'Layouts/Contact Form',
    description: 'Standard contact form with name, email, subject, and message',
    builder: (context) => const ContactFormLayoutStory(),
  ),
  
  // Survey Form Layout
  Story(
    name: 'Layouts/Survey Form',
    description: 'Multi-question survey with various input types',
    builder: (context) => const SurveyFormLayoutStory(),
  ),
  
  // Registration Form Layout
  Story(
    name: 'Layouts/Registration Form',
    description: 'User registration with personal details and preferences',
    builder: (context) => const RegistrationFormLayoutStory(),
  ),
  
  // Multi-Column Layout
  Story(
    name: 'Layouts/Multi Column',
    description: 'Complex form with multiple columns and sections',
    builder: (context) => const MultiColumnLayoutStory(),
  ),
  
  // Responsive Grid Layout
  Story(
    name: 'Layouts/Responsive Grid',
    description: 'Adaptive layout that works on different screen sizes',
    builder: (context) => const ResponsiveGridLayoutStory(),
  ),
  
  // Dashboard Layout
  Story(
    name: 'Layouts/Dashboard',
    description: 'Dashboard-style layout with cards and metrics',
    builder: (context) => const DashboardLayoutStory(),
  ),
];

// Base layout story widget for consistent presentation
class LayoutStoryBase extends StatelessWidget {
  final String title;
  final String description;
  final Widget layout;
  final List<String> features;
  final String useCase;
  final String layoutCode;

  const LayoutStoryBase({
    super.key,
    required this.title,
    required this.description,
    required this.layout,
    required this.features,
    required this.useCase,
    required this.layoutCode,
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
              Tab(text: 'Layout'),
              Tab(text: 'Features'),
              Tab(text: 'Code'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Layout Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: layout,
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
                            'Use Case',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(useCase),
                          const SizedBox(height: 24),
                          Text(
                            'Key Features',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...features.map((feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, 
                                  color: Colors.green, size: 20),
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
                            'Layout Implementation',
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
                                  layoutCode,
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

// Contact Form Layout Story
class ContactFormLayoutStory extends HookWidget {
  const ContactFormLayoutStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    // Pre-populate contact form layout
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'first_name',
            gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'last_name',
            gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'email',
            gridPosition: const GridPosition(x: 0, y: 1, width: 4, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'phone',
            gridPosition: const GridPosition(x: 0, y: 2, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'company',
            gridPosition: const GridPosition(x: 2, y: 2, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'subject',
            gridPosition: const GridPosition(x: 0, y: 3, width: 4, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'message',
            gridPosition: const GridPosition(x: 0, y: 4, width: 4, height: 3),
            widget: const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.message),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'newsletter',
            gridPosition: const GridPosition(x: 0, y: 7, width: 3, height: 1),
            widget: CheckboxListTile(
              title: const Text('Subscribe to newsletter'),
              value: false,
              onChanged: (_) {},
            ),
          ),
          WidgetPlacement(
            id: 'submit',
            gridPosition: const GridPosition(x: 3, y: 7, width: 1, height: 1),
            widget: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return LayoutStoryBase(
      title: 'Contact Form Layout',
      description: 'A professional contact form with all essential fields',
      layout: Container(
        height: 600,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FormLayout(
          gridDimensions: const GridDimensions(width: 4, height: 8),
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
      features: [
        'Two-column name fields for balanced layout',
        'Full-width email field with icon for prominence',
        'Side-by-side phone and company fields',
        'Large message area spanning multiple rows',
        'Newsletter subscription checkbox',
        'Action button positioned for natural flow',
      ],
      useCase: 'Perfect for business websites, support pages, or any scenario where you need to collect comprehensive contact information from users.',
      layoutCode: '''
// Contact form layout setup
final contactFormPlacements = [
  WidgetPlacement(
    id: 'first_name',
    gridPosition: GridPosition(x: 0, y: 0, width: 2, height: 1),
    widget: TextField(
      decoration: InputDecoration(
        labelText: 'First Name',
        border: OutlineInputBorder(),
      ),
    ),
  ),
  WidgetPlacement(
    id: 'last_name',
    gridPosition: GridPosition(x: 2, y: 0, width: 2, height: 1),
    widget: TextField(
      decoration: InputDecoration(
        labelText: 'Last Name',
        border: OutlineInputBorder(),
      ),
    ),
  ),
  WidgetPlacement(
    id: 'email',
    gridPosition: GridPosition(x: 0, y: 1, width: 4, height: 1),
    widget: TextField(
      decoration: InputDecoration(
        labelText: 'Email Address',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
    ),
  ),
  // Message field spans multiple rows
  WidgetPlacement(
    id: 'message',
    gridPosition: GridPosition(x: 0, y: 4, width: 4, height: 3),
    widget: TextField(
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Message',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    ),
  ),
];

FormLayout(
  gridDimensions: GridDimensions(width: 4, height: 8),
  placements: contactFormPlacements,
)''',
    );
  }
}

// Survey Form Layout Story
class SurveyFormLayoutStory extends HookWidget {
  const SurveyFormLayoutStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    // Pre-populate survey form layout
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'title',
            gridPosition: const GridPosition(x: 0, y: 0, width: 6, height: 1),
            widget: const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Customer Satisfaction Survey',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'rating',
            gridPosition: const GridPosition(x: 0, y: 1, width: 3, height: 2),
            widget: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Satisfaction',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) => 
                        const Icon(Icons.star_border, color: Colors.amber)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'recommend',
            gridPosition: const GridPosition(x: 3, y: 1, width: 3, height: 2),
            widget: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Would you recommend us?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Radio(value: true, groupValue: null, onChanged: (_) {}),
                        const Text('Yes'),
                        const SizedBox(width: 16),
                        Radio(value: false, groupValue: null, onChanged: (_) {}),
                        const Text('No'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'categories',
            gridPosition: const GridPosition(x: 0, y: 3, width: 6, height: 2),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Which aspects impressed you most? (Select all)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_box_outline_blank),
                            SizedBox(width: 4),
                            Text('Quality'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_box_outline_blank),
                            SizedBox(width: 4),
                            Text('Service'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_box_outline_blank),
                            SizedBox(width: 4),
                            Text('Value'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_box_outline_blank),
                            SizedBox(width: 4),
                            Text('Speed'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'improvements',
            gridPosition: const GridPosition(x: 0, y: 5, width: 6, height: 3),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggestions for improvement',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tell us how we can improve...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'contact_info',
            gridPosition: const GridPosition(x: 0, y: 8, width: 4, height: 1),
            widget: CheckboxListTile(
              title: const Text('I would like to be contacted about my feedback'),
              value: false,
              onChanged: (_) {},
            ),
          ),
          WidgetPlacement(
            id: 'submit_survey',
            gridPosition: const GridPosition(x: 4, y: 8, width: 2, height: 1),
            widget: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text('Submit Survey'),
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return LayoutStoryBase(
      title: 'Survey Form Layout',
      description: 'Multi-question survey with various input types and visual sections',
      layout: Container(
        height: 700,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FormLayout(
          gridDimensions: const GridDimensions(width: 6, height: 9),
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
      features: [
        'Header card with prominent survey title',
        'Side-by-side rating and recommendation sections',
        'Multi-select checkboxes for category selection',
        'Large text area for detailed feedback',
        'Optional contact preference checkbox',
        'Clear visual separation using cards',
      ],
      useCase: 'Ideal for customer feedback, employee satisfaction surveys, product reviews, or any scenario requiring diverse question types and clear visual organization.',
      layoutCode: '''
// Survey form with mixed question types
final surveyPlacements = [
  // Header
  WidgetPlacement(
    id: 'title',
    gridPosition: GridPosition(x: 0, y: 0, width: 6, height: 1),
    widget: Card(
      color: Colors.blue,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Customer Satisfaction Survey',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ),
  
  // Side-by-side questions
  WidgetPlacement(
    id: 'rating',
    gridPosition: GridPosition(x: 0, y: 1, width: 3, height: 2),
    widget: Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Overall Satisfaction'),
            // Star rating widget
          ],
        ),
      ),
    ),
  ),
  
  // Multi-row text area
  WidgetPlacement(
    id: 'improvements',
    gridPosition: GridPosition(x: 0, y: 5, width: 6, height: 3),
    widget: Card(
      child: TextField(
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Suggestions for improvement',
          border: OutlineInputBorder(),
        ),
      ),
    ),
  ),
];''',
    );
  }
}

// Registration Form Layout Story
class RegistrationFormLayoutStory extends HookWidget {
  const RegistrationFormLayoutStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    // Pre-populate registration form layout
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'header',
            gridPosition: const GridPosition(x: 0, y: 0, width: 4, height: 1),
            widget: const Card(
              color: Colors.green,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Create Your Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'username',
            gridPosition: const GridPosition(x: 0, y: 1, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'email',
            gridPosition: const GridPosition(x: 2, y: 1, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'password',
            gridPosition: const GridPosition(x: 0, y: 2, width: 2, height: 1),
            widget: const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'confirm_password',
            gridPosition: const GridPosition(x: 2, y: 2, width: 2, height: 1),
            widget: const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'first_name',
            gridPosition: const GridPosition(x: 0, y: 3, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'last_name',
            gridPosition: const GridPosition(x: 2, y: 3, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'birthdate',
            gridPosition: const GridPosition(x: 0, y: 4, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Birth Date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'gender',
            gridPosition: const GridPosition(x: 2, y: 4, width: 2, height: 1),
            widget: const DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              items: [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: null,
            ),
          ),
          WidgetPlacement(
            id: 'terms',
            gridPosition: const GridPosition(x: 0, y: 5, width: 4, height: 1),
            widget: CheckboxListTile(
              title: const Text('I agree to the Terms of Service and Privacy Policy'),
              value: false,
              onChanged: (_) {},
            ),
          ),
          WidgetPlacement(
            id: 'newsletter',
            gridPosition: const GridPosition(x: 0, y: 6, width: 4, height: 1),
            widget: CheckboxListTile(
              title: const Text('Subscribe to our newsletter for updates'),
              value: true,
              onChanged: (_) {},
            ),
          ),
          WidgetPlacement(
            id: 'register',
            gridPosition: const GridPosition(x: 0, y: 7, width: 2, height: 1),
            widget: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add),
              label: const Text('Create Account'),
            ),
          ),
          WidgetPlacement(
            id: 'login',
            gridPosition: const GridPosition(x: 2, y: 7, width: 2, height: 1),
            widget: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.login),
              label: const Text('Already have account?'),
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return LayoutStoryBase(
      title: 'Registration Form Layout',
      description: 'Comprehensive user registration with account details and preferences',
      layout: Container(
        height: 600,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FormLayout(
          gridDimensions: const GridDimensions(width: 4, height: 8),
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
      features: [
        'Prominent header card for clear purpose',
        'Side-by-side username and email fields',
        'Password and confirmation in adjacent columns',
        'Personal information in logical grouping',
        'Date picker and dropdown for structured input',
        'Terms and newsletter checkboxes with clear text',
        'Dual action buttons for registration and login',
      ],
      useCase: 'Perfect for user onboarding, membership signups, or any application requiring comprehensive user information collection with clear visual hierarchy.',
      layoutCode: '''
// Registration form with logical field grouping
final registrationPlacements = [
  // Header
  WidgetPlacement(
    id: 'header',
    gridPosition: GridPosition(x: 0, y: 0, width: 4, height: 1),
    widget: Card(
      color: Colors.green,
      child: Text('Create Your Account'),
    ),
  ),
  
  // Account credentials side-by-side
  WidgetPlacement(
    id: 'username',
    gridPosition: GridPosition(x: 0, y: 1, width: 2, height: 1),
    widget: TextField(
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.person),
      ),
    ),
  ),
  WidgetPlacement(
    id: 'email',
    gridPosition: GridPosition(x: 2, y: 1, width: 2, height: 1),
    widget: TextField(
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
      ),
    ),
  ),
  
  // Password fields
  WidgetPlacement(
    id: 'password',
    gridPosition: GridPosition(x: 0, y: 2, width: 2, height: 1),
    widget: TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
      ),
    ),
  ),
  
  // Action buttons
  WidgetPlacement(
    id: 'register',
    gridPosition: GridPosition(x: 0, y: 7, width: 2, height: 1),
    widget: ElevatedButton(
      child: Text('Create Account'),
      onPressed: () {},
    ),
  ),
];''',
    );
  }
}

// Multi-Column Layout Story
class MultiColumnLayoutStory extends HookWidget {
  const MultiColumnLayoutStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    // Pre-populate multi-column layout
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          // Header spanning full width
          WidgetPlacement(
            id: 'header',
            gridPosition: const GridPosition(x: 0, y: 0, width: 8, height: 1),
            widget: const Card(
              color: Colors.purple,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Employee Information Form',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Left Column - Personal Info
          WidgetPlacement(
            id: 'personal_header',
            gridPosition: const GridPosition(x: 0, y: 1, width: 4, height: 1),
            widget: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: const Text(
                'Personal Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'employee_id',
            gridPosition: const GridPosition(x: 0, y: 2, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'department',
            gridPosition: const GridPosition(x: 2, y: 2, width: 2, height: 1),
            widget: const DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'hr', child: Text('Human Resources')),
                DropdownMenuItem(value: 'it', child: Text('Information Technology')),
                DropdownMenuItem(value: 'finance', child: Text('Finance')),
                DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
              ],
              onChanged: null,
            ),
          ),
          WidgetPlacement(
            id: 'full_name',
            gridPosition: const GridPosition(x: 0, y: 3, width: 4, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'email_work',
            gridPosition: const GridPosition(x: 0, y: 4, width: 4, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Work Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
          ),
          
          // Right Column - Contact & Emergency
          WidgetPlacement(
            id: 'contact_header',
            gridPosition: const GridPosition(x: 4, y: 1, width: 4, height: 1),
            widget: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade50,
              child: const Text(
                'Contact & Emergency Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'phone_mobile',
            gridPosition: const GridPosition(x: 4, y: 2, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Mobile Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'phone_home',
            gridPosition: const GridPosition(x: 6, y: 2, width: 2, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Home Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'address',
            gridPosition: const GridPosition(x: 4, y: 3, width: 4, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Home Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'emergency_contact',
            gridPosition: const GridPosition(x: 4, y: 4, width: 4, height: 1),
            widget: const TextField(
              decoration: InputDecoration(
                labelText: 'Emergency Contact',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emergency),
              ),
            ),
          ),
          
          // Bottom section spanning full width
          WidgetPlacement(
            id: 'notes',
            gridPosition: const GridPosition(x: 0, y: 5, width: 8, height: 2),
            widget: const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Additional Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          WidgetPlacement(
            id: 'save',
            gridPosition: const GridPosition(x: 6, y: 7, width: 2, height: 1),
            widget: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Save Employee'),
            ),
          ),
        ];
        
        for (final placement in placements) {
          formState.addPlacement(placement);
        }
      }
      return null;
    }, []);
    
    return LayoutStoryBase(
      title: 'Multi-Column Layout',
      description: 'Complex form with distinct sections in multiple columns',
      layout: Container(
        height: 600,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FormLayout(
          gridDimensions: const GridDimensions(width: 8, height: 8),
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
      features: [
        'Full-width header for unified branding',
        'Two distinct column sections with visual separation',
        'Color-coded section headers for easy navigation',
        'Logical grouping of related information',
        'Mixed field types within each column',
        'Full-width elements where appropriate',
        'Strategic button placement for workflow',
      ],
      useCase: 'Ideal for complex data entry forms, employee records, detailed surveys, or any scenario where information naturally falls into multiple categories that benefit from side-by-side presentation.',
      layoutCode: '''
// Multi-column layout with sections
final multiColumnPlacements = [
  // Full-width header
  WidgetPlacement(
    id: 'header',
    gridPosition: GridPosition(x: 0, y: 0, width: 8, height: 1),
    widget: Card(
      color: Colors.purple,
      child: Text('Employee Information Form'),
    ),
  ),
  
  // Left column header
  WidgetPlacement(
    id: 'personal_header',
    gridPosition: GridPosition(x: 0, y: 1, width: 4, height: 1),
    widget: Container(
      color: Colors.blue.shade50,
      child: Text('Personal Information'),
    ),
  ),
  
  // Left column fields
  WidgetPlacement(
    id: 'employee_id',
    gridPosition: GridPosition(x: 0, y: 2, width: 2, height: 1),
    widget: TextField(
      decoration: InputDecoration(labelText: 'Employee ID'),
    ),
  ),
  
  // Right column header
  WidgetPlacement(
    id: 'contact_header',
    gridPosition: GridPosition(x: 4, y: 1, width: 4, height: 1),
    widget: Container(
      color: Colors.green.shade50,
      child: Text('Contact & Emergency Information'),
    ),
  ),
  
  // Right column fields
  WidgetPlacement(
    id: 'phone_mobile',
    gridPosition: GridPosition(x: 4, y: 2, width: 2, height: 1),
    widget: TextField(
      decoration: InputDecoration(
        labelText: 'Mobile Phone',
        prefixIcon: Icon(Icons.phone_android),
      ),
    ),
  ),
];''',
    );
  }
}

// Responsive Grid Layout Story
class ResponsiveGridLayoutStory extends HookWidget {
  const ResponsiveGridLayoutStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final screenSize = useState('Desktop');
    
    // Pre-populate responsive layout
    useEffect(() {
      if (formState.placements.isEmpty) {
        _createResponsiveLayout(formState, screenSize.value);
      }
      return null;
    }, []);
    
    return LayoutStoryBase(
      title: 'Responsive Grid Layout',
      description: 'Adaptive layout that adjusts to different screen sizes',
      layout: Column(
        children: [
          // Screen size selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Screen Size: '),
                  const SizedBox(width: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Mobile', label: Text('Mobile')),
                      ButtonSegment(value: 'Tablet', label: Text('Tablet')),
                      ButtonSegment(value: 'Desktop', label: Text('Desktop')),
                    ],
                    selected: {screenSize.value},
                    onSelectionChanged: (Set<String> selection) {
                      screenSize.value = selection.first;
                      _createResponsiveLayout(formState, screenSize.value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FormLayout(
                gridDimensions: _getGridDimensions(screenSize.value),
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
        ],
      ),
      features: [
        'Adaptive grid dimensions based on screen size',
        'Responsive field widths and arrangements',
        'Optimal layout for each device category',
        'Maintains usability across all screen sizes',
        'Single-column mobile layout for touch interaction',
        'Multi-column desktop layout for efficiency',
      ],
      useCase: 'Essential for web applications that need to work across devices, ensuring optimal user experience on mobile phones, tablets, and desktop computers.',
      layoutCode: '''
// Responsive layout implementation
GridDimensions getGridDimensions(String screenSize) {
  switch (screenSize) {
    case 'Mobile':
      return GridDimensions(width: 2, height: 10);
    case 'Tablet':
      return GridDimensions(width: 4, height: 6);
    case 'Desktop':
    default:
      return GridDimensions(width: 6, height: 4);
  }
}

void createResponsiveLayout(FormState formState, String screenSize) {
  formState.clearAll();
  
  if (screenSize == 'Mobile') {
    // Single column layout
    formState.addPlacement(WidgetPlacement(
      id: 'name',
      gridPosition: GridPosition(x: 0, y: 0, width: 2, height: 1),
    ));
    formState.addPlacement(WidgetPlacement(
      id: 'email',
      gridPosition: GridPosition(x: 0, y: 1, width: 2, height: 1),
    ));
  } else if (screenSize == 'Desktop') {
    // Multi-column layout
    formState.addPlacement(WidgetPlacement(
      id: 'name',
      gridPosition: GridPosition(x: 0, y: 0, width: 3, height: 1),
    ));
    formState.addPlacement(WidgetPlacement(
      id: 'email',
      gridPosition: GridPosition(x: 3, y: 0, width: 3, height: 1),
    ));
  }
}''',
    );
  }
  
  void _createResponsiveLayout(dynamic formState, String screenSize) {
    formState.clearAll();
    
    if (screenSize == 'Mobile') {
      // Mobile: Single column layout
      final placements = [
        WidgetPlacement(
          id: 'name',
          gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'email',
          gridPosition: const GridPosition(x: 0, y: 1, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'phone',
          gridPosition: const GridPosition(x: 0, y: 2, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'message',
          gridPosition: const GridPosition(x: 0, y: 3, width: 2, height: 4),
          widget: const TextField(
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ),
        WidgetPlacement(
          id: 'submit',
          gridPosition: const GridPosition(x: 0, y: 7, width: 2, height: 1),
          widget: ElevatedButton(
            onPressed: () {},
            child: const Text('Send Message'),
          ),
        ),
      ];
      
      for (final placement in placements) {
        formState.addPlacement(placement);
      }
    } else if (screenSize == 'Tablet') {
      // Tablet: Two column layout
      final placements = [
        WidgetPlacement(
          id: 'name',
          gridPosition: const GridPosition(x: 0, y: 0, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'email',
          gridPosition: const GridPosition(x: 2, y: 0, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'phone',
          gridPosition: const GridPosition(x: 0, y: 1, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'company',
          gridPosition: const GridPosition(x: 2, y: 1, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Company',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'message',
          gridPosition: const GridPosition(x: 0, y: 2, width: 4, height: 3),
          widget: const TextField(
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ),
        WidgetPlacement(
          id: 'submit',
          gridPosition: const GridPosition(x: 3, y: 5, width: 1, height: 1),
          widget: ElevatedButton(
            onPressed: () {},
            child: const Text('Send'),
          ),
        ),
      ];
      
      for (final placement in placements) {
        formState.addPlacement(placement);
      }
    } else {
      // Desktop: Multi-column layout
      final placements = [
        WidgetPlacement(
          id: 'name',
          gridPosition: const GridPosition(x: 0, y: 0, width: 3, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'email',
          gridPosition: const GridPosition(x: 3, y: 0, width: 3, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'phone',
          gridPosition: const GridPosition(x: 0, y: 1, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'company',
          gridPosition: const GridPosition(x: 2, y: 1, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Company',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'department',
          gridPosition: const GridPosition(x: 4, y: 1, width: 2, height: 1),
          widget: const TextField(
            decoration: InputDecoration(
              labelText: 'Department',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        WidgetPlacement(
          id: 'message',
          gridPosition: const GridPosition(x: 0, y: 2, width: 6, height: 2),
          widget: const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ),
      ];
      
      for (final placement in placements) {
        formState.addPlacement(placement);
      }
    }
  }
  
  GridDimensions _getGridDimensions(String screenSize) {
    switch (screenSize) {
      case 'Mobile':
        return const GridDimensions(width: 2, height: 8);
      case 'Tablet':
        return const GridDimensions(width: 4, height: 6);
      case 'Desktop':
      default:
        return const GridDimensions(width: 6, height: 4);
    }
  }
}

// Dashboard Layout Story
class DashboardLayoutStory extends HookWidget {
  const DashboardLayoutStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    
    // Pre-populate dashboard layout
    useEffect(() {
      if (formState.placements.isEmpty) {
        final placements = [
          WidgetPlacement(
            id: 'title',
            gridPosition: const GridPosition(x: 0, y: 0, width: 6, height: 1),
            widget: const Card(
              color: Colors.indigo,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Analytics Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'metric1',
            gridPosition: const GridPosition(x: 0, y: 1, width: 2, height: 2),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.people, size: 40, color: Colors.blue),
                    SizedBox(height: 8),
                    Text('1,234', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Total Users'),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'metric2',
            gridPosition: const GridPosition(x: 2, y: 1, width: 2, height: 2),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.trending_up, size: 40, color: Colors.green),
                    SizedBox(height: 8),
                    Text('98.5%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Uptime'),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'metric3',
            gridPosition: const GridPosition(x: 4, y: 1, width: 2, height: 2),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.attach_money, size: 40, color: Colors.orange),
                    SizedBox(height: 8),
                    Text('\$45,678', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Revenue'),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'chart',
            gridPosition: const GridPosition(x: 0, y: 3, width: 4, height: 3),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Performance', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: Text('Chart Placeholder\n📊', 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 32)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          WidgetPlacement(
            id: 'activities',
            gridPosition: const GridPosition(x: 4, y: 3, width: 2, height: 3),
            widget: const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Activity', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.person_add, color: Colors.green),
                      title: Text('New user registered'),
                      subtitle: Text('2 minutes ago'),
                      dense: true,
                    ),
                    ListTile(
                      leading: Icon(Icons.shopping_cart, color: Colors.blue),
                      title: Text('Order completed'),
                      subtitle: Text('5 minutes ago'),
                      dense: true,
                    ),
                    ListTile(
                      leading: Icon(Icons.warning, color: Colors.orange),
                      title: Text('Server warning'),
                      subtitle: Text('12 minutes ago'),
                      dense: true,
                    ),
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
    
    return LayoutStoryBase(
      title: 'Dashboard Layout',
      description: 'Information dashboard with metrics, charts, and activity feeds',
      layout: Container(
        height: 600,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
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
          showGrid: false,
        ),
      ),
      features: [
        'Full-width header for branding and title',
        'Grid of metric cards with icons and values',
        'Large chart area for data visualization',
        'Activity feed with timeline information',
        'Consistent card-based design system',
        'Responsive layout adapts to content',
        'Visual hierarchy guides attention',
      ],
      useCase: 'Perfect for admin panels, business intelligence dashboards, monitoring systems, or any interface that needs to present multiple data points and activities in an organized, scannable format.',
      layoutCode: '''
// Dashboard layout with metrics and charts
final dashboardPlacements = [
  // Header
  WidgetPlacement(
    id: 'title',
    gridPosition: GridPosition(x: 0, y: 0, width: 6, height: 1),
    widget: Card(
      color: Colors.indigo,
      child: Text('Analytics Dashboard'),
    ),
  ),
  
  // Metric cards in row
  WidgetPlacement(
    id: 'metric1',
    gridPosition: GridPosition(x: 0, y: 1, width: 2, height: 2),
    widget: Card(
      child: Column(
        children: [
          Icon(Icons.people, size: 40),
          Text('1,234', style: TextStyle(fontSize: 24)),
          Text('Total Users'),
        ],
      ),
    ),
  ),
  
  // Large chart area
  WidgetPlacement(
    id: 'chart',
    gridPosition: GridPosition(x: 0, y: 3, width: 4, height: 3),
    widget: Card(
      child: Column(
        children: [
          Text('Monthly Performance'),
          // Chart widget here
        ],
      ),
    ),
  ),
  
  // Activity sidebar
  WidgetPlacement(
    id: 'activities',
    gridPosition: GridPosition(x: 4, y: 3, width: 2, height: 3),
    widget: Card(
      child: Column(
        children: [
          Text('Recent Activity'),
          // Activity list here
        ],
      ),
    ),
  ),
];''',
    );
  }
}