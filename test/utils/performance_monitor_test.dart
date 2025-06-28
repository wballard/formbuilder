import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/utils/performance_monitor.dart';

void main() {
  group('PerformanceMonitor', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
    });

    tearDown(() {
      monitor.dispose();
    });

    test('should track frame times', () async {
      monitor.startFrame();

      // Simulate some work
      await Future.delayed(const Duration(milliseconds: 10));

      monitor.endFrame();

      final stats = monitor.getStats();
      expect(stats.frameCount, equals(1));
      expect(stats.averageFrameTime, greaterThan(0));
      expect(stats.maxFrameTime, greaterThan(0));
    });

    test('should calculate FPS correctly', () async {
      // Record several frames
      for (int i = 0; i < 10; i++) {
        monitor.startFrame();
        await Future.delayed(const Duration(milliseconds: 16)); // ~60 FPS
        monitor.endFrame();
      }

      final stats = monitor.getStats();
      expect(stats.frameCount, equals(10));
      expect(stats.currentFps, greaterThan(50));
      expect(stats.currentFps, lessThan(70));
    });

    test('should track operations', () async {
      monitor.startOperation('widget_build');
      await Future.delayed(const Duration(milliseconds: 5));
      monitor.endOperation('widget_build');

      monitor.startOperation('state_update');
      await Future.delayed(const Duration(milliseconds: 3));
      monitor.endOperation('state_update');

      final operationStats = monitor.getOperationStats();
      expect(operationStats['widget_build']?.count, equals(1));
      expect(operationStats['widget_build']?.totalTime, greaterThan(0));
      expect(operationStats['state_update']?.count, equals(1));
      expect(operationStats['state_update']?.totalTime, greaterThan(0));
    });

    test('should track memory usage', () async {
      monitor.recordMemoryUsage();

      final stats = monitor.getStats();
      expect(stats.currentMemoryUsage, greaterThan(0));
      expect(stats.peakMemoryUsage, greaterThan(0));
    });

    test('should limit history size', () async {
      // Record more frames than the limit
      for (int i = 0; i < 150; i++) {
        monitor.startFrame();
        monitor.endFrame();
      }

      final stats = monitor.getStats();
      expect(stats.frameCount, equals(150));
      // Internal history should be limited
      expect(monitor.frameTimes.length, lessThanOrEqualTo(100));
    });

    test('should reset stats', () async {
      monitor.startFrame();
      monitor.endFrame();
      monitor.recordMemoryUsage();

      monitor.reset();

      final stats = monitor.getStats();
      expect(stats.frameCount, equals(0));
      expect(stats.averageFrameTime, equals(0));
      expect(stats.currentMemoryUsage, equals(0));
    });

    test('should detect performance issues', () async {
      // Simulate slow frame
      monitor.startFrame();
      await Future.delayed(const Duration(milliseconds: 50)); // Slow frame
      monitor.endFrame();

      final stats = monitor.getStats();
      expect(stats.slowFrameCount, equals(1));
      expect(stats.hasPerformanceIssues, isTrue);
    });

    test('should provide performance level', () async {
      // Good performance
      for (int i = 0; i < 10; i++) {
        monitor.startFrame();
        await Future.delayed(const Duration(milliseconds: 10));
        monitor.endFrame();
      }

      expect(monitor.getPerformanceLevel(), equals(PerformanceLevel.high));

      // Poor performance
      monitor.reset();
      for (int i = 0; i < 10; i++) {
        monitor.startFrame();
        await Future.delayed(const Duration(milliseconds: 40));
        monitor.endFrame();
      }

      expect(monitor.getPerformanceLevel(), equals(PerformanceLevel.low));
    });
  });
}
