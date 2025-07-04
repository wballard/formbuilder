# Failing Tests Report

After merging the issue/grid_sizing branch, there are 9 failing tests out of 868 total tests (98.96% pass rate).

## Summary of Failures

### 1. Golden File Tests (3 failures)
These tests are failing due to layout overflow errors in the golden file generation:

- **Widget Golden Tests > Grid widget appearance** - RenderLayoutGrid overflowed by 90 pixels on the bottom
- **Widget Golden Tests > Dark theme widgets** - RenderLayoutGrid overflowed by 90 pixels, plus widget deactivation errors
- **Form Layout Golden Tests > Error states** - RenderLayoutGrid overflowed by 72 pixels on the bottom

### 2. Form Layout Tests (3 failures)

- **FormLayout > uses custom toolbox height in vertical layout** - Expected 200, got 600.0
- **FormLayout > applies custom theme** - Found 2 Theme widgets instead of 1 expected
- **FormLayout > switches to vertical layout on small screens** - Multiple overflow errors:
  - AccessibleToolbar Row overflowed by 145 pixels
  - GridResizeControls Row overflowed by 4.5 pixels

### 3. Accessibility Tests (2 failures)

- **Widget Accessibility Tests > Keyboard navigation support** - RenderPhysicalShape size missing error
- **Widget Accessibility Tests > Screen reader support** - Multiple exceptions during semantics updates

### 4. Widget Tests (1 failure)

- **AccessibleCategorizedToolbox > should handle tab key for category expansion** - Expected "Container" text not found

## Root Causes

1. **Layout Overflow Issues**: The drag/drop fixes may have introduced layout constraints that cause overflow in test environments with fixed sizes
2. **Theme Duplication**: The FormLayout theme test is finding multiple Theme widgets, suggesting theme nesting issues
3. **Semantics/Accessibility**: Layout issues are cascading into accessibility/semantics problems
4. **Test Environment Constraints**: Many tests use fixed sizes that may be too small for the updated layouts

## Recommended Actions

1. Fix layout overflow issues by adjusting test container sizes or widget constraints
2. Update golden files after fixing overflow issues
3. Resolve theme duplication in FormLayout
4. Fix the toolbox height calculation in vertical layout mode
5. Update the AccessibleCategorizedToolbox test to match current implementation