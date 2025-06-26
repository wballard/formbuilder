import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// Enum representing different resize handle positions
enum ResizeHandleType {
  topLeft,
  top,
  topRight,
  left,
  right,
  bottomLeft,
  bottom,
  bottomRight,
}

/// Data class for resize operations
class ResizeData {
  /// The ID of the widget being resized
  final String widgetId;
  
  /// The type of resize handle being dragged
  final ResizeHandleType handleType;
  
  /// The original placement before resize
  final WidgetPlacement startPlacement;

  const ResizeData({
    required this.widgetId,
    required this.handleType,
    required this.startPlacement,
  });
}

/// Extension to get the appropriate cursor for each handle type
extension ResizeHandleTypeCursor on ResizeHandleType {
  SystemMouseCursor get cursor {
    switch (this) {
      case ResizeHandleType.topLeft:
      case ResizeHandleType.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeHandleType.topRight:
      case ResizeHandleType.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case ResizeHandleType.top:
      case ResizeHandleType.bottom:
        return SystemMouseCursors.resizeUpDown;
      case ResizeHandleType.left:
      case ResizeHandleType.right:
        return SystemMouseCursors.resizeLeftRight;
    }
  }
}

/// A resize handle widget that can be dragged to resize the parent widget
class ResizeHandle extends StatefulWidget {
  /// The type of resize handle
  final ResizeHandleType type;
  
  /// The widget placement data
  final WidgetPlacement placement;
  
  /// Callback when resize starts
  final void Function(ResizeData)? onResizeStart;
  
  /// Callback when resize updates
  final void Function(ResizeData, Offset delta)? onResizeUpdate;
  
  /// Callback when resize ends
  final void Function()? onResizeEnd;

  const ResizeHandle({
    super.key,
    required this.type,
    required this.placement,
    this.onResizeStart,
    this.onResizeUpdate,
    this.onResizeEnd,
  });

  @override
  State<ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return _buildPositionedHandle(theme);
  }

  /// Build positioned handle based on type
  Widget _buildPositionedHandle(ThemeData theme) {
    const handleSize = 16.0;
    const offset = handleSize / 2;

    final handleWidget = MouseRegion(
      cursor: widget.type.cursor,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Draggable<ResizeData>(
        data: ResizeData(
          widgetId: widget.placement.id,
          handleType: widget.type,
          startPlacement: widget.placement,
        ),
        feedback: _buildHandle(theme, isActive: true),
        childWhenDragging: _buildHandle(theme, isActive: true),
        onDragStarted: () {
          widget.onResizeStart?.call(ResizeData(
            widgetId: widget.placement.id,
            handleType: widget.type,
            startPlacement: widget.placement,
          ));
        },
        onDragUpdate: (details) {
          widget.onResizeUpdate?.call(
            ResizeData(
              widgetId: widget.placement.id,
              handleType: widget.type,
              startPlacement: widget.placement,
            ),
            details.delta,
          );
        },
        onDragEnd: (_) {
          widget.onResizeEnd?.call();
        },
        child: _buildHandle(theme, isActive: _isHovering),
      ),
    );

    switch (widget.type) {
      case ResizeHandleType.topLeft:
        return Positioned(
          top: -offset,
          left: -offset,
          child: handleWidget,
        );
      case ResizeHandleType.top:
        return Positioned(
          top: -offset,
          left: 0,
          right: 0,
          child: Center(child: handleWidget),
        );
      case ResizeHandleType.topRight:
        return Positioned(
          top: -offset,
          right: -offset,
          child: handleWidget,
        );
      case ResizeHandleType.left:
        return Positioned(
          top: 0,
          bottom: 0,
          left: -offset,
          child: Center(child: handleWidget),
        );
      case ResizeHandleType.right:
        return Positioned(
          top: 0,
          bottom: 0,
          right: -offset,
          child: Center(child: handleWidget),
        );
      case ResizeHandleType.bottomLeft:
        return Positioned(
          bottom: -offset,
          left: -offset,
          child: handleWidget,
        );
      case ResizeHandleType.bottom:
        return Positioned(
          bottom: -offset,
          left: 0,
          right: 0,
          child: Center(child: handleWidget),
        );
      case ResizeHandleType.bottomRight:
        return Positioned(
          bottom: -offset,
          right: -offset,
          child: handleWidget,
        );
    }
  }

  /// Build the visual handle widget
  Widget _buildHandle(ThemeData theme, {required bool isActive}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isActive 
            ? theme.primaryColor 
            : theme.primaryColor.withValues(alpha: 0.7),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}