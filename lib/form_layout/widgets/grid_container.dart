import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';
import 'package:formbuilder/form_layout/widgets/accessible_grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/accessible_placed_widget.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/widgets/safe_hit_test_wrapper.dart';

/// Container that combines GridWidget with PlacedWidgets
class GridContainer extends StatelessWidget {
  /// The current layout state
  final LayoutState layoutState;

  /// Map of widget builders by widget name
  final Map<String, Widget Function(BuildContext, WidgetPlacement)>
  widgetBuilders;

  /// ID of the currently selected widget
  final String? selectedWidgetId;

  /// IDs of widgets being dragged
  final Set<String> draggingWidgetIds;

  /// IDs of widgets being resized
  final Set<String> resizingWidgetIds;

  /// Cells to highlight on the grid
  final Set<Point<int>>? highlightedCells;

  /// Color for highlighted cells
  final Color? highlightColor;

  /// Function to determine if a cell is valid
  final bool Function(Point<int>)? isCellValid;

  /// Callback when a widget is tapped
  final void Function(String widgetId)? onWidgetTap;

  /// Whether widgets can be dragged
  final bool canDragWidgets;

  /// Callback when a widget drag starts
  final void Function(WidgetPlacement)? onWidgetDragStarted;

  /// Callback when a widget drag ends
  final VoidCallback? onWidgetDragEnd;

  /// Callback when a widget drag is completed
  final void Function(DraggableDetails)? onWidgetDragCompleted;

  /// Callback when a widget resize starts
  final void Function(ResizeData)? onWidgetResizeStart;

  /// Callback when a widget resize updates
  final void Function(ResizeData, Offset delta)? onWidgetResizeUpdate;

  /// Callback when a widget resize ends
  final VoidCallback? onWidgetResizeEnd;

  /// Callback when a widget is resized
  final void Function(String widgetId, WidgetPlacement newPlacement)?
  onWidgetResize;

  /// Callback when a widget should be deleted
  final void Function(String widgetId)? onWidgetDelete;

  /// Whether the form is in preview mode (hides editing UI)
  final bool isPreviewMode;

  /// Animation settings
  final AnimationSettings animationSettings;

  const GridContainer({
    super.key,
    required this.layoutState,
    required this.widgetBuilders,
    this.selectedWidgetId,
    this.draggingWidgetIds = const {},
    this.resizingWidgetIds = const {},
    this.highlightedCells,
    this.highlightColor,
    this.isCellValid,
    this.onWidgetTap,
    this.canDragWidgets = true,
    this.onWidgetDragStarted,
    this.onWidgetDragEnd,
    this.onWidgetDragCompleted,
    this.onWidgetResizeStart,
    this.onWidgetResizeUpdate,
    this.onWidgetResizeEnd,
    this.onWidgetResize,
    this.onWidgetDelete,
    this.isPreviewMode = false,
    this.animationSettings = const AnimationSettings(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = FormLayoutTheme.of(context);
    final materialTheme = Theme.of(context);

    // Calculate grid height based on rows
    final gridHeight = layoutState.dimensions.rows * theme.rowHeight;

    return SizedBox(
      height: gridHeight,
      child: AccessibleGridSemantics(
        dimensions: layoutState.dimensions,
        placedWidgetCount: layoutState.widgets.length,
        isPreviewMode: isPreviewMode,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Placed widgets layer
                Positioned.fill(
                  child: LayoutGrid(
                    columnSizes: List.generate(
                      layoutState.dimensions.columns,
                      (_) => 1.fr,
                    ),
                    rowSizes: List.generate(
                      layoutState.dimensions.rows,
                      (_) => FixedTrackSize(theme.rowHeight),
                    ),
                    columnGap: isPreviewMode ? 8 : 0,
                    rowGap: isPreviewMode ? 8 : 0,
                    children: _buildPlacedWidgets(context),
                  ),
                ),
                // Grid lines overlay (only show in edit mode)
                if (!isPreviewMode)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AccessibleGridWidget(
                        dimensions: layoutState.dimensions,
                        lineColor: materialTheme
                            .dividerColor, // Use theme divider color for grid lines
                        lineWidth: 1.5, // Slightly thicker lines
                        highlightedCells: highlightedCells,
                        highlightColor: highlightColor,
                        isCellValid: isCellValid,
                        animationSettings: animationSettings,
                        showGridLines: true,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build the placed widgets
  List<Widget> _buildPlacedWidgets(BuildContext context) {
    return layoutState.widgets.map((placement) {
      // Get the widget builder
      final widgetBuilder = widgetBuilders[placement.widgetName];

      // Create child widget or error widget
      final child = widgetBuilder != null
          ? widgetBuilder(context, placement)
          : _buildErrorWidget(context, placement.widgetName);

      final isSelected = selectedWidgetId == placement.id;
      final isDragging = draggingWidgetIds.contains(placement.id);
      final isResizing = resizingWidgetIds.contains(placement.id);

      // Wrap in PlacedWidget (or simple container in preview mode)
      if (isPreviewMode) {
        return Container(
          padding: const EdgeInsets.all(
            4,
          ), // Keep simple padding for preview mode
          child: child,
        ).withGridPlacement(
          columnStart: placement.column,
          columnSpan: placement.width,
          rowStart: placement.row,
          rowSpan: placement.height,
        );
      } else {
        // Wrap in SafeHitTestWrapper to prevent hit test errors with multi-cell widgets
        return SafeHitTestWrapper(
          child: AccessiblePlacedWidget(
            placement: placement,
            isSelected: isSelected,
            isDragging: isDragging,
            canDrag: canDragWidgets,
            showResizeHandles: isSelected && !isDragging && !isResizing,
            showDeleteButton: isSelected && !isDragging && !isResizing,
            animationSettings: animationSettings,
            onTap: onWidgetTap != null
                ? () => onWidgetTap!(placement.id)
                : null,
            onDelete: onWidgetDelete != null
                ? () => onWidgetDelete!(placement.id)
                : null,
            onDragStarted: onWidgetDragStarted,
            onDragEnd: onWidgetDragEnd,
            onDragCompleted: onWidgetDragCompleted,
            onResizeStart: onWidgetResizeStart,
            onResizeUpdate: onWidgetResizeUpdate,
            onResizeEnd: onWidgetResizeEnd,
            child: child,
          ),
        ).withGridPlacement(
          columnStart: placement.column,
          columnSpan: placement.width,
          rowStart: placement.row,
          rowSpan: placement.height,
        );
      }
    }).toList();
  }

  /// Get the area name for a widget placement
  String _getAreaName(WidgetPlacement placement) {
    // For single cell widgets
    if (placement.width == 1 && placement.height == 1) {
      return 'cell_${placement.row}_${placement.column}';
    }

    // For multi-cell widgets, we need to specify all cells
    final cells = <String>[];
    for (
      int row = placement.row;
      row < placement.row + placement.height;
      row++
    ) {
      for (
        int col = placement.column;
        col < placement.column + placement.width;
        col++
      ) {
        cells.add('cell_${row}_$col');
      }
    }
    return cells.join(' ');
  }

  /// Build an error widget for missing widget builders
  Widget _buildErrorWidget(BuildContext context, String widgetName) {
    final materialTheme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: materialTheme.colorScheme.errorContainer,
        border: Border.all(color: materialTheme.colorScheme.error),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: materialTheme.colorScheme.onErrorContainer,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  widgetName,
                  style: TextStyle(
                    color: materialTheme.colorScheme.onErrorContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
