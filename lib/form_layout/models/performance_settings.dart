import 'package:flutter/foundation.dart';
import 'dart:collection';

/// Quality levels for performance optimization
enum QualityLevel {
  low('Low Quality', 'Prioritizes performance over visual quality'),
  balanced('Balanced', 'Good balance between performance and quality'),
  high('High Quality', 'Prioritizes visual quality over performance');

  const QualityLevel(this.displayName, this.description);
  
  final String displayName;
  final String description;
  
  /// Animation duration for this quality level
  Duration get animationDuration {
    switch (this) {
      case QualityLevel.low:
        return const Duration(milliseconds: 100);
      case QualityLevel.balanced:
        return const Duration(milliseconds: 200);
      case QualityLevel.high:
        return const Duration(milliseconds: 300);
    }
  }
  
  /// Render scale factor for this quality level
  double get renderScale {
    switch (this) {
      case QualityLevel.low:
        return 0.8;
      case QualityLevel.balanced:
        return 1.0;
      case QualityLevel.high:
        return 1.0;
    }
  }
  
  /// Whether to use anti-aliasing
  bool get useAntiAliasing {
    switch (this) {
      case QualityLevel.low:
        return false;
      case QualityLevel.balanced:
        return true;
      case QualityLevel.high:
        return true;
    }
  }
}

/// Performance settings for the form builder
@immutable
class PerformanceSettings {
  const PerformanceSettings({
    this.qualityLevel = QualityLevel.balanced,
    this.enableAnimations = true,
    this.enableVirtualScrolling = true,
    this.maxHistorySize = 50,
    this.dragUpdateFrequency = 60,
    this.enableMemoryOptimization = true,
    this.enableDebugMode = false,
    this.autoAdaptPerformance = false,
    this.cacheSize = 100,
    this.enableBackgroundProcessing = true,
  }) : assert(maxHistorySize > 0, 'Max history size must be greater than 0'),
       assert(dragUpdateFrequency > 0, 'Drag update frequency must be greater than 0'),
       assert(cacheSize >= 0, 'Cache size must be non-negative');

  final QualityLevel qualityLevel;
  final bool enableAnimations;
  final bool enableVirtualScrolling;
  final int maxHistorySize;
  final int dragUpdateFrequency;
  final bool enableMemoryOptimization;
  final bool enableDebugMode;
  final bool autoAdaptPerformance;
  final int cacheSize;
  final bool enableBackgroundProcessing;

  /// Whether this is in auto-adaptation mode
  bool get isAutoMode => autoAdaptPerformance;

  /// Create settings optimized for low-performance devices
  const PerformanceSettings.lowPerformance()
      : qualityLevel = QualityLevel.low,
        enableAnimations = false,
        enableVirtualScrolling = true,
        maxHistorySize = 20,
        dragUpdateFrequency = 30,
        enableMemoryOptimization = true,
        enableDebugMode = false,
        autoAdaptPerformance = false,
        cacheSize = 50,
        enableBackgroundProcessing = false;

  /// Create settings optimized for high-performance devices
  const PerformanceSettings.highPerformance()
      : qualityLevel = QualityLevel.high,
        enableAnimations = true,
        enableVirtualScrolling = true,
        maxHistorySize = 100,
        dragUpdateFrequency = 120,
        enableMemoryOptimization = false,
        enableDebugMode = false,
        autoAdaptPerformance = false,
        cacheSize = 200,
        enableBackgroundProcessing = true;

  /// Create settings optimized for battery saving
  const PerformanceSettings.batterySaver()
      : qualityLevel = QualityLevel.low,
        enableAnimations = false,
        enableVirtualScrolling = true,
        maxHistorySize = 15,
        dragUpdateFrequency = 20,
        enableMemoryOptimization = true,
        enableDebugMode = false,
        autoAdaptPerformance = false,
        cacheSize = 30,
        enableBackgroundProcessing = false;

  /// Create settings with auto-adaptation enabled
  const PerformanceSettings.auto()
      : qualityLevel = QualityLevel.balanced,
        enableAnimations = true,
        enableVirtualScrolling = true,
        maxHistorySize = 50,
        dragUpdateFrequency = 60,
        enableMemoryOptimization = true,
        enableDebugMode = false,
        autoAdaptPerformance = true,
        cacheSize = 100,
        enableBackgroundProcessing = true;

  /// Create a copy with modified values
  PerformanceSettings copyWith({
    QualityLevel? qualityLevel,
    bool? enableAnimations,
    bool? enableVirtualScrolling,
    int? maxHistorySize,
    int? dragUpdateFrequency,
    bool? enableMemoryOptimization,
    bool? enableDebugMode,
    bool? autoAdaptPerformance,
    int? cacheSize,
    bool? enableBackgroundProcessing,
  }) {
    return PerformanceSettings(
      qualityLevel: qualityLevel ?? this.qualityLevel,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableVirtualScrolling: enableVirtualScrolling ?? this.enableVirtualScrolling,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
      dragUpdateFrequency: dragUpdateFrequency ?? this.dragUpdateFrequency,
      enableMemoryOptimization: enableMemoryOptimization ?? this.enableMemoryOptimization,
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      autoAdaptPerformance: autoAdaptPerformance ?? this.autoAdaptPerformance,
      cacheSize: cacheSize ?? this.cacheSize,
      enableBackgroundProcessing: enableBackgroundProcessing ?? this.enableBackgroundProcessing,
    );
  }

  /// Get effective settings based on current performance metrics
  PerformanceSettings getEffectiveSettings({
    required double currentFps,
    required int memoryUsage, // in MB
  }) {
    if (!autoAdaptPerformance) return this;

    // Determine quality level based on performance
    QualityLevel effectiveQuality;
    bool effectiveAnimations;

    if (currentFps >= 50 && memoryUsage < 200) {
      effectiveQuality = QualityLevel.high;
      effectiveAnimations = true;
    } else if (currentFps >= 30 && memoryUsage < 400) {
      effectiveQuality = QualityLevel.balanced;
      effectiveAnimations = enableAnimations;
    } else {
      effectiveQuality = QualityLevel.low;
      effectiveAnimations = false;
    }

    return copyWith(
      qualityLevel: effectiveQuality,
      enableAnimations: effectiveAnimations,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'qualityLevel': qualityLevel.name,
      'enableAnimations': enableAnimations,
      'enableVirtualScrolling': enableVirtualScrolling,
      'maxHistorySize': maxHistorySize,
      'dragUpdateFrequency': dragUpdateFrequency,
      'enableMemoryOptimization': enableMemoryOptimization,
      'enableDebugMode': enableDebugMode,
      'autoAdaptPerformance': autoAdaptPerformance,
      'cacheSize': cacheSize,
      'enableBackgroundProcessing': enableBackgroundProcessing,
    };
  }

  /// Create from JSON
  factory PerformanceSettings.fromJson(Map<String, dynamic> json) {
    return PerformanceSettings(
      qualityLevel: QualityLevel.values.firstWhere(
        (e) => e.name == json['qualityLevel'],
        orElse: () => QualityLevel.balanced,
      ),
      enableAnimations: json['enableAnimations'] ?? true,
      enableVirtualScrolling: json['enableVirtualScrolling'] ?? true,
      maxHistorySize: json['maxHistorySize'] ?? 50,
      dragUpdateFrequency: json['dragUpdateFrequency'] ?? 60,
      enableMemoryOptimization: json['enableMemoryOptimization'] ?? true,
      enableDebugMode: json['enableDebugMode'] ?? false,
      autoAdaptPerformance: json['autoAdaptPerformance'] ?? false,
      cacheSize: json['cacheSize'] ?? 100,
      enableBackgroundProcessing: json['enableBackgroundProcessing'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformanceSettings &&
          runtimeType == other.runtimeType &&
          qualityLevel == other.qualityLevel &&
          enableAnimations == other.enableAnimations &&
          enableVirtualScrolling == other.enableVirtualScrolling &&
          maxHistorySize == other.maxHistorySize &&
          dragUpdateFrequency == other.dragUpdateFrequency &&
          enableMemoryOptimization == other.enableMemoryOptimization &&
          enableDebugMode == other.enableDebugMode &&
          autoAdaptPerformance == other.autoAdaptPerformance &&
          cacheSize == other.cacheSize &&
          enableBackgroundProcessing == other.enableBackgroundProcessing;

  @override
  int get hashCode =>
      qualityLevel.hashCode ^
      enableAnimations.hashCode ^
      enableVirtualScrolling.hashCode ^
      maxHistorySize.hashCode ^
      dragUpdateFrequency.hashCode ^
      enableMemoryOptimization.hashCode ^
      enableDebugMode.hashCode ^
      autoAdaptPerformance.hashCode ^
      cacheSize.hashCode ^
      enableBackgroundProcessing.hashCode;

  @override
  String toString() =>
      'PerformanceSettings(qualityLevel: $qualityLevel, enableAnimations: $enableAnimations, autoAdaptPerformance: $autoAdaptPerformance)';
}

/// Performance metrics tracking
class PerformanceMetrics {
  const PerformanceMetrics({
    required this.averageFrameTime,
    required this.averageFps,
    required this.peakMemoryUsage,
    required this.averageMemoryUsage,
    required this.frameDropCount,
  });

  final double averageFrameTime;
  final double averageFps;
  final int peakMemoryUsage;
  final int averageMemoryUsage;
  final int frameDropCount;
}

/// Performance profiler for automatic optimization
class PerformanceProfiler {
  static const int _maxHistorySize = 60; // Keep 60 samples
  static const double _frameDropThreshold = 33.33; // 30 FPS threshold

  final Queue<double> _frameTimes = Queue<double>();
  final Queue<int> _memoryUsages = Queue<int>();
  PerformanceSettings _currentSettings = const PerformanceSettings();
  int _frameDropCount = 0;

  /// Update current performance settings
  void updateSettings(PerformanceSettings settings) {
    _currentSettings = settings;
  }

  /// Record performance metrics
  void recordPerformanceMetrics({
    required double frameTime,
    required int memoryUsage,
  }) {
    _frameTimes.addLast(frameTime);
    _memoryUsages.addLast(memoryUsage);

    if (frameTime > _frameDropThreshold) {
      _frameDropCount++;
    }

    // Limit history size
    while (_frameTimes.length > _maxHistorySize) {
      _frameTimes.removeFirst();
    }
    while (_memoryUsages.length > _maxHistorySize) {
      _memoryUsages.removeFirst();
    }
  }

  /// Get current performance metrics
  PerformanceMetrics getPerformanceMetrics() {
    if (_frameTimes.isEmpty) {
      return const PerformanceMetrics(
        averageFrameTime: 16.67,
        averageFps: 60.0,
        peakMemoryUsage: 0,
        averageMemoryUsage: 0,
        frameDropCount: 0,
      );
    }

    final avgFrameTime = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    final avgFps = 1000 / avgFrameTime;
    final avgMemory = _memoryUsages.reduce((a, b) => a + b) ~/ _memoryUsages.length;
    final peakMemory = _memoryUsages.reduce((a, b) => a > b ? a : b);

    return PerformanceMetrics(
      averageFrameTime: avgFrameTime,
      averageFps: avgFps,
      peakMemoryUsage: peakMemory,
      averageMemoryUsage: avgMemory,
      frameDropCount: _frameDropCount,
    );
  }

  /// Suggest settings based on device capabilities
  PerformanceSettings suggestSettings({
    required int deviceRam, // in MB
    required int cpuCores,
    required int gpuMemory, // in MB
  }) {
    // High-end device criteria
    if (deviceRam >= 6 * 1024 && cpuCores >= 6 && gpuMemory >= 2 * 1024) {
      return const PerformanceSettings.highPerformance();
    }
    
    // Low-end device criteria
    if (deviceRam <= 3 * 1024 || cpuCores <= 4 || gpuMemory <= 1024) {
      return const PerformanceSettings.lowPerformance();
    }
    
    // Medium-end device - use balanced settings
    return const PerformanceSettings();
  }

  /// Get adapted settings based on current performance
  PerformanceSettings getAdaptedSettings() {
    if (!_currentSettings.autoAdaptPerformance) {
      return _currentSettings;
    }

    final metrics = getPerformanceMetrics();
    
    return _currentSettings.getEffectiveSettings(
      currentFps: metrics.averageFps,
      memoryUsage: metrics.averageMemoryUsage ~/ (1024 * 1024), // Convert bytes to MB
    );
  }

  /// Reset all metrics
  void reset() {
    _frameTimes.clear();
    _memoryUsages.clear();
    _frameDropCount = 0;
  }

  /// Dispose of the profiler
  void dispose() {
    reset();
  }
}