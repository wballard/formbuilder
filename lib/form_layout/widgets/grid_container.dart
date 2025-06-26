import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'dart:math';

/// Container that combines GridWidget with PlacedWidgets
class GridContainer extends StatelessWidget {
  /// The current layout state
  final LayoutState layoutState;
  
  /// Map of widget builders by widget name
  final Map<String, Widget> widgetBuilders;
  
  /// ID of the currently selected widget
  final String? selectedWidgetId;
  
  /// IDs of widgets being dragged
  final Set<String> draggingWidgetIds;
  
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

  const GridContainer({
    super.key,
    required this.layoutState,
    required this.widgetBuilders,
    this.selectedWidgetId,
    this.draggingWidgetIds = const {},
    this.highlightedCells,
    this.highlightColor,
    this.isCellValid,
    this.onWidgetTap,
    this.canDragWidgets = true,
    this.onWidgetDragStarted,
    this.onWidgetDragEnd,
    this.onWidgetDragCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid background
        GridWidget(
          dimensions: layoutState.dimensions,
          highlightedCells: highlightedCells,
          highlightColor: highlightColor,
          isCellValid: isCellValid,
        ),
        // Placed widgets overlay
        LayoutGrid(
          areas: _generateAreas(),
          columnSizes: List.generate(
            layoutState.dimensions.columns,
            (_) => 1.fr,
          ),
          rowSizes: List.generate(
            layoutState.dimensions.rows,
            (_) => 1.fr,
          ),
          columnGap: 0,
          rowGap: 0,
          children: _buildPlacedWidgets(context),
        ),
      ],
    );
  }

  /// Generate area names for the grid
  String _generateAreas() {
    final buffer = StringBuffer();
    for (int row = 0; row < layoutState.dimensions.rows; row++) {
      if (row > 0) buffer.write('\n');
      for (int col = 0; col < layoutState.dimensions.columns; col++) {
        if (col > 0) buffer.write(' ');
        buffer.write('cell_${row}_$col');
      }
    }
    return buffer.toString();
  }

  /// Build the placed widgets
  List<Widget> _buildPlacedWidgets(BuildContext context) {
    return layoutState.widgets.map((placement) {
      // Get the widget builder
      final widgetBuilder = widgetBuilders[placement.widgetName];
      
      // Create child widget or error widget
      final child = widgetBuilder ?? _buildErrorWidget(placement.widgetName);
      
      // Wrap in PlacedWidget
      return PlacedWidget(
        placement: placement,
        isSelected: selectedWidgetId == placement.id,
        isDragging: draggingWidgetIds.contains(placement.id),
        canDrag: canDragWidgets,
        onTap: onWidgetTap != null ? () => onWidgetTap!(placement.id) : null,
        onDragStarted: onWidgetDragStarted,
        onDragEnd: onWidgetDragEnd,
        onDragCompleted: onWidgetDragCompleted,
        child: child,
      ).inGridArea(_getAreaName(placement));
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
    for (int row = placement.row; row < placement.row + placement.height; row++) {
      for (int col = placement.column; col < placement.column + placement.width; col++) {
        cells.add('cell_${row}_$col');
      }
    }
    return cells.join(' ');
  }

  /// Build an error widget for missing widget builders
  Widget _buildErrorWidget(String widgetName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              widgetName,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}