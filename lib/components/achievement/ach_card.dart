import 'package:flutter/material.dart';
import 'package:reflect/models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool achieved;
  final ThemeData themeData;
  const AchievementCard({super.key, required this.achievement, required this.achieved, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: themeData.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
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
          Expanded(child: Icon(achievement.icon, color: achieved ? achievement.color : Colors.grey, size: 58,)),
          SizedBox(height: 10,),
          Text(achievement.title, style: themeData.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center,),
          SizedBox(height: 5,),
          Text(achievement.description, style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary.withOpacity(0.6), fontWeight: FontWeight.w500, fontSize: 12), textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}