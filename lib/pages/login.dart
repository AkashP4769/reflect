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
  double progress = 0;
  bool visible = false;

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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
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
                                height: height * ((-0.4) * value + 0.47), 
                                child: (value != 1) ? Opacity(
                                  opacity: 1 - value,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 100),
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
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("A journal for your thoughts", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600),),
                                          Text("A reflection for your soul.", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ) : Placeholder(color: Colors.transparent,)
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
                                    LoginCard(togglePage: togglePage,),
                                    SignUpCard(togglePage: togglePage,),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      }
                      
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



