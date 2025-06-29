import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formbuilder/form_layout/form_layout.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/widgets/accessible_categorized_toolbox.dart';
import 'package:formbuilder/form_layout/widgets/grid_drag_target.dart';
import 'package:formbuilder/form_layout/widgets/keyboard_handler.dart';
import 'package:formbuilder/form_layout/widgets/form_layout_action_dispatcher.dart';
import 'package:formbuilder/form_layout/widgets/animated_mode_switcher.dart';
import 'package:formbuilder/form_layout/widgets/accessible_toolbar.dart';
import 'package:formbuilder/form_layout/intents/form_layout_intents.dart';

/// A test wrapper for FormLayout that exposes the controller
class FormLayoutTestWrapper extends HookWidget {
  final CategorizedToolbox toolbox;
  final LayoutState? initialLayout;
  final void Function(FormLayoutController controller)? onControllerCreated;
  final bool showToolbox;
  final Axis toolboxPosition;
  final double? toolboxWidth;
  final double? toolboxHeight;
  final bool enableUndo;
  final int undoLimit;

  const FormLayoutTestWrapper({
    super.key,
    required this.toolbox,
    this.initialLayout,
    this.onControllerCreated,
    this.showToolbox = true,
    this.toolboxPosition = Axis.horizontal,
    this.toolboxWidth,
    this.toolboxHeight,
    this.enableUndo = true,
    this.undoLimit = 50,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useFormLayout(
      initialLayout ?? LayoutState.empty(),
      undoLimit: undoLimit,
    );

    // Notify test about controller creation
    useEffect(() {
      onControllerCreated?.call(controller);
      return null;
    }, []);

    // Build the form layout content manually (similar to FormLayout)
    Widget content = FormLayoutActionDispatcher(
      controller: controller,
      child: KeyboardHandler(
        controller: controller,
        child: AnimatedModeSwitcher(
          isPreviewMode: controller.isPreviewMode,
          editChild: _buildEditLayout(context, controller),
          previewChild: _buildPreviewLayout(context, controller),
        ),
      ),
    );

    return Theme(
      data: Theme.of(context),
      child: content,
    );
  }

  Widget _buildEditLayout(BuildContext context, FormLayoutController controller) {
    final grid = GridDragTarget(
      layoutState: controller.state,
      widgetBuilders: _getWidgetBuilders(toolbox),
      toolbox: toolbox.toSimpleToolbox(),
      onWidgetDropped: (placement) => controller.addWidget(placement),
      onWidgetMoved: (id, newPlacement) => controller.updateWidget(id, newPlacement),
      onWidgetResize: (id, newPlacement) => controller.updateWidget(id, newPlacement),
      onWidgetDelete: (id) => controller.removeWidget(id),
      onGridResize: (dimensions) => controller.resizeGrid(dimensions),
      selectedWidgetId: controller.selectedWidgetId,
      onWidgetTap: (id) => controller.selectWidget(id),
    );

    if (!showToolbox) {
      return grid;
    }

    Widget toolboxWidget = AccessibleCategorizedToolbox(
      toolbox: toolbox,
      scrollDirection: toolboxPosition == Axis.horizontal ? Axis.vertical : Axis.horizontal,
    );

    if (toolboxPosition == Axis.horizontal) {
      // Horizontal layout (toolbox on left)
      return Row(
        children: [
          SizedBox(
            width: toolboxWidth ?? 250,
            child: toolboxWidget,
          ),
          Expanded(child: grid),
        ],
      );
    } else {
      // Vertical layout (toolbox on top)
      return Column(
        children: [
          SizedBox(
            height: toolboxHeight ?? 150,
            child: toolboxWidget,
          ),
          Expanded(child: grid),
        ],
      );
    }
  }

  Widget _buildPreviewLayout(BuildContext context, FormLayoutController controller) {
    return GridDragTarget(
      layoutState: controller.state,
      widgetBuilders: _getWidgetBuilders(toolbox),
      toolbox: toolbox.toSimpleToolbox(),
      selectedWidgetId: null,
      onWidgetTap: null,
    );
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