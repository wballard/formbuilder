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

/// The main FormLayout widget that provides a complete form building interface
class FormLayout extends HookWidget {
  /// The toolbox containing available widgets
  final CategorizedToolbox toolbox;
  
  /// Initial layout state, if any
  final LayoutState? initialLayout;
  
  /// Callback when layout changes
  final void Function(LayoutState)? onLayoutChanged;
  
  /// Whether to show the toolbox
  final bool showToolbox;
  
  /// Position of the toolbox (horizontal = left, vertical = top)
  final Axis toolboxPosition;
  
  /// Width of the toolbox when in horizontal layout
  final double? toolboxWidth;
  
  /// Height of the toolbox when in vertical layout
  final double? toolboxHeight;
  
  /// Whether undo/redo is enabled
  final bool enableUndo;
  
  /// Maximum number of undo states to keep
  final int undoLimit;
  
  /// Custom theme for the form layout
  final ThemeData? theme;
  
  /// Animation settings for the form layout
  final AnimationSettings? animationSettings;
  
  /// Callback when layout export is requested
  final void Function(String jsonString)? onExportLayout;
  
  /// Callback when layout import is requested
  final void Function(LayoutState? layout, String? error)? onImportLayout;

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
    final effectiveAnimationSettings = animationSettings ?? 
        AnimationSettings.fromMediaQuery(context);
    
    // Initialize the form layout controller
    final controller = useFormLayout(
      initialLayout ?? LayoutState(
        dimensions: const GridDimensions(columns: 4, rows: 5),
        widgets: const [],
      ),
      undoLimit: undoLimit,
    );

    // Listen to layout changes and notify callback
    useEffect(() {
      if (onLayoutChanged != null) {
        // Debounce to avoid excessive callbacks
        final debounceTimer = Stream.periodic(
          const Duration(milliseconds: 100),
          (_) => controller.state,
        ).distinct().listen((state) {
          onLayoutChanged!(state);
        });
        
        return debounceTimer.cancel;
      }
      return null;
    }, [controller.state]);

    // Determine responsive layout
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final effectivePosition = isSmallScreen ? Axis.vertical : toolboxPosition;
    
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
      content = Theme(
        data: theme!,
        child: content,
      );
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
            scrollDirection: position,
            animationSettings: animationSettings,
            onItemActivated: (item, position) {
              // Handle keyboard activation of toolbox items
              Actions.maybeInvoke<AddWidgetIntent>(
                context,
                AddWidgetIntent(
                  item: item,
                  position: position,
                ),
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
                toolbox: CategorizedToolbox(categories: toolbox.categories).toSimpleToolbox(),
                selectedWidgetId: controller.selectedWidgetId,
                onWidgetTap: (id) => controller.selectWidget(id),
                animationSettings: animationSettings,
              ),
              previewChild: GridDragTarget(
                layoutState: controller.state,
                widgetBuilders: _getWidgetBuilders(toolbox),
                toolbox: CategorizedToolbox(categories: toolbox.categories).toSimpleToolbox(),
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
            SizedBox(
              width: toolboxWidth ?? 250,
              child: toolboxWidget,
            ),
            const VerticalDivider(width: 1),
          ],
          gridWidget,
        ],
      );
    } else {
      return Column(
        children: [
          if (toolboxWidget != null) ...[
            SizedBox(
              height: toolboxHeight ?? 150,
              child: toolboxWidget,
            ),
            const Divider(height: 1),
          ],
          gridWidget,
        ],
      );
    }
  }


  Map<String, Widget Function(BuildContext, WidgetPlacement)> _getWidgetBuilders(CategorizedToolbox toolbox) {
    final builders = <String, Widget Function(BuildContext, WidgetPlacement)>{};
    for (final category in toolbox.categories) {
      for (final item in category.items) {
        builders[item.name] = item.gridBuilder;
      }
    }
    return builders;
  }
}