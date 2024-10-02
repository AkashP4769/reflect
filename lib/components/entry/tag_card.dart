import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reflect/models/tag.dart';

class TagCard extends StatelessWidget {
  final Tag tag;
  final ThemeData themeData;
  final bool selected;
  const TagCard({super.key, required this.tag, required this.themeData, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: selected ? Color(int.parse(tag.color)) : Colors.transparent,
        border: Border.all(
          color: selected ?  Colors.transparent : Color(int.parse(tag.color)),
          width: 1.0,
        ),
        boxShadow: const [
           BoxShadow(
              blurRadius: 5.0,
              spreadRadius: 2.0,
              color: Color(0x11000000)
            )
        ],
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Text(
        tag.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
    );
  }
}