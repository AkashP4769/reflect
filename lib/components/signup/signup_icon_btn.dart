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
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: px ?? 15, horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 10,  horizontal: mx ?? 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color.fromARGB(255, 255, 255, 255),
          const Color.fromARGB(255, 222, 222, 222),
        ]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color:  Color.fromARGB(64, 0, 0, 0),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 6), // changes position of shadow
          ),
        ],
      ),
      child: Center(child: SvgPicture.asset(
        'assets/images/$imgSrc.svg',
        width: 25,
        semanticsLabel: 'A red up arrow'
      )),
    );
  }
}