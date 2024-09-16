import 'package:flutter/material.dart';
import 'package:reflect/models/chapter.dart';

class ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final ThemeData themeData;
  const ChapterCard({super.key, required this.chapter, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 5),
      decoration: BoxDecoration(
        color: themeData.colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: Column(
        children: [
          Text(chapter.title, style: themeData.textTheme.titleMedium?.copyWith(color: Color(0xffFF9432), fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
          SizedBox(height: 10),
          Text(chapter.description, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
          SizedBox(height: 10),
          Text("No. of entries - ${chapter.entryCount}", style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSecondary,fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}