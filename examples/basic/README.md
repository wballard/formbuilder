# Basic Form Builder Example

This example demonstrates a simple contact form builder using the FormLayout widget with basic form field types.

## Features

- Text fields (name, email, message)
- Buttons (submit, cancel)
- Checkboxes (newsletter subscription, terms acceptance)
- Save/load functionality to persist form layouts
- Preview mode to see the form without editing capabilities

## Running the Example

```bash
flutter run -t examples/basic/lib/main.dart
```

## Key Components

- **BasicFormBuilder**: Main example widget showing basic form builder usage
- **Save/Load**: Demonstrates persisting form layouts to SharedPreferences
- **Preview Mode**: Shows how to toggle between edit and preview modes
- **Basic Toolbox**: Simple toolbox with essential form field types

## Usage

1. **Drag and Drop**: Drag widgets from the toolbox onto the grid
2. **Resize**: Select a widget and drag the resize handles
3. **Delete**: Select a widget and press Delete key
4. **Save Layout**: Click the save button to persist your form
5. **Load Layout**: Click the load button to restore a saved form
6. **Preview**: Toggle preview mode to see the form without editing

## Code Structure

```
basic/
├── lib/
│   ├── main.dart           # Entry point
│   ├── basic_form_builder.dart  # Main form builder widget
│   └── widgets/            # Custom form field widgets
│       ├── contact_fields.dart
│       └── basic_toolbox.dart
└── README.md
```

## Best Practices Demonstrated

- Clean separation of concerns
- Proper state management
- Responsive design
- Accessibility support
- Error handling