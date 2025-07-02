Debug this:

Restarted application in 28ms.

════════ Exception caught by gestures library ══════════════════════════════════
The following assertion was thrown while handling a pointer data packet:
Cannot hit test a render box that has never been laid out.
The hitTest() method was called on this RenderBox: RenderRepaintBoundary#1e8c7 NEEDS-LAYOUT NEEDS-PAINT
    needs compositing
    parentData: areaName=cell_1_1 cell_1_2; offset=Offset(0.0, 0.0)
    constraints: MISSING
    size: MISSING
    usefulness ratio: no metrics collected yet (never painted)
    child: RenderSemanticsAnnotations#03c22 NEEDS-LAYOUT NEEDS-PAINT
        needs compositing
        parentData: <none>
        constraints: MISSING
        size: MISSING
        child: RenderSemanticsAnnotations#ad6b6 NEEDS-LAYOUT NEEDS-PAINT
            needs compositing
            parentData: <none>
            constraints: MISSING
            size: MISSING
            child: RenderTransform#fedc3 NEEDS-LAYOUT NEEDS-PAINT
                needs compositing
                parentData: <none>
                constraints: MISSING
                size: MISSING
                transform matrix: [0] 1.0,0.0,0.0,0.0
[1] 0.0,1.0,0.0,0.0
[2] 0.0,0.0,1.0,0.0
[3] 0.0,0.0,0.0,1.0
                origin: null
                alignment: Alignment.center
                textDirection: ltr
                transformHitTests: true
                child: RenderOpacity#98538 NEEDS-LAYOUT NEEDS-PAINT
                    needs compositing
                    parentData: <none>
                    constraints: MISSING
                    size: MISSING
                    opacity: 1.0
Unfortunately, this object's geometry is not known at this time, probably because it has never been laid out. This means it cannot be accurately hit-tested.
If you are trying to perform a hit test during the layout phase itself, make sure you only hit test nodes that have completed layout (e.g. the node's children, after their layout() method has been called).

When the exception was thrown, this was the stack:
dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 266:3       throw_
package:flutter/src/rendering/box.dart 2922:11                                    <fn>
package:flutter/src/rendering/box.dart 2952:14                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter_layout_grid/src/rendering/layout_grid.dart 874:12                 hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/stack.dart 695:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/widgets/layout_builder.dart 466:19                            hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 183:63                               hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/stack.dart 695:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 2667:22                              <fn>
package:flutter/src/rendering/box.dart 876:31                                     addWithRawTransform
package:flutter/src/rendering/box.dart 810:12                                     addWithPaintTransform
package:flutter/src/rendering/proxy_box.dart 2663:18                              hitTestChildren
package:flutter/src/rendering/proxy_box.dart 2657:12                              hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/stack.dart 695:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 2667:22                              <fn>
package:flutter/src/rendering/box.dart 876:31                                     addWithRawTransform
package:flutter/src/rendering/box.dart 810:12                                     addWithPaintTransform
package:flutter/src/rendering/proxy_box.dart 2663:18                              hitTestChildren
package:flutter/src/rendering/proxy_box.dart 2657:12                              hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/stack.dart 695:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/flex.dart 1309:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/flex.dart 1309:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 183:63                               hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 183:63                               hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/flex.dart 1309:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/custom_layout.dart 429:12                           hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 2139:18                              hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/custom_layout.dart 429:12                           hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 2139:18                              hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 3732:31                              hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/stack.dart 695:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 3063:22                              <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/proxy_box.dart 3056:18                              hitTestChildren
package:flutter/src/rendering/proxy_box.dart 3042:12                              hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 3063:22                              <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/proxy_box.dart 3056:18                              hitTestChildren
package:flutter/src/rendering/proxy_box.dart 3042:12                              hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 3863:31                              hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/widgets/overlay.dart 1106:21                                  childHitTest
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/widgets/overlay.dart 1107:21                                  hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 3984:56                              hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 183:63                               hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/widgets/tap_region.dart 234:72                                hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/flex.dart 1309:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/stack.dart 695:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/flex.dart 1309:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/flex.dart 1309:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 1568:18                              hitTest
package:flutter/src/rendering/box.dart 3351:23                                    <fn>
package:flutter/src/rendering/box.dart 840:31                                     addWithPaintOffset
package:flutter/src/rendering/box.dart 3346:32                                    defaultHitTestChildren
package:flutter/src/rendering/flex.dart 1309:12                                   hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/box.dart 2955:11                                    hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 183:63                               hitTest
package:flutter/src/rendering/proxy_box.dart 128:19                               hitTestChildren
package:flutter/src/rendering/proxy_box.dart 183:63                               hitTest
package:flutter/src/rendering/view.dart 311:12                                    hitTest
package:flutter/src/rendering/binding.dart 662:34                                 hitTestInView
package:flutter/src/gestures/binding.dart 408:7                                   [_handlePointerEventImmediately]
package:flutter/src/gestures/binding.dart 394:5                                   handlePointerEvent
package:flutter/src/gestures/binding.dart 341:7                                   [_flushPointerEventQueue]
package:flutter/src/gestures/binding.dart 308:9                                   [_handlePointerDataPacket]
dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/operations.dart 117:77  tear
lib/_engine/engine/platform_dispatcher.dart 1327:5                                invoke1
lib/_engine/engine/platform_dispatcher.dart 281:5                                 invokeOnPointerDataPacket
lib/_engine/engine/pointer_binding.dart 411:30                                    [_sendToFramework]
lib/_engine/engine/pointer_binding.dart 231:7                                     onPointerData
dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/operations.dart 117:77  tear
lib/_engine/engine/pointer_binding.dart 1002:16                                   <fn>
lib/_engine/engine/pointer_binding.dart 912:7                                     <fn>
lib/_engine/engine/pointer_binding.dart 535:9                                     loggedHandler
dart-sdk/lib/async/zone.dart 1849:54                                              runUnary
dart-sdk/lib/async/zone.dart 1804:26                                              <fn>
dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 224:27    _callDartFunctionFast1
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by gestures library ══════════════════════════════════
Cannot hit test a render box that has never been laid out.
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by gestures library ══════════════════════════════════
Cannot hit test a render box that has never been laid out.
════════════════════════════════════════════════════════════════════════════════
