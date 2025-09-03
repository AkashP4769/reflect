import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reflect/components/common/animated_reflect.dart';
import 'package:reflect/components/common/reflect.dart';
import 'package:reflect/components/signup/login_card.dart';
import 'package:reflect/components/signup/signup_card.dart';
import 'package:reflect/constants/colors.dart';
import 'package:reflect/components/signup/bg_splash.dart';
import 'package:reflect/constants/curves.dart';
import 'package:reflect/services/auth_service.dart';
import 'package:reflect/theme/theme_manager.dart';

class LoginPage extends StatefulWidget {
  final void Function(Color)? signInwWithGoogle;
  final void Function(Color)? signInWithApple;
  final void Function(String, String, Color)? signInWithEmailAndPass;
  final void Function(String name, String email, String password, String confirmPassword, Color)? signUpWithEmailAndPass;

  final String? loginErrorMsg;
  final String? signupErrorMsg;
  const LoginPage({super.key, this.signInwWithGoogle, this.signInWithApple, this.signInWithEmailAndPass, this.signUpWithEmailAndPass, this.loginErrorMsg, this.signupErrorMsg});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late PageController? _pageController;
  double progress = 0;
  bool visible = true;
  bool splashPlayed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController()..addListener((){
      setState(() {
        progress = _pageController!.page!;
      });
    });
  }


  void dispose(){
    _pageController!.dispose();
    super.dispose();
  }

  void togglePage(){
    setState(() {
      if(_pageController!.page == 0){
        _pageController!.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
      }else {
        _pageController!.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
      }
    });
  }

  void toggleVisible(){
    setState(() {
      visible = !visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        /*child: Text("Bruhhhh"),*/
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Bg_Splash(),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: visible ? 1 : 0, end: visible ? 0 : 1),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInExpo,
                      builder: (BuildContext context, double value, Widget? child){
                        return Column( //wrap with scroll
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /*ElevatedButton(onPressed: (){
                                  setState(() {
                                    splashPlayed = false;
                                  });
                                }, child: Text("start")
                            ),*/
                            if(splashPlayed) GestureDetector(
                              onTap: toggleVisible,
                              child: Reflect(value: value,)
                            ),

                            GestureDetector(
                              onVerticalDragEnd: (details){
                                print(details.primaryVelocity);
                                if(details.primaryVelocity!.abs() > 50){
                                  toggleVisible();
                                }
                              },
                              child: Container(
                                height: height * ((-0.4) * value + 0.5), 
                                child: (value != 1) ? Opacity(
                                  opacity: 1 - value,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 100),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.8),
                                          Colors.black.withOpacity(0.4),
                                          Colors.black.withOpacity(0.2),
                                          Colors.transparent
                                        ],
                                      )
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("A journal for your thoughts", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600),),
                                          Text("A reflection for your soul.", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ) : const Placeholder(color: Colors.transparent,)
                              )
                            ),
                            //swipe = 0  -> height = height * 0.5
                            //swipe = 1 -> height = height * 0.1
                            GestureDetector(
                              onVerticalDragEnd: (details){
                                print(details.primaryVelocity);
                                if(details.primaryVelocity! > 50){
                                  toggleVisible();
                                }
                              },
    
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: (480 + progress * 120) * value,
                                //duration: Duration(milliseconds: 400),
                                child: PageView(
                                  controller: _pageController,
                                  children: [
                                    LoginCard(togglePage: togglePage, signInWithEmailAndPass: widget.signInWithEmailAndPass!, signInWithApple: widget.signInWithApple!, signInwWithGoogle: widget.signInwWithGoogle!, errorMsg: widget.loginErrorMsg!,),
                                    SignUpCard(togglePage: togglePage, signUpWithEmailAndPass: widget.signUpWithEmailAndPass!, signInWithApple: widget.signInWithApple!, signInWithGoogle: widget.signInwWithGoogle!, errorMsg: widget.signupErrorMsg!, ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      }
                      
                ),
              ),
            ),
            if(!splashPlayed) TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 3000),
              curve: Curves.easeInOutQuint,
              builder: (BuildContext context, double _value, Widget? child){
                if(_value == 1){WidgetsBinding.instance.addPostFrameCallback((_){
                  setState((){
                    splashPlayed = true;
                  });
                });}
                final int color = (255 * _value).round();
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 1 - _value,
                          child: Container(
                            height: height,
                            color: Colors.white,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedReflect(value: _value, color: color,),
                            SizedBox(height: height/2,)
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}



