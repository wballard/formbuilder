import 'package:flutter/material.dart';
import 'basic_form_builder.dart';

void main() {
  runApp(const BasicFormBuilderApp());
}

class BasicFormBuilderApp extends StatelessWidget {
  const BasicFormBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Form Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const BasicFormBuilder(),
      debugShowCheckedModeBanner: false,
    );
  }
}