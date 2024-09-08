import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/signup/bg_splash.dart';
import 'package:reflect/pages/auth.dart';
import 'package:reflect/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const AuthPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
