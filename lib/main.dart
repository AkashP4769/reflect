import 'package:flutter/material.dart';
import 'package:reflect/components/signup/bg_splash.dart';
import 'package:reflect/pages/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
