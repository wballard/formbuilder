When I resize a widget, the drag handle moves, but the widget itself does not.

The hit testing for drag and drop of a widget isn't working for anything except the first row.

The drag handles move, but the drag box does not resize, nor does the widget.

The drag handle hit test regions are too small. [FIXED]

Use the Features/Resize Widgets story as the example to debug.

using the top or bottom drag handles does not highlight the drag target area above or below, there is no obvious resizing

when i drag and drop, the grid provides feedback but the widget is not moved to a new location

when i resize, the grid provides feedback but the widget is not moved to a new location [FIXED - resize now properly updates both position and size]

Widgets are not stretching to fill the grid cells.

The 'delete widget' button should not have a hard coded color, but should pull the theme warning color.

Dragging the resize handle really does need to resize the resize selection box to outline the grid area that will be the result -- in addition to highlighting the grid.