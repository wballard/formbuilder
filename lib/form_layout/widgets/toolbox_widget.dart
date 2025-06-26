import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';

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

  const ToolboxWidget({
    super.key,
    required this.toolbox,
    this.direction = Axis.vertical,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        direction: direction,
        spacing: spacing,
        runSpacing: spacing,
        children: toolbox.items.map((item) => _buildToolboxItem(context, item)).toList(),
      ),
    );
  }

  /// Builds a single toolbox item with Material Design styling
  Widget _buildToolboxItem(BuildContext context, ToolboxItem item) {
    return _HoverableCard(
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
                padding: const EdgeInsets.all(8),
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
                padding: const EdgeInsets.all(8),
                child: Text(
                  item.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: _isHovered ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}