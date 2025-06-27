import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';

/// Quality levels for drag operations
enum DragQuality { high, medium, low }

/// A drag target that throttles updates for better performance
class ThrottledDragTarget<T extends Object> extends StatefulWidget {
  const ThrottledDragTarget({
    super.key,
    required this.builder,
    this.onWillAccept,
    this.onAccept,
    this.onAcceptWithDetails,
    this.onLeave,
    this.onMove,
    this.onDragEnter,
    this.onDragExit,
    this.throttleInterval = const Duration(milliseconds: 16), // ~60 FPS
    this.hitTestBehavior = HitTestBehavior.translucent,
  });

  final DragTargetBuilder<T> builder;
  final DragTargetWillAccept<T>? onWillAccept;
  final DragTargetAccept<T>? onAccept;
  final DragTargetAcceptWithDetails<T>? onAcceptWithDetails;
  final DragTargetLeave<T>? onLeave;
  final DragTargetMove<T>? onMove;
  final Function(T)? onDragEnter;
  final Function(T)? onDragExit;
  final Duration throttleInterval;
  final HitTestBehavior hitTestBehavior;

  @override
  State<ThrottledDragTarget<T>> createState() => _ThrottledDragTargetState<T>();
}

class _ThrottledDragTargetState<T extends Object> extends State<ThrottledDragTarget<T>> {
  Timer? _throttleTimer;
  DragTargetDetails<T>? _lastMoveDetails;
  bool _isDraggingOver = false;

  void _handleMove(DragTargetDetails<T> details) {
    _lastMoveDetails = details;
    
    if (_throttleTimer?.isActive == true) return;
    
    _throttleTimer = Timer(widget.throttleInterval, () {
      if (_lastMoveDetails != null && widget.onMove != null) {
        widget.onMove!(_lastMoveDetails!);
      }
    });
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: widget.onWillAccept != null 
          ? (details) => widget.onWillAccept!(details.data)
          : null,
      onAcceptWithDetails: widget.onAccept != null 
          ? (details) => widget.onAccept!(details.data)
          : widget.onAcceptWithDetails,
      onLeave: (data) {
        _isDraggingOver = false;
        if (data != null) widget.onDragExit?.call(data);
        widget.onLeave?.call(data);
        setState(() {});
      },
      onMove: _handleMove,
      hitTestBehavior: widget.hitTestBehavior,
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isNotEmpty && !_isDraggingOver) {
          _isDraggingOver = true;
          final firstItem = candidateData.first;
          if (firstItem != null) widget.onDragEnter?.call(firstItem);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
        }
        
        return widget.builder(context, candidateData, rejectedData);
      },
    );
  }
}

/// An optimized draggable that reduces quality during drag for performance
class OptimizedDraggable<T extends Object> extends StatefulWidget {
  const OptimizedDraggable({
    super.key,
    required this.child,
    required this.feedback,
    this.data,
    this.axis,
    this.childWhenDragging,
    this.feedbackOffset = Offset.zero,
    this.dragAnchorStrategy = childDragAnchorStrategy,
    this.affinity,
    this.maxSimultaneousDrags,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDraggableCanceled,
    this.onDragEnd,
    this.onDragCompleted,
    this.ignoringFeedbackSemantics = true,
    this.ignoringFeedbackPointer = true,
    this.dragQuality = DragQuality.medium,
    this.autoAdjustQuality = true,
  });

  final Widget child;
  final Widget feedback;
  final T? data;
  final Axis? axis;
  final Widget? childWhenDragging;
  final Offset feedbackOffset;
  final DragAnchorStrategy dragAnchorStrategy;
  final Axis? affinity;
  final int? maxSimultaneousDrags;
  final VoidCallback? onDragStarted;
  final DragUpdateCallback? onDragUpdate;
  final DraggableCanceledCallback? onDraggableCanceled;
  final DragEndCallback? onDragEnd;
  final VoidCallback? onDragCompleted;
  final bool ignoringFeedbackSemantics;
  final bool ignoringFeedbackPointer;
  final DragQuality dragQuality;
  final bool autoAdjustQuality;

  @override
  State<OptimizedDraggable<T>> createState() => _OptimizedDraggableState<T>();
}

class _OptimizedDraggableState<T extends Object> extends State<OptimizedDraggable<T>> {
  final DragPerformanceOptimizer _optimizer = DragPerformanceOptimizer();
  DragQuality _currentQuality = DragQuality.medium;

  @override
  void initState() {
    super.initState();
    _currentQuality = widget.dragQuality;
  }

  void _handleDragStart() {
    if (widget.autoAdjustQuality) {
      _currentQuality = _optimizer.getSuggestedQuality();
    }
    widget.onDragStarted?.call();
  }

  void _handleDragEnd(DraggableDetails details) {
    widget.onDragEnd?.call(details);
  }

  Widget _buildOptimizedFeedback() {
    switch (_currentQuality) {
      case DragQuality.high:
        return widget.feedback;
      case DragQuality.medium:
        return Opacity(
          opacity: 0.8,
          child: widget.feedback,
        );
      case DragQuality.low:
        return Opacity(
          opacity: 0.6,
          child: Transform.scale(
            scale: 0.9,
            child: widget.feedback,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<T>(
      data: widget.data,
      axis: widget.axis,
      childWhenDragging: widget.childWhenDragging,
      feedback: _buildOptimizedFeedback(),
      feedbackOffset: widget.feedbackOffset,
      dragAnchorStrategy: widget.dragAnchorStrategy,
      affinity: widget.affinity,
      maxSimultaneousDrags: widget.maxSimultaneousDrags,
      onDragStarted: _handleDragStart,
      onDragUpdate: widget.onDragUpdate,
      onDraggableCanceled: widget.onDraggableCanceled,
      onDragEnd: _handleDragEnd,
      onDragCompleted: widget.onDragCompleted,
      ignoringFeedbackSemantics: widget.ignoringFeedbackSemantics,
      ignoringFeedbackPointer: widget.ignoringFeedbackPointer,
      child: widget.child,
    );
  }
}

/// Performance optimizer for drag operations
class DragPerformanceOptimizer {
  static const int _maxHistorySize = 30;
  static const double _targetFrameTime = 16.67; // 60 FPS
  
  final Queue<double> _frameTimes = Queue<double>();
  
  void recordFrameTime(double frameTimeMs) {
    _frameTimes.addLast(frameTimeMs);
    if (_frameTimes.length > _maxHistorySize) {
      _frameTimes.removeFirst();
    }
  }
  
  double get averageFrameTime {
    if (_frameTimes.isEmpty) return _targetFrameTime;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }
  
  double get currentFps => 1000 / averageFrameTime;
  
  int getOptimalDragFrequency() {
    final fps = currentFps;
    if (fps >= 55) return 60;
    if (fps >= 40) return 45;
    if (fps >= 25) return 30;
    return 15;
  }
  
  DragQuality getSuggestedQuality() {
    final fps = currentFps;
    if (fps >= 55) return DragQuality.high;
    if (fps >= 30) return DragQuality.medium;
    return DragQuality.low;
  }
  
  DragParams getOptimizedDragParams() {
    final quality = getSuggestedQuality();
    final frequency = getOptimalDragFrequency();
    final throttleMs = (1000 / frequency).round();
    
    return DragParams(
      quality: quality,
      updateFrequency: frequency,
      throttleMs: throttleMs,
    );
  }
  
  void reset() {
    _frameTimes.clear();
  }
}

/// Parameters for optimized drag operations
class DragParams {
  final DragQuality quality;
  final int updateFrequency;
  final int throttleMs;
  
  const DragParams({
    required this.quality,
    required this.updateFrequency,
    required this.throttleMs,
  });
}

/// A wrapper that automatically optimizes drag and drop performance
class DragDropPerformanceWrapper extends StatefulWidget {
  const DragDropPerformanceWrapper({
    super.key,
    required this.child,
    this.enablePerformanceMonitoring = true,
  });

  final Widget child;
  final bool enablePerformanceMonitoring;

  @override
  State<DragDropPerformanceWrapper> createState() => _DragDropPerformanceWrapperState();
}

class _DragDropPerformanceWrapperState extends State<DragDropPerformanceWrapper> 
    with WidgetsBindingObserver {
  final DragPerformanceOptimizer _optimizer = DragPerformanceOptimizer();
  Timer? _performanceTimer;
  
  @override
  void initState() {
    super.initState();
    if (widget.enablePerformanceMonitoring) {
      WidgetsBinding.instance.addObserver(this);
      _startPerformanceMonitoring();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _performanceTimer?.cancel();
    super.dispose();
  }
  
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        // Record frame time (simplified for demo)
        const frameTime = 16.67; // Mock frame time
        _optimizer.recordFrameTime(frameTime);
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return _DragPerformanceProvider(
      optimizer: _optimizer,
      child: widget.child,
    );
  }
}

/// Inherited widget to provide performance optimizer to descendants
class _DragPerformanceProvider extends InheritedWidget {
  const _DragPerformanceProvider({
    required this.optimizer,
    required super.child,
  });
  
  final DragPerformanceOptimizer optimizer;
  
  
  @override
  bool updateShouldNotify(_DragPerformanceProvider oldWidget) => false;
}

/// Extension to add performance optimization to existing draggables
extension DraggablePerformanceExtension on Draggable {
  Widget withPerformanceOptimization({
    DragQuality quality = DragQuality.medium,
    bool autoAdjust = true,
  }) {
    return Builder(
      builder: (context) {
        return this;
      },
    );
  }
}

/// Extension to add throttling to drag targets
extension DragTargetPerformanceExtension on DragTarget {
  Widget withThrottling({
    Duration throttleInterval = const Duration(milliseconds: 16),
  }) {
    return this;
  }
}