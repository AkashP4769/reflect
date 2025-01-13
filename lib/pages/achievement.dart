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
    Achievement(title: "First Impressions", description: "Create your very first journal entry", icon: Icons.star, color: Colors.orangeAccent),
    Achievement(title: "Epic Chronicler", description: "Write 100,000 words in total.", icon: Icons.history_edu, color: Colors.yellow),
    //Achievement(title: "Master Chronicler", description: "Write 500,000 words in total.", icon: Icons.history_edu, color: Colors.white),
    Achievement(title: "New Journey", description: "Create your first chapter", icon: Icons.auto_stories, color: Colors.teal),
    Achievement(title: "Saga Creator", description: "Create 10 chapters", icon: Icons.history_edu, color: Colors.tealAccent),

    Achievement(title: "Taggy", description: "Create 10 tags", icon: Icons.sell, color: Colors.lightBlue),
    Achievement(title: "Tag Master", description: "Create 50 tags", icon: Icons.style, color: Colors.cyan),

    Achievement(title: "Favorites Fanatic", description: "Favorite 25 of your own entries", icon: Icons.favorite_outline, color: Colors.pink),
    Achievement(title: "Favorites Master", description: "Favorite 50 of your own entries", icon: Icons.favorite_rounded, color: Colors.pinkAccent),

    Achievement(title: "The Collector", description: "Create 100 entries", icon: Icons.task, color: Colors.green),
    Achievement(title: "The Chronicler", description: "Create 500 entries", icon: Icons.receipt_long, color: Colors.greenAccent),

    //Upload your first image achievement
    Achievement(title: "Picture Perfect", description: "Upload your first image", icon: Icons.photo_camera, color: Colors.blueAccent),
    Achievement(title: "Photographer", description: "Upload 10 images", icon: Icons.photo_album, color: Colors.blueAccent),

    Achievement(title: "Short and sweet", description: "Write an entry with fewer than 50 words.", icon: Icons.fiber_manual_record, color: Colors.purpleAccent),
    Achievement(title: "Long-winded", description: "Write an entry with more than 1000 words.", icon: Icons.circle, color: Colors.purpleAccent),

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Achievements", style: themeData.textTheme.titleLarge,),
            SizedBox(height: 20,),
            /*GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 16),
              itemBuilder: (BuildContext context, int index){
                return AchievementCard(achievement: achievements[index], achieved: true, themeData: themeData);
              }
            )*/
            ListView.builder(
              shrinkWrap: true,
              clipBehavior: Clip.none,

              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              itemBuilder: (BuildContext context, int index){
                return AchievementCard(achievement: achievements[index], achieved: true, themeData: themeData);
              }
            )
          ],
        ),
      ),
    );
  }}