import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/alignment_guide.dart';
import 'dart:math';

void main() {
  group('AlignmentGuide', () {
    test('should create horizontal guide', () {
      const guide = AlignmentGuide(
        type: GuideType.horizontal,
        position: 100.0,
        start: 0.0,
        end: 500.0,
      );

      expect(guide.type, equals(GuideType.horizontal));
      expect(guide.position, equals(100.0));
      expect(guide.start, equals(0.0));
      expect(guide.end, equals(500.0));
      expect(guide.isTemporary, isFalse);
    });

    test('should create vertical guide', () {
      const guide = AlignmentGuide(
        type: GuideType.vertical,
        position: 200.0,
        start: 50.0,
        end: 300.0,
        isTemporary: true,
      );

      expect(guide.type, equals(GuideType.vertical));
      expect(guide.position, equals(200.0));
      expect(guide.start, equals(50.0));
      expect(guide.end, equals(300.0));
      expect(guide.isTemporary, isTrue);
    });

    test('should support equality comparison', () {
      const guide1 = AlignmentGuide(
        type: GuideType.horizontal,
        position: 100.0,
        start: 0.0,
        end: 500.0,
      );
      const guide2 = AlignmentGuide(
        type: GuideType.horizontal,
        position: 100.0,
        start: 0.0,
        end: 500.0,
      );
      const guide3 = AlignmentGuide(
        type: GuideType.vertical,
        position: 100.0,
        start: 0.0,
        end: 500.0,
      );

      expect(guide1, equals(guide2));
      expect(guide1, isNot(equals(guide3)));
    });
  });

  group('AlignmentGuideDetector', () {
    late AlignmentGuideDetector detector;

    setUp(() {
      detector = AlignmentGuideDetector(threshold: 10.0);
    });

    test('should detect center alignment between widgets', () {
      final widget1 = Rectangle(100, 100, 100, 50);
      final widget2 = Rectangle(300, 100, 100, 50);
      final movingWidget = Rectangle(200, 95, 80, 60); // Center Y = 125

      final guides = detector.detectCenterAlignment(movingWidget, [
        widget1,
        widget2,
      ]);

      expect(guides, isNotEmpty);
      // Should detect horizontal center alignment
      expect(
        guides.any(
          (g) => g.type == GuideType.horizontal && g.position == 125.0,
        ),
        isTrue,
      );
    });

    test('should detect edge alignment', () {
      final widget1 = Rectangle(100, 100, 100, 50);
      final movingWidget = Rectangle(195, 100, 80, 60);

      final guides = detector.detectEdgeAlignment(movingWidget, [widget1]);

      expect(guides, isNotEmpty);
      // Should detect right edge of widget1 aligning with left edge of moving widget
      expect(
        guides.any((g) => g.type == GuideType.vertical && g.position == 200.0),
        isTrue,
      );
    });

    test('should detect equal spacing', () {
      final widget1 = Rectangle(100, 100, 50, 50);
      final widget2 = Rectangle(200, 100, 50, 50);
      final movingWidget = Rectangle(300, 100, 50, 50);

      final guides = detector.detectEqualSpacing(movingWidget, [
        widget1,
        widget2,
      ]);

      expect(guides, isNotEmpty);
      // Should detect equal spacing of 50 pixels
    });

    test('should not detect guides beyond threshold', () {
      final widget1 = Rectangle(100, 100, 100, 50);
      final movingWidget = Rectangle(
        250,
        200,
        80,
        60,
      ); // Too far for threshold on all edges

      final guides = detector.detectEdgeAlignment(movingWidget, [widget1]);

      expect(guides, isEmpty);
    });
  });

  group('GuideType', () {
    test('should have correct enum values', () {
      expect(GuideType.values, contains(GuideType.horizontal));
      expect(GuideType.values, contains(GuideType.vertical));
      expect(GuideType.values, contains(GuideType.centerHorizontal));
      expect(GuideType.values, contains(GuideType.centerVertical));
    });
  });
}
