import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/animation_settings.dart';

void main() {
  group('AnimationSettings Serialization', () {
    test('should serialize default settings to JSON correctly', () {
      const settings = AnimationSettings();

      final json = settings.toJson();

      expect(json, {
        'enabled': true,
        'shortDuration': 150,
        'mediumDuration': 250,
        'longDuration': 350,
        'defaultCurve': 'easeInOut',
        'entranceCurve': 'easeOutBack',
        'exitCurve': 'easeInCubic',
        'dragStartScale': 1.05,
        'entranceScale': 0.8,
      });
    });

    test('should serialize disabled settings to JSON correctly', () {
      const settings = AnimationSettings.noAnimations();

      final json = settings.toJson();

      expect(json, {
        'enabled': false,
        'shortDuration': 0,
        'mediumDuration': 0,
        'longDuration': 0,
        'defaultCurve': 'linear',
        'entranceCurve': 'linear',
        'exitCurve': 'linear',
        'dragStartScale': 1.0,
        'entranceScale': 1.0,
      });
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'enabled': true,
        'shortDuration': 100,
        'mediumDuration': 200,
        'longDuration': 300,
        'defaultCurve': 'bounceOut',
        'entranceCurve': 'elasticOut',
        'exitCurve': 'fastOutSlowIn',
        'dragStartScale': 1.1,
        'entranceScale': 0.9,
      };

      final settings = AnimationSettings.fromJson(json);

      expect(settings.enabled, true);
      expect(settings.shortDuration, const Duration(milliseconds: 100));
      expect(settings.mediumDuration, const Duration(milliseconds: 200));
      expect(settings.longDuration, const Duration(milliseconds: 300));
      expect(settings.defaultCurve, Curves.bounceOut);
      expect(settings.dragStartScale, 1.1);
      expect(settings.entranceScale, 0.9);
    });

    test('should handle round-trip serialization', () {
      const original = AnimationSettings(
        enabled: true,
        shortDuration: Duration(milliseconds: 120),
        mediumDuration: Duration(milliseconds: 220),
        longDuration: Duration(milliseconds: 320),
        defaultCurve: Curves.easeInOut,
        dragStartScale: 1.2,
      );

      final json = original.toJson();
      final deserialized = AnimationSettings.fromJson(json);

      expect(deserialized.enabled, original.enabled);
      expect(deserialized.shortDuration, original.shortDuration);
      expect(deserialized.mediumDuration, original.mediumDuration);
      expect(deserialized.longDuration, original.longDuration);
      expect(deserialized.dragStartScale, original.dragStartScale);
    });

    test('should handle missing fields with defaults', () {
      final incompleteJson = {
        'enabled': false,
        // Other fields missing
      };

      final settings = AnimationSettings.fromJson(incompleteJson);

      expect(settings.enabled, false);
      expect(
        settings.shortDuration,
        const Duration(milliseconds: 150),
      ); // Default
      expect(
        settings.mediumDuration,
        const Duration(milliseconds: 250),
      ); // Default
    });

    test('should handle unknown curve names gracefully', () {
      final json = {
        'enabled': true,
        'defaultCurve': 'unknownCurve',
        'entranceCurve': 'anotherUnknownCurve',
      };

      final settings = AnimationSettings.fromJson(json);

      expect(settings.defaultCurve, Curves.easeInOut); // Fallback to default
      expect(
        settings.entranceCurve,
        Curves.easeInOut,
      ); // Fallback to default from _stringToCurve
    });

    test('should serialize and deserialize all curve types', () {
      final testCurves = [
        Curves.linear,
        Curves.ease,
        Curves.easeIn,
        Curves.easeOut,
        Curves.easeInOut,
        Curves.bounceIn,
        Curves.bounceOut,
        Curves.elasticIn,
        Curves.elasticOut,
      ];

      for (final curve in testCurves) {
        final settings = AnimationSettings(defaultCurve: curve);
        final json = settings.toJson();
        final deserialized = AnimationSettings.fromJson(json);

        expect(deserialized.defaultCurve, curve);
      }
    });
  });
}
