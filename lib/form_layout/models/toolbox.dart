import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// A category of toolbox items for organization
@immutable
class ToolboxCategory {
  /// The name of this category
  final String name;

  /// The items in this category
  final List<ToolboxItem> items;

  const ToolboxCategory({required this.name, required this.items});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolboxCategory &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          listEquals(items, other.items);

  @override
  int get hashCode => name.hashCode ^ items.hashCode;
}

/// An organized toolbox with categories of items
@immutable
class CategorizedToolbox {
  /// The categories in this toolbox
  final List<ToolboxCategory> categories;

  const CategorizedToolbox({required this.categories});

  /// Gets all items from all categories as a flat list
  List<ToolboxItem> get allItems {
    return categories.expand((category) => category.items).toList();
  }

  /// Gets widget builders for all items
  Map<String, Widget Function(BuildContext, WidgetPlacement)>
  get widgetBuilders {
    final builders = <String, Widget Function(BuildContext, WidgetPlacement)>{};
    for (final category in categories) {
      for (final item in category.items) {
        builders[item.name] = item.gridBuilder;
      }
    }
    return builders;
  }

  /// Finds an item by name across all categories
  ToolboxItem? findItem(String name) {
    for (final category in categories) {
      final item = category.items
          .where((item) => item.name == name)
          .firstOrNull;
      if (item != null) return item;
    }
    return null;
  }

  /// Creates a simple toolbox from the categorized toolbox
  Toolbox toSimpleToolbox() {
    return Toolbox(items: allItems);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorizedToolbox &&
          runtimeType == other.runtimeType &&
          listEquals(categories, other.categories);

  @override
  int get hashCode => categories.hashCode;
}
