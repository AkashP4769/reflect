

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/common/loading.dart';
import 'package:reflect/pages/login.dart';
import 'package:reflect/pages/navigation.dart';
import 'package:reflect/pages/waiting.dart';
import 'package:reflect/services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String loginErrorMsg = '';
  String signupErrorMsg = '';
  bool authPermission = FirebaseAuth.instance.currentUser == null ? false : true;
  bool backendVerified = FirebaseAuth.instance.currentUser == null ? false : true;


  void signInWithGoogle(Color loadingColor) async {
    showLoading(context, loadingColor);
    authPermission = false;
    backendVerified = false;
    loginErrorMsg = '';
    final authResponse = await AuthService.signInWithGoogle();
    if(authResponse['code'] == 1) authPermission = true;

    print("authPermission changed: $authPermission");
    backendVerified = true;
    setState(() {});
    Navigator.pop(context);
  }

  void signInWithApple(Color loadingColor) async {
    String msg = "Apple Sign In is not available yet!";
    if(msg != '') setState(() => loginErrorMsg = msg);
  }

  void signInWithEmailAndPass(String email, String password, Color loadingColor) async {
    showLoading(context, loadingColor);
    String msg = await AuthService.signInWithEmailPassword(email, password);
    if(msg != '') setState(() => loginErrorMsg = msg);
    Navigator.pop(context);
  }

  void signUpWithEmailAndPass(String name, String email, String password, String confirmPassword, Color loadingColor) async {
    if(password != confirmPassword){
      setState(() => signupErrorMsg = "Passwords do not match!");
      return;
    }
    showLoading(context, loadingColor);
    String msg = await AuthService.createUserWithEmailAndPassword(name, email, password);
    if(msg != '') setState(() => signupErrorMsg = msg);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData && backendVerified) {
             if(authPermission) return NavigationPage();
             else return WaitingPage();
            }
          else {
            return LoginPage(signInwWithGoogle: signInWithGoogle, signInWithApple: signInWithApple, signInWithEmailAndPass: signInWithEmailAndPass, signUpWithEmailAndPass: signUpWithEmailAndPass , loginErrorMsg: loginErrorMsg, signupErrorMsg: signupErrorMsg);
          }
        },
      ),
    );
  }
}