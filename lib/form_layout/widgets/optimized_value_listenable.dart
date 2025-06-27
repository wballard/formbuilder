import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// An optimized ValueListenableBuilder that avoids unnecessary rebuilds
class OptimizedValueListenableBuilder<T> extends StatefulWidget {
  const OptimizedValueListenableBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
    this.child,
  });

  final ValueListenable<T> valueListenable;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;

  @override
  State<OptimizedValueListenableBuilder<T>> createState() =>
      _OptimizedValueListenableBuilderState<T>();
}

class _OptimizedValueListenableBuilderState<T>
    extends State<OptimizedValueListenableBuilder<T>> {
  late T _value;
  
  @override
  void initState() {
    super.initState();
    _value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(OptimizedValueListenableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      _value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
    final newValue = widget.valueListenable.value;
    // Only rebuild if value actually changed
    if (_value != newValue) {
      setState(() {
        _value = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value, widget.child);
  }
}

/// A ValueNotifier that debounces changes to reduce unnecessary updates
class DebouncedValueNotifier<T> extends ValueNotifier<T> {
  DebouncedValueNotifier({
    required T initialValue,
    required this.debounceTime,
  }) : super(initialValue);

  final Duration debounceTime;
  Timer? _debounceTimer;
  T? _pendingValue;

  @override
  set value(T newValue) {
    _pendingValue = newValue;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceTime, () {
      if (_pendingValue != null && _pendingValue != value) {
        super.value = _pendingValue as T;
      }
      _pendingValue = null;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// A builder that only rebuilds when a specific part of the state changes
class SelectiveStateBuilder<TState, TSelected> extends StatefulWidget {
  const SelectiveStateBuilder({
    super.key,
    required this.valueListenable,
    required this.selector,
    required this.builder,
    this.child,
  });

  final ValueListenable<TState> valueListenable;
  final TSelected Function(TState) selector;
  final Widget Function(BuildContext, TSelected, Widget?) builder;
  final Widget? child;

  @override
  State<SelectiveStateBuilder<TState, TSelected>> createState() =>
      _SelectiveStateBuilderState<TState, TSelected>();
}

class _SelectiveStateBuilderState<TState, TSelected>
    extends State<SelectiveStateBuilder<TState, TSelected>> {
  late TSelected _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selector(widget.valueListenable.value);
    widget.valueListenable.addListener(_stateChanged);
  }

  @override
  void didUpdateWidget(SelectiveStateBuilder<TState, TSelected> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable ||
        oldWidget.selector != widget.selector) {
      oldWidget.valueListenable.removeListener(_stateChanged);
      _selectedValue = widget.selector(widget.valueListenable.value);
      widget.valueListenable.addListener(_stateChanged);
    }
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_stateChanged);
    super.dispose();
  }

  void _stateChanged() {
    final newSelectedValue = widget.selector(widget.valueListenable.value);
    // Only rebuild if the selected value changed
    if (_selectedValue != newSelectedValue) {
      setState(() {
        _selectedValue = newSelectedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selectedValue, widget.child);
  }
}

/// Utility mixin for state classes to provide change notifications
mixin ChangeNotifierState<T extends StatefulWidget> on State<T> {
  final List<VoidCallback> _listeners = [];
  
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
  
  @override
  void dispose() {
    _listeners.clear();
    super.dispose();
  }
}

/// A throttled version of ValueNotifier that limits update frequency
class ThrottledValueNotifier<T> extends ValueNotifier<T> {
  ThrottledValueNotifier({
    required T initialValue,
    required this.throttleTime,
  }) : super(initialValue);

  final Duration throttleTime;
  DateTime? _lastUpdate;
  T? _pendingValue;
  Timer? _throttleTimer;

  @override
  set value(T newValue) {
    final now = DateTime.now();
    _pendingValue = newValue;
    
    if (_lastUpdate == null || 
        now.difference(_lastUpdate!).compareTo(throttleTime) >= 0) {
      // Update immediately
      _updateValue(newValue);
    } else {
      // Schedule throttled update
      _throttleTimer?.cancel();
      final remainingTime = throttleTime - now.difference(_lastUpdate!);
      _throttleTimer = Timer(remainingTime, () {
        if (_pendingValue != null) {
          _updateValue(_pendingValue as T);
        }
      });
    }
  }

  void _updateValue(T newValue) {
    super.value = newValue;
    _lastUpdate = DateTime.now();
    _pendingValue = null;
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }
}