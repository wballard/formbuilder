# Form Designer Example

This example demonstrates the advanced features of the form builder, showcasing custom widgets, theme customization, and import/export capabilities.

## Features

- Advanced widget types with custom properties
- Theme customization and styling options
- Import/export layouts in multiple formats
- Custom widget creation interface
- Advanced validation rules
- Conditional visibility rules
- Integration with external data sources

## Running the Example

```bash
flutter run -t examples/designer/lib/main.dart
```

## Key Components

- **FormDesigner**: Main advanced form designer widget
- **Custom Widgets**: Create and configure custom widget types
- **Theme Editor**: Visual theme customization
- **Layout Manager**: Import/export and template management
- **Validation Builder**: Visual validation rule builder

## Usage

1. **Design Mode**: Full-featured form design with all widgets
2. **Theme Editor**: Customize colors, fonts, and spacing
3. **Widget Properties**: Configure advanced widget properties
4. **Export Options**: Save as JSON, YAML, or custom format
5. **Templates**: Save and reuse form templates

## Code Structure

```
designer/
├── lib/
│   ├── main.dart                   # Entry point
│   ├── form_designer.dart          # Main designer widget
│   ├── models/
│   │   ├── custom_widget.dart      # Custom widget model
│   │   └── theme_config.dart       # Theme configuration
│   └── widgets/
│       ├── designer_toolbox.dart   # Advanced toolbox
│       ├── property_editor.dart    # Widget property editor
│       ├── theme_editor.dart       # Theme customization
│       └── validation_builder.dart # Validation rule builder
└── README.md
```

## Advanced Features

### Custom Widgets
- Define custom widget types
- Configure properties and behaviors
- Save as reusable components

### Theme Customization
- Color schemes
- Typography settings
- Spacing and layout rules
- Dark/light theme variants

### Import/Export
- JSON format for data exchange
- YAML for human-readable configs
- Custom export formats
- Template library

### Validation Rules
- Required fields
- Pattern matching
- Custom validators
- Cross-field validation

## Best Practices Demonstrated

- Advanced state management
- Custom widget architecture
- Theme system integration
- Extensible design patterns
- Performance optimization