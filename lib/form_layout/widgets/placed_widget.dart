import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// A widget that renders a placed widget on the grid with interaction states
class PlacedWidget extends StatefulWidget {
  /// The placement information for this widget
  final WidgetPlacement placement;
  
  /// The child widget to display
  final Widget child;
  
  /// Callback when the widget is tapped
  final VoidCallback? onTap;
  
  /// Whether this widget is currently selected
  final bool isSelected;
  
  /// Whether this widget is being dragged
  final bool isDragging;
  
  /// Padding around the content
  final EdgeInsets contentPadding;

  const PlacedWidget({
    super.key,
    required this.placement,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.isDragging = false,
    this.contentPadding = const EdgeInsets.all(8),
  });

  @override
  State<PlacedWidget> createState() => _PlacedWidgetState();
}

class _PlacedWidgetState extends State<PlacedWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux
    );
    
    // Calculate elevation based on state
    double elevation = 2.0;
    if (_isHovering && isDesktop) {
      elevation = 4.0;
    }
    
    // Build the content
    Widget content = Padding(
      padding: widget.contentPadding,
      child: widget.child,
    );
    
    // Wrap in Material for elevation and ink effects
    content = Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(4),
      color: Colors.white,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            border: widget.isSelected
                ? Border.all(
                    color: theme.primaryColor,
                    width: 2.0,
                  )
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: content,
        ),
      ),
    );
    
    // Apply dragging opacity
    if (widget.isDragging) {
      content = Opacity(
        opacity: 0.5,
        child: content,
      );
    }
    
    // Add mouse region for desktop hover effects
    if (isDesktop) {
      content = MouseRegion(
        cursor: SystemMouseCursors.move,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: content,
      );
    }
    
    return content;
  }
}