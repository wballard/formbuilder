import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'question_types/question_widgets.dart';

CategorizedToolbox createSurveyToolbox() {
  return CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Choice Questions',
        items: [
          ToolboxItem(
            name: 'single_choice',
            displayName: 'Single Choice',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.radio_button_checked, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Single', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => SingleChoiceWidget(placement: placement),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'multiple_choice',
            displayName: 'Multiple Choice',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_box, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Multiple', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => MultipleChoiceWidget(placement: placement),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'yes_no',
            displayName: 'Yes/No Question',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumbs_up_down, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Yes/No', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => YesNoWidget(placement: placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Rating Questions',
        items: [
          ToolboxItem(
            name: 'rating_5',
            displayName: '5-Star Rating',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('5 Stars', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => RatingWidget(placement: placement, maxRating: 5),
            defaultWidth: 3,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'rating_10',
            displayName: '10-Point Scale',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.linear_scale, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('1-10', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => RatingWidget(placement: placement, maxRating: 10),
            defaultWidth: 4,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Text Questions',
        items: [
          ToolboxItem(
            name: 'short_text',
            displayName: 'Short Text',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.short_text, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Short', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => ShortTextWidget(placement: placement),
            defaultWidth: 3,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'long_text',
            displayName: 'Long Text',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notes, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Long', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => LongTextWidget(placement: placement),
            defaultWidth: 4,
            defaultHeight: 2,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Special',
        items: [
          ToolboxItem(
            name: 'date_picker',
            displayName: 'Date Picker',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Date', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => DatePickerWidget(placement: placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'page_break',
            displayName: 'Page Break',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insert_page_break, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Break', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => PageBreakWidget(placement: placement),
            defaultWidth: 4,
            defaultHeight: 1,
          ),
        ],
      ),
    ],
  );
}