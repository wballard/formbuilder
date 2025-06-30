import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

class SingleChoiceWidget extends StatefulWidget {
  final WidgetPlacement placement;

  const SingleChoiceWidget({super.key, required this.placement});

  @override
  State<SingleChoiceWidget> createState() => _SingleChoiceWidgetState();
}

class _SingleChoiceWidgetState extends State<SingleChoiceWidget> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How satisfied are you with our service?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('Very Satisfied'),
            value: 'very_satisfied',
            groupValue: _selectedValue,
            onChanged: (value) => setState(() => _selectedValue = value),
            dense: true,
          ),
          RadioListTile<String>(
            title: const Text('Satisfied'),
            value: 'satisfied',
            groupValue: _selectedValue,
            onChanged: (value) => setState(() => _selectedValue = value),
            dense: true,
          ),
          RadioListTile<String>(
            title: const Text('Neutral'),
            value: 'neutral',
            groupValue: _selectedValue,
            onChanged: (value) => setState(() => _selectedValue = value),
            dense: true,
          ),
        ],
      ),
    );
  }
}

class MultipleChoiceWidget extends StatefulWidget {
  final WidgetPlacement placement;

  const MultipleChoiceWidget({super.key, required this.placement});

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  final Set<String> _selectedValues = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which features do you use? (Select all that apply)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Form Builder'),
            value: _selectedValues.contains('form_builder'),
            onChanged: (value) => setState(() {
              if (value == true) {
                _selectedValues.add('form_builder');
              } else {
                _selectedValues.remove('form_builder');
              }
            }),
            dense: true,
          ),
          CheckboxListTile(
            title: const Text('Drag & Drop'),
            value: _selectedValues.contains('drag_drop'),
            onChanged: (value) => setState(() {
              if (value == true) {
                _selectedValues.add('drag_drop');
              } else {
                _selectedValues.remove('drag_drop');
              }
            }),
            dense: true,
          ),
          CheckboxListTile(
            title: const Text('Templates'),
            value: _selectedValues.contains('templates'),
            onChanged: (value) => setState(() {
              if (value == true) {
                _selectedValues.add('templates');
              } else {
                _selectedValues.remove('templates');
              }
            }),
            dense: true,
          ),
        ],
      ),
    );
  }
}

class YesNoWidget extends StatefulWidget {
  final WidgetPlacement placement;

  const YesNoWidget({super.key, required this.placement});

  @override
  State<YesNoWidget> createState() => _YesNoWidgetState();
}

class _YesNoWidgetState extends State<YesNoWidget> {
  bool? _value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Would you recommend us to others?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Yes')),
              ButtonSegment(value: false, label: Text('No')),
            ],
            selected: _value != null ? {_value!} : {},
            onSelectionChanged: (values) {
              setState(() {
                _value = values.first;
              });
            },
          ),
        ],
      ),
    );
  }
}

class RatingWidget extends StatefulWidget {
  final WidgetPlacement placement;
  final int maxRating;

  const RatingWidget({
    super.key,
    required this.placement,
    this.maxRating = 5,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int? _rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate your overall experience',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.maxRating, (index) {
              final value = index + 1;
              return IconButton(
                icon: Icon(
                  _rating != null && _rating! >= value
                      ? Icons.star
                      : Icons.star_border,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => setState(() => _rating = value),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ShortTextWidget extends StatelessWidget {
  final WidgetPlacement placement;

  const ShortTextWidget({super.key, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Your name',
          hintText: 'Enter your name',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class LongTextWidget extends StatelessWidget {
  final WidgetPlacement placement;

  const LongTextWidget({super.key, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Additional comments',
          hintText: 'Please share any additional feedback',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
        maxLines: 4,
      ),
    );
  }
}

class DatePickerWidget extends StatefulWidget {
  final WidgetPlacement placement;

  const DatePickerWidget({super.key, required this.placement});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of visit',
          hintText: 'Select date',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        controller: TextEditingController(
          text: _selectedDate != null
              ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
              : '',
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (date != null) {
            setState(() => _selectedDate = date);
          }
        },
      ),
    );
  }
}

class PageBreakWidget extends StatelessWidget {
  final WidgetPlacement placement;

  const PageBreakWidget({super.key, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insert_page_break, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Page Break',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Divider(thickness: 2)),
        ],
      ),
    );
  }
}