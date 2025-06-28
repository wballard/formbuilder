import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Performance level enum
enum PerformanceLevel { high, medium, low }

/// Statistics about performance
class PerformanceStats {
  final int frameCount;
  final double averageFrameTime;
  final double maxFrameTime;
  final double currentFps;
  final int slowFrameCount;
  final int currentMemoryUsage;
  final int peakMemoryUsage;
  final bool hasPerformanceIssues;

  const PerformanceStats({
    required this.frameCount,
    required this.averageFrameTime,
    required this.maxFrameTime,
    required this.currentFps,
    required this.slowFrameCount,
    required this.currentMemoryUsage,
    required this.peakMemoryUsage,
    required this.hasPerformanceIssues,
  });
}

/// Operation statistics
class OperationStats {
  final int count;
  final double totalTime;
  final double averageTime;
  final double maxTime;

  const OperationStats({
    required this.count,
    required this.totalTime,
    required this.averageTime,
    required this.maxTime,
  });
}

/// Performance monitoring utility
class PerformanceMonitor {
  static const int _maxHistorySize = 100;
  static const double _slowFrameThreshold = 16.67 * 2; // 30 FPS threshold

  final Queue<double> _frameTimes = Queue<double>();
  final Map<String, _OperationData> _operations = {};
  final Map<String, DateTime> _activeOperations = {};

  DateTime? _frameStartTime;
  int _totalFrameCount = 0;
  int _slowFrameCount = 0;
  double _maxFrameTime = 0;

  int _currentMemoryUsage = 0;
  int _peakMemoryUsage = 0;

  /// Get frame times for testing
  @visibleForTesting
  Queue<double> get frameTimes => _frameTimes;

  /// Start tracking a new frame
  void startFrame() {
    _frameStartTime = DateTime.now();
  }

  /// End tracking the current frame
  void endFrame() {
    if (_frameStartTime == null) return;

    final frameTime =
        DateTime.now().difference(_frameStartTime!).inMicroseconds / 1000.0;
    _frameTimes.addLast(frameTime);

    if (_frameTimes.length > _maxHistorySize) {
      _frameTimes.removeFirst();
    }

    _totalFrameCount++;
    if (frameTime > _slowFrameThreshold) {
      _slowFrameCount++;
    }

    if (frameTime > _maxFrameTime) {
      _maxFrameTime = frameTime;
    }

    _frameStartTime = null;
  }

  /// Start tracking an operation
  void startOperation(String name) {
    _activeOperations[name] = DateTime.now();
  }

  /// End tracking an operation
  void endOperation(String name) {
    final startTime = _activeOperations.remove(name);
    if (startTime == null) return;

    final duration =
        DateTime.now().difference(startTime).inMicroseconds / 1000.0;

    _operations.putIfAbsent(name, () => _OperationData());
    _operations[name]!.addSample(duration);
  }

  /// Record current memory usage
  void recordMemoryUsage() {
    // In a real implementation, this would get actual memory usage
    // For testing, we'll use a mock value
    _currentMemoryUsage = 100 * 1024 * 1024; // 100 MB mock value
    if (_currentMemoryUsage > _peakMemoryUsage) {
      _peakMemoryUsage = _currentMemoryUsage;
    }
  }

  /// Get performance statistics
  PerformanceStats getStats() {
    final frameCount = _totalFrameCount;
    double averageFrameTime = 0;
    double currentFps = 0;

    if (_frameTimes.isNotEmpty) {
      averageFrameTime =
          _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
      currentFps = averageFrameTime > 0 ? 1000 / averageFrameTime : 0;
    }

    return PerformanceStats(
      frameCount: frameCount,
      averageFrameTime: averageFrameTime,
      maxFrameTime: _maxFrameTime,
      currentFps: currentFps,
      slowFrameCount: _slowFrameCount,
      currentMemoryUsage: _currentMemoryUsage,
      peakMemoryUsage: _peakMemoryUsage,
      hasPerformanceIssues:
          _slowFrameCount > frameCount * 0.05, // More than 5% slow frames
    );
  }

  /// Get operation statistics
  Map<String, OperationStats> getOperationStats() {
    final stats = <String, OperationStats>{};

    _operations.forEach((name, data) {
      stats[name] = OperationStats(
        count: data.count,
        totalTime: data.totalTime,
        averageTime: data.averageTime,
        maxTime: data.maxTime,
      );
    });

    return stats;
  }

  /// Get current performance level
  PerformanceLevel getPerformanceLevel() {
    final stats = getStats();

    if (stats.currentFps >= 55) {
      return PerformanceLevel.high;
    } else if (stats.currentFps >= 30) {
      return PerformanceLevel.medium;
    } else {
      return PerformanceLevel.low;
    }
  }

  /// Reset all statistics
  void reset() {
    _frameTimes.clear();
    _operations.clear();
    _activeOperations.clear();
    _frameStartTime = null;
    _totalFrameCount = 0;
    _slowFrameCount = 0;
    _maxFrameTime = 0;
    _currentMemoryUsage = 0;
    _peakMemoryUsage = 0;
  }

  /// Dispose of resources
  void dispose() {
    reset();
  }
}

/// Internal class to track operation data
class _OperationData {
  int count = 0;
  double totalTime = 0;
  double maxTime = 0;

  void addSample(double time) {
    count++;
    totalTime += time;
    if (time > maxTime) {
      maxTime = time;
    }
  }

  double get averageTime => count > 0 ? totalTime / count : 0;
}
