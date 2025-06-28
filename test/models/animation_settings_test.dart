import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';

void main() {
  group('AnimationSettings', () {
    test('should have default values', () {
      const settings = AnimationSettings();

      expect(settings.enabled, true);
      expect(settings.shortDuration, const Duration(milliseconds: 150));
      expect(settings.mediumDuration, const Duration(milliseconds: 250));
      expect(settings.longDuration, const Duration(milliseconds: 350));
      expect(settings.defaultCurve, Curves.easeInOut);
      expect(settings.entranceCurve, Curves.easeOutBack);
      expect(settings.exitCurve, Curves.easeInCubic);
      expect(settings.dragStartScale, 1.05);
      expect(settings.entranceScale, 0.8);
    });

    test('should create no animations settings', () {
      const settings = AnimationSettings.noAnimations();

      expect(settings.enabled, false);
      expect(settings.shortDuration, Duration.zero);
      expect(settings.mediumDuration, Duration.zero);
      expect(settings.longDuration, Duration.zero);
      expect(settings.defaultCurve, Curves.linear);
      expect(settings.entranceCurve, Curves.linear);
      expect(settings.exitCurve, Curves.linear);
      expect(settings.dragStartScale, 1.0);
      expect(settings.entranceScale, 1.0);
    });

    test('should get duration based on animation type', () {
      const settings = AnimationSettings();

      expect(
        settings.getDuration(AnimationType.short),
        const Duration(milliseconds: 150),
      );
      expect(
        settings.getDuration(AnimationType.medium),
        const Duration(milliseconds: 250),
      );
      expect(
        settings.getDuration(AnimationType.long),
        const Duration(milliseconds: 350),
      );
    });

    test('should return zero duration when disabled', () {
      const settings = AnimationSettings.noAnimations();

      expect(settings.getDuration(AnimationType.short), Duration.zero);
      expect(settings.getDuration(AnimationType.medium), Duration.zero);
      expect(settings.getDuration(AnimationType.long), Duration.zero);
    });

    test('should get curve based on animation type', () {
      const settings = AnimationSettings();

      expect(settings.getCurve(AnimationType.entrance), Curves.easeOutBack);
      expect(settings.getCurve(AnimationType.exit), Curves.easeInCubic);
      expect(settings.getCurve(AnimationType.short), Curves.easeInOut);
      expect(settings.getCurve(AnimationType.medium), Curves.easeInOut);
      expect(settings.getCurve(AnimationType.long), Curves.easeInOut);
    });

    test('should return linear curve when disabled', () {
      const settings = AnimationSettings.noAnimations();

      expect(settings.getCurve(AnimationType.entrance), Curves.linear);
      expect(settings.getCurve(AnimationType.exit), Curves.linear);
      expect(settings.getCurve(AnimationType.short), Curves.linear);
    });

    testWidgets('should create settings from MediaQuery', (
      WidgetTester tester,
    ) async {
      // Test with animations enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final settings = AnimationSettings.fromMediaQuery(context);
              expect(settings.enabled, true);
              return Container();
            },
          ),
        ),
      );

      // Test with animations disabled (simulate accessibility setting)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                final settings = AnimationSettings.fromMediaQuery(context);
                expect(settings.enabled, false);
                expect(settings.shortDuration, Duration.zero);
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });
}
