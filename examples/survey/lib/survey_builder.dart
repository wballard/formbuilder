import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'models/survey_model.dart';
import 'widgets/survey_toolbox.dart';
import 'widgets/survey_navigator.dart';

class SurveyBuilder extends StatefulWidget {
  const SurveyBuilder({super.key});

  @override
  State<SurveyBuilder> createState() => _SurveyBuilderState();
}

class _SurveyBuilderState extends State<SurveyBuilder> {
  LayoutState? _currentLayout;
  int _currentPage = 0;
  final _survey = SurveyModel(
    title: 'Customer Satisfaction Survey',
    pages: [
      SurveyPage(title: 'Basic Information', questions: []),
      SurveyPage(title: 'Product Experience', questions: []),
      SurveyPage(title: 'Feedback', questions: []),
    ],
  );

  final _initialLayout = LayoutState(
    dimensions: const GridDimensions(columns: 4, rows: 8),
    widgets: [],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_survey.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Preview Survey',
            onPressed: _previewSurvey,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Survey',
            onPressed: _exportSurvey,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'new':
                  _newSurvey();
                  break;
                case 'template':
                  _loadTemplate();
                  break;
                case 'settings':
                  _showSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'new', child: Text('New Survey')),
              const PopupMenuItem(value: 'template', child: Text('Use Template')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'settings', child: Text('Survey Settings')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SurveyNavigator(
            pages: _survey.pages,
            currentPage: _currentPage,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
          ),
          Expanded(
            child: FormLayout(
              key: ValueKey('page_$_currentPage'),
              toolbox: createSurveyToolbox(),
              initialLayout: _currentLayout ?? _initialLayout,
              onLayoutChanged: (layout) {
                setState(() {
                  _currentLayout = layout;
                });
              },
              showToolbox: true,
              toolboxPosition: Axis.vertical,
              toolboxWidth: 200,
              enableUndo: true,
            ),
          ),
        ],
      ),
    );
  }

  void _previewSurvey() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyPreview(survey: _survey),
      ),
    );
  }

  void _exportSurvey() {
    final surveyJson = {
      'title': _survey.title,
      'pages': _survey.pages.map((page) => {
        'title': page.title,
        'questions': page.questions.map((q) => q.toJson()).toList(),
      }).toList(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Survey'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Survey JSON:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(surveyJson),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _newSurvey() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Survey'),
        content: const Text('This will clear the current survey. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _currentLayout = null;
                _currentPage = 0;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Create New'),
          ),
        ],
      ),
    );
  }

  void _loadTemplate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Survey Templates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Customer Satisfaction'),
              subtitle: const Text('5 pages, 15 questions'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template loaded')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Course Evaluation'),
              subtitle: const Text('3 pages, 10 questions'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template loaded')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Employee Feedback'),
              subtitle: const Text('4 pages, 20 questions'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template loaded')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Survey Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Survey Title',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _survey.title),
              onChanged: (value) {
                setState(() {
                  _survey.title = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Anonymous Responses'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Allow Skip Questions'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class SurveyPreview extends StatefulWidget {
  final SurveyModel survey;

  const SurveyPreview({super.key, required this.survey});

  @override
  State<SurveyPreview> createState() => _SurveyPreviewState();
}

class _SurveyPreviewState extends State<SurveyPreview> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Preview'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / widget.survey.pages.length,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.survey.pages[_currentPage].title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        const Expanded(
                          child: Center(
                            child: Text('Survey questions would appear here'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentPage > 0)
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                },
                                child: const Text('Previous'),
                              )
                            else
                              const SizedBox(),
                            if (_currentPage < widget.survey.pages.length - 1)
                              FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                },
                                child: const Text('Next'),
                              )
                            else
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Survey completed!')),
                                  );
                                },
                                child: const Text('Submit'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}