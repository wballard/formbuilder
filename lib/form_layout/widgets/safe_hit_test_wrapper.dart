import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A wrapper widget that ensures proper layout before allowing hit testing.
/// This prevents "Cannot hit test a render box that has never been laid out" errors
/// when used with LayoutGrid and multi-cell spanning widgets.
class SafeHitTestWrapper extends SingleChildRenderObjectWidget {
  const SafeHitTestWrapper({
    super.key,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSafeHitTestWrapper();
  }
}

class RenderSafeHitTestWrapper extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Only allow hit testing if we have been laid out
    if (!hasSize) {
      return false;
    }
    
    // Ensure child is also laid out before hit testing
    if (child != null && child is RenderBox) {
      final RenderBox childBox = child as RenderBox;
      if (!childBox.hasSize) {
        return false;
      }
    }
    
    return super.hitTest(result, position: position);
  }
  
  @override
  void performLayout() {
    super.performLayout();
    // Ensure we mark needs paint after layout to trigger proper rendering
    markNeedsPaint();
  }
}