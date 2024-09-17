import 'package:flutter/material.dart';
import 'package:reflect/constants/colors.dart';

class SignUpPassField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final ThemeData themeData;
  const SignUpPassField({super.key, required this.text, required this.controller, required this.themeData});

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
        style: widget.themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          labelStyle: widget.themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: widget.themeData.colorScheme.onPrimary.withOpacity(0.7)),
          labelText: widget.text,
          
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: widget.themeData.colorScheme.onPrimary,),
            onPressed: () {
              setState(() {
                obscure = !obscure;
              });
            },
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.themeData.colorScheme.onPrimary
            ),
            borderRadius: BorderRadius.circular(8)
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.themeData.colorScheme.primary,
            )
          )
        ),
      ),
    );
  }
}