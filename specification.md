# FormLayout Specification

FormLayout is a Flutter widget that allows drag and drop grid layout of Widget to create customizable Forms.

## Technology

- Use storybook_flutter https://pub.dev/packages/storybook_flutter
- Use flutter_layout_grid https://pub.dev/packages/flutter_layout_grid

## Standards

Create thoughful and easy to use Flutter Widgets following Material Design.

Search the web for inspiration of drag and drop form builders.

Look at high quality widgets such as https://github.com/imaNNeo/fl_chart for project structure and API ideas.

Think deeply about the properties to pass to the constructor.

Think deeply about the Intents each widget will invoke, and how Actions to handle intents. All callbacks `onX` should have a paired Intent.

## Concepts

- Grid: the layout surface to create the form
- Widget: individual components we add to the form
- Toolbox: a collection of named widgets allowed on the form
- Layout: the dimensions of the Grid, named Widgets, and their placement

Expect the programmer to provide the Widgets, including all captions, handling, form field validation.

FormLayout is just about drag and drop layout of widgets, to create a Layout.

## Requirements

### Drag and Drop

As a user, I want to drag and drop Widgets from a Toolbox and arrange them to create a custom form.

### Grid Layout

As a user, I want Widgets to align to the columns of the Grid layout.

### Resize Grid

As a user, I want to be able to drag and resize the number of rows or columns in the layout Grid.

### Resize Widget

As a user I want to be able to drag and resize a Widget in the Grid.

### Move Widget

As a user I want to be able to move a Widget to a different location.

### No Overlapping

As a user I DO NOT want to be able to overlap Widgets. Each widget needs its own set of cells in the grid.

### Delete Widget

As a user I want to be able to delete a Widget from the Grid.

### Undo/Redo

As a user I want to be able to undo and redo my form building actions.

### Form Preview

As a user I want to be able to preview how the form will look and function for end users.

### Widget Types

As a programmer, I want to be able to specify my own named Widgets for the Toolbox.

As a programmer, I expect a builder callback from the Toolbox to provide a Widget, typically an icon, to represent my widget in the Toolbox.

As a programmer, I expect a builder callback from the Layout to provide a Widget that is the actual on the Grid widget.

### Grid Indicators

As a user I want visual indicators showing the grid structure, widget boundaries, and drop zones during drag operations.

### Keyboard Navigation

As a user I want to be able to navigate and modify the form using keyboard shortcuts for accessibility.

### Form State

As a programmer, I expect an onFormChanged callback that provides be the current Layout.
