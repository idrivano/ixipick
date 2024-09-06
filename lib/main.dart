import 'package:flutter/material.dart';

import 'splash.dart';
import 'widgets/styles/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ixi Pick',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
