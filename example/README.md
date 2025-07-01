# FormBuilder Example & Storybook

This directory contains both the interactive storybook showcase and usage examples for the FormBuilder widget.

## Running the Examples

### Interactive Storybook (Default)
The comprehensive storybook with all components, features, and demonstrations:

```bash
flutter run
# or
flutter run -t lib/main.dart
```

### Simple Usage Example
A basic example showing how to use the FormBuilder widget:

```bash
flutter run -t lib/main_simple.dart
```

## Structure

- `lib/main.dart` - Entry point for the storybook app
- `lib/main_simple.dart` - Simple usage example 
- `lib/storybook_app.dart` - Storybook application configuration
- `lib/form_layout_example.dart` - Comprehensive FormBuilder usage example
- `lib/stories/` - Storybook stories organized by category:
  - `components/` - Individual widget demonstrations
  - `features/` - Interactive feature demos (drag/drop, resize, etc.)
  - `layouts/` - Common form layout patterns
  - `themes/` - Visual customization examples
  - `integration/` - Complete implementation examples
  - `playground/` - Interactive form builder
  - `use_cases/` - Real-world application examples
  - `performance/` - Performance testing and optimization
  - `documentation/` - Guides and API documentation

## Key Features Demonstrated

- **Drag and Drop**: Move widgets from toolbox to grid and between grid positions
- **Resize**: Adjust widget sizes with resize handles
- **Undo/Redo**: Full history management
- **Keyboard Navigation**: Accessible navigation and manipulation
- **Preview Mode**: See forms as end users would
- **Themes**: Light/dark themes and customization
- **Performance**: Optimization techniques for large forms
- **Accessibility**: Screen reader support and keyboard navigation

## Quick Start

1. Install dependencies: `flutter pub get`
2. Run the storybook: `flutter run`
3. Explore the different categories in the sidebar
4. Try the Playground section for full interactive experience

The storybook provides an excellent way to understand the FormBuilder capabilities before integrating it into your own projects.