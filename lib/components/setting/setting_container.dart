import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflect/main.dart';

class SettingContainer extends StatelessWidget {
  final ThemeData themeData;
  final Widget child;
  const SettingContainer({super.key, required this.child, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: themeData.colorScheme.surface,
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
      child: child
    );
  }
}