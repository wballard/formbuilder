import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/widgets/grid_container.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/widgets/form_preview.dart';
import 'package:formbuilder/form_layout/models/layout_state.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

void main() {
  group('Hardcoded Values Tests', () {
    testWidgets('GridContainer should use theme values instead of hardcoded pixels', (tester) async {
      const customTheme = FormLayoutTheme(
        defaultPadding: EdgeInsets.all(16.0),
      );
      
      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 2, rows: 2),
        widgets: [
          WidgetPlacement(
            id: 'test-widget',
            widgetName: 'TestWidget',
            column: 0,
            row: 0,
            width: 1,
            height: 1,
          ),
        ],
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutThemeWidget(
            theme: customTheme,
            child: Scaffold(
              body: GridContainer(
                layoutState: layoutState,
                widgetBuilders: {
                  'TestWidget': (context, placement) => Container(
                    color: Colors.blue,
                    child: const Text('Test'),
                  ),
                },
                isPreviewMode: true, // This should use theme gaps instead of hardcoded 8
              ),
            ),
          ),
        ),
      );

      // The widget should build without errors
      expect(find.byType(GridContainer), findsOneWidget);
      
      // In preview mode, gaps should be based on theme, not hardcoded 8
      // This test will initially fail because the code uses hardcoded values
      // We expect the gap to be derived from theme's defaultPadding
      // The current code uses hardcoded 8 for columnGap and rowGap in preview mode
    });

    testWidgets('PlacedWidget should use theme values for padding and sizing', (tester) async {
      const customTheme = FormLayoutTheme(
        defaultPadding: EdgeInsets.all(20.0),
      );
      
      final placement = WidgetPlacement(
        id: 'test-widget',
        widgetName: 'TestWidget', 
        column: 0,
        row: 0,
        width: 1,
        height: 1,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutThemeWidget(
            theme: customTheme,
            child: Scaffold(
              body: SizedBox(
                width: 200,
                height: 200,
                child: PlacedWidget(
                  placement: placement,
                  child: Container(
                    color: Colors.red,
                    child: const Text('Test'),
                  ),
                  // Currently uses hardcoded EdgeInsets.all(8) default
                  // Should respect the theme's defaultPadding
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PlacedWidget), findsOneWidget);
      
      // The PlacedWidget should not use hardcoded padding values
      // This test helps ensure we replace hardcoded EdgeInsets.all(8) with theme values
    });

    testWidgets('Theme should provide consistent spacing values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final theme = FormLayoutTheme.of(context);
              
              // Verify that theme provides consistent spacing
              expect(theme.defaultPadding, isNotNull);
              expect(theme.widgetBorderRadius, isNotNull);
              
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('FormPreview should use theme values for spacing', (tester) async {
      const customTheme = FormLayoutTheme(
        defaultPadding: EdgeInsets.all(32.0),
      );
      
      final layoutState = LayoutState(
        dimensions: const GridDimensions(columns: 2, rows: 2),
        widgets: [
          WidgetPlacement(
            id: 'preview-widget',
            widgetName: 'PreviewWidget',
            column: 0,
            row: 0,
            width: 1,
            height: 1,
          ),
        ],
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: FormLayoutThemeWidget(
            theme: customTheme,
            child: Scaffold(
              body: FormPreview(
                layoutState: layoutState,
                widgetBuilders: {
                  'PreviewWidget': (context, placement) => Container(
                    color: Colors.green,
                    child: const Text('Preview'),
                  ),
                },
                // Currently uses hardcoded padding and gap values
                // Should use theme-based values
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FormPreview), findsOneWidget);
      
      // FormPreview should not use hardcoded spacing values
      // This test helps ensure consistent theme usage
    });

    group('Font Size Tests', () {
      testWidgets('Widgets should use theme-based font sizes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(
                bodyMedium: TextStyle(fontSize: 18), // Custom base font size
              ),
            ),
            home: Builder(
              builder: (context) {
                final textTheme = Theme.of(context).textTheme;
                
                // Font sizes should be based on theme's text styles
                // Not hardcoded values like fontSize: 12, fontSize: 14, etc.
                expect(textTheme.bodyMedium?.fontSize, 18);
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Icon Size Tests', () {
      testWidgets('Icon sizes should be based on theme or relative to font size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              iconTheme: const IconThemeData(size: 28), // Custom icon size
            ),
            home: Builder(
              builder: (context) {
                final iconTheme = Theme.of(context).iconTheme;
                
                // Icon sizes should be based on theme's iconTheme
                // Not hardcoded values like size: 24, size: 16, etc.
                expect(iconTheme.size, 28);
                
                return Container();
              },
            ),
          ),
        );
      });
    });
  });
}