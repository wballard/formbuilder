import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

/// Controller for managing form layout state
class FormLayoutController extends ChangeNotifier {
  LayoutState _state;
  String? _selectedWidgetId;
  final Set<String> _draggingWidgetIds = <String>{};
  final Set<String> _resizingWidgetIds = <String>{};

  FormLayoutController(this._state);

  /// Current layout state
  LayoutState get state => _state;

  /// Currently selected widget ID
  String? get selectedWidgetId => _selectedWidgetId;

  /// Set of widget IDs currently being dragged
  Set<String> get draggingWidgetIds => Set.unmodifiable(_draggingWidgetIds);

  /// Set of widget IDs currently being resized
  Set<String> get resizingWidgetIds => Set.unmodifiable(_resizingWidgetIds);

  /// Add a widget to the layout
  void addWidget(WidgetPlacement placement) {
    if (!_state.canAddWidget(placement)) {
      throw ArgumentError('Cannot add widget: placement conflicts with existing widgets or is out of bounds');
    }
    _state = _state.addWidget(placement);
    notifyListeners();
  }

  /// Remove a widget from the layout
  void removeWidget(String widgetId) {
    final widget = _state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }
    
    _state = _state.removeWidget(widgetId);
    
    // Clear selection if the removed widget was selected
    if (_selectedWidgetId == widgetId) {
      _selectedWidgetId = null;
    }
    
    // Clear drag/resize state for the removed widget
    _draggingWidgetIds.remove(widgetId);
    _resizingWidgetIds.remove(widgetId);
    
    notifyListeners();
  }

  /// Update a widget's placement
  void updateWidget(String widgetId, WidgetPlacement placement) {
    if (_state.getWidget(widgetId) == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }
    
    // Create a temporary state without the current widget to check if the new placement is valid
    final tempState = _state.removeWidget(widgetId);
    if (!tempState.canAddWidget(placement)) {
      throw ArgumentError('Cannot update widget: new placement conflicts with existing widgets or is out of bounds');
    }
    
    _state = _state.updateWidget(widgetId, placement);
    notifyListeners();
  }

  /// Move a widget to a new position
  void moveWidget(String widgetId, int newColumn, int newRow) {
    final widget = _state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }
    
    final newPlacement = widget.copyWith(column: newColumn, row: newRow);
    updateWidget(widgetId, newPlacement);
  }

  /// Resize a widget
  void resizeWidget(String widgetId, int newWidth, int newHeight) {
    final widget = _state.getWidget(widgetId);
    if (widget == null) {
      throw ArgumentError('Widget with ID "$widgetId" does not exist');
    }
    
    final newPlacement = widget.copyWith(width: newWidth, height: newHeight);
    updateWidget(widgetId, newPlacement);
  }

  /// Select a widget
  void selectWidget(String? widgetId) {
    _selectedWidgetId = widgetId;
    notifyListeners();
  }

  /// Resize the grid
  void resizeGrid(GridDimensions dimensions) {
    _state = _state.resizeGrid(dimensions);
    notifyListeners();
  }

  /// Start dragging a widget
  void startDragging(String widgetId) {
    _draggingWidgetIds.add(widgetId);
    notifyListeners();
  }

  /// Stop dragging a widget
  void stopDragging(String widgetId) {
    _draggingWidgetIds.remove(widgetId);
    notifyListeners();
  }

  /// Start resizing a widget
  void startResizing(String widgetId) {
    _resizingWidgetIds.add(widgetId);
    notifyListeners();
  }

  /// Stop resizing a widget
  void stopResizing(String widgetId) {
    _resizingWidgetIds.remove(widgetId);
    notifyListeners();
  }

  /// Check if a widget is currently being dragged
  bool isDragging(String widgetId) => _draggingWidgetIds.contains(widgetId);

  /// Check if a widget is currently being resized
  bool isResizing(String widgetId) => _resizingWidgetIds.contains(widgetId);

  /// Check if a widget is currently selected
  bool isSelected(String widgetId) => _selectedWidgetId == widgetId;
}

/// Custom hook for managing form layout state
FormLayoutController useFormLayout(LayoutState initialState) {
  return use(_FormLayoutHook(initialState));
}

class _FormLayoutHook extends Hook<FormLayoutController> {
  const _FormLayoutHook(this.initialState);

  final LayoutState initialState;

  @override
  HookState<FormLayoutController, Hook<FormLayoutController>> createState() => _FormLayoutHookState();
}

class _FormLayoutHookState extends HookState<FormLayoutController, _FormLayoutHook> {
  late FormLayoutController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = FormLayoutController(hook.initialState);
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