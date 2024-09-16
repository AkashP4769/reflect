import 'package:flutter/material.dart';

class Reflect extends StatelessWidget {
  final double value;
  const Reflect({
    super.key, required this.value
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(child: Text("Reflect", style: TextStyle(color: Colors.white, fontSize: 56 - 8*value, fontFamily: "Poppins", fontWeight: FontWeight.w600, height: 1),)),
        Container(
          child: Transform.flip(
            flipY: true,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                Color.fromARGB(94, 255, 255, 255),
                Color.fromARGB(0, 255, 255, 255),
              ]).createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Text("Reflect", style: TextStyle(fontSize: 56 - 8*value, fontFamily: "Poppins", fontWeight: FontWeight.w600, height: 1),),
            ),
          ),
        )
      ],
    );
  }
}