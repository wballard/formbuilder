dragging a widget from the toolbox errors:

════════ Exception caught by gesture library ═══════════════════════════════════
The following ArgumentError was thrown while routing a pointer event:
Invalid argument(s): Cannot add widget: placement conflicts with existing widgets or is out of bounds

When the exception was thrown, this was the stack:
dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 266:3       throw_
errors.dart:266
package:formbuilder/form_layout/utils/commands.dart 23:7                          execute
commands.dart:23
package:formbuilder/form_layout/hooks/use_form_layout.dart 59:31                  [_executeCommand]
use_form_layout.dart:59
package:formbuilder/form_layout/hooks/use_form_layout.dart 72:5                   addWidget
use_form_layout.dart:72
package:formbuilder/form_layout/form_layout.dart 341:29                           <fn>
form_layout.dart:341
package:formbuilder/form_layout/widgets/grid_drag_target.dart 720:30              <fn>
grid_drag_target.dart:720
package:flutter/src/widgets/drag_target.dart 798:35                               didDrop
drag_target.dart:798
package:flutter/src/widgets/drag_target.dart 971:7                                finishDrag
drag_target.dart:971
package:flutter/src/widgets/drag_target.dart 884:5                                end
drag_target.dart:884
package:flutter/src/gestures/multidrag.dart 163:13                                [_up]
multidrag.dart:163
package:flutter/src/gestures/multidrag.dart 266:12                                [_handleEvent]
multidrag.dart:266
dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/operations.dart 117:77  tear
operations.dart:117
