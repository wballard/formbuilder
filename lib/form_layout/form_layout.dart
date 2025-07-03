import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/accessible_categorized_toolbox.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/keyboard_handler.dart';
import 'package:formbuilder/form_layout/widgets/form_layout_action_dispatcher.dart';
import 'package:formbuilder/form_layout/widgets/animated_mode_switcher.dart';
import 'package:formbuilder/form_layout/widgets/accessible_toolbar.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';

/// The main widget for building interactive form layouts.
/// 
/// FormLayout provides a complete drag-and-drop form building interface with
/// a toolbox of available widgets, a grid-based layout system, and full support
/// for undo/redo, preview mode, and import/export functionality.
/// 
/// ## Features
/// 
/// - **Drag-and-drop interface**: Drag widgets from the toolbox to the grid
/// - **Grid-based layout**: Flexible grid system for responsive form design
/// - **Undo/redo support**: Built-in history management with configurable limits
/// - **Preview mode**: Switch between edit and preview modes
/// - **Import/export**: Save and load layouts as JSON
/// - **Keyboard navigation**: Full keyboard accessibility support
/// - **Responsive design**: Adapts to different screen sizes
/// - **Theming**: Customizable appearance with Material Design
/// 
/// ## Basic Usage
/// 
/// ```dart
/// FormLayout(
///   toolbox: CategorizedToolbox(
///     categories: [
///       ToolboxCategory(
///         name: 'Basic Inputs',
///         icon: Icons.input,
///         items: [
///           ToolboxItem(
///             name: 'text_field',
///             icon: Icons.text_fields,
///             label: 'Text Field',
///             gridBuilder: (context, placement) => 
///               TextField(key: ValueKey(placement.id)),
///           ),
///         ],
///       ),
///     ],
///   ),
///   onLayoutChanged: (layout) {
///     print('Layout updated: ${layout.widgets.length} widgets');
///   },
/// )
/// ```
/// 
/// ## Advanced Usage
/// 
/// ```dart
/// FormLayout(
///   toolbox: myToolbox,
///   initialLayout: savedLayout,
///   showToolbox: true,
///   toolboxPosition: Axis.horizontal,
///   toolboxWidth: 300,
///   enableUndo: true,
///   undoLimit: 100,
///   theme: ThemeData(
///     primarySwatch: Colors.blue,
///   ),
///   animationSettings: AnimationSettings(
///     enableAnimations: true,
///     animationDuration: Duration(milliseconds: 200),
///   ),
///   onLayoutChanged: (layout) => saveLayout(layout),
///   onExportLayout: (jsonString) => shareLayout(jsonString),
///   onImportLayout: (layout, error) {
///     if (error != null) {
///       showError(error);
///     } else {
///       showSuccess('Layout imported');
///     }
///   },
/// )
/// ```
/// 
/// @see [CategorizedToolbox] for creating widget toolboxes
/// @see [LayoutState] for the layout data model
/// @see [FormLayoutController] for programmatic control
/// @see [AnimationSettings] for animation configuration
class FormLayout extends HookWidget {
  /// The toolbox containing available widgets for drag-and-drop.
  /// 
  /// This defines all the widget types that users can add to their forms.
  /// Widgets are organized into categories for better user experience.
  final CategorizedToolbox toolbox;

  /// Initial layout state to display when the widget is first built.
  /// 
  /// If null, an empty 4x5 grid will be created by default.
  /// Use this to restore previously saved layouts.
  final LayoutState? initialLayout;

  /// Callback invoked whenever the layout changes.
  /// 
  /// This includes adding, removing, moving, or resizing widgets.
  /// The callback is debounced to avoid excessive calls during drag operations.
  /// 
  /// Use this to persist layout changes:
  /// ```dart
  /// onLayoutChanged: (layout) async {
  ///   await storage.saveLayout(layout.toJson());
  /// }
  /// ```
  final void Function(LayoutState)? onLayoutChanged;

  /// Whether to show the widget toolbox.
  /// 
  /// Set to false to hide the toolbox and only show the grid area.
  /// Useful for read-only or preview-only scenarios.
  final bool showToolbox;

  /// Position of the toolbox relative to the grid.
  /// 
  /// - [Axis.horizontal]: Toolbox appears on the left side
  /// - [Axis.vertical]: Toolbox appears at the top
  /// 
  /// On small screens (<600px), vertical layout is forced regardless of this setting.
  final Axis toolboxPosition;

  /// Width of the toolbox when using horizontal layout.
  /// 
  /// Defaults to 250 pixels if not specified.
  /// Only applies when [toolboxPosition] is [Axis.horizontal].
  final double? toolboxWidth;

  /// Height of the toolbox when using vertical layout.
  /// 
  /// Defaults to 150 pixels if not specified.
  /// Only applies when [toolboxPosition] is [Axis.vertical].
  final double? toolboxHeight;

  /// Whether undo/redo functionality is enabled.
  /// 
  /// When true, users can undo/redo layout changes using:
  /// - Toolbar buttons
  /// - Keyboard shortcuts (Ctrl+Z / Ctrl+Y)
  /// - Actions/Intents system
  final bool enableUndo;

  /// Maximum number of undo states to keep in history.
  /// 
  /// Older states are discarded when this limit is reached.
  /// Higher values use more memory but allow more undo steps.
  final int undoLimit;

  /// Custom theme for the form layout widget.
  /// 
  /// If provided, this theme will be applied to all child widgets.
  /// Use this to customize colors, fonts, and other visual properties.
  final ThemeData? theme;

  /// Animation settings for transitions and interactions.
  /// 
  /// If null, settings are determined from accessibility preferences
  /// using [AnimationSettings.fromMediaQuery].
  final AnimationSettings? animationSettings;

  /// Callback invoked when the user requests to export the layout.
  /// 
  /// The layout is provided as a JSON string that can be saved or shared.
  /// Triggered by the export button in the toolbar.
  /// 
  /// Example:
  /// ```dart
  /// onExportLayout: (jsonString) {
  ///   Clipboard.setData(ClipboardData(text: jsonString));
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Layout copied to clipboard')),
  ///   );
  /// }
  /// ```
  final void Function(String jsonString)? onExportLayout;

  /// Callback invoked when the user imports a layout.
  /// 
  /// If import succeeds, [layout] contains the imported data and [error] is null.
  /// If import fails, [layout] is null and [error] contains the error message.
  /// 
  /// Example:
  /// ```dart
  /// onImportLayout: (layout, error) {
  ///   if (error != null) {
  ///     showDialog(
  ///       context: context,
  ///       builder: (_) => AlertDialog(
  ///         title: Text('Import Failed'),
  ///         content: Text(error),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  final void Function(LayoutState? layout, String? error)? onImportLayout;

  /// Creates a FormLayout widget.
  /// 
  /// The [toolbox] parameter is required and defines the available widgets.
  /// All other parameters are optional and have sensible defaults.
  const FormLayout({
    super.key,
    required this.toolbox,
    this.initialLayout,
    this.onLayoutChanged,
    this.showToolbox = true,
    this.toolboxPosition = Axis.horizontal,
    this.toolboxWidth,
    this.toolboxHeight,
    this.enableUndo = true,
    this.undoLimit = 50,
    this.theme,
    this.animationSettings,
    this.onExportLayout,
    this.onImportLayout,
  });

  @override
  Widget build(BuildContext context) {
    // Get animation settings, respecting accessibility preferences
    final effectiveAnimationSettings =
        animationSettings ?? AnimationSettings.fromMediaQuery(context);

    // Initialize the form layout controller
    final controller = useFormLayout(
      initialLayout ??
          LayoutState(
            dimensions: const GridDimensions(columns: 4, rows: 5),
            widgets: const [],
          ),
      undoLimit: undoLimit,
    );

    // Listen to layout changes and notify callback
    useEffect(() {
      if (onLayoutChanged != null) {
        // Debounce to avoid excessive callbacks
        final debounceTimer =
            Stream.periodic(
              const Duration(milliseconds: 100),
              (_) => controller.state,
            ).distinct().listen((state) {
              onLayoutChanged!(state);
            });

        return debounceTimer.cancel;
      }
      return null;
    }, [controller.state]);

    // Always use horizontal layout with vertical toolbox
    const effectivePosition = Axis.horizontal;

    // Build the main content
    Widget content = FormLayoutActionDispatcher(
      controller: controller,
      onExportLayout: onExportLayout,
      onImportLayout: onImportLayout,
      child: KeyboardHandler(
        controller: controller,
        child: _buildLayout(
          context,
          controller,
          effectivePosition,
          effectiveAnimationSettings,
        ),
      ),
    );

    // Apply theme if provided
    if (theme != null) {
      content = Theme(data: theme!, child: content);
    }

    return content;
  }

  Widget _buildLayout(
    BuildContext context,
    FormLayoutController controller,
    Axis position,
    AnimationSettings animationSettings,
  ) {
    final toolboxWidget = showToolbox
        ? AccessibleCategorizedToolbox(
            toolbox: toolbox,
            scrollDirection: Axis.vertical, // Always vertical as per requirements
            animationSettings: animationSettings,
            onItemActivated: (item, position) {
              // Handle keyboard activation of toolbox items
              Actions.maybeInvoke<AddWidgetIntent>(
                context,
                AddWidgetIntent(item: item, position: position),
              );
            },
          )
        : null;

    final gridWidget = Expanded(
      child: Column(
        children: [
          AnimatedToolbar(
            isVisible: !controller.isPreviewMode,
            animationSettings: animationSettings,
            slideFrom: AxisDirection.up,
            child: AccessibleToolbar(
              controller: controller,
              enableUndo: enableUndo,
            ),
          ),
          Expanded(
            child: AnimatedModeSwitcher(
              isPreviewMode: controller.isPreviewMode,
              animationSettings: animationSettings,
              editChild: GridDragTarget(
                layoutState: controller.state,
                widgetBuilders: _getWidgetBuilders(toolbox),
                toolbox: CategorizedToolbox(
                  categories: toolbox.categories,
                ).toSimpleToolbox(),
                selectedWidgetId: controller.selectedWidgetId,
                onWidgetTap: (id) => controller.selectWidget(id),
                onWidgetMoved: (widgetId, newPlacement) => controller.updateWidget(widgetId, newPlacement),
                onWidgetResize: (widgetId, newPlacement) => controller.updateWidget(widgetId, newPlacement),
                onWidgetDelete: (widgetId) => controller.removeWidget(widgetId),
                onGridResize: (dimensions) => controller.resizeGrid(dimensions),
                animationSettings: animationSettings,
              ),
              previewChild: GridDragTarget(
                layoutState: controller.state,
                widgetBuilders: _getWidgetBuilders(toolbox),
                toolbox: CategorizedToolbox(
                  categories: toolbox.categories,
                ).toSimpleToolbox(),
                selectedWidgetId: null,
                onWidgetTap: null,
                animationSettings: animationSettings,
              ),
            ),
          ),
        ],
      ),
    );

    if (position == Axis.horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (toolboxWidget != null) ...[
            SizedBox(width: toolboxWidth ?? 250, child: toolboxWidget),
            const VerticalDivider(width: 1),
          ],
          gridWidget,
        ],
      );
    } else {
      return Column(
        children: [
          if (toolboxWidget != null) ...[
            SizedBox(height: toolboxHeight ?? 150, child: toolboxWidget),
            const Divider(height: 1),
          ],
          gridWidget,
        ],
      );
    }
  }

  Map<String, Widget Function(BuildContext, WidgetPlacement)>
  _getWidgetBuilders(CategorizedToolbox toolbox) {
    final builders = <String, Widget Function(BuildContext, WidgetPlacement)>{};
    for (final category in toolbox.categories) {
      for (final item in category.items) {
        builders[item.name] = item.gridBuilder;
      }
    }
    return builders;
  }
}
