import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';
import 'package:formbuilder/form_layout/widgets/animated_drag_feedback.dart';
import 'package:formbuilder/form_layout/utils/accessibility_utils.dart';
import 'dart:math';

/// An accessible categorized toolbox widget with keyboard navigation
class AccessibleCategorizedToolbox extends StatefulWidget {
  /// The categorized toolbox to display
  final CategorizedToolbox toolbox;
  
  /// The scroll direction for the toolbox
  final Axis scrollDirection;
  
  /// Padding around the toolbox
  final EdgeInsets padding;
  
  /// Spacing between categories
  final double categorySpacing;
  
  /// Spacing between items
  final double itemSpacing;
  
  /// Animation settings
  final AnimationSettings animationSettings;
  
  /// Callback when an item is activated via keyboard
  final void Function(ToolboxItem, Point<int>)? onItemActivated;

  const AccessibleCategorizedToolbox({
    super.key,
    required this.toolbox,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(8),
    this.categorySpacing = 8.0,
    this.itemSpacing = 8.0,
    this.animationSettings = const AnimationSettings(),
    this.onItemActivated,
  });

  @override
  State<AccessibleCategorizedToolbox> createState() => _AccessibleCategorizedToolboxState();
}

class _AccessibleCategorizedToolboxState extends State<AccessibleCategorizedToolbox> {
  final FocusNode _toolboxFocusNode = FocusNode();
  int _selectedCategoryIndex = 0;
  int _selectedItemIndex = 0;
  final Set<String> _expandedCategories = {};
  
  // Focus nodes for keyboard navigation
  final Map<String, FocusNode> _itemFocusNodes = {};

  @override
  void initState() {
    super.initState();
    // Expand first category by default
    if (widget.toolbox.categories.isNotEmpty) {
      _expandedCategories.add(widget.toolbox.categories.first.name);
    }
    
    // Create focus nodes for all items
    for (final category in widget.toolbox.categories) {
      for (final item in category.items) {
        _itemFocusNodes[item.name] = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    _toolboxFocusNode.dispose();
    for (final node in _itemFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  /// Handle keyboard navigation
  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    
    final key = event.logicalKey;
    
    // Navigation keys
    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowRight) {
      _navigateNext();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowLeft) {
      _navigatePrevious();
      return KeyEventResult.handled;
    }
    
    // Enter/Space to activate
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _activateCurrentItem();
      return KeyEventResult.handled;
    }
    
    // Tab to expand/collapse category
    if (key == LogicalKeyboardKey.tab && !HardwareKeyboard.instance.isShiftPressed) {
      _toggleCurrentCategory();
      return KeyEventResult.handled;
    }
    
    return KeyEventResult.ignored;
  }

  void _navigateNext() {
    setState(() {
      if (_selectedCategoryIndex < widget.toolbox.categories.length - 1) {
        _selectedCategoryIndex++;
        _selectedItemIndex = 0;
      } else if (_selectedItemIndex < 
          widget.toolbox.categories[_selectedCategoryIndex].items.length - 1) {
        _selectedItemIndex++;
      }
    });
    _focusCurrentItem();
  }

  void _navigatePrevious() {
    setState(() {
      if (_selectedItemIndex > 0) {
        _selectedItemIndex--;
      } else if (_selectedCategoryIndex > 0) {
        _selectedCategoryIndex--;
        _selectedItemIndex = 
            widget.toolbox.categories[_selectedCategoryIndex].items.length - 1;
      }
    });
    _focusCurrentItem();
  }

  void _focusCurrentItem() {
    final category = widget.toolbox.categories[_selectedCategoryIndex];
    if (_selectedItemIndex < category.items.length) {
      final item = category.items[_selectedItemIndex];
      _itemFocusNodes[item.name]?.requestFocus();
      
      AccessibilityUtils.announceStatus(
        context,
        'Selected ${item.displayName} in ${category.name}',
      );
    }
  }

  void _toggleCurrentCategory() {
    final category = widget.toolbox.categories[_selectedCategoryIndex];
    setState(() {
      if (_expandedCategories.contains(category.name)) {
        _expandedCategories.remove(category.name);
      } else {
        _expandedCategories.add(category.name);
      }
    });
    
    AccessibilityUtils.announceStatus(
      context,
      '${category.name} ${_expandedCategories.contains(category.name) ? "expanded" : "collapsed"}',
    );
  }

  void _activateCurrentItem() {
    final category = widget.toolbox.categories[_selectedCategoryIndex];
    if (_selectedItemIndex < category.items.length) {
      final item = category.items[_selectedItemIndex];
      
      // If we have a keyboard activation callback, use it
      if (widget.onItemActivated != null) {
        // Default to placing at grid position 0,0
        widget.onItemActivated!(item, const Point(0, 0));
        
        AccessibilityUtils.announceStatus(
          context,
          'Activated ${item.displayName}. Use arrow keys to position on grid.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _toolboxFocusNode,
      onKeyEvent: (node, event) => _handleKeyEvent(event),
      child: Semantics(
        label: 'Widget toolbox',
        hint: 'Use arrow keys to navigate, Enter to select, Tab to expand categories',
        child: ListView.separated(
          padding: widget.padding,
          scrollDirection: widget.scrollDirection,
          itemCount: widget.toolbox.categories.length,
          separatorBuilder: (context, index) => SizedBox(
            width: widget.scrollDirection == Axis.horizontal ? widget.categorySpacing : null,
            height: widget.scrollDirection == Axis.vertical ? widget.categorySpacing : null,
          ),
          itemBuilder: (context, categoryIndex) {
            final category = widget.toolbox.categories[categoryIndex];
            final isExpanded = _expandedCategories.contains(category.name);
            final isSelected = _selectedCategoryIndex == categoryIndex;
            
            return _buildAccessibleCategory(
              context,
              category,
              categoryIndex,
              isExpanded,
              isSelected,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccessibleCategory(
    BuildContext context,
    ToolboxCategory category,
    int categoryIndex,
    bool isExpanded,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: '${category.name} category',
      hint: isExpanded ? 'Expanded. Tab to collapse' : 'Collapsed. Tab to expand',
      selected: isSelected,
      child: Card(
        elevation: isSelected ? 4 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category header
            AccessibleTouchTarget(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedCategories.remove(category.name);
                  } else {
                    _expandedCategories.add(category.name);
                  }
                });
              },
              semanticLabel: category.name,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      semanticLabel: isExpanded ? 'Collapse' : 'Expand',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Category items
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: widget.itemSpacing,
                  runSpacing: widget.itemSpacing,
                  children: category.items.asMap().entries.map((entry) {
                    final itemIndex = entry.key;
                    final item = entry.value;
                    final isItemSelected = isSelected && _selectedItemIndex == itemIndex;
                    
                    return _buildAccessibleItem(
                      context,
                      item,
                      isItemSelected,
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibleItem(
    BuildContext context,
    ToolboxItem item,
    bool isSelected,
  ) {
    final semanticLabel = AccessibilityUtils.getToolboxItemLabel(
      item.displayName,
      item.defaultWidth,
      item.defaultHeight,
    );
    
    return Focus(
      focusNode: _itemFocusNodes[item.name],
      child: Semantics(
        label: semanticLabel,
        selected: isSelected,
        child: SizedBox(
          width: 80,
          height: 80,
          child: Draggable<ToolboxItem>(
            data: item,
            feedback: AnimatedDragFeedback(
              animationSettings: widget.animationSettings,
              child: Material(
                elevation: 8,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: item.toolboxBuilder(context),
                ),
              ),
            ),
            child: AccessibleFocusIndicator(
              isFocused: isSelected,
              child: Card(
                elevation: isSelected ? 4 : 1,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      // Find the item's category and index
                      for (int i = 0; i < widget.toolbox.categories.length; i++) {
                        final cat = widget.toolbox.categories[i];
                        final idx = cat.items.indexOf(item);
                        if (idx != -1) {
                          _selectedCategoryIndex = i;
                          _selectedItemIndex = idx;
                          break;
                        }
                      }
                    });
                    _focusCurrentItem();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: item.toolboxBuilder(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          item.displayName,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}