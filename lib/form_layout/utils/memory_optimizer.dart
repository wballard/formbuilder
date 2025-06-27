import 'package:flutter/material.dart';
import 'dart:collection';
import 'dart:async';

/// Memory optimization utility for tracking and managing memory usage
class MemoryOptimizer {
  static const int _memoryPressureThreshold = 512 * 1024 * 1024; // 512 MB
  static const int _cleanupThreshold = 400 * 1024 * 1024; // 400 MB
  
  int _currentMemoryUsage = 0;
  int _peakMemoryUsage = 0;
  final Map<String, int> _allocations = {};
  bool _disposed = false;
  
  /// Current memory usage in bytes
  int get currentMemoryUsage => _currentMemoryUsage;
  
  /// Peak memory usage in bytes
  int get peakMemoryUsage => _peakMemoryUsage;
  
  /// Record current memory usage
  void recordMemoryUsage(int bytes) {
    if (_disposed) return;
    
    _currentMemoryUsage = bytes;
    if (bytes > _peakMemoryUsage) {
      _peakMemoryUsage = bytes;
    }
  }
  
  /// Check if system is under memory pressure
  bool isUnderMemoryPressure() {
    return _currentMemoryUsage > _memoryPressureThreshold;
  }
  
  /// Check if memory cleanup should be performed
  bool shouldCleanupMemory() {
    return _currentMemoryUsage > _cleanupThreshold;
  }
  
  /// Track an allocation with a tag
  void trackAllocation(String tag, int bytes) {
    if (_disposed) return;
    _allocations[tag] = bytes;
  }
  
  /// Release an allocation
  void releaseAllocation(String tag) {
    _allocations.remove(tag);
  }
  
  /// Get size of allocation by tag
  int getAllocationSize(String tag) {
    return _allocations[tag] ?? 0;
  }
  
  /// Get total tracked allocations
  int get totalTrackedAllocations {
    return _allocations.values.fold(0, (sum, size) => sum + size);
  }
  
  /// Reset all memory statistics
  void reset() {
    _currentMemoryUsage = 0;
    _peakMemoryUsage = 0;
    _allocations.clear();
  }
  
  /// Dispose of the optimizer
  void dispose() {
    _disposed = true;
    _allocations.clear();
  }
}

/// Limited history manager that automatically removes old entries
class LimitedHistoryManager<T> {
  LimitedHistoryManager({required this.maxSize})
    : assert(maxSize > 0, 'Max size must be greater than 0');
  
  final int maxSize;
  final Queue<T> _items = Queue<T>();
  int _currentIndex = -1;
  
  /// Current number of items
  int get length => _items.length;
  
  /// All items in order
  List<T> get items => _items.toList();
  
  /// Whether undo is possible
  bool get canUndo => _currentIndex > 0;
  
  /// Whether redo is possible  
  bool get canRedo => _currentIndex < _items.length - 1;
  
  /// Add an item to history
  void add(T item) {
    // If we're not at the end, remove everything after current position
    while (_items.length > _currentIndex + 1) {
      _items.removeLast();
    }
    
    _items.addLast(item);
    _currentIndex = _items.length - 1;
    
    // Remove oldest items if we exceed max size
    while (_items.length > maxSize) {
      _items.removeFirst();
      _currentIndex--;
    }
    
    // Ensure current index is valid
    if (_currentIndex < 0 && _items.isNotEmpty) {
      _currentIndex = 0;
    }
  }
  
  /// Undo to previous item
  T? undo() {
    if (!canUndo) return null;
    
    _currentIndex--;
    return _items.elementAt(_currentIndex);
  }
  
  /// Redo to next item
  T? redo() {
    if (!canRedo) return null;
    
    _currentIndex++;
    return _items.elementAt(_currentIndex);
  }
  
  /// Get current item
  T? get current {
    if (_currentIndex < 0 || _currentIndex >= _items.length) return null;
    return _items.elementAt(_currentIndex);
  }
  
  /// Clear all history
  void clear() {
    _items.clear();
    _currentIndex = -1;
  }
}

/// Resource pool for reusing expensive objects
class ResourcePool<T> {
  ResourcePool({
    required this.factory,
    this.onDispose,
    this.maxSize = 10,
  }) : assert(maxSize > 0, 'Max size must be greater than 0');
  
  final T Function() factory;
  final void Function(T)? onDispose;
  final int maxSize;
  final Queue<T> _available = Queue<T>();
  bool _disposed = false;
  
  /// Number of available resources
  int get availableCount => _available.length;
  
  /// Acquire a resource from the pool
  T acquire() {
    if (_disposed) throw StateError('Resource pool has been disposed');
    
    if (_available.isNotEmpty) {
      return _available.removeFirst();
    }
    
    return factory();
  }
  
  /// Release a resource back to the pool
  void release(T resource) {
    if (_disposed) return;
    
    if (_available.length < maxSize) {
      _available.addLast(resource);
    } else {
      // Pool is full, dispose the resource
      onDispose?.call(resource);
    }
  }
  
  /// Dispose the pool and all resources
  void disposePool() {
    _disposed = true;
    
    while (_available.isNotEmpty) {
      final resource = _available.removeFirst();
      onDispose?.call(resource);
    }
  }
  
  // Use different name to avoid conflict with Object.dispose if T is a widget
  void dispose() => disposePool();
}

/// Widget that responds to memory pressure
class MemoryAwareWidget extends StatefulWidget {
  const MemoryAwareWidget({
    super.key,
    required this.child,
    this.onMemoryPressure,
    this.memoryCheckInterval = const Duration(seconds: 5),
  });
  
  final Widget child;
  final VoidCallback? onMemoryPressure;
  final Duration memoryCheckInterval;
  
  @override
  State<MemoryAwareWidget> createState() => MemoryAwareWidgetState();
}

class MemoryAwareWidgetState extends State<MemoryAwareWidget> {
  Timer? _memoryCheckTimer;
  final MemoryOptimizer _optimizer = MemoryOptimizer();
  
  @override
  void initState() {
    super.initState();
    _startMemoryMonitoring();
  }
  
  @override
  void dispose() {
    _memoryCheckTimer?.cancel();
    _optimizer.dispose();
    super.dispose();
  }
  
  void _startMemoryMonitoring() {
    _memoryCheckTimer = Timer.periodic(widget.memoryCheckInterval, (_) {
      _checkMemoryPressure();
    });
  }
  
  void _checkMemoryPressure() {
    // In a real implementation, this would get actual memory usage
    // For testing, we use a mock value
    _optimizer.recordMemoryUsage(100 * 1024 * 1024); // 100 MB mock
    
    if (_optimizer.shouldCleanupMemory()) {
      widget.onMemoryPressure?.call();
    }
  }
  
  /// Method to simulate memory pressure for testing
  void simulateMemoryPressure() {
    widget.onMemoryPressure?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mixin for automatic resource cleanup
mixin AutoCleanupMixin<T extends StatefulWidget> on State<T> {
  final List<VoidCallback> _cleanupCallbacks = [];
  
  /// Register a cleanup callback
  void registerCleanup(VoidCallback callback) {
    _cleanupCallbacks.add(callback);
  }
  
  /// Remove a cleanup callback
  void unregisterCleanup(VoidCallback callback) {
    _cleanupCallbacks.remove(callback);
  }
  
  @override
  void dispose() {
    // Call all cleanup callbacks
    for (final callback in _cleanupCallbacks) {
      try {
        callback();
      } catch (e) {
        // Log error but continue with other cleanups
        debugPrint('Error during cleanup: $e');
      }
    }
    _cleanupCallbacks.clear();
    super.dispose();
  }
}

/// Cache with automatic cleanup based on memory pressure
class MemoryAwareCache<K, V> {
  MemoryAwareCache({
    this.maxSize = 100,
    this.memoryOptimizer,
  });
  
  final int maxSize;
  final MemoryOptimizer? memoryOptimizer;
  final Map<K, V> _cache = {};
  final Queue<K> _accessOrder = Queue<K>();
  
  /// Get value from cache
  V? get(K key) {
    final value = _cache[key];
    if (value != null) {
      // Move to end of access order
      _accessOrder.remove(key);
      _accessOrder.addLast(key);
    }
    return value;
  }
  
  /// Put value in cache
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache[key] = value;
      _accessOrder.remove(key);
      _accessOrder.addLast(key);
    } else {
      _cache[key] = value;
      _accessOrder.addLast(key);
      
      // Check if we need to evict
      _evictIfNeeded();
    }
  }
  
  /// Remove value from cache
  V? remove(K key) {
    _accessOrder.remove(key);
    return _cache.remove(key);
  }
  
  /// Clear all cached values
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }
  
  /// Current cache size
  int get size => _cache.length;
  
  /// Check if cache contains key
  bool containsKey(K key) => _cache.containsKey(key);
  
  void _evictIfNeeded() {
    // Always respect max size
    while (_cache.length > maxSize) {
      _evictLeastRecentlyUsed();
    }
    
    // Additional eviction if under memory pressure
    if (memoryOptimizer?.shouldCleanupMemory() == true) {
      final targetSize = (maxSize * 0.7).round(); // Evict 30%
      while (_cache.length > targetSize) {
        _evictLeastRecentlyUsed();
      }
    }
  }
  
  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isNotEmpty) {
      final oldestKey = _accessOrder.removeFirst();
      _cache.remove(oldestKey);
    }
  }
}

/// Timer that automatically cleans up
class AutoCleanupTimer {
  AutoCleanupTimer({
    required this.duration,
    required this.callback,
    this.periodic = false,
  }) {
    if (periodic) {
      _timer = Timer.periodic(duration, (_) => callback());
    } else {
      _timer = Timer(duration, callback);
    }
  }
  
  final Duration duration;
  final VoidCallback callback;
  final bool periodic;
  Timer? _timer;
  
  /// Check if timer is active
  bool get isActive => _timer?.isActive ?? false;
  
  /// Cancel the timer
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Dispose (alias for cancel)
  void dispose() => cancel();
}