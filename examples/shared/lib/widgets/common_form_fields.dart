import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// A validated email field with proper formatting
class EmailFormField extends StatelessWidget {
  final WidgetPlacement placement;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool required;

  const EmailFormField({
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
          labelText: 'Email Address${required ? ' *' : ''}',
          hintText: 'example@email.com',
          prefixIcon: const Icon(Icons.email),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
        ],
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Email is required';
          }
          if (value != null && value.isNotEmpty) {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email address';
            }
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}

/// A phone number field with formatting
class PhoneFormField extends StatelessWidget {
  final WidgetPlacement placement;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool required;

  const PhoneFormField({
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
          labelText: 'Phone Number${required ? ' *' : ''}',
          hintText: '(123) 456-7890',
          prefixIcon: const Icon(Icons.phone),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _PhoneNumberFormatter(),
        ],
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Phone number is required';
          }
          if (value != null && value.isNotEmpty && value.length < 14) {
            return 'Please enter a complete phone number';
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}

/// A currency input field
class CurrencyFormField extends StatelessWidget {
  final WidgetPlacement placement;
  final double? initialValue;
  final ValueChanged<double>? onChanged;
  final bool required;
  final String currency;

  const CurrencyFormField({
    super.key,
    required this.placement,
    this.initialValue,
    this.onChanged,
    this.required = false,
    this.currency = '\$',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        initialValue: initialValue?.toStringAsFixed(2),
        decoration: InputDecoration(
          labelText: 'Amount${required ? ' *' : ''}',
          prefixText: currency,
          prefixIcon: const Icon(Icons.attach_money),
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Amount is required';
          }
          return null;
        },
        onChanged: (value) {
          if (onChanged != null) {
            final amount = double.tryParse(value);
            if (amount != null) {
              onChanged!(amount);
            }
          }
        },
      ),
    );
  }
}

/// A password field with visibility toggle
class PasswordFormField extends StatefulWidget {
  final WidgetPlacement placement;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool required;
  final bool showStrengthIndicator;

  const PasswordFormField({
    super.key,
    required this.placement,
    this.initialValue,
    this.onChanged,
    this.required = false,
    this.showStrengthIndicator = true,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;
  String _password = '';

  @override
  void initState() {
    super.initState();
    _password = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: widget.initialValue,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Password${widget.required ? ' *' : ''}',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (widget.required && (value == null || value.isEmpty)) {
                return 'Password is required';
              }
              if (value != null && value.isNotEmpty && value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _password = value;
              });
              widget.onChanged?.call(value);
            },
          ),
          if (widget.showStrengthIndicator && _password.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _PasswordStrengthIndicator(password: _password),
            ),
        ],
      ),
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final color = _getStrengthColor(strength);
    final label = _getStrengthLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  int _calculateStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak password';
      case 2:
        return 'Fair password';
      case 3:
        return 'Good password';
      case 4:
        return 'Strong password';
      default:
        return '';
    }
  }
}

/// Custom phone number formatter
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;

    if (newText.isNotEmpty) {
      buffer.write('(');
      if (newValue.selection.end >= 1) selectionIndex++;
    }

    for (int i = 0; i < newText.length && i < 10; i++) {
      if (i == 3) {
        buffer.write(') ');
        if (newValue.selection.end > i) selectionIndex += 2;
      } else if (i == 6) {
        buffer.write('-');
        if (newValue.selection.end > i) selectionIndex++;
      }
      buffer.write(newText[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}