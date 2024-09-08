import 'package:flutter/material.dart';

class AnimatedReflect extends StatelessWidget {
  //final double value;
  const AnimatedReflect({
    super.key, //required this.value
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(child: Text("Reflect", style: TextStyle(color: Colors.black, fontSize: 56/* - 8*value*/, fontFamily: "Poppins", fontWeight: FontWeight.w600, height: 1),)),
        Container(
          child: Transform.flip(
            flipY: true,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                Color.fromARGB(94, 17, 17, 17),
                Color.fromARGB(0, 0, 0, 0),
              ]).createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Text("Reflect", style: TextStyle(fontSize: 56 /*- 8*value*/, fontFamily: "Poppins", fontWeight: FontWeight.w600, height: 1),),
            ),
          ),
        )
      ],
    );
  }
}