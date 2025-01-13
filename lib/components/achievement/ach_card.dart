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
          Icon(achievement.icon, color: achieved ? achievement.color : Colors.grey,),
          SizedBox(height: 10,),
          Text(achievement.title, style: TextStyle(color: themeData.colorScheme.onPrimary, fontWeight: FontWeight.w500),),
          Text(achievement.description, style: TextStyle(color: themeData.colorScheme.onPrimary.withOpacity(0.8), fontWeight: FontWeight.w500),),
        ],
      ),
    );
  }
}