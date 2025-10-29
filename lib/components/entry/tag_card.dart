import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reflect/models/tag.dart';

class TagCard extends StatelessWidget {
  final Tag tag;
  final ThemeData themeData;
  final bool selected;
  final bool deleteBit;
  const TagCard({super.key, required this.tag, required this.themeData, required this.selected, required this.deleteBit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: selected ? Color(tag.color) : deleteBit ? Color.fromARGB(255, 255, 119, 119) : Colors.transparent,
        border: Border.all(
          color: selected ? themeData.colorScheme.secondary : deleteBit ? Color.fromARGB(255, 255, 119, 119) : Color(tag.color),
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
        style: TextStyle(
          color: !selected ? Color(tag.color) : Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }
}