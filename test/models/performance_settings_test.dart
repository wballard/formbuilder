import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/models/performance_settings.dart';

void main() {
  group('PerformanceSettings', () {
    test('should have default values', () {
      const settings = PerformanceSettings();

      expect(settings.qualityLevel, equals(QualityLevel.balanced));
      expect(settings.enableAnimations, isTrue);
      expect(settings.enableVirtualScrolling, isTrue);
      expect(settings.maxHistorySize, equals(50));
      expect(settings.dragUpdateFrequency, equals(60));
      expect(settings.enableMemoryOptimization, isTrue);
      expect(settings.enableDebugMode, isFalse);
    });

    test('should create performance preset settings', () {
      const lowPerf = PerformanceSettings.lowPerformance();
      expect(lowPerf.qualityLevel, equals(QualityLevel.low));
      expect(lowPerf.enableAnimations, isFalse);
      expect(lowPerf.maxHistorySize, equals(20));
      expect(lowPerf.dragUpdateFrequency, equals(30));

      const highPerf = PerformanceSettings.highPerformance();
      expect(highPerf.qualityLevel, equals(QualityLevel.high));
      expect(highPerf.enableAnimations, isTrue);
      expect(highPerf.maxHistorySize, equals(100));
      expect(highPerf.dragUpdateFrequency, equals(120));

      const battery = PerformanceSettings.batterySaver();
      expect(battery.qualityLevel, equals(QualityLevel.low));
      expect(battery.enableAnimations, isFalse);
      expect(battery.enableMemoryOptimization, isTrue);
    });

    test('should copy with modifications', () {
      const original = PerformanceSettings();

      final modified = original.copyWith(
        qualityLevel: QualityLevel.high,
        enableAnimations: false,
      );

      expect(modified.qualityLevel, equals(QualityLevel.high));
      expect(modified.enableAnimations, isFalse);
      expect(
        modified.enableVirtualScrolling,
        equals(original.enableVirtualScrolling),
      );
    });

    test('should detect auto settings', () {
      const auto = PerformanceSettings.auto();
      expect(auto.isAutoMode, isTrue);

      const manual = PerformanceSettings();
      expect(manual.isAutoMode, isFalse);
    });

    test('should calculate effective settings based on performance', () {
      const auto = PerformanceSettings.auto();

      // Good performance
      final goodPerf = auto.getEffectiveSettings(
        currentFps: 60,
        memoryUsage: 100,
      );
      expect(goodPerf.qualityLevel, equals(QualityLevel.high));
      expect(goodPerf.enableAnimations, isTrue);

      // Medium performance
      final mediumPerf = auto.getEffectiveSettings(
        currentFps: 45,
        memoryUsage: 300,
      );
      expect(mediumPerf.qualityLevel, equals(QualityLevel.balanced));

      // Poor performance
      final poorPerf = auto.getEffectiveSettings(
        currentFps: 20,
        memoryUsage: 600,
      );
      expect(poorPerf.qualityLevel, equals(QualityLevel.low));
      expect(poorPerf.enableAnimations, isFalse);
    });

    test('should validate settings', () {
      expect(
        () => PerformanceSettings(maxHistorySize: 0),
        throwsAssertionError,
      );
      expect(
        () => PerformanceSettings(dragUpdateFrequency: 0),
        throwsAssertionError,
      );
      expect(() => PerformanceSettings(cacheSize: -1), throwsAssertionError);
    });

    test('should serialize to/from JSON', () {
      const original = PerformanceSettings(
        qualityLevel: QualityLevel.high,
        enableAnimations: false,
        maxHistorySize: 75,
      );

      final json = original.toJson();
      final restored = PerformanceSettings.fromJson(json);

      expect(restored.qualityLevel, equals(original.qualityLevel));
      expect(restored.enableAnimations, equals(original.enableAnimations));
      expect(restored.maxHistorySize, equals(original.maxHistorySize));
    });
  });

  group('QualityLevel', () {
    test('should have correct descriptions', () {
      expect(QualityLevel.low.description, contains('performance'));
      expect(QualityLevel.balanced.description, contains('balance'));
      expect(QualityLevel.high.description, contains('quality'));
    });

    test('should have correct animation durations', () {
      expect(
        QualityLevel.low.animationDuration,
        lessThan(QualityLevel.balanced.animationDuration),
      );
      expect(
        QualityLevel.balanced.animationDuration,
        lessThan(QualityLevel.high.animationDuration),
      );
    });

    test('should have correct render scales', () {
      expect(QualityLevel.low.renderScale, lessThan(1.0));
      expect(QualityLevel.balanced.renderScale, equals(1.0));
      expect(QualityLevel.high.renderScale, greaterThanOrEqualTo(1.0));
    });
  });

  group('PerformanceProfiler', () {
    late PerformanceProfiler profiler;

    setUp(() {
      profiler = PerformanceProfiler();
    });

    tearDown(() {
      profiler.dispose();
    });

    test('should suggest settings based on device capability', () {
      // High-end device
      final highEnd = profiler.suggestSettings(
        deviceRam: 8 * 1024, // 8 GB
        cpuCores: 8,
        gpuMemory: 4 * 1024, // 4 GB
      );
      expect(highEnd.qualityLevel, equals(QualityLevel.high));

      // Low-end device
      final lowEnd = profiler.suggestSettings(
        deviceRam: 2 * 1024, // 2 GB
        cpuCores: 4,
        gpuMemory: 512, // 512 MB
      );
      expect(lowEnd.qualityLevel, equals(QualityLevel.low));
    });

    test('should adapt settings based on runtime performance', () {
      // Start with auto settings (not high performance)
      profiler.updateSettings(const PerformanceSettings.auto());

      // Simulate poor performance
      for (int i = 0; i < 10; i++) {
        profiler.recordPerformanceMetrics(
          frameTime: 50.0, // 20 FPS
          memoryUsage: 700 * 1024 * 1024, // 700 MB
        );
      }

      final adapted = profiler.getAdaptedSettings();
      expect(adapted.qualityLevel, equals(QualityLevel.low));
    });

    test('should track performance history', () {
      profiler.recordPerformanceMetrics(
        frameTime: 16.67,
        memoryUsage: 100 * 1024 * 1024,
      );
      profiler.recordPerformanceMetrics(
        frameTime: 20.0,
        memoryUsage: 150 * 1024 * 1024,
      );

      final metrics = profiler.getPerformanceMetrics();
      expect(metrics.averageFrameTime, closeTo(18.335, 0.1));
      expect(metrics.averageFps, closeTo(54.5, 1.0));
    });
  });
}
