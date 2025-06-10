import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiGün',
      theme: AppTheme.darkTheme,
      home: LoginScreen(),
    );
  }
}
