import 'package:flutter/material.dart';

void main() {
  runApp(const FormBuilderApp());
}

class FormBuilderApp extends StatelessWidget {
  const FormBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormBuilder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FormBuilder'),
      ),
      body: const Center(
        child: Text('FormLayout Widget Demo', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
