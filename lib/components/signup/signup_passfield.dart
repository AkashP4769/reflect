import 'package:flutter/material.dart';
import 'package:reflect/constants/colors.dart';

class SignUpPassField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  const SignUpPassField({super.key, required this.text, required this.controller});

  @override
  State<SignUpPassField> createState() => _SignUpPassFieldState();
}

class _SignUpPassFieldState extends State<SignUpPassField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: widget.controller,
        obscureText: obscure,
        style: TextStyle(color: grey, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelStyle: TextStyle(color: grey, fontSize: 15, fontFamily: "Poppins", fontWeight: FontWeight.w400),
          labelText: widget.text,
          
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: grey,),
            onPressed: () {
              setState(() {
                obscure = !obscure;
              });
            },
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: grey
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