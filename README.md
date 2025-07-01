# FormBuilder

[![Flutter CI](https://github.com/wballard/formbuilder/actions/workflows/ci.yml/badge.svg)](https://github.com/wballard/formbuilder/actions/workflows/ci.yml)
[![Storybook](https://img.shields.io/badge/storybook-live-ff4785)](https://wballard.github.io/formbuilder/)

A Flutter widget library that provides drag-and-drop form building capabilities using a grid layout system.

## 🚀 Live Demo

Check out the [interactive Storybook](https://wballard.github.io/formbuilder/) to explore all components and features.

## Project Structure

```
lib/
├── main.dart                    # Simple demo application
├── formbuilder.dart            # Package export file
└── form_layout/                # FormLayout widget package
    ├── widgets/                # UI components
    ├── models/                 # Data models
    ├── hooks/                  # Custom Flutter hooks
    ├── intents/                # Intent/Action definitions
    └── utils/                  # Utility functions
example/
├── lib/
│   ├── main.dart               # Storybook showcase
│   ├── main_simple.dart        # Simple usage example
│   └── stories/                # Storybook stories
└── README.md                   # Example documentation
```

## Features

- Drag and drop widgets from a toolbox onto a grid
- Resize and reposition widgets on the grid
- Grid-based layout system with customizable dimensions
- Undo/redo functionality
- Preview mode to see the form as end users would
- Keyboard navigation and accessibility support
- Customizable themes and styling

## Getting Started

### Run the main app
```bash
fvm flutter run
```

### Run Storybook for development
```bash
cd example
fvm flutter run
```

### Run simple usage example
```bash
cd example
fvm flutter run -t lib/main_simple.dart
```

## Development

This project uses:
- `storybook_flutter` for component development and documentation
- `flutter_layout_grid` for grid layout functionality
- `flutter_hooks` for state management
- `undo` package for undo/redo functionality

## Testing

Run tests with:
```bash
fvm flutter test
```

Run analysis with:
```bash
fvm flutter analyze
```