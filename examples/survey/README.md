# Survey Builder Example

This example demonstrates building multi-page surveys with various question types and conditional logic.

## Features

- Multiple question types (single choice, multiple choice, rating, text)
- Page navigation with progress tracking
- Basic conditional logic (show/hide questions based on answers)
- Export survey results to JSON
- Survey templates for quick start

## Running the Example

```bash
flutter run -t examples/survey/lib/main.dart
```

## Key Components

- **SurveyBuilder**: Main widget for creating and editing surveys
- **Question Types**: Various question widgets (radio, checkbox, rating, text)
- **PageNavigation**: Multi-page survey support with progress indication
- **ConditionalLogic**: Simple rules engine for showing/hiding questions
- **ResultsExporter**: Export survey responses in different formats

## Usage

1. **Create Survey**: Start with a blank survey or use a template
2. **Add Questions**: Drag question types from the toolbox
3. **Configure Logic**: Set up conditional display rules
4. **Preview Survey**: Test the survey flow before publishing
5. **Export Results**: Download responses as JSON or CSV

## Code Structure

```
survey/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── survey_builder.dart       # Main survey builder widget
│   ├── models/
│   │   ├── survey_model.dart     # Survey data model
│   │   ├── question_model.dart   # Question data model
│   │   └── logic_model.dart      # Conditional logic model
│   └── widgets/
│       ├── question_types/       # Different question widgets
│       ├── survey_navigator.dart # Page navigation
│       └── survey_toolbox.dart   # Question type toolbox
└── README.md
```

## Question Types

- **Single Choice**: Radio buttons for one answer
- **Multiple Choice**: Checkboxes for multiple answers
- **Rating Scale**: 1-5 or 1-10 rating scales
- **Text Input**: Short and long text responses
- **Yes/No**: Simple boolean questions
- **Date/Time**: Date and time pickers

## Best Practices Demonstrated

- Modular question components
- State management for survey responses
- Navigation and flow control
- Data validation and export
- Responsive design for all devices