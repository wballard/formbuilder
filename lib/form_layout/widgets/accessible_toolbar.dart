import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/hooks/use_form_layout.dart';
import 'package:formbuilder/form_layout/utils/accessibility_utils.dart';

/// An accessible toolbar with proper semantics and focus management
class AccessibleToolbar extends StatelessWidget {
  /// The form layout controller
  final FormLayoutController controller;

  /// Whether undo/redo is enabled
  final bool enableUndo;

  const AccessibleToolbar({
    super.key,
    required this.controller,
    this.enableUndo = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Form builder toolbar',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            // Undo/Redo buttons
            if (enableUndo) ...[
              Semantics(
                label: 'Undo',
                hint: controller.canUndo
                    ? 'Undo last action'
                    : 'No actions to undo',
                button: true,
                enabled: controller.canUndo,
                child: AccessibleTouchTarget(
                  onTap: controller.canUndo ? controller.undo : null,
                  child: Tooltip(
                    message: 'Undo (Ctrl+Z)',
                    child: Icon(
                      Icons.undo,
                      color: controller.canUndo
                          ? theme.iconTheme.color
                          : theme.disabledColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: 'Redo',
                hint: controller.canRedo
                    ? 'Redo last undone action'
                    : 'No actions to redo',
                button: true,
                enabled: controller.canRedo,
                child: AccessibleTouchTarget(
                  onTap: controller.canRedo ? controller.redo : null,
                  child: Tooltip(
                    message: 'Redo (Ctrl+Shift+Z)',
                    child: Icon(
                      Icons.redo,
                      color: controller.canRedo
                          ? theme.iconTheme.color
                          : theme.disabledColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const VerticalDivider(),
              const SizedBox(width: 8),
            ],

            // Preview mode toggle
            Semantics(
              label: controller.isPreviewMode
                  ? 'Exit preview mode'
                  : 'Enter preview mode',
              hint: 'Toggle between edit and preview modes',
              button: true,
              toggled: controller.isPreviewMode,
              child: AccessibleTouchTarget(
                onTap: () {
                  controller.togglePreviewMode();
                  AccessibilityUtils.announceStatus(
                    context,
                    controller.isPreviewMode
                        ? 'Entered preview mode'
                        : 'Entered edit mode',
                  );
                },
                child: Tooltip(
                  message: 'Toggle Preview Mode (Ctrl+P)',
                  child: Icon(
                    controller.isPreviewMode
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Grid size indicator
            Semantics(
              label: 'Grid size indicator',
              value:
                  '${controller.state.dimensions.columns} columns by ${controller.state.dimensions.rows} rows',
              readOnly: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.grid_on,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                      semanticLabel: 'Grid',
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.state.dimensions.columns} × ${controller.state.dimensions.rows}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      semanticsLabel: null, // Already provided above
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
