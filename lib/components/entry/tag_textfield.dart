import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TagTextField extends StatelessWidget {
  final ThemeData themeData;
  TagTextField({super.key, required this.themeData});
  final String selectedColor = '0xFF452659';
  final List<String> availableColors = [
    '0xFF452659',
    '0xFF595635',
    '0xFF556889',
    '0xFF454569',
    '0xFF262635',
    '0xFF452365',
    '0xFF565632',
    '0xFF785623',
    '0xFFA45563',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Color(int.parse(selectedColor)),
          width: 2.0,
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
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add a tag',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          PopupMenuButton<String>(
            color: themeData.colorScheme.secondary,
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: Color(int.parse(selectedColor)),
            ),
            onSelected: (String value) {
              print(value);
            },
            popUpAnimationStyle: AnimationStyle(
              curve: Curves.easeInOut,
              reverseCurve: Curves.easeInOut,
            ),
            itemBuilder: (BuildContext context) {
              return availableColors.map((String color) {
                return PopupMenuItem<String>(
                  value: color,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Color(int.parse(color)),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }
}