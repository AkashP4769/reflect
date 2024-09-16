import 'package:flutter/material.dart';

class ImageStack extends StatelessWidget {
  final double? width;
  final double? height;
  const ImageStack({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: height ?? 320,
      width: width ?? 320,
      decoration: BoxDecoration(
        color: const Color(0xffEAEAEA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3)
          )
        ],
      ),
    );
  }
}