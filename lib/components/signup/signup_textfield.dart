import 'package:flutter/material.dart';
import 'package:reflect/constants/colors.dart';

class SignUpTextField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  const SignUpTextField({super.key, required this.text, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: grey, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelStyle: TextStyle(color: grey, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w400),
          labelText: text,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white
            ),
            borderRadius: BorderRadius.circular(8)
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white
            )
          )
        ),
      ),
    );
  }
}