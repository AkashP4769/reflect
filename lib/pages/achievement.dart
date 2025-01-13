import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reflect/components/achievement/ach_card.dart';
import 'package:reflect/main.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:reflect/models/achievement.dart';

class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<AchievementPage> {
  List<Achievement> achievements = [
    Achievement(title: "First Impressions", description: "Create your very first journal entry", icon: Icons.star, color: Colors.yellowAccent),
    Achievement(title: "Epic Chronicler", description: "Write 100,000 words in total.", icon: Icons.history_edu, color: Colors.white),
  ];


  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Achievements", style: themeData.textTheme.titleLarge,),
          SizedBox(height: 20,),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemBuilder: (BuildContext context, int index){
              return AchievementCard(achievement: achievements[index], achieved: true, themeData: themeData);
            }
          )
        ],
      ),
    );
  }}