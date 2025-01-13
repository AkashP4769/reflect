

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reflect/components/common/loading.dart';
import 'package:reflect/models/user_setting.dart';
import 'package:reflect/pages/login.dart';
import 'package:reflect/pages/navigation.dart';
import 'package:reflect/pages/waiting.dart';
import 'package:reflect/services/auth_service.dart';
import 'package:reflect/services/encryption_service.dart';
import 'package:reflect/services/user_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool authPermission;
  String loginErrorMsg = '';
  String signupErrorMsg = '';
  late bool backendVerified = false;
  Box settingBox = Hive.box('settings');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAuthPermission();
  }

  void saveAuthPermission(bool authP) async {
    settingBox.put('authPermission', authP);
  }

  void loadAuthPermission() async {
    authPermission = settingBox.get('authPermission', defaultValue: false);
    final UserSetting userSetting = await UserService().getUserSettingFromCache();
    bool flag = true;

    if(userSetting.encryptionMode == 'encrypted'){
      if(await EncryptionService().getSymmetricKey() == null) flag = false;
    }

    backendVerified = (FirebaseAuth.instance.currentUser == null ? false : true) && flag;
    setState(() {});
  }


  void signInWithGoogle(Color loadingColor) async {
    showLoading(context, loadingColor);
    authPermission = true;
    backendVerified = false;
    loginErrorMsg = '';
    final authResponse = await AuthService.signInWithGoogle();
    if(authResponse['encryptionMode'] == 'encrypted'){
      final encryptionService = EncryptionService();
      final symKey = await encryptionService.getSymmetricKey();

      if(symKey == null) authPermission = false;
      else if(encryptionService.decryptData(authResponse['keyValidator'], symKey) != '11111') authPermission = false;
    }

    /*if([0, 1, 2, 4].contains(authResponse['code']) || authResponse['encryptionMode'] != 'encrypted'){
      authPermission = true;
      saveAuthPermission(true);
    }*/

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