import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// A URL input field with validation
class UrlFormField extends StatelessWidget {
  final WidgetPlacement placement;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool required;

  const UrlFormField({
    super.key,
    required this.placement,
    this.initialValue,
    this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: 'Website URL${required ? ' *' : ''}',
          hintText: 'https://example.com',
          prefixIcon: const Icon(Icons.link),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.url,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'URL is required';
          }
          if (value != null && value.isNotEmpty) {
            final urlRegex = RegExp(
              r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)'
            );
            if (!urlRegex.hasMatch(value)) {
              return 'Please enter a valid URL';
            }
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}

/// A credit card number field with formatting and validation
class CreditCardFormField extends StatelessWidget {
  final WidgetPlacement placement;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool required;

  const CreditCardFormField({
    super.key,
    required this.placement,
    this.initialValue,
    this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: 'Credit Card Number${required ? ' *' : ''}',
          hintText: '1234 5678 9012 3456',
          prefixIcon: const Icon(Icons.credit_card),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _CreditCardFormatter(),
        ],
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Credit card number is required';
          }
          if (value != null && value.isNotEmpty) {
            final digitsOnly = value.replaceAll(' ', '');
            if (digitsOnly.length < 13 || digitsOnly.length > 19) {
              return 'Please enter a valid credit card number';
            }
            if (!_isValidLuhn(digitsOnly)) {
              return 'Invalid credit card number';
            }
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  bool _isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
}

/// A date range picker field
class DateRangeFormField extends StatefulWidget {
  final WidgetPlacement placement;
  final DateTimeRange? initialValue;
  final ValueChanged<DateTimeRange>? onChanged;
  final bool required;

  const DateRangeFormField({
    super.key,
    required this.placement,
    this.initialValue,
    this.onChanged,
    this.required = false,
  });

  @override
  State<DateRangeFormField> createState() => _DateRangeFormFieldState();
}

class _DateRangeFormFieldState extends State<DateRangeFormField> {
  DateTimeRange? _dateRange;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateRange = widget.initialValue;
    _updateController();
  }

  void _updateController() {
    if (_dateRange != null) {
      final start = '${_dateRange!.start.month}/${_dateRange!.start.day}/${_dateRange!.start.year}';
      final end = '${_dateRange!.end.month}/${_dateRange!.end.day}/${_dateRange!.end.year}';
      _controller.text = '$start - $end';
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date Range${widget.required ? ' *' : ''}',
          hintText: 'Select date range',
          prefixIcon: const Icon(Icons.date_range),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: _dateRange,
              );
              
              if (range != null) {
                setState(() {
                  _dateRange = range;
                  _updateController();
                });
                widget.onChanged?.call(range);
              }
            },
          ),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (widget.required && _dateRange == null) {
            return 'Date range is required';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A time picker field
class TimeFormField extends StatefulWidget {
  final WidgetPlacement placement;
  final TimeOfDay? initialValue;
  final ValueChanged<TimeOfDay>? onChanged;
  final bool required;

  const TimeFormField({
    super.key,
    required this.placement,
    this.initialValue,
    this.onChanged,
    this.required = false,
  });

  @override
  State<TimeFormField> createState() => _TimeFormFieldState();
}

class _TimeFormFieldState extends State<TimeFormField> {
  TimeOfDay? _time;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _time = widget.initialValue;
    _updateController();
  }

  void _updateController() {
    if (_time != null) {
      final hour = _time!.hourOfPeriod == 0 ? 12 : _time!.hourOfPeriod;
      final minute = _time!.minute.toString().padLeft(2, '0');
      final period = _time!.period == DayPeriod.am ? 'AM' : 'PM';
      _controller.text = '$hour:$minute $period';
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Time${widget.required ? ' *' : ''}',
          hintText: 'Select time',
          prefixIcon: const Icon(Icons.access_time),
          border: const OutlineInputBorder(),
        ),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _time ?? TimeOfDay.now(),
          );
          
          if (time != null) {
            setState(() {
              _time = time;
              _updateController();
            });
            widget.onChanged?.call(time);
          }
        },
        validator: (value) {
          if (widget.required && _time == null) {
            return 'Time is required';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A percentage input field
class PercentageFormField extends StatelessWidget {
  final WidgetPlacement placement;
  final double? initialValue;
  final ValueChanged<double>? onChanged;
  final bool required;
  final double min;
  final double max;

  const PercentageFormField({
    super.key,
    required this.placement,
    this.initialValue,
    this.onChanged,
    this.required = false,
    this.min = 0,
    this.max = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        initialValue: initialValue?.toStringAsFixed(1),
        decoration: InputDecoration(
          labelText: 'Percentage${required ? ' *' : ''}',
          suffixText: '%',
          prefixIcon: const Icon(Icons.percent),
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
        ],
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Percentage is required';
          }
          if (value != null && value.isNotEmpty) {
            final percentage = double.tryParse(value);
            if (percentage == null) {
              return 'Please enter a valid number';
            }
            if (percentage < min || percentage > max) {
              return 'Must be between $min% and $max%';
            }
          }
          return null;
        },
        onChanged: (value) {
          if (onChanged != null) {
            final percentage = double.tryParse(value);
            if (percentage != null) {
              onChanged!(percentage);
            }
          }
        },
      ),
    );
  }
}

/// Custom credit card formatter
class _CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;
    int newTextIndex = 0;

    for (int i = 0; i < newText.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
        if (newTextIndex < selectionIndex) selectionIndex++;
      }
      buffer.write(newText[i]);
      newTextIndex++;
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}