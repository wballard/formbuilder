import 'package:flutter/material.dart';
import 'form_designer.dart';

void main() {
  runApp(const FormDesignerApp());
}

class FormDesignerApp extends StatelessWidget {
  const FormDesignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Designer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const FormDesigner(),
      debugShowCheckedModeBanner: false,
    );
  }
}