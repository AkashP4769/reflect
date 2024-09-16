import 'package:flutter/material.dart';

class ImageStack extends StatelessWidget {
  final double? width;
  final double? height;
  final Offset? offset;
  final double? rotation;
  final double? padding;
  final Widget? child;
  const ImageStack({super.key, this.width, this.height, this.offset, this.rotation, this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset ?? const Offset(0, 0),
      child: Transform(
        transform: Matrix4.identity()..rotateZ((rotation ?? 0) * 3.1415927 / 180),
        alignment: FractionalOffset.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding ?? 20, vertical: padding ?? 0),
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
          child: child,
        )
      )
    );
  }
}