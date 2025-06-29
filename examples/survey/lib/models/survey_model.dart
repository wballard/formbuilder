class SurveyModel {
  String title;
  List<SurveyPage> pages;
  bool allowAnonymous;
  bool allowSkip;

  SurveyModel({
    required this.title,
    required this.pages,
    this.allowAnonymous = true,
    this.allowSkip = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'pages': pages.map((p) => p.toJson()).toList(),
    'allowAnonymous': allowAnonymous,
    'allowSkip': allowSkip,
  };
}

class SurveyPage {
  String title;
  List<Question> questions;

  SurveyPage({
    required this.title,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'questions': questions.map((q) => q.toJson()).toList(),
  };
}

abstract class Question {
  String id;
  String text;
  bool required;

  Question({
    required this.id,
    required this.text,
    this.required = true,
  });

  Map<String, dynamic> toJson();
}

class SingleChoiceQuestion extends Question {
  List<String> options;

  SingleChoiceQuestion({
    required super.id,
    required super.text,
    required this.options,
    super.required,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'single_choice',
    'text': text,
    'options': options,
    'required': required,
  };
}

class MultipleChoiceQuestion extends Question {
  List<String> options;

  MultipleChoiceQuestion({
    required super.id,
    required super.text,
    required this.options,
    super.required,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'multiple_choice',
    'text': text,
    'options': options,
    'required': required,
  };
}

class RatingQuestion extends Question {
  int minRating;
  int maxRating;
  String? minLabel;
  String? maxLabel;

  RatingQuestion({
    required super.id,
    required super.text,
    this.minRating = 1,
    this.maxRating = 5,
    this.minLabel,
    this.maxLabel,
    super.required,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'rating',
    'text': text,
    'minRating': minRating,
    'maxRating': maxRating,
    'minLabel': minLabel,
    'maxLabel': maxLabel,
    'required': required,
  };
}

class TextQuestion extends Question {
  bool multiline;
  int? maxLength;

  TextQuestion({
    required super.id,
    required super.text,
    this.multiline = false,
    this.maxLength,
    super.required,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'text',
    'text': text,
    'multiline': multiline,
    'maxLength': maxLength,
    'required': required,
  };
}