import 'package:flutter/material.dart';
import 'dashboard_builder.dart';

void main() {
  runApp(const DashboardBuilderApp());
}

class DashboardBuilderApp extends StatelessWidget {
  const DashboardBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DashboardBuilder(),
      debugShowCheckedModeBanner: false,
    );
  }
}