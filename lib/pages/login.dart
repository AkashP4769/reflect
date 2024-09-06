import 'package:flutter/material.dart';
import 'package:reflect/components/common/reflect.dart';
import 'package:reflect/components/signup/login_card.dart';
import 'package:reflect/components/signup/signup_card.dart';
import 'package:reflect/constants/colors.dart';
import 'package:reflect/components/signup/bg_splash.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late PageController? _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
  }

  void dispose(){
    _pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Bg_Splash(),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Reflect(),
                    const SizedBox(height: 60),
                    PageView(
                      controller: _pageController,
                      children: const [
                        SignUpCard(),
                        LoginCard()
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



