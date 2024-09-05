import 'package:flutter/material.dart';
import 'package:reflect/components/common/reflect.dart';
import 'package:reflect/components/signup/signup_card.dart';
import 'package:reflect/constants/colors.dart';
import 'package:reflect/pages/bg_splash.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Bg_Splash(),
            Positioned(
              top: 120,
              child: const Reflect()
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SignUpCard(),
            )
          ],
        ),
      ),
    );
  }
}



