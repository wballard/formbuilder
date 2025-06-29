import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

class NameField extends StatelessWidget {
  final WidgetPlacement placement;

  const NameField({super.key, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  final WidgetPlacement placement;

  const EmailField({super.key, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Email Address',
          hintText: 'Enter your email',
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}

class MessageField extends StatelessWidget {
  final WidgetPlacement placement;

  const MessageField({super.key, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Message',
          hintText: 'Enter your message',
          alignLabelWithHint: true,
          prefixIcon: Icon(Icons.message),
          border: OutlineInputBorder(),
        ),
        maxLines: 4,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a message';
          }
          return null;
        },
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final WidgetPlacement placement;

  const SubmitButton({super.key, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FilledButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Form submitted!')),
          );
        },
        icon: const Icon(Icons.send),
        label: const Text('Submit'),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final WidgetPlacement placement;

  const CancelButton({super.key, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Form cancelled')),
          );
        },
        icon: const Icon(Icons.cancel),
        label: const Text('Cancel'),
      ),
    );
  }
}

class NewsletterCheckbox extends StatefulWidget {
  final WidgetPlacement placement;

  const NewsletterCheckbox({super.key, required this.placement});

  @override
  State<NewsletterCheckbox> createState() => _NewsletterCheckboxState();
}

class _NewsletterCheckboxState extends State<NewsletterCheckbox> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CheckboxListTile(
        value: _checked,
        onChanged: (value) {
          setState(() {
            _checked = value ?? false;
          });
        },
        title: const Text('Subscribe to newsletter'),
        subtitle: const Text('Get updates about new features'),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}

class TermsCheckbox extends StatefulWidget {
  final WidgetPlacement placement;

  const TermsCheckbox({super.key, required this.placement});

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CheckboxListTile(
        value: _checked,
        onChanged: (value) {
          setState(() {
            _checked = value ?? false;
          });
        },
        title: const Text('I agree to the terms and conditions'),
        subtitle: Text(
          'You must agree to continue',
          style: TextStyle(
            color: _checked ? null : Theme.of(context).colorScheme.error,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}