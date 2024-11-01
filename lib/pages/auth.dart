

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/common/loading.dart';
import 'package:reflect/pages/login.dart';
import 'package:reflect/pages/navigation.dart';
import 'package:reflect/services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String loginErrorMsg = '';
  String signupErrorMsg = '';


  void signInWithGoogle() async {
    showLoading(context, const Color(0xffFFAC5F));
    String msg = await AuthService.signInWithGoogle();
    if(msg != '') setState(() => loginErrorMsg = msg);
    Navigator.pop(context);
  }

  void signInWithApple() async {
    String msg = "Apple Sign In is not available yet!";
    if(msg != '') setState(() => loginErrorMsg = msg);
  }

  void signInWithEmailAndPass(String email, String password) async {
    showLoading(context, const Color(0xffFFAC5F));
    String msg = await AuthService.signInWithEmailPassword(email, password);
    if(msg != '') setState(() => loginErrorMsg = msg);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData) {
            return const NavigationPage();
            }
          else {
            return LoginPage(signInwWithGoogle: signInWithGoogle, signInWithApple: signInWithApple, signInWithEmailAndPass: signInWithEmailAndPass, loginErrorMsg: loginErrorMsg, signupErrorMsg: signupErrorMsg);
          }
        },
      ),
    );
  }
}