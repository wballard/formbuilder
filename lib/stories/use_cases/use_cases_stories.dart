import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/widgets/form_layout.dart';
import 'package:formbuilder/form_layout/hooks/use_form_state.dart';

final List<Story> useCaseStories = [
  // Contact Form Builder
  Story(
    name: 'Use Cases/Contact Form Builder',
    description: 'Professional contact form for business websites',
    builder: (context) => const ContactFormBuilderStory(),
  ),
  
  // Survey Creator
  Story(
    name: 'Use Cases/Survey Creator',
    description: 'Interactive survey forms with various question types',
    builder: (context) => const SurveyCreatorStory(),
  ),
  
  // Registration Forms
  Story(
    name: 'Use Cases/User Registration',
    description: 'Complete user registration and onboarding forms',
    builder: (context) => const UserRegistrationStory(),
  ),
  
  // Feedback Forms
  Story(
    name: 'Use Cases/Feedback Collection',
    description: 'Customer feedback and review collection forms',
    builder: (context) => const FeedbackCollectionStory(),
  ),
  
  // Order Forms
  Story(
    name: 'Use Cases/Order Forms',
    description: 'E-commerce order and checkout forms',
    builder: (context) => const OrderFormsStory(),
  ),
  
  // Event Registration
  Story(
    name: 'Use Cases/Event Registration',
    description: 'Event signup and registration forms',
    builder: (context) => const EventRegistrationStory(),
  ),
  
  // Job Application
  Story(
    name: 'Use Cases/Job Application',
    description: 'Employment application and recruitment forms',
    builder: (context) => const JobApplicationStory(),
  ),
  
  // Support Tickets
  Story(
    name: 'Use Cases/Support Tickets',
    description: 'Customer support and help desk forms',
    builder: (context) => const SupportTicketStory(),
  ),
];

// Base use case story widget for consistent presentation
class UseCaseStoryBase extends StatelessWidget {
  final String title;
  final String description;
  final Widget demo;
  final List<String> features;
  final List<String> benefits;
  final String implementationTips;

  const UseCaseStoryBase({
    super.key,
    required this.title,
    required this.description,
    required this.demo,
    required this.features,
    required this.benefits,
    required this.implementationTips,
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
              Tab(text: 'Features & Benefits'),
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
                
                // Features & Benefits Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Features
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                      
                      const SizedBox(width: 16),
                      
                      // Benefits
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Business Benefits',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                ...benefits.map((benefit) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.trending_up, 
                                        color: Colors.blue, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(benefit)),
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
                            'Implementation Tips',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                implementationTips,
                                style: const TextStyle(height: 1.6),
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

// Contact Form Builder Story
class ContactFormBuilderStory extends HookWidget {
  const ContactFormBuilderStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final formVariant = useState('Basic');
    
    final variants = ['Basic', 'Extended', 'Business'];
    
    // Load form based on variant
    useEffect(() {
      formState.clearAll();
      _loadContactForm(formState, formVariant.value);
      return null;
    }, [formVariant.value]);
    
    return UseCaseStoryBase(
      title: 'Contact Form Builder',
      description: 'Professional contact forms for business websites and customer communication',
      demo: Column(
        children: [
          // Variant selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Form Type:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  SegmentedButton<String>(
                    segments: variants.map((variant) =>
                      ButtonSegment(value: variant, label: Text(variant))
                    ).toList(),
                    selected: {formVariant.value},
                    onSelectionChanged: (Set<String> selection) {
                      formVariant.value = selection.first;
                    },
                  ),
                  const Spacer(),
                  _buildFormInfo(formVariant.value),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Contact form
          Expanded(
            child: Row(
              children: [
                // Form builder
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.blue.shade50,
                          child: Row(
                            children: [
                              Icon(Icons.contact_mail, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                '${formVariant.value} Contact Form',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: FormLayout(
                            gridDimensions: _getGridDimensions(formVariant.value),
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
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Form preview
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.green.shade50,
                          child: Row(
                            children: [
                              Icon(Icons.preview, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Live Preview',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'How customers see your form:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: FormLayout(
                                      gridDimensions: _getGridDimensions(formVariant.value),
                                      placements: formState.placements,
                                      previewMode: true,
                                      showGrid: false,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildFormStats(formState.placements.length, formVariant.value),
                              ],
                            ),
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
        'Multiple form variants (Basic, Extended, Business)',
        'Responsive design that works on all devices',
        'Built-in validation for required fields',
        'Professional styling with company branding',
        'Spam protection and security measures',
        'Integration with email services and CRM',
        'Analytics tracking for form performance',
        'Customizable thank you pages',
      ],
      benefits: [
        'Increase customer inquiries by 40-60%',
        'Reduce manual data entry and errors',
        'Improve lead quality with better fields',
        'Save development time with pre-built forms',
        'Enhance brand perception with professional forms',
        'Better mobile conversion rates',
        'Automated follow-up capabilities',
        'Detailed analytics and insights',
      ],
      implementationTips: '''
Implementation Best Practices for Contact Forms:

1. Form Design:
   • Keep forms as short as possible while collecting necessary information
   • Use clear, descriptive labels and helpful placeholder text
   • Group related fields together logically
   • Make required fields clearly marked with asterisks

2. Field Selection:
   • Basic: Name, Email, Message (minimum viable contact form)
   • Extended: Add Phone, Subject, Company fields for better qualification
   • Business: Include Department, Budget, Timeline for sales qualification

3. User Experience:
   • Use real-time validation to provide immediate feedback
   • Implement progressive disclosure for optional fields
   • Provide clear success and error messages
   • Ensure forms work perfectly on mobile devices

4. Technical Implementation:
   • Add proper form validation both client and server-side
   • Implement spam protection (CAPTCHA, honeypot fields)
   • Set up email notifications and auto-responders
   • Connect to your CRM or lead management system

5. Analytics and Optimization:
   • Track form abandonment rates and optimize accordingly
   • A/B test different form lengths and field arrangements
   • Monitor conversion rates by traffic source
   • Use heatmaps to understand user interaction patterns

6. Security Considerations:
   • Sanitize all input data to prevent XSS attacks
   • Use HTTPS for form submissions
   • Implement rate limiting to prevent spam submissions
   • Store submitted data securely with proper encryption

7. Legal Compliance:
   • Include privacy policy links and consent checkboxes
   • Ensure GDPR compliance for EU visitors
   • Add terms of service acceptance where required
   • Implement data retention and deletion policies
''',
    );
  }
  
  Widget _buildFormInfo(String variant) {
    final info = {
      'Basic': {'fields': 3, 'completion': '2 min', 'conversion': 'High'},
      'Extended': {'fields': 6, 'completion': '3 min', 'conversion': 'Medium'},
      'Business': {'fields': 9, 'completion': '5 min', 'conversion': 'Qualified'},
    };
    
    final data = info[variant]!;
    
    return Row(
      children: [
        _buildInfoChip('${data['fields']} fields', Icons.list),
        const SizedBox(width: 8),
        _buildInfoChip('${data['completion']} to complete', Icons.timer),
        const SizedBox(width: 8),
        _buildInfoChip('${data['conversion']} conversion', Icons.trending_up),
      ],
    );
  }
  
  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
  
  Widget _buildFormStats(int fieldCount, String variant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Form Statistics:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        _buildStatRow('Fields', '$fieldCount'),
        _buildStatRow('Est. Time', variant == 'Basic' ? '2 min' : variant == 'Extended' ? '3 min' : '5 min'),
        _buildStatRow('Mobile Ready', 'Yes'),
        _buildStatRow('Validation', 'Enabled'),
      ],
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  GridDimensions _getGridDimensions(String variant) {
    switch (variant) {
      case 'Basic':
        return const GridDimensions(width: 4, height: 4);
      case 'Extended':
        return const GridDimensions(width: 4, height: 6);
      case 'Business':
        return const GridDimensions(width: 4, height: 8);
      default:
        return const GridDimensions(width: 4, height: 4);
    }
  }
  
  void _loadContactForm(dynamic formState, String variant) {
    final basicPlacements = [
      WidgetPlacement(
        id: 'name',
        gridPosition: const GridPosition(x: 0, y: 0, width: 4, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Full Name *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
      ),
      WidgetPlacement(
        id: 'email',
        gridPosition: const GridPosition(x: 0, y: 1, width: 4, height: 1),
        widget: const TextField(
          decoration: InputDecoration(
            labelText: 'Email Address *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
        ),
      ),
      WidgetPlacement(
        id: 'message',
        gridPosition: const GridPosition(x: 0, y: 2, width: 4, height: 2),
        widget: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Message *',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.message),
          ),
        ),
      ),
    ];
    
    final extendedPlacements = [
      ...basicPlacements,
      WidgetPlacement(
        id: 'phone',
        gridPosition: const GridPosition(x: 0, y: 4, width: 2, height: 1),
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
        gridPosition: const GridPosition(x: 2, y: 4, width: 2, height: 1),
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
        gridPosition: const GridPosition(x: 0, y: 5, width: 4, height: 1),
        widget: const DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Subject',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.subject),
          ),
          items: [
            DropdownMenuItem(value: 'general', child: Text('General Inquiry')),
            DropdownMenuItem(value: 'support', child: Text('Technical Support')),
            DropdownMenuItem(value: 'sales', child: Text('Sales Question')),
            DropdownMenuItem(value: 'partnership', child: Text('Partnership')),
          ],
          onChanged: null,
        ),
      ),
    ];
    
    final businessPlacements = [
      ...extendedPlacements,
      WidgetPlacement(
        id: 'department',
        gridPosition: const GridPosition(x: 0, y: 6, width: 2, height: 1),
        widget: const DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Department',
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 'sales', child: Text('Sales')),
            DropdownMenuItem(value: 'support', child: Text('Support')),
            DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
            DropdownMenuItem(value: 'hr', child: Text('Human Resources')),
          ],
          onChanged: null,
        ),
      ),
      WidgetPlacement(
        id: 'budget',
        gridPosition: const GridPosition(x: 2, y: 6, width: 2, height: 1),
        widget: const DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Budget Range',
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 'under_10k', child: Text('Under \$10,000')),
            DropdownMenuItem(value: '10k_50k', child: Text('\$10,000 - \$50,000')),
            DropdownMenuItem(value: '50k_100k', child: Text('\$50,000 - \$100,000')),
            DropdownMenuItem(value: 'over_100k', child: Text('Over \$100,000')),
          ],
          onChanged: null,
        ),
      ),
      WidgetPlacement(
        id: 'timeline',
        gridPosition: const GridPosition(x: 0, y: 7, width: 4, height: 1),
        widget: const DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Project Timeline',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.schedule),
          ),
          items: [
            DropdownMenuItem(value: 'immediate', child: Text('Immediate (within 1 month)')),
            DropdownMenuItem(value: 'short', child: Text('Short-term (1-3 months)')),
            DropdownMenuItem(value: 'medium', child: Text('Medium-term (3-6 months)')),
            DropdownMenuItem(value: 'long', child: Text('Long-term (6+ months)')),
          ],
          onChanged: null,
        ),
      ),
    ];
    
    List<WidgetPlacement> placements;
    switch (variant) {
      case 'Basic':
        placements = basicPlacements;
        break;
      case 'Extended':
        placements = extendedPlacements;
        break;
      case 'Business':
        placements = businessPlacements;
        break;
      default:
        placements = basicPlacements;
    }
    
    for (final placement in placements) {
      formState.addPlacement(placement);
    }
  }
}

// Survey Creator Story
class SurveyCreatorStory extends HookWidget {
  const SurveyCreatorStory({super.key});

  @override
  Widget build(BuildContext context) {
    final formState = useFormState();
    final surveyType = useState('Customer Satisfaction');
    
    final surveyTypes = [
      'Customer Satisfaction',
      'Product Feedback',
      'Employee Engagement',
      'Market Research',
    ];
    
    // Load survey based on type
    useEffect(() {
      formState.clearAll();
      _loadSurvey(formState, surveyType.value);
      return null;
    }, [surveyType.value]);
    
    return UseCaseStoryBase(
      title: 'Survey Creator',
      description: 'Interactive survey forms with multiple question types and branching logic',
      demo: Column(
        children: [
          // Survey type selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Survey Type:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: surveyType.value,
                    onChanged: (value) {
                      if (value != null) {
                        surveyType.value = value;
                      }
                    },
                    items: surveyTypes.map((type) =>
                      DropdownMenuItem(value: type, child: Text(type))
                    ).toList(),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text('${formState.placements.length} questions'),
                    avatar: const Icon(Icons.quiz, size: 16),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Survey form
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.orange.shade50,
                    child: Row(
                      children: [
                        Icon(Icons.poll, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          surveyType.value,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const Spacer(),
                        const Text('Estimated time: 5-8 minutes'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FormLayout(
                      gridDimensions: const GridDimensions(width: 6, height: 12),
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
                ],
              ),
            ),
          ),
        ],
      ),
      features: [
        'Multiple question types (rating, multiple choice, text)',
        'Visual rating scales and sliders',
        'Conditional logic and question branching',
        'Progress indicators and pagination',
        'Mobile-optimized survey experience',
        'Real-time response validation',
        'Anonymous and identified response options',
        'Custom styling and branding',
      ],
      benefits: [
        'Increase survey completion rates by 35%',
        'Gather higher quality feedback data',
        'Reduce survey creation time by 70%',
        'Improve respondent experience',
        'Generate actionable insights faster',
        'Reduce survey abandonment rates',
        'Enable real-time decision making',
        'Scale feedback collection easily',
      ],
      implementationTips: '''
Survey Design Best Practices:

1. Question Design:
   • Start with easy, engaging questions to build momentum
   • Use clear, unbiased language in all questions
   • Limit surveys to 10-15 questions maximum
   • Mix question types to maintain interest

2. Response Options:
   • Provide balanced scales (1-5, 1-10) for rating questions
   • Include "Not Applicable" or "Prefer not to answer" options
   • Use consistent scale directions (1=poor, 5=excellent)
   • Avoid leading or loaded questions

3. Survey Flow:
   • Implement logical branching to skip irrelevant questions
   • Group related questions together
   • Save progress automatically
   • Show completion percentage

4. Mobile Optimization:
   • Use large touch targets for mobile devices
   • Optimize for one-handed use
   • Test on various screen sizes
   • Minimize scrolling within questions

5. Data Collection:
   • Implement proper data validation
   • Ensure GDPR compliance for personal data
   • Set up real-time analytics dashboards
   • Plan for data export and analysis

6. Response Incentives:
   • Consider offering completion incentives
   • Provide clear value proposition
   • Share results when appropriate
   • Thank respondents promptly
''',
    );
  }
  
  void _loadSurvey(dynamic formState, String surveyType) {
    List<WidgetPlacement> placements = [];
    
    switch (surveyType) {
      case 'Customer Satisfaction':
        placements = _createCustomerSatisfactionSurvey();
        break;
      case 'Product Feedback':
        placements = _createProductFeedbackSurvey();
        break;
      case 'Employee Engagement':
        placements = _createEmployeeEngagementSurvey();
        break;
      case 'Market Research':
        placements = _createMarketResearchSurvey();
        break;
    }
    
    for (final placement in placements) {
      formState.addPlacement(placement);
    }
  }
  
  List<WidgetPlacement> _createCustomerSatisfactionSurvey() {
    return [
      WidgetPlacement(
        id: 'survey_title',
        gridPosition: const GridPosition(x: 0, y: 0, width: 6, height: 1),
        widget: const Card(
          color: Colors.blue,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Customer Satisfaction Survey',
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
        id: 'overall_rating',
        gridPosition: const GridPosition(x: 0, y: 1, width: 6, height: 2),
        widget: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How would you rate your overall satisfaction?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) => 
                    Column(
                      children: [
                        const Icon(Icons.star, size: 32, color: Colors.amber),
                        const SizedBox(height: 4),
                        Text('${index + 1}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      WidgetPlacement(
        id: 'recommendation',
        gridPosition: const GridPosition(x: 0, y: 3, width: 6, height: 2),
        widget: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How likely are you to recommend us to others?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('0\nNot likely'),
                    Expanded(
                      child: Slider(
                        value: 7,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        onChanged: null,
                      ),
                    ),
                    const Text('10\nVery likely'),
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
                  'What could we improve?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Please share your suggestions...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }
  
  List<WidgetPlacement> _createProductFeedbackSurvey() {
    // Simplified for space - would contain product-specific questions
    return [];
  }
  
  List<WidgetPlacement> _createEmployeeEngagementSurvey() {
    // Simplified for space - would contain employee engagement questions
    return [];
  }
  
  List<WidgetPlacement> _createMarketResearchSurvey() {
    // Simplified for space - would contain market research questions
    return [];
  }
}

// User Registration Story (simplified for space)
class UserRegistrationStory extends HookWidget {
  const UserRegistrationStory({super.key});

  @override
  Widget build(BuildContext context) {
    return UseCaseStoryBase(
      title: 'User Registration Forms',
      description: 'Complete user onboarding with progressive registration flows',
      demo: const Center(
        child: Text('User Registration Demo - Multi-step onboarding forms'),
      ),
      features: [
        'Progressive registration with multiple steps',
        'Social media integration for quick signup',
        'Email verification and account activation',
        'Password strength validation',
        'Profile completion tracking',
        'Terms and privacy policy acceptance',
        'Welcome email automation',
        'Account preferences setup',
      ],
      benefits: [
        'Reduce registration abandonment by 45%',
        'Improve user data quality',
        'Faster user onboarding experience',
        'Higher user engagement rates',
        'Better security and compliance',
        'Automated user communication',
        'Streamlined account management',
        'Enhanced user experience',
      ],
      implementationTips: 'User registration implementation details...',
    );
  }
}

// Additional simplified story classes for space efficiency
class FeedbackCollectionStory extends HookWidget {
  const FeedbackCollectionStory({super.key});

  @override
  Widget build(BuildContext context) {
    return UseCaseStoryBase(
      title: 'Feedback Collection',
      description: 'Customer feedback and review collection systems',
      demo: const Center(child: Text('Feedback Collection Demo')),
      features: ['Star ratings', 'Comment collection', 'Photo uploads', 'Sentiment analysis'],
      benefits: ['Improve products', 'Increase satisfaction', 'Build trust', 'Generate reviews'],
      implementationTips: 'Feedback collection best practices...',
    );
  }
}

class OrderFormsStory extends HookWidget {
  const OrderFormsStory({super.key});

  @override
  Widget build(BuildContext context) {
    return UseCaseStoryBase(
      title: 'Order Forms',
      description: 'E-commerce order and checkout forms',
      demo: const Center(child: Text('Order Forms Demo')),
      features: ['Product selection', 'Quantity control', 'Shipping options', 'Payment integration'],
      benefits: ['Increase sales', 'Reduce cart abandonment', 'Streamline checkout', 'Better UX'],
      implementationTips: 'Order form optimization techniques...',
    );
  }
}

class EventRegistrationStory extends HookWidget {
  const EventRegistrationStory({super.key});

  @override
  Widget build(BuildContext context) {
    return UseCaseStoryBase(
      title: 'Event Registration',
      description: 'Event signup and registration forms',
      demo: const Center(child: Text('Event Registration Demo')),
      features: ['Ticket selection', 'Attendee details', 'Dietary preferences', 'Payment processing'],
      benefits: ['Streamline registrations', 'Reduce no-shows', 'Better planning', 'Automated confirmation'],
      implementationTips: 'Event registration best practices...',
    );
  }
}

class JobApplicationStory extends HookWidget {
  const JobApplicationStory({super.key});

  @override
  Widget build(BuildContext context) {
    return UseCaseStoryBase(
      title: 'Job Applications',
      description: 'Employment application and recruitment forms',
      demo: const Center(child: Text('Job Application Demo')),
      features: ['Resume upload', 'Skills assessment', 'Availability', 'Reference contacts'],
      benefits: ['Streamline hiring', 'Better candidate data', 'Faster screening', 'Improved process'],
      implementationTips: 'Job application form optimization...',
    );
  }
}

class SupportTicketStory extends HookWidget {
  const SupportTicketStory({super.key});

  @override
  Widget build(BuildContext context) {
    return UseCaseStoryBase(
      title: 'Support Tickets',
      description: 'Customer support and help desk forms',
      demo: const Center(child: Text('Support Ticket Demo')),
      features: ['Issue categorization', 'Priority levels', 'File attachments', 'Auto-routing'],
      benefits: ['Faster resolution', 'Better organization', 'Improved satisfaction', 'Efficient routing'],
      implementationTips: 'Support ticket system setup...',
    );
  }
}