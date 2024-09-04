import 'package:flutter/material.dart';
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
          children: [
            //Bg_Splash(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(child: Text("Reflect", style: TextStyle(fontSize: 48, fontFamily: "Poppins", fontWeight: FontWeight.w600, height: 1),)),
                  Container(
                    child: Transform.flip(
                      flipY: true,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                          const Color.fromARGB(93, 0, 0, 0),
                          const Color.fromARGB(0, 0, 0, 0),
                        ]).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Text("Reflect", style: TextStyle(fontSize: 48, fontFamily: "Poppins", fontWeight: FontWeight.w600, height: 1),),
                      ),
                    ),
                  )
                ],
              ),
            
            )
          ],
        ),
      ),
    );
  }
}