import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/animated_grid_widget.dart';
import 'package:formbuilder/form_layout/utils/accessibility_utils.dart';
import 'dart:math';

/// An accessible grid widget with semantics and keyboard navigation
class AccessibleGridWidget extends StatefulWidget {
  /// The grid dimensions
  final GridDimensions dimensions;

  /// Color for the grid lines
  final Color lineColor;

  /// Width of the grid lines
  final double lineWidth;

  /// Background color
  final Color backgroundColor;

  /// Cells to highlight
  final Set<Point<int>>? highlightedCells;

  /// Color for highlighted cells
  final Color? highlightColor;

  /// Function to determine if a cell is valid
  final bool Function(Point<int>)? isCellValid;

  /// Animation settings
  final AnimationSettings animationSettings;

  /// Whether to show grid lines (for preview mode)
  final bool showGridLines;

  /// Callback when a cell is selected via keyboard
  final void Function(Point<int>)? onCellSelected;

  AccessibleGridWidget({
    super.key,
    required this.dimensions,
    Color? lineColor,
    this.lineWidth = 1.0,
    this.backgroundColor = Colors.transparent,
    this.highlightedCells,
    this.highlightColor,
    this.isCellValid,
    this.animationSettings = const AnimationSettings(),
    this.showGridLines = true,
    this.onCellSelected,
  }) : lineColor = lineColor ?? Colors.transparent;

  @override
  State<AccessibleGridWidget> createState() => _AccessibleGridWidgetState();
}

class _AccessibleGridWidgetState extends State<AccessibleGridWidget> {
  final FocusNode _gridFocusNode = FocusNode();
  Point<int>? _focusedCell;
  bool _isGridFocused = false;

  @override
  void initState() {
    super.initState();
    _gridFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _gridFocusNode.removeListener(_handleFocusChange);
    _gridFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isGridFocused = _gridFocusNode.hasFocus;
      if (_isGridFocused && _focusedCell == null) {
        // Start at top-left when first focused
        _focusedCell = const Point(0, 0);
        _announceCurrentCell();
      } else if (!_isGridFocused) {
        _focusedCell = null;
      }
    });
  }

  /// Handle keyboard navigation within the grid
  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || _focusedCell == null) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    Point<int>? newCell;

    if (key == LogicalKeyboardKey.arrowLeft && _focusedCell!.x > 0) {
      newCell = Point(_focusedCell!.x - 1, _focusedCell!.y);
    } else if (key == LogicalKeyboardKey.arrowRight &&
        _focusedCell!.x < widget.dimensions.columns - 1) {
      newCell = Point(_focusedCell!.x + 1, _focusedCell!.y);
    } else if (key == LogicalKeyboardKey.arrowUp && _focusedCell!.y > 0) {
      newCell = Point(_focusedCell!.x, _focusedCell!.y - 1);
    } else if (key == LogicalKeyboardKey.arrowDown &&
        _focusedCell!.y < widget.dimensions.rows - 1) {
      newCell = Point(_focusedCell!.x, _focusedCell!.y + 1);
    }

    if (newCell != null) {
      setState(() {
        _focusedCell = newCell;
      });
      _announceCurrentCell();
      return KeyEventResult.handled;
    }

    // Enter/Space to select cell
    if ((key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) &&
        widget.onCellSelected != null) {
      widget.onCellSelected!(_focusedCell!);
      AccessibilityUtils.announceStatus(
        context,
        'Cell selected at column ${_focusedCell!.x + 1}, row ${_focusedCell!.y + 1}',
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _announceCurrentCell() {
    if (_focusedCell == null) return;

    final cellLabel = AccessibilityUtils.getGridCellLabel(
      _focusedCell!.x,
      _focusedCell!.y,
    );

    // Check if cell is occupied
    final isOccupied = widget.highlightedCells?.contains(_focusedCell) ?? false;
    final isValid = widget.isCellValid?.call(_focusedCell!) ?? true;

    String status = cellLabel;
    if (isOccupied) {
      status += isValid ? '. Cell occupied' : '. Cell invalid';
    } else {
      status += '. Cell empty';
    }

    AccessibilityUtils.announceStatus(context, status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor = widget.lineColor != Colors.transparent 
        ? widget.lineColor 
        : theme.dividerColor;
    
    // Calculate highlighted cells including focused cell
    Set<Point<int>>? allHighlightedCells = widget.highlightedCells;
    if (_isGridFocused && _focusedCell != null) {
      allHighlightedCells = {...allHighlightedCells ?? {}, _focusedCell!};
    }

    // Determine highlight color for focused cell
    Color? effectiveHighlightColor = widget.highlightColor;
    if (_isGridFocused &&
        _focusedCell != null &&
        !(widget.highlightedCells?.contains(_focusedCell) ?? false)) {
      // Use a different color for keyboard focus
      effectiveHighlightColor = Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2);
    }

    return Focus(
      focusNode: _gridFocusNode,
      onKeyEvent: (node, event) => _handleKeyEvent(event),
      child: Semantics(
        label: 'Form layout grid',
        hint:
            'Use arrow keys to navigate cells. ${widget.dimensions.columns} columns by ${widget.dimensions.rows} rows',
        textField: false,
        container: true,
        child: GestureDetector(
          onTap: () {
            // Request focus when tapped
            _gridFocusNode.requestFocus();
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              if (!_isGridFocused) {
                _gridFocusNode.requestFocus();
              }
            },
            child: AnimatedGridWidget(
              dimensions: widget.dimensions,
              lineColor: effectiveLineColor,
              lineWidth: widget.lineWidth,
              backgroundColor: widget.backgroundColor,
              highlightedCells: allHighlightedCells,
              highlightColor: effectiveHighlightColor,
              isCellValid: (cell) {
                if (_focusedCell != null && cell == _focusedCell) {
                  // Focused cell is always valid for highlighting
                  return true;
                }
                return widget.isCellValid?.call(cell) ?? true;
              },
              animationSettings: widget.animationSettings,
              showGridLines: widget.showGridLines,
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible grid container that provides proper semantics for the entire grid area
class AccessibleGridSemantics extends StatelessWidget {
  /// The child widget (usually the grid container)
  final Widget child;

  /// The grid dimensions
  final GridDimensions dimensions;

  /// Number of placed widgets
  final int placedWidgetCount;

  /// Whether in preview mode
  final bool isPreviewMode;

  const AccessibleGridSemantics({
    super.key,
    required this.child,
    required this.dimensions,
    required this.placedWidgetCount,
    this.isPreviewMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final gridDescription =
        'Form layout grid with ${dimensions.columns} columns '
        'and ${dimensions.rows} rows. '
        '${placedWidgetCount == 0 ? "No widgets placed" : "$placedWidgetCount widget${placedWidgetCount == 1 ? "" : "s"} placed"}. '
        '${isPreviewMode ? "Preview mode active" : "Edit mode active"}';

    return Semantics(
      label: gridDescription,
      container: true,
      liveRegion: true,
      child: child,
    );
  }
}
