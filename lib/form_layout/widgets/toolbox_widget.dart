import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

/// A widget that displays a collection of draggable toolbox items
class ToolboxWidget extends StatelessWidget {
  /// The toolbox containing the items to display
  final Toolbox toolbox;

  /// The direction to lay out the items
  final Axis direction;

  /// Spacing between items
  final double spacing;

  /// Padding around the widget
  final EdgeInsets padding;

  /// Callback when drag starts with the item being dragged
  final void Function(ToolboxItem)? onDragStarted;

  /// Callback when drag ends
  final void Function()? onDragEnd;

  /// Callback when drag is completed
  final void Function()? onDragCompleted;

  const ToolboxWidget({
    super.key,
    required this.toolbox,
    this.direction = Axis.vertical,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(8),
    this.onDragStarted,
    this.onDragEnd,
    this.onDragCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        direction: direction,
        spacing: spacing,
        runSpacing: spacing,
        children: toolbox.items
            .map((item) => _buildToolboxItem(context, item))
            .toList(),
      ),
    );
  }

  /// Builds a single toolbox item with themed styling
  Widget _buildToolboxItem(BuildContext context, ToolboxItem item) {
    final formTheme = FormLayoutTheme.of(context);

    final widget = _HoverableCard(
      child: Tooltip(
        message: item.displayName,
        child: SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Widget preview container with fixed size
              Container(
                width: 100,
                height: 100,
                padding: formTheme.defaultPadding,
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: 84, // 100 - 16 (padding)
                    maxHeight: 84,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: item.toolboxBuilder(context),
                    ),
                  ),
                ),
              ),
              // Item name
              Padding(
                padding: formTheme.defaultPadding,
                child: Text(
                  item.displayName,
                  style: formTheme.labelStyle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return LongPressDraggable<ToolboxItem>(
      data: item,
      feedback: Material(
        elevation: formTheme.elevations * 4, // Higher elevation for feedback
        borderRadius: formTheme.widgetBorderRadius,
        color: Colors.transparent, // Must stay transparent for toolbox drag feedback
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: 100,
            height: 140, // Approximate height including text
            child: widget,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: widget),
      onDragStarted: () => onDragStarted?.call(item),
      onDragEnd: (_) => onDragEnd?.call(),
      onDragCompleted: onDragCompleted,
      child: widget,
    );
  }
}

/// A Card widget that responds to hover with elevation changes
class _HoverableCard extends StatefulWidget {
  final Widget child;

  const _HoverableCard({required this.child});

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final formTheme = FormLayoutTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: _isHovered
              ? formTheme.elevations * 2
              : formTheme.elevations,
          shape: RoundedRectangleBorder(
            borderRadius: formTheme.widgetBorderRadius,
          ),
          color: formTheme.toolboxBackgroundColor,
          child: widget.child,
        ),
      ),
    );
  }
}
