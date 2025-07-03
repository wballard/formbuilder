import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/animated_drag_feedback.dart';

/// A widget that displays a categorized toolbox with expandable sections
class CategorizedToolboxWidget extends StatefulWidget {
  /// The categorized toolbox to display
  final CategorizedToolbox toolbox;

  /// The scroll direction for the toolbox
  final Axis scrollDirection;

  /// Padding around the toolbox
  final EdgeInsets padding;

  /// Spacing between categories
  final double categorySpacing;

  /// Spacing between items
  final double itemSpacing;

  /// Animation settings
  final AnimationSettings animationSettings;

  const CategorizedToolboxWidget({
    super.key,
    required this.toolbox,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(8),
    this.categorySpacing = 8.0,
    this.itemSpacing = 8.0,
    this.animationSettings = const AnimationSettings(),
  });

  @override
  State<CategorizedToolboxWidget> createState() =>
      _CategorizedToolboxWidgetState();
}

class _CategorizedToolboxWidgetState extends State<CategorizedToolboxWidget> {
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    // Expand all categories by default
    for (final category in widget.toolbox.categories) {
      _expandedCategories.add(category.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scrollDirection == Axis.vertical) {
      return ListView(
        padding: widget.padding,
        children: _buildCategories(context),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildCategories(context),
        ),
      );
    }
  }

  List<Widget> _buildCategories(BuildContext context) {
    final widgets = <Widget>[];

    for (int i = 0; i < widget.toolbox.categories.length; i++) {
      final category = widget.toolbox.categories[i];
      final isExpanded = _expandedCategories.contains(category.name);

      if (i > 0) {
        widgets.add(
          SizedBox(
            width: widget.scrollDirection == Axis.horizontal
                ? widget.categorySpacing
                : null,
            height: widget.scrollDirection == Axis.vertical
                ? widget.categorySpacing
                : null,
          ),
        );
      }

      widgets.add(_buildCategory(context, category, isExpanded));
    }

    return widgets;
  }

  Widget _buildCategory(
    BuildContext context,
    ToolboxCategory category,
    bool isExpanded,
  ) {
    final theme = Theme.of(context);

    if (widget.scrollDirection == Axis.vertical) {
      return ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedCategories.add(category.name);
            } else {
              _expandedCategories.remove(category.name);
            }
          });
        },
        title: Text(
          category.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: category.items
            .map((item) => _buildListItem(context, item))
            .toList(),
      );
    } else {
      // Horizontal layout
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.name, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: category.items
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(right: widget.itemSpacing),
                        child: _buildItem(context, item),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildListItem(BuildContext context, ToolboxItem item) {
    return Draggable<ToolboxItem>(
      data: item,
      feedback: AnimatedDragFeedback(
        animationSettings: widget.animationSettings,
        child: Material(
          elevation: 8,
          child: Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListTile(
              leading: SizedBox(
                width: 32,
                height: 32,
                child: item.toolboxBuilder(context),
              ),
              title: Text(item.displayName),
            ),
          ),
        ),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 32,
          height: 32,
          child: item.toolboxBuilder(context),
        ),
        title: Text(
          item.displayName,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        onTap: () {
          // Could show item details or initiate drag programmatically
        },
        tileColor: Theme.of(context).colorScheme.surface,
        hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildItem(BuildContext context, ToolboxItem item) {
    // Keep the old method for horizontal layout
    return SizedBox(
      width: 80,
      height: 80,
      child: Draggable<ToolboxItem>(
        data: item,
        feedback: AnimatedDragFeedback(
          animationSettings: widget.animationSettings,
          child: Material(
            elevation: 8,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: item.toolboxBuilder(context),
            ),
          ),
        ),
        child: Card(
          child: InkWell(
            onTap: () {
              // Could show item details
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: item.toolboxBuilder(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    item.displayName,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
