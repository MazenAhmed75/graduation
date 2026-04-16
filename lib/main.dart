import 'package:flutter/material.dart';
import 'theme.dart';
import 'main_screen.dart';

void main() {
  runApp(const MindfulCuratorApp());
}

class MindfulCuratorApp extends StatelessWidget {
  const MindfulCuratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindful Curator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}
