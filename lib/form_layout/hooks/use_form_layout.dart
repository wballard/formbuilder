import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/utils/commands.dart';

/// Controller for managing form layout state with undo/redo support
class FormLayoutController extends ChangeNotifier {
  LayoutState _state;
  String? _selectedWidgetId;
  final Set<String> _draggingWidgetIds = <String>{};
  final Set<String> _resizingWidgetIds = <String>{};
  bool _isPreviewMode = false;

  // Manual undo/redo implementation
  final List<LayoutState> _undoStack = [];
  final List<LayoutState> _redoStack = [];
  final int _undoLimit;

  FormLayoutController(this._state, {int undoLimit = 50})
    : _undoLimit = undoLimit;

  /// Current layout state
  LayoutState get state => _state;

  /// Currently selected widget ID
  String? get selectedWidgetId => _selectedWidgetId;

  /// Set of widget IDs currently being dragged
  Set<String> get draggingWidgetIds => Set.unmodifiable(_draggingWidgetIds);

  /// Set of widget IDs currently being resized
  Set<String> get resizingWidgetIds => Set.unmodifiable(_resizingWidgetIds);

  /// Whether undo is possible
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether redo is possible
  bool get canRedo => _redoStack.isNotEmpty;

  /// Whether the form is in preview mode
  bool get isPreviewMode => _isPreviewMode;

  /// Execute a command and add it to the undo stack
  void _executeCommand(FormLayoutCommand command) {
    // Save current state to undo stack
    _undoStack.add(_state);

    // Limit undo stack size
    if (_undoStack.length > _undoLimit) {
      _undoStack.removeAt(0);
    }

    // Clear redo stack when new command is executed
    _redoStack.clear();

    try {
      final newState = command.execute(_state);
      _state = newState;
      notifyListeners();
    } catch (e) {
      // If command fails, remove the state we just added
      _undoStack.removeLast();
      rethrow;
    }
  }

  /// Add a widget to the layout
  void addWidget(WidgetPlacement placement) {
    final command = AddWidgetCommand(placement);
    _executeCommand(command);
  }

  /// Remove a widget from the layout
  void removeWidget(String widgetId) {
    final widget = _state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }

    final command = RemoveWidgetCommand(widgetId, widget);
    _executeCommand(command);

    // Clear selection if the removed widget was selected
    if (_selectedWidgetId == widgetId) {
      _selectedWidgetId = null;
    }

    // Clear drag/resize state for the removed widget
    _draggingWidgetIds.remove(widgetId);
    _resizingWidgetIds.remove(widgetId);
  }

  /// Update a widget's placement
  void updateWidget(String widgetId, WidgetPlacement placement) {
    final oldWidget = _state.getWidget(widgetId);
    if (oldWidget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }

    final command = UpdateWidgetCommand(widgetId, oldWidget, placement);
    _executeCommand(command);
  }

  /// Move a widget to a new position
  void moveWidget(String widgetId, int newColumn, int newRow) {
    final widget = _state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }

    final newPlacement = widget.copyWith(column: newColumn, row: newRow);
    final command = MoveWidgetCommand(widgetId, widget, newPlacement);
    _executeCommand(command);
  }

  /// Resize a widget
  void resizeWidget(String widgetId, int newWidth, int newHeight) {
    final widget = _state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }

    final newPlacement = widget.copyWith(width: newWidth, height: newHeight);
    final command = ResizeWidgetCommand(widgetId, widget, newPlacement);
    _executeCommand(command);
  }

  /// Select a widget (not undoable)
  void selectWidget(String? widgetId) {
    _selectedWidgetId = widgetId;
    notifyListeners();
  }

  /// Resize the grid
  void resizeGrid(GridDimensions dimensions) {
    final command = ResizeGridCommand(_state.dimensions, dimensions);
    _executeCommand(command);
  }

  /// Start dragging a widget (not undoable)
  void startDragging(String widgetId) {
    _draggingWidgetIds.add(widgetId);
    notifyListeners();
  }

  /// Stop dragging a widget (not undoable)
  void stopDragging(String widgetId) {
    _draggingWidgetIds.remove(widgetId);
    notifyListeners();
  }

  /// Start resizing a widget (not undoable)
  void startResizing(String widgetId) {
    _resizingWidgetIds.add(widgetId);
    notifyListeners();
  }

  /// Stop resizing a widget (not undoable)
  void stopResizing(String widgetId) {
    _resizingWidgetIds.remove(widgetId);
    notifyListeners();
  }

  /// Undo the last operation
  void undo() {
    if (_undoStack.isNotEmpty) {
      // Save current state to redo stack
      _redoStack.add(_state);

      // Restore previous state
      _state = _undoStack.removeLast();
      notifyListeners();
    }
  }

  /// Redo the next operation
  void redo() {
    if (_redoStack.isNotEmpty) {
      // Save current state to undo stack
      _undoStack.add(_state);

      // Limit undo stack size
      if (_undoStack.length > _undoLimit) {
        _undoStack.removeAt(0);
      }

      // Restore next state
      _state = _redoStack.removeLast();
      notifyListeners();
    }
  }

  /// Clear the undo/redo history
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  /// Check if a widget is currently being dragged
  bool isDragging(String widgetId) => _draggingWidgetIds.contains(widgetId);

  /// Check if a widget is currently being resized
  bool isResizing(String widgetId) => _resizingWidgetIds.contains(widgetId);

  /// Check if a widget is currently selected
  bool isSelected(String widgetId) => _selectedWidgetId == widgetId;

  /// Set preview mode state
  void setPreviewMode(bool preview) {
    if (_isPreviewMode != preview) {
      _isPreviewMode = preview;
      // Clear selection when entering preview mode
      if (preview) {
        _selectedWidgetId = null;
      }
      notifyListeners();
    }
  }

  /// Toggle preview mode on/off
  void togglePreviewMode() {
    setPreviewMode(!_isPreviewMode);
  }

  /// Load a new layout state (creates undo point)
  void loadLayout(LayoutState newLayout) {
    // Save current state to undo stack
    _undoStack.add(_state);

    // Limit undo stack size
    if (_undoStack.length > _undoLimit) {
      _undoStack.removeAt(0);
    }

    // Clear redo stack when new layout is loaded
    _redoStack.clear();

    // Set the new layout
    _state = newLayout;

    // Clear selection and interaction states
    _selectedWidgetId = null;
    _draggingWidgetIds.clear();
    _resizingWidgetIds.clear();

    notifyListeners();
  }
}

/// Custom hook for managing form layout state
FormLayoutController useFormLayout(
  LayoutState initialState, {
  int undoLimit = 50,
}) {
  return use(_FormLayoutHook(initialState, undoLimit));
}

class _FormLayoutHook extends Hook<FormLayoutController> {
  const _FormLayoutHook(this.initialState, this.undoLimit);

  final LayoutState initialState;
  final int undoLimit;

  @override
  HookState<FormLayoutController, Hook<FormLayoutController>> createState() =>
      _FormLayoutHookState();
}

class _FormLayoutHookState
    extends HookState<FormLayoutController, _FormLayoutHook> {
  late FormLayoutController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = FormLayoutController(
      hook.initialState,
      undoLimit: hook.undoLimit,
    );
    _controller.addListener(_onControllerChanged);
  }

  @override
  FormLayoutController build(BuildContext context) {
    return _controller;
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  String get debugLabel => 'useFormLayout';
}
