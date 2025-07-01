import 'package:flutter/material.dart';
import 'form_layout_example.dart';

void main() {
  runApp(const SimpleExampleApp());
}

class SimpleExampleApp extends StatelessWidget {
  const SimpleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormBuilder Simple Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FormLayoutExample(),
    );
  }
}