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
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: themeData.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: achieved ? achievement.color : Colors.black.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(achievement.title, style: themeData.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center,),
              Text(achievement.description, style: themeData.textTheme.bodyMedium!.copyWith(color: themeData.colorScheme.onPrimary.withOpacity(0.6), fontWeight: FontWeight.w500, fontSize: 12), textAlign: TextAlign.center,),
            ],
          ),
          Icon(achievement.icon, color: achieved ? achievement.color : Colors.grey, size: 32,),
          
        ],
      ),
    );
  }
}