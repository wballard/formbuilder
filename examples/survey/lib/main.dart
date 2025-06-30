import 'package:flutter/material.dart';
import 'survey_builder.dart';

void main() {
  runApp(const SurveyBuilderApp());
}

class SurveyBuilderApp extends StatelessWidget {
  const SurveyBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survey Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SurveyBuilder(),
      debugShowCheckedModeBanner: false,
    );
  }
}