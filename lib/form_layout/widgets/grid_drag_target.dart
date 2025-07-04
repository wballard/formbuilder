import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/widgets/grid_resize_controls.dart';
import 'package:formbuilder/form_layout/widgets/resize_handle.dart';
import 'package:formbuilder/form_layout/widgets/animated_drag_feedback.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';
import 'dart:math';

/// A widget that wraps GridContainer with drag and drop functionality
class GridDragTarget extends StatefulWidget {
  /// The current layout state
  final LayoutState layoutState;

  /// Widget builders for rendering placed widgets
  final Map<String, Widget Function(BuildContext, WidgetPlacement)>
  widgetBuilders;

  /// The toolbox containing available widgets
  final Toolbox toolbox;

  /// Callback when a widget is dropped on the grid
  final void Function(WidgetPlacement)? onWidgetDropped;

  /// Callback when a widget is moved to a new position
  final void Function(String widgetId, WidgetPlacement newPlacement)?
  onWidgetMoved;

  /// Callback when a widget is resized
  final void Function(String widgetId, WidgetPlacement newPlacement)?
  onWidgetResize;

  /// Callback when a widget should be deleted
  final void Function(String widgetId)? onWidgetDelete;

  /// Callback when the grid is resized
  final void Function(GridDimensions)? onGridResize;

  /// ID of the currently selected widget
  final String? selectedWidgetId;

  /// Callback when a widget is tapped
  final void Function(String)? onWidgetTap;

  /// Animation settings for visual feedback
  final AnimationSettings animationSettings;

  const GridDragTarget({
    super.key,
    required this.layoutState,
    required this.widgetBuilders,
    required this.toolbox,
    this.onWidgetDropped,
    this.onWidgetMoved,
    this.onWidgetResize,
    this.onWidgetDelete,
    this.onGridResize,
    this.selectedWidgetId,
    this.onWidgetTap,
    this.animationSettings = const AnimationSettings(),
  });

  @override
  State<GridDragTarget> createState() => _GridDragTargetState();
}

class _GridDragTargetState extends State<GridDragTarget> {
  /// Current highlighted cells during drag
  Set<Point<int>>? _highlightedCells;

  /// Whether the current drag position is valid
  bool _isValidDrop = false;


  /// The widget currently being moved (if any)
  WidgetPlacement? _movingWidget;

  /// The widget currently being resized (if any)
  ResizeData? _resizingWidget;

  /// The new dimensions during resize
  WidgetPlacement? _resizePreview;

  /// The initial position when resize drag started
  Offset? _resizeDragStartPosition;

  /// Convert screen position to grid coordinates
  Point<int>? _getGridCoordinates(Offset globalPosition) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final localPosition = renderBox.globalToLocal(globalPosition);
    
    // Get the theme to access row height
    final theme = FormLayoutTheme.of(context);
    
    // Calculate actual grid size based on intrinsic dimensions
    final gridWidth = renderBox.size.width;
    
    // Calculate cell size using actual grid dimensions
    final cellWidth = gridWidth / widget.layoutState.dimensions.columns;
    final cellHeight = theme.rowHeight;

    // Convert to grid coordinates
    final column = (localPosition.dx / cellWidth).floor();
    final row = (localPosition.dy / cellHeight).floor();

    // Clamp to grid boundaries
    final clampedColumn = column.clamp(
      0,
      widget.layoutState.dimensions.columns - 1,
    );
    final clampedRow = row.clamp(0, widget.layoutState.dimensions.rows - 1);

    return Point(clampedColumn, clampedRow);
  }

  /// Calculate which cells would be occupied by a widget placement
  Set<Point<int>> _getOccupiedCells(
    int column,
    int row,
    int width,
    int height,
  ) {
    final cells = <Point<int>>{};

    for (int r = row; r < row + height; r++) {
      for (int c = column; c < column + width; c++) {
        if (r < widget.layoutState.dimensions.rows &&
            c < widget.layoutState.dimensions.columns) {
          cells.add(Point(c, r));
        }
      }
    }

    return cells;
  }

  /// Check if a placement would be valid (no overlaps, fits in grid)
  bool _isValidPlacement(
    int column,
    int row,
    int width,
    int height, {
    String? excludeWidgetId,
  }) {
    // Check if placement fits in grid
    if (column + width > widget.layoutState.dimensions.columns ||
        row + height > widget.layoutState.dimensions.rows ||
        column < 0 ||
        row < 0) {
      return false;
    }

    // Create temporary placement to check for overlaps
    final tempPlacement = WidgetPlacement(
      id: 'temp',
      widgetName: 'temp',
      column: column,
      row: row,
      width: width,
      height: height,
    );

    // Check if it overlaps with existing widgets (excluding the moving widget)
    for (final existing in widget.layoutState.widgets) {
      if (excludeWidgetId != null && existing.id == excludeWidgetId) {
        continue; // Skip the widget being moved
      }
      if (tempPlacement.overlaps(existing)) {
        return false;
      }
    }

    return true;
  }

  /// Update highlighted cells based on drag position for ToolboxItem
  void _updateHighlightedCells(ToolboxItem item, Offset? dragPosition) {
    if (dragPosition == null) {
      setState(() {
        _highlightedCells = null;
        _isValidDrop = false;
      });
      return;
    }

    final gridCoords = _getGridCoordinates(dragPosition);
    if (gridCoords == null) {
      setState(() {
        _highlightedCells = null;
        _isValidDrop = false;
        });
      return;
    }

    final cells = _getOccupiedCells(
      gridCoords.x,
      gridCoords.y,
      item.defaultWidth,
      item.defaultHeight,
    );

    final isValid = _isValidPlacement(
      gridCoords.x,
      gridCoords.y,
      item.defaultWidth,
      item.defaultHeight,
    );


    setState(() {
      _highlightedCells = cells;
      _isValidDrop = isValid;
      _movingWidget = null; // Clear moving widget for toolbox drags
    });
  }

  /// Update highlighted cells based on drag position for WidgetPlacement
  void _updateHighlightedCellsForWidget(
    WidgetPlacement widget,
    Offset? dragPosition,
  ) {
    if (dragPosition == null) {
      setState(() {
        _highlightedCells = null;
        _isValidDrop = false;
        _movingWidget = null;
      });
      return;
    }

    final gridCoords = _getGridCoordinates(dragPosition);
    if (gridCoords == null) {
      setState(() {
        _highlightedCells = null;
        _isValidDrop = false;
          _movingWidget = widget;
      });
      return;
    }

    final cells = _getOccupiedCells(
      gridCoords.x,
      gridCoords.y,
      widget.width,
      widget.height,
    );

    final isValid = _isValidPlacement(
      gridCoords.x,
      gridCoords.y,
      widget.width,
      widget.height,
      excludeWidgetId: widget.id,
    );

    setState(() {
      _highlightedCells = cells;
      _isValidDrop = isValid;
      _movingWidget = widget;
    });
  }

  /// Calculate new dimensions based on resize handle and drag delta
  WidgetPlacement _calculateResizeDimensions(
    ResizeData resizeData,
    Offset delta,
  ) {
    final startPlacement = resizeData.startPlacement;
    final handleType = resizeData.handleType;

    // Convert delta to grid cell units
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return startPlacement;

    // Get the theme to access row height
    final theme = FormLayoutTheme.of(context);
    
    // Calculate cell dimensions using actual grid dimensions
    final gridWidth = renderBox.size.width;
    final cellWidth = gridWidth / widget.layoutState.dimensions.columns;
    final cellHeight = theme.rowHeight;

    final deltaCellsX = (delta.dx / cellWidth).round();
    final deltaCellsY = (delta.dy / cellHeight).round();

    // Calculate new dimensions based on handle type
    int newColumn = startPlacement.column;
    int newRow = startPlacement.row;
    int newWidth = startPlacement.width;
    int newHeight = startPlacement.height;

    switch (handleType) {
      case ResizeHandleType.topLeft:
        newColumn = startPlacement.column + deltaCellsX;
        newRow = startPlacement.row + deltaCellsY;
        newWidth = startPlacement.width - deltaCellsX;
        newHeight = startPlacement.height - deltaCellsY;
        break;
      case ResizeHandleType.top:
        newRow = startPlacement.row + deltaCellsY;
        newHeight = startPlacement.height - deltaCellsY;
        break;
      case ResizeHandleType.topRight:
        newRow = startPlacement.row + deltaCellsY;
        newWidth = startPlacement.width + deltaCellsX;
        newHeight = startPlacement.height - deltaCellsY;
        break;
      case ResizeHandleType.left:
        newColumn = startPlacement.column + deltaCellsX;
        newWidth = startPlacement.width - deltaCellsX;
        break;
      case ResizeHandleType.right:
        newWidth = startPlacement.width + deltaCellsX;
        break;
      case ResizeHandleType.bottomLeft:
        newColumn = startPlacement.column + deltaCellsX;
        newWidth = startPlacement.width - deltaCellsX;
        newHeight = startPlacement.height + deltaCellsY;
        break;
      case ResizeHandleType.bottom:
        newHeight = startPlacement.height + deltaCellsY;
        break;
      case ResizeHandleType.bottomRight:
        newWidth = startPlacement.width + deltaCellsX;
        newHeight = startPlacement.height + deltaCellsY;
        break;
    }

    // Enforce minimum size (1x1)
    newWidth = newWidth.clamp(1, widget.layoutState.dimensions.columns);
    newHeight = newHeight.clamp(1, widget.layoutState.dimensions.rows);

    // Ensure widget stays within grid bounds
    newColumn = newColumn.clamp(
      0,
      widget.layoutState.dimensions.columns - newWidth,
    );
    newRow = newRow.clamp(0, widget.layoutState.dimensions.rows - newHeight);

    return startPlacement.copyWith(
      column: newColumn,
      row: newRow,
      width: newWidth,
      height: newHeight,
    );
  }

  /// Update highlighted cells for resize operation
  void _updateHighlightedCellsForResize(
    ResizeData resizeData,
    Offset? dragPosition,
  ) {
    if (dragPosition == null) {
      setState(() {
        _highlightedCells = null;
        _isValidDrop = false;
        _resizingWidget = null;
        _resizePreview = null;
        _resizeDragStartPosition = null;
      });
      return;
    }

    // Initialize start position on first drag update
    _resizeDragStartPosition ??= dragPosition;

    // Calculate delta from start position
    final delta = dragPosition - _resizeDragStartPosition!;
    final newPlacement = _calculateResizeDimensions(resizeData, delta);

    final cells = _getOccupiedCells(
      newPlacement.column,
      newPlacement.row,
      newPlacement.width,
      newPlacement.height,
    );

    final isValid = _isValidPlacement(
      newPlacement.column,
      newPlacement.row,
      newPlacement.width,
      newPlacement.height,
      excludeWidgetId: resizeData.widgetId,
    );

    setState(() {
      _highlightedCells = cells;
      _isValidDrop = isValid;
      _resizingWidget = resizeData;
      _resizePreview = newPlacement;
      _movingWidget = null; // Clear moving widget for resize operations
    });
  }

  /// Handle keyboard events for widget deletion
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && widget.selectedWidgetId != null) {
      final isDeleteKey =
          event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace;

      if (isDeleteKey) {
        // Call the direct callback if provided
        widget.onWidgetDelete?.call(widget.selectedWidgetId!);

        // Also invoke the intent for action handling
        Actions.maybeInvoke<RemoveWidgetIntent>(
          context,
          RemoveWidgetIntent(widgetId: widget.selectedWidgetId!),
        );
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // Create the base GridContainer
    final gridContainer = GridContainer(
      layoutState: widget.layoutState,
      widgetBuilders: widget.widgetBuilders,
      selectedWidgetId: widget.selectedWidgetId,
      onWidgetTap: widget.onWidgetTap,
      highlightedCells: _highlightedCells,
      highlightColor: _highlightedCells != null
          ? (_isValidDrop
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.error.withValues(alpha: 0.3))
          : null,
      draggingWidgetIds: _movingWidget != null ? {_movingWidget!.id} : {},
      resizingWidgetIds: _resizingWidget != null
          ? {_resizingWidget!.widgetId}
          : {},
      canDragWidgets: true,
      onWidgetDragStarted: (placement) {
        // Widget drag started - no need to track in GridDragTarget state
      },
      onWidgetDragEnd: () {
        // Widget drag ended - no need to track in GridDragTarget state
      },
      onWidgetDragCompleted: (details) {
        // Widget drag completed - no need to track in GridDragTarget state
      },
      onWidgetResizeStart: (resizeData) {
        setState(() {
          _resizingWidget = resizeData;
          _resizeDragStartPosition = null;
          _resizePreview = null;
        });
      },
      onWidgetResizeUpdate: (resizeData, delta) {
        // The resize handle provides a delta from the drag start position
        // We need to calculate the new placement based on this delta
        final newPlacement = _calculateResizeDimensions(resizeData, delta);
        
        // Get the cells that would be occupied by the resized widget
        final cells = _getOccupiedCells(
          newPlacement.column,
          newPlacement.row,
          newPlacement.width,
          newPlacement.height,
        );
        
        // Check if the new placement is valid
        final isValid = _isValidPlacement(
          newPlacement.column,
          newPlacement.row,
          newPlacement.width,
          newPlacement.height,
          excludeWidgetId: resizeData.widgetId,
        );
        
        // Update the highlighted cells to show resize preview
        setState(() {
          _highlightedCells = cells;
          _isValidDrop = isValid;
          _resizingWidget = resizeData;
          _resizePreview = newPlacement;
        });
      },
      onWidgetResizeEnd: () {
        // Apply the resize if we have a valid preview
        if (_resizePreview != null && _isValidDrop && _resizingWidget != null) {
          // If position changed, we need to move the widget first
          final originalPlacement = _resizingWidget!.startPlacement;
          final needsMove = _resizePreview!.column != originalPlacement.column ||
                           _resizePreview!.row != originalPlacement.row;
          
          if (needsMove) {
            // Move the widget to the new position
            Actions.maybeInvoke<MoveWidgetIntent>(
              context,
              MoveWidgetIntent(
                widgetId: _resizingWidget!.widgetId,
                newPosition: Point(_resizePreview!.column, _resizePreview!.row),
              ),
            );
          }
          
          // Then resize it if size changed
          final needsResize = _resizePreview!.width != originalPlacement.width ||
                             _resizePreview!.height != originalPlacement.height;
          
          if (needsResize) {
            Actions.maybeInvoke<ResizeWidgetIntent>(
              context,
              ResizeWidgetIntent(
                widgetId: _resizingWidget!.widgetId,
                newSize: Size(
                  _resizePreview!.width.toDouble(),
                  _resizePreview!.height.toDouble(),
                ),
              ),
            );
          }
          
          // Use callback approach if provided
          if (widget.onWidgetResize != null) {
            widget.onWidgetResize!(_resizingWidget!.widgetId, _resizePreview!);
          }
        }
        
        // Clear the preview state
        setState(() {
          _highlightedCells = null;
          _isValidDrop = false;
            _resizingWidget = null;
          _resizePreview = null;
          _resizeDragStartPosition = null;
        });
      },
      onWidgetResize: widget.onWidgetResize,
      onWidgetDelete: widget.onWidgetDelete,
    );

    // Stack all drag targets and wrap with Focus for keyboard handling
    final focusedStack = Focus(
      key: const Key('grid_drag_target_focus'),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: AnimatedDropTarget(
        isActive: _highlightedCells != null,
        animationSettings: widget.animationSettings,
        activeScale: 1.0,
        activeColor: null,
        child: Stack(
          children: [
            // Base grid container - must be first to receive normal events
            gridContainer,
            
            // DragTarget for WidgetPlacement (moving existing widgets)
            DragTarget<WidgetPlacement>(
              onWillAcceptWithDetails: (details) {
                // Always return true to keep drag evaluation active
                // Actual validation is handled in onMove and on drop
                final gridCoords = _getGridCoordinates(details.offset);
                if (gridCoords != null) {
                  final isValid = _isValidPlacement(
                    gridCoords.x,
                    gridCoords.y,
                    details.data.width,
                    details.data.height,
                    excludeWidgetId: details.data.id,
                  );
                  debugPrint('GridDragTarget: move valid = $isValid for ${details.data.id} at (${gridCoords.x}, ${gridCoords.y})');
                }
                // Always return true to prevent Flutter from caching a rejection
                return true;
              },
              onAcceptWithDetails: (details) {
                debugPrint('GridDragTarget WidgetPlacement: onAcceptWithDetails called for ${details.data.id}');
                // Use details.offset directly to ensure coordinate consistency
                final gridCoords = _getGridCoordinates(details.offset);
                debugPrint('GridDragTarget WidgetPlacement: gridCoords = $gridCoords');
                if (gridCoords != null) {
                  // Validate the move before actually performing it
                  final isValid = _isValidPlacement(
                    gridCoords.x,
                    gridCoords.y,
                    details.data.width,
                    details.data.height,
                    excludeWidgetId: details.data.id,
                  );
                  
                  if (isValid) {
                    // Use callback approach if provided
                    if (widget.onWidgetMoved != null) {
                      final newPlacement = details.data.copyWith(
                        column: gridCoords.x,
                        row: gridCoords.y,
                      );
                      debugPrint('GridDragTarget WidgetPlacement: calling onWidgetMoved with newPlacement (${newPlacement.column}, ${newPlacement.row})');
                      widget.onWidgetMoved!(details.data.id, newPlacement);
                    } else {
                      // Fall back to Actions if no callback
                      debugPrint('GridDragTarget WidgetPlacement: using Actions fallback');
                      Actions.maybeInvoke<MoveWidgetIntent>(
                        context,
                        MoveWidgetIntent(
                          widgetId: details.data.id,
                          newPosition: Point(gridCoords.x, gridCoords.y),
                        ),
                      );
                    }
                  } else {
                    debugPrint('GridDragTarget: Move rejected - invalid placement at (${gridCoords.x}, ${gridCoords.y})');
                  }
                } else {
                  debugPrint('GridDragTarget WidgetPlacement: Could not calculate grid coordinates from drop position');
                }

                // Clear highlights after drop
                setState(() {
                  _highlightedCells = null;
                  _isValidDrop = false;
                            _movingWidget = null;
                });
              },
              onMove: (details) {
                _updateHighlightedCellsForWidget(details.data, details.offset);
              },
              onLeave: (data) {
                setState(() {
                  _highlightedCells = null;
                  _isValidDrop = false;
                            _movingWidget = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                // Return transparent container that doesn't interfere with hit testing
                return IgnorePointer(
                  child: Container(
                    color: Colors.transparent,
                  ),
                );
              },
            ),

            // DragTarget for ResizeData (resizing existing widgets)
            DragTarget<ResizeData>(
              onWillAcceptWithDetails: (details) {
                // For resize operations, accept if we have valid resize preview
                return _resizePreview != null && _isValidDrop;
              },
              onAcceptWithDetails: (details) {
                if (_resizePreview != null) {
                  Actions.maybeInvoke<ResizeWidgetIntent>(
                    context,
                    ResizeWidgetIntent(
                      widgetId: details.data.widgetId,
                      newSize: Size(
                        _resizePreview!.width.toDouble(),
                        _resizePreview!.height.toDouble(),
                      ),
                    ),
                  );
                }

                // Clear highlights after drop
                setState(() {
                  _highlightedCells = null;
                  _isValidDrop = false;
                            _resizingWidget = null;
                  _resizePreview = null;
                  _resizeDragStartPosition = null;
                });
              },
              onMove: (details) {
                _updateHighlightedCellsForResize(details.data, details.offset);
              },
              onLeave: (data) {
                setState(() {
                  _highlightedCells = null;
                  _isValidDrop = false;
                            _resizingWidget = null;
                  _resizePreview = null;
                  _resizeDragStartPosition = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                // Return transparent container that doesn't interfere with hit testing
                return IgnorePointer(
                  child: Container(
                    color: Colors.transparent,
                  ),
                );
              },
            ),

            // DragTarget for ToolboxItem (new widgets)
            DragTarget<ToolboxItem>(
              onWillAcceptWithDetails: (details) {
                // Always return true to keep drag evaluation active
                // Actual validation is handled in onMove and visual feedback
                final gridCoords = _getGridCoordinates(details.offset);
                if (gridCoords != null) {
                  final isValid = _isValidPlacement(
                    gridCoords.x,
                    gridCoords.y,
                    details.data.defaultWidth,
                    details.data.defaultHeight,
                  );
                  debugPrint('GridDragTarget: placement valid = $isValid for ${details.data.name} at (${gridCoords.x}, ${gridCoords.y})');
                }
                // Always return true to prevent Flutter from caching a rejection
                return true;
              },
              onAcceptWithDetails: (details) {
                // Use details.offset directly to ensure coordinate consistency
                final gridCoords = _getGridCoordinates(details.offset);
                if (gridCoords != null) {
                  // Validate the placement before actually creating the widget
                  final isValid = _isValidPlacement(
                    gridCoords.x,
                    gridCoords.y,
                    details.data.defaultWidth,
                    details.data.defaultHeight,
                  );
                  
                  if (isValid) {
                    // Use callback approach if provided
                    if (widget.onWidgetDropped != null) {
                      final placement = WidgetPlacement(
                        id: '${details.data.name}_${DateTime.now().millisecondsSinceEpoch}',
                        widgetName: details.data.name,
                        column: gridCoords.x,
                        row: gridCoords.y,
                        width: details.data.defaultWidth,
                        height: details.data.defaultHeight,
                        properties: {},
                      );
                      widget.onWidgetDropped!(placement);
                    } else {
                      // Fall back to Actions if no callback
                      Actions.maybeInvoke<AddWidgetIntent>(
                        context,
                        AddWidgetIntent(
                          item: details.data,
                          position: Point(gridCoords.x, gridCoords.y),
                        ),
                      );
                    }
                  } else {
                    debugPrint('GridDragTarget: Drop rejected - invalid placement at (${gridCoords.x}, ${gridCoords.y})');
                  }
                } else {
                  debugPrint('GridDragTarget: Could not calculate grid coordinates from drop position');
                }

                // Clear highlights after drop
                setState(() {
                  _highlightedCells = null;
                  _isValidDrop = false;
                            _movingWidget = null;
                });
              },
              onMove: (details) {
                _updateHighlightedCells(details.data, details.offset);
              },
              onLeave: (data) {
                setState(() {
                  _highlightedCells = null;
                  _isValidDrop = false;
                            _movingWidget = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                // Return transparent container that doesn't interfere with hit testing
                return IgnorePointer(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    // Wrap with grid resize controls
    return GridResizeControls(
      dimensions: widget.layoutState.dimensions,
      onGridResize: widget.onGridResize,
      child: focusedStack,
    );
  }
}
