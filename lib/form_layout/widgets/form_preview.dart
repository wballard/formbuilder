import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// Widget that renders a form in preview mode without editing capabilities
class FormPreview extends StatelessWidget {
  /// The current layout state to preview
  final LayoutState layoutState;

  /// Map of widget builders by widget name
  final Map<String, Widget Function(BuildContext, WidgetPlacement)>
  widgetBuilders;

  /// Background color for preview mode
  final Color? backgroundColor;

  /// Whether to show a preview mode indicator
  final bool showPreviewIndicator;

  const FormPreview({
    super.key,
    required this.layoutState,
    required this.widgetBuilders,
    this.backgroundColor,
    this.showPreviewIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Stack(
        children: [
          // Clean form layout without editing UI
          LayoutGrid(
            areas: _generateAreas(),
            columnSizes: List.generate(
              layoutState.dimensions.columns,
              (_) => 1.fr,
            ),
            rowSizes: List.generate(layoutState.dimensions.rows, (_) => 1.fr),
            columnGap: 8,
            rowGap: 8,
            children: _buildPreviewWidgets(context),
          ),
          // Preview mode indicator
          if (showPreviewIndicator)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Preview Mode',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
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

  /// Build widgets for preview (without editing UI)
  List<Widget> _buildPreviewWidgets(BuildContext context) {
    return layoutState.widgets.map((placement) {
      // Get the widget builder
      final widgetBuilder = widgetBuilders[placement.widgetName];

      // Create child widget or error widget
      final child = widgetBuilder != null
          ? widgetBuilder(context, placement)
          : _buildErrorWidget(placement.widgetName);

      // Wrap in a simple container without editing controls
      return Container(
        padding: const EdgeInsets.all(4),
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

    // For multi-cell widgets, create a span area name
    final startRow = placement.row;
    final endRow = placement.row + placement.height - 1;
    final startCol = placement.column;
    final endCol = placement.column + placement.width - 1;

    return 'span_${startRow}_${startCol}_${endRow}_$endCol';
  }

  /// Build error widget for missing widget types
  Widget _buildErrorWidget(String widgetName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
          const SizedBox(height: 4),
          Text(
            'Unknown widget: $widgetName',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
