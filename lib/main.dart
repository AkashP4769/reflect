import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/signup/bg_splash.dart';
import 'package:reflect/pages/auth.dart';
import 'package:reflect/pages/login.dart';
import 'package:reflect/theme/theme_constants.dart';
import 'package:reflect/theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeManager themeManager = ThemeManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    themeManager.addListener(themeListener);
  }
  
  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  themeListener(){
    if(mounted)setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      routes: {
        '/': (context) => const AuthPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
