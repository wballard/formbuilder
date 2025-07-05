import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// Builder function that creates the toolbox representation of a widget
typedef ToolboxWidgetBuilder = Widget Function(BuildContext context);

/// Builder function that creates the actual widget on the grid
typedef GridWidgetBuilder =
    Widget Function(BuildContext context, WidgetPlacement placement);

/// Represents an item that can be dragged from the toolbox onto the form
class ToolboxItem {
  /// Unique identifier for the item
  final String name;

  /// User-friendly display name
  final String displayName;

  /// Builder for the toolbox representation
  final ToolboxWidgetBuilder toolboxBuilder;

  /// Builder for the grid widget
  final GridWidgetBuilder gridBuilder;

  /// Default width in grid columns
  final int defaultWidth;

  /// Default height in grid rows
  final int defaultHeight;

  ToolboxItem({
    required this.name,
    required this.displayName,
    required this.toolboxBuilder,
    required this.gridBuilder,
    required this.defaultWidth,
    required this.defaultHeight,
  }) : assert(name.isNotEmpty, 'Name cannot be empty'),
       assert(displayName.isNotEmpty, 'Display name cannot be empty'),
       assert(defaultWidth >= 1, 'Default width must be at least 1'),
       assert(defaultHeight >= 1, 'Default height must be at least 1');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolboxItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          displayName == other.displayName &&
          toolboxBuilder == other.toolboxBuilder &&
          gridBuilder == other.gridBuilder &&
          defaultWidth == other.defaultWidth &&
          defaultHeight == other.defaultHeight;

  @override
  int get hashCode =>
      name.hashCode ^
      displayName.hashCode ^
      toolboxBuilder.hashCode ^
      gridBuilder.hashCode ^
      defaultWidth.hashCode ^
      defaultHeight.hashCode;

  @override
  String toString() {
    return 'ToolboxItem(name: $name, displayName: $displayName, '
        'defaultWidth: $defaultWidth, defaultHeight: $defaultHeight)';
  }
}

/// Manages a collection of toolbox items
class Toolbox {
  final List<ToolboxItem> items;

  Toolbox({required List<ToolboxItem> items})
    : items = List.unmodifiable(items) {
    // Validate unique names
    final names = items.map((item) => item.name).toSet();
    if (names.length != items.length) {
      throw ArgumentError('Toolbox items must have unique names');
    }
  }

  /// Gets an item by name, returns null if not found
  ToolboxItem? getItem(String name) {
    try {
      return items.firstWhere((item) => item.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Creates a toolbox with default form widgets
  factory Toolbox.withDefaults() {
    return Toolbox(
      items: [
        ToolboxItem(
          name: 'text_input',
          displayName: 'Text Input',
          toolboxBuilder: (context) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.text_fields, size: 20),
                  const SizedBox(width: 8),
                  Text('Text Input'),
                ],
              ),
            );
          },
          gridBuilder: (context, placement) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(4),
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text('Text Input', style: TextStyle(fontSize: 12)),
              ),
            );
          },
          defaultWidth: 2,
          defaultHeight: 1,
        ),
        ToolboxItem(
          name: 'button',
          displayName: 'Button',
          toolboxBuilder: (context) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_button, size: 20, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Text('Button', style: TextStyle(color: theme.colorScheme.onPrimary)),
                ],
              ),
            );
          },
          gridBuilder: (context, placement) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'Button',
                  style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12),
                ),
              ),
            );
          },
          defaultWidth: 2,
          defaultHeight: 1,
        ),
        ToolboxItem(
          name: 'label',
          displayName: 'Label',
          toolboxBuilder: (context) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_outline, size: 20),
                  const SizedBox(width: 8),
                  Text('Label'),
                ],
              ),
            );
          },
          gridBuilder: (context, placement) => Container(
            padding: const EdgeInsets.all(4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Label', style: TextStyle(fontSize: 14)),
            ),
          ),
          defaultWidth: 2,
          defaultHeight: 1,
        ),
        ToolboxItem(
          name: 'checkbox',
          displayName: 'Checkbox',
          toolboxBuilder: (context) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_box_outline_blank, size: 20),
                  const SizedBox(width: 8),
                  Text('Checkbox'),
                ],
              ),
            );
          },
          gridBuilder: (context, placement) => Container(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Icon(Icons.check_box_outline_blank, size: 20),
                const SizedBox(width: 8),
                Text('Checkbox', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          defaultWidth: 2,
          defaultHeight: 1,
        ),
        ToolboxItem(
          name: 'dropdown',
          displayName: 'Dropdown',
          toolboxBuilder: (context) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_drop_down, size: 20),
                  const SizedBox(width: 8),
                  Text('Dropdown'),
                ],
              ),
            );
          },
          gridBuilder: (context, placement) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Dropdown', style: TextStyle(fontSize: 12)),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            );
          },
          defaultWidth: 2,
          defaultHeight: 1,
        ),
        ToolboxItem(
          name: 'radio_group',
          displayName: 'Radio Group',
          toolboxBuilder: (context) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radio_button_unchecked, size: 20),
                  const SizedBox(width: 8),
                  Text('Radio Group'),
                ],
              ),
            );
          },
          gridBuilder: (context, placement) => Container(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radio_button_unchecked, size: 16),
                    const SizedBox(width: 4),
                    Text('Option 1', style: TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radio_button_unchecked, size: 16),
                    const SizedBox(width: 4),
                    Text('Option 2', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          defaultWidth: 2,
          defaultHeight: 2,
        ),
        ToolboxItem(
          name: 'textarea',
          displayName: 'Text Area',
          toolboxBuilder: (context) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notes, size: 20),
                  const SizedBox(width: 8),
                  Text('Text Area'),
                ],
              ),
            );
          },
          gridBuilder: (context, placement) {
            final theme = Theme.of(context);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              padding: const EdgeInsets.all(4),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Text Area',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            );
          },
          defaultWidth: 3,
          defaultHeight: 3,
        ),
      ],
    );
  }
}