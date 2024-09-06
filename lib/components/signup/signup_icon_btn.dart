import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reflect/constants/colors.dart';

class SignUpIconButton extends StatelessWidget {
  final String imgSrc;
  double? px;
  double? mx;
  SignUpIconButton({super.key, this.px, this.mx, required this.imgSrc});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 0,  horizontal: 20),
      child: Center(child: SvgPicture.asset(
        'assets/images/$imgSrc.svg',
        width: 25,
        semanticsLabel: 'login'
      )),
    );
  }
}