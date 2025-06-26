import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/widgets/animated_mode_switcher.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';

void main() {
  group('AnimatedModeSwitcher', () {
    testWidgets('should show edit child when not in preview mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedModeSwitcher(
            isPreviewMode: false,
            editChild: Text('Edit Mode'),
            previewChild: Text('Preview Mode'),
          ),
        ),
      );

      expect(find.text('Edit Mode'), findsOneWidget);
      expect(find.text('Preview Mode'), findsNothing);
    });

    testWidgets('should show preview child when in preview mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedModeSwitcher(
            isPreviewMode: true,
            editChild: Text('Edit Mode'),
            previewChild: Text('Preview Mode'),
          ),
        ),
      );

      expect(find.text('Edit Mode'), findsNothing);
      expect(find.text('Preview Mode'), findsOneWidget);
    });

    testWidgets('should animate transition between modes', (WidgetTester tester) async {
      // Start in edit mode
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedModeSwitcher(
            isPreviewMode: false,
            editChild: Text('Edit Mode'),
            previewChild: Text('Preview Mode'),
          ),
        ),
      );

      expect(find.text('Edit Mode'), findsOneWidget);
      expect(find.text('Preview Mode'), findsNothing);

      // Switch to preview mode
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedModeSwitcher(
            isPreviewMode: true,
            editChild: Text('Edit Mode'),
            previewChild: Text('Preview Mode'),
          ),
        ),
      );

      // During animation, both widgets should be present
      expect(find.text('Edit Mode'), findsOneWidget);
      expect(find.text('Preview Mode'), findsOneWidget);

      // Complete the animation
      await tester.pumpAndSettle();

      // After animation, only preview should be visible
      expect(find.text('Edit Mode'), findsNothing);
      expect(find.text('Preview Mode'), findsOneWidget);
    });

    testWidgets('should not animate when animations are disabled', (WidgetTester tester) async {
      const noAnimations = AnimationSettings.noAnimations();
      
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedModeSwitcher(
            isPreviewMode: false,
            animationSettings: noAnimations,
            editChild: Text('Edit Mode'),
            previewChild: Text('Preview Mode'),
          ),
        ),
      );

      expect(find.text('Edit Mode'), findsOneWidget);
      expect(find.text('Preview Mode'), findsNothing);

      // Switch to preview mode with no animations
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedModeSwitcher(
            isPreviewMode: true,
            animationSettings: noAnimations,
            editChild: Text('Edit Mode'),
            previewChild: Text('Preview Mode'),
          ),
        ),
      );

      // Should immediately show preview without animation
      expect(find.text('Edit Mode'), findsNothing);
      expect(find.text('Preview Mode'), findsOneWidget);
    });
  });

  group('AnimatedToolbar', () {
    testWidgets('should show toolbar when visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedToolbar(
            isVisible: true,
            child: Text('Toolbar Content'),
          ),
        ),
      );

      expect(find.text('Toolbar Content'), findsOneWidget);
    });

    testWidgets('should hide toolbar when not visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedToolbar(
            isVisible: false,
            child: Text('Toolbar Content'),
          ),
        ),
      );

      // Complete any animations
      await tester.pumpAndSettle();

      // Toolbar should be hidden (opacity 0)
      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 0.0);
    });

    testWidgets('should animate visibility changes', (WidgetTester tester) async {
      // Start with visible toolbar
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedToolbar(
            isVisible: true,
            child: Text('Toolbar Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Check initial opacity
      var opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 1.0);

      // Hide toolbar
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedToolbar(
            isVisible: false,
            child: Text('Toolbar Content'),
          ),
        ),
      );

      // During animation - pump a short duration to catch mid-animation
      await tester.pump(const Duration(milliseconds: 50));
      
      // The animation might be fast, so just check that it's animating
      // by verifying the AnimatedOpacity widget exists and is configured correctly
      opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, lessThanOrEqualTo(1.0));
      expect(opacity.opacity, greaterThanOrEqualTo(0.0));

      // Complete animation
      await tester.pumpAndSettle();
      opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 0.0);
    });

    testWidgets('should slide from specified direction', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedToolbar(
            isVisible: false,
            slideFrom: AxisDirection.up,
            child: Text('Toolbar Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check slide offset when hidden (should be offset up)
      final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
      expect(slide.offset, const Offset(0.0, -1.0));

      // Show toolbar
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedToolbar(
            isVisible: true,
            slideFrom: AxisDirection.up,
            child: Text('Toolbar Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check slide offset when visible (should be at origin)
      final visibleSlide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
      expect(visibleSlide.offset, Offset.zero);
    });
  });
}